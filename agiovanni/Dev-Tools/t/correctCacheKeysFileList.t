#$Id: correctCacheKeysFileList.t,v 1.1 2015/02/20 22:04:00 csmit Exp $
#-@@@ Giovanni, Version $Name:  $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Giovanni-Cache.t'

#########################

use strict;
use warnings;

use File::Temp qw/ tempdir /;
use Giovanni::Cache;
use Giovanni::Logger;
use File::Basename;
use FindBin qw($Bin);

use Test::More tests => 8;
BEGIN { use_ok('Dev::Tools') }

# Test the functionality to correct cache keys.

# setup a cache somewhere
my $cacheDir   = tempdir();
my $workingDir = tempdir();
my $logger     = Giovanni::Logger->new(
    session_dir       => $workingDir,
    manifest_filename => 'mfst.whatever+blah.xml'
);
my $cacher = Giovanni::Cache->getCacher(
    TYPE      => 'file',
    LOGGER    => $logger,
    CACHE_DIR => $cacheDir
);

# put some stuff in the cache
putInCache( "replace1", "file1", "region_A", "hello world" );
putInCache( "key2",     "file2", "region_A", "hello world" );
putInCache( "replace3", "file3", "region_A", "hello world" );
putInCache( "key3",     "file3", "region_A", "hello world" );
putInCache( "key4",     "file4", "region_A", "hello world" );

# get the cache db file
my $dbFile = "$cacheDir/region_A.db";

# write this to a file
my $dbFileList = "$workingDir/dbFileList.txt";
open( FILE, ">", $dbFileList ) or die "Unable to open file $dbFileList";
print FILE $dbFile . "\n";
close(FILE);

# find the script
my $script = findScript("correctCacheKeys.pl");
if ( !( -e $script ) ) {
    die "Unable to find correctCacheKeys.pl";
}

## CALL THE SCRIPT ##
my $cmd
    = qq($script --dbFileList $dbFileList --regex "replace" --replacement "key");
my $ret = system($cmd);
is( $ret, 0, "Command returned 0: $ret" );

# get stuff out of the cache
my $outHash = $cacher->get(
    DIRECTORY      => $workingDir,
    KEYS           => [ "key1", "key2", "key3", "key4", "replace1" ],
    REGION_LEVEL_1 => "region_A",
);
is( $outHash->{key1}->{FILENAME}, 'file1', "file1" );
is( $outHash->{key2}->{FILENAME}, 'file2', "file2" );
is( $outHash->{key3}->{FILENAME}, 'file3', "file3" );
is( $outHash->{key4}->{FILENAME}, 'file4', "file4" );
ok( !exists( $outHash->{replace1} ), "no more replace1 key" );
ok( !exists( $outHash->{replace3} ), "no more replace3 key" );

# Helper function to put stuff into the cache.
sub putInCache {
    my ( $key, $filename, $region, $contents ) = @_;
    my $dir = tempdir( CLEANUP => 1 );
    open( OUT, ">", "$dir/$filename" ) or die $!;
    print OUT $contents;
    close(OUT);
    $cacher->put(
        DIRECTORY      => $dir,
        KEYS           => [$key],
        FILENAMES      => [$filename],
        REGION_LEVEL_1 => $region
    );
}

sub findScript {
    my ($scriptName) = @_;

    my $dirname = dirname(__FILE__);
    my $script  = "$dirname/../scripts/$scriptName";

    unless ( -f $script ) {

        # see if we can find the script relative to our current location
        $script = "blib/script/$scriptName";
        foreach my $dir ( split( /\/+/, $FindBin::Bin ) ) {
            next if ( $dir =~ /^\s*$/ );
            last if ( -f $script );
            $script = "../$script";
        }
    }

    return $script;
}
