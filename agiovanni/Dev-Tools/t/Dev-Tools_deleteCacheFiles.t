#$Id: cleanCacheDb.t,v 1.4 2015/04/01 19:06:22 csmit Exp $
#-@@@ Giovanni, Version $Name:  $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Giovanni-BoundingBox.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
BEGIN { use_ok('Dev::Tools') }

use strict;
use warnings;

use FindBin qw($Bin);
use File::Temp qw/ tempdir /;
use Giovanni::Logger;
use Giovanni::Cache;

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
putInCache( "key1", "file1", "region_A", "hello world" );
putInCache( "key2", "file2", "region_A", "hello world" );
putInCache( "key3", "file3", "region_A", "hello world" );

putInCache( "key1", "file1", "region_B", "hello world" );
putInCache( "key2", "file2", "region_B", "hello world" );
putInCache( "key3", "file3", "region_B", "hello world" );

# delete some files from the two regions
my @filesToDelete = (
    "$cacheDir/region_A/file1", "$cacheDir/region_A/file2",
    "$cacheDir/region_B/file1",
);

Dev::Tools::deleteCacheFiles( FILE_LIST => \@filesToDelete, VERBOSE => 1 )
    ;

# make sure the files are gone
for my $file (@filesToDelete) {
    ok( !( -e $file ), "File $file is gone." );
}

# make sure we removed things from the cache correctly
my $outHash = $cacher->get(
    DIRECTORY      => $workingDir,
    KEYS           => [ "key1", "key2", "key3" ],
    REGION_LEVEL_1 => "region_A",
);

ok( !( exists( $outHash->{"key1"} ) ), "key1 in first region is gone" );
ok( !( exists( $outHash->{"key2"} ) ), "key2 in first region is gone" );
ok( exists( $outHash->{"key3"} ),      "key3 in first region is present" );

# delete the file that was put in the working directory
unlink("$workingDir/file3");

$outHash = $cacher->get(
    DIRECTORY      => $workingDir,
    KEYS           => [ "key1", "key2", "key3" ],
    REGION_LEVEL_1 => "region_B",
);

ok( !( exists( $outHash->{"key1"} ) ), "key1 in second region is gone" );
ok( exists( $outHash->{"key2"} ),      "key2 in second region is present" );
ok( exists( $outHash->{"key3"} ),      "key3 in second region is present" );

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

