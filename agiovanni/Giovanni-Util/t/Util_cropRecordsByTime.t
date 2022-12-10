#!/usr/bin/perl -w

=head1 NAME

Util_cropRecordsByTime.t - Unit test script for Util::cropRecordsByTime()

=head1 PROJECT

Giovanni

=head1 SYNOPSIS

Util_cropRecordsByTime.t

=head1 DESCRIPTION

The Util::cropRecordsByTime() crops records by time in a series of files, each
containing records of multiple time steps.

=head1 OPTIONS

=over 4

=back

=head1 AUTHOR

Jianfu Pan (jianfu.pan@nasa.gov)

=cut

use Test::More tests => 5;
use Giovanni::Util;

#
# Initial setting
#

my $ncfiles
    = [ "Util_cropRecordsByTime_01.nc", "Util_cropRecordsByTime_02.nc" ];
my @files_to_clean = ();
foreach my $f (@$ncfiles) { push( @files_to_clean, $f ); }

# Create test data
my $rc = create_test_data($ncfiles);

# Test existence of test nc files
my $k = 1;
foreach my $f (@$ncfiles) {
    ok( ( -f $f ), "Created test nc file $k" );
    $k++;
}

# Call the method
my $T0 = "2006-01-01T09:00:00Z";
my $T1 = "2006-01-02T08:00:00Z";

my $ncfiles_new = Giovanni::Util::cropRecordsByTime( $ncfiles, $T0, $T1 );
ok( $? eq 0, "Script runs successfully" );

# Test script results
my @times0 = `ncks -H -C -v time $ncfiles_new->[0]`;
chomp(@times0);
pop(@times0) if $times0[-1] eq "";
my ($t0) = ( $times0[0] =~ /time\[0\]=(\d+)/ );
is( $t0, 1136107800, "Start time cropped" );

my @times1 = `ncks -H -C -v time $ncfiles_new->[-1]`;
chomp(@times1);
pop(@times1) if $times1[-1] eq "";
my ($t1) = ( $times1[-1] =~ /time\[\d+\]=(\d+)/ );
is( $t1, 1136158200, "Start time cropped" );

# Clean up
unlink( @files_to_clean, @$ncfiles_new ) unless $ENV{'SAVE_TEST_FILES'};

exit(0);

#########################

sub create_test_data {
    my ($ncfiles) = @_;

    # Read block at __DATA__ and write to a CDL file
    local ($/) = undef;
    my $cdldata = <DATA>;

    # Split the DATA text into three separate files
    my @cdl = ( $cdldata =~ m/(netcdf .*?\}\n)/gs );

    # Create nc files
    my $k = 0;
    foreach my $ncdump (@cdl) {
        open( NC, ">ncdump.cdl" ) || die("ERROR Fail to create tmp cdl file");
        print NC $ncdump;
        `ncgen -b -o $ncfiles->[$k] ncdump.cdl`;
        close(NC);
        $k++;
    }
    unlink("ncdump.cdl");

    return 1;
}

# In test data below, first 3 are MOD files and the next 2 are MYD files with
# middle file missing (for testing missing file handling)
__DATA__
netcdf \1 {
dimensions:
	time = UNLIMITED ; // (24 currently)
	lat = 3 ;
	lon = 4 ;
variables:
	double MAT1NXSLV_5_2_0_SLP(time, lat, lon) ;
		MAT1NXSLV_5_2_0_SLP:_FillValue = 999999986991104. ;
		MAT1NXSLV_5_2_0_SLP:coordinates = "time lat lon" ;
		MAT1NXSLV_5_2_0_SLP:fmissing_value = 1.e+15f ;
		MAT1NXSLV_5_2_0_SLP:fullpath = "/EOSGRID/Data Fields/SLP" ;
		MAT1NXSLV_5_2_0_SLP:long_name = "Sea level pressure" ;
		MAT1NXSLV_5_2_0_SLP:missing_value = 1.e+15f ;
		MAT1NXSLV_5_2_0_SLP:product_short_name = "MAT1NXSLV" ;
		MAT1NXSLV_5_2_0_SLP:product_version = "5.2.0" ;
		MAT1NXSLV_5_2_0_SLP:quantity_type = "Air Pressure" ;
		MAT1NXSLV_5_2_0_SLP:standard_name = "sea_level_pressure" ;
		MAT1NXSLV_5_2_0_SLP:units = "Pa" ;
		MAT1NXSLV_5_2_0_SLP:valid_range = -1.e+30f, 1.e+30f ;
		MAT1NXSLV_5_2_0_SLP:vmax = 1.e+30f ;
		MAT1NXSLV_5_2_0_SLP:vmin = -1.e+30f ;
	double lat(lat) ;
		lat:standard_name = "latitude" ;
		lat:units = "degrees_north" ;
	double lon(lon) ;
		lon:standard_name = "longitude" ;
		lon:units = "degrees_east" ;
	double time(time) ;
		time:begin_date = 20060101 ;
		time:begin_time = 3000 ;
		time:fullpath = "TIME:EOSGRID" ;
		time:long_name = "time" ;
		time:standard_name = "time" ;
		time:time_increment = 10000 ;
		time:units = "seconds since 1970-01-01 00:00:00" ;

// global attributes:
		:nco_openmp_thread_number = 1 ;
		:Conventions = "CF-1.4" ;
		:NCO = "4.3.1" ;
		:start_time = "2006-01-01T00:00:00Z" ;
		:end_time = "2006-01-01T23:59:59Z" ;
		:temporal_resolution = "hourly" ;
		:history = "Wed Aug 28 18:12:14 2013: ncks -O -d lat,40.,41. -d lon,-88.,-86. scrubbed.MAT1NXSLV_5_2_0_SLP.20060101.nc /tmp/jpan/1.nc" ;
data:

 MAT1NXSLV_5_2_0_SLP =
  1012.2853125, 1012.3753125, 1012.3353125, 1012.3053125,
  1011.8553125, 1011.8753125, 1011.9353125, 1011.9453125,
  1011.5653125, 1011.5653125, 1011.4953125, 1011.5453125,
  1012.66390625, 1012.77390625, 1012.81390625, 1012.71390625,
  1012.25390625, 1012.33390625, 1012.37390625, 1012.39390625,
  1011.92390625, 1011.94390625, 1011.97390625, 1011.85390625,
  1012.7909375, 1013.0009375, 1013.0909375, 1012.9809375,
  1012.4609375, 1012.5809375, 1012.6209375, 1012.6109375,
  1012.2609375, 1012.3409375, 1012.3009375, 1012.3009375,
  1012.651484375, 1012.951484375, 1013.101484375, 1013.071484375,
  1012.341484375, 1012.631484375, 1012.761484375, 1012.831484375,
  1012.201484375, 1012.421484375, 1012.521484375, 1012.521484375,
  1012.45890625, 1012.81890625, 1012.98890625, 1013.03890625,
  1012.16390625, 1012.52890625, 1012.65890625, 1012.81890625,
  1012.02390625, 1012.32890625, 1012.48890625, 1012.59890625,
  1012.17296875, 1012.71796875, 1013.00796875, 1013.09796875,
  1011.95796875, 1012.40796875, 1012.69296875, 1012.90796875,
  1011.86796875, 1012.25796875, 1012.51796875, 1012.70796875,
  1011.97203125, 1012.51203125, 1012.80203125, 1013.13703125,
  1011.77703125, 1012.26203125, 1012.61703125, 1013.00703125,
  1011.62703125, 1012.16203125, 1012.53703125, 1012.78703125,
  1012.3753125, 1012.8153125, 1013.0453125, 1013.2953125,
  1012.1903125, 1012.6153125, 1012.8853125, 1013.2153125,
  1012.1453125, 1012.5253125, 1012.8203125, 1013.1553125,
  1012.479140625, 1013.229140625, 1013.559140625, 1013.729140625,
  1012.614140625, 1013.179140625, 1013.419140625, 1013.679140625,
  1012.699140625, 1013.139140625, 1013.479140625, 1013.599140625,
  1012.21546875, 1013.05546875, 1013.59546875, 1014.04546875,
  1012.28546875, 1013.07046875, 1013.59546875, 1014.01546875,
  1012.47546875, 1013.16046875, 1013.66546875, 1013.89546875,
  1011.8021875, 1012.8421875, 1013.5321875, 1014.1721875,
  1011.9971875, 1012.9571875, 1013.6121875, 1014.2421875,
  1012.2071875, 1013.0271875, 1013.8021875, 1014.2121875,
  1011.4365625, 1012.5015625, 1013.2715625, 1014.0615625,
  1011.6065625, 1012.6565625, 1013.4215625, 1014.2015625,
  1011.9115625, 1012.8415625, 1013.6215625, 1014.2715625,
  1011.10734375, 1012.13234375, 1012.95734375, 1013.74734375,
  1011.28234375, 1012.29734375, 1012.99734375, 1013.81734375,
  1011.51734375, 1012.42734375, 1013.26734375, 1013.96734375,
  1011.098515625, 1012.108515625, 1012.928515625, 1013.708515625,
  1011.148515625, 1012.233515625, 1012.958515625, 1013.768515625,
  1011.328515625, 1012.298515625, 1013.088515625, 1013.818515625,
  1011.19078125, 1012.29578125, 1013.26578125, 1014.10578125,
  1011.31578125, 1012.43078125, 1013.24578125, 1014.08578125,
  1011.54578125, 1012.60578125, 1013.39578125, 1014.13578125,
  1010.989765625, 1012.104765625, 1013.229765625, 1014.249765625,
  1011.059765625, 1012.324765625, 1013.279765625, 1014.289765625,
  1011.279765625, 1012.544765625, 1013.569765625, 1014.429765625,
  1010.33234375, 1011.43734375, 1012.48734375, 1013.60734375,
  1010.44234375, 1011.61234375, 1012.62734375, 1013.75734375,
  1010.72234375, 1011.91234375, 1012.88734375, 1013.95734375,
  1008.911953125, 1010.186953125, 1011.316953125, 1012.551953125,
  1009.066953125, 1010.306953125, 1011.501953125, 1012.741953125,
  1009.356953125, 1010.696953125, 1011.921953125, 1012.971953125,
  1007.487734375, 1008.870234375, 1009.995234375, 1011.275234375,
  1007.750234375, 1009.035234375, 1010.155234375, 1011.465234375,
  1008.145234375, 1009.325234375, 1010.555234375, 1011.795234375,
  1006.37328125, 1007.79828125, 1009.01328125, 1010.29328125,
  1006.63828125, 1008.03828125, 1009.20328125, 1010.55328125,
  1007.10828125, 1008.43328125, 1009.59328125, 1010.83328125,
  1005.63171875, 1007.04171875, 1008.23171875, 1009.57171875,
  1005.88671875, 1007.29171875, 1008.47171875, 1009.94171875,
  1006.29171875, 1007.58171875, 1008.88171875, 1010.23171875,
  1005.29125, 1006.74625, 1007.91625, 1009.15625,
  1005.53125, 1006.91625, 1008.08625, 1009.46625,
  1006.01625, 1007.31625, 1008.50625, 1009.87625,
  1005.15984375, 1006.51984375, 1007.73984375, 1008.96984375,
  1005.48984375, 1006.79984375, 1007.88984375, 1009.20984375,
  1005.82984375, 1007.06984375, 1008.32984375, 1009.68984375,
  1005.127421875, 1006.417421875, 1007.587421875, 1008.737421875,
  1005.537421875, 1006.777421875, 1007.857421875, 1009.067421875,
  1005.907421875, 1007.037421875, 1008.227421875, 1009.527421875 ;

 lat = 40, 40.5, 41 ;

 lon = -88, -87.3333333333333, -86.6666666666667, -86 ;

 time = 1136075400, 1136079000, 1136082600, 1136086200, 1136089800, 
    1136093400, 1136097000, 1136100600, 1136104200, 1136107800, 1136111400, 
    1136115000, 1136118600, 1136122200, 1136125800, 1136129400, 1136133000, 
    1136136600, 1136140200, 1136143800, 1136147400, 1136151000, 1136154600, 
    1136158200 ;
}
netcdf \2 {
dimensions:
	time = UNLIMITED ; // (24 currently)
	lat = 3 ;
	lon = 4 ;
variables:
	double MAT1NXSLV_5_2_0_SLP(time, lat, lon) ;
		MAT1NXSLV_5_2_0_SLP:_FillValue = 999999986991104. ;
		MAT1NXSLV_5_2_0_SLP:coordinates = "time lat lon" ;
		MAT1NXSLV_5_2_0_SLP:fmissing_value = 1.e+15f ;
		MAT1NXSLV_5_2_0_SLP:fullpath = "/EOSGRID/Data Fields/SLP" ;
		MAT1NXSLV_5_2_0_SLP:long_name = "Sea level pressure" ;
		MAT1NXSLV_5_2_0_SLP:missing_value = 1.e+15f ;
		MAT1NXSLV_5_2_0_SLP:product_short_name = "MAT1NXSLV" ;
		MAT1NXSLV_5_2_0_SLP:product_version = "5.2.0" ;
		MAT1NXSLV_5_2_0_SLP:quantity_type = "Air Pressure" ;
		MAT1NXSLV_5_2_0_SLP:standard_name = "sea_level_pressure" ;
		MAT1NXSLV_5_2_0_SLP:units = "Pa" ;
		MAT1NXSLV_5_2_0_SLP:valid_range = -1.e+30f, 1.e+30f ;
		MAT1NXSLV_5_2_0_SLP:vmax = 1.e+30f ;
		MAT1NXSLV_5_2_0_SLP:vmin = -1.e+30f ;
	double lat(lat) ;
		lat:standard_name = "latitude" ;
		lat:units = "degrees_north" ;
	double lon(lon) ;
		lon:standard_name = "longitude" ;
		lon:units = "degrees_east" ;
	double time(time) ;
		time:begin_date = 20060102 ;
		time:begin_time = 3000 ;
		time:fullpath = "TIME:EOSGRID" ;
		time:long_name = "time" ;
		time:standard_name = "time" ;
		time:time_increment = 10000 ;
		time:units = "seconds since 1970-01-01 00:00:00" ;

// global attributes:
		:nco_openmp_thread_number = 1 ;
		:Conventions = "CF-1.4" ;
		:NCO = "4.3.1" ;
		:start_time = "2006-01-02T00:00:00Z" ;
		:end_time = "2006-01-02T23:59:59Z" ;
		:temporal_resolution = "hourly" ;
		:history = "Wed Aug 28 18:13:53 2013: ncks -O -d lat,40.,41. -d lon,-88.,-86. scrubbed.MAT1NXSLV_5_2_0_SLP.20060102.nc /tmp/jpan/2.nc" ;
data:

 MAT1NXSLV_5_2_0_SLP =
  1005.201875, 1006.501875, 1007.631875, 1008.811875,
  1005.611875, 1006.821875, 1007.891875, 1009.191875,
  1006.061875, 1007.251875, 1008.431875, 1009.671875,
  1005.12671875, 1006.44671875, 1007.57671875, 1008.71671875,
  1005.48671875, 1006.73671875, 1007.80671875, 1009.07671875,
  1006.00671875, 1007.19671875, 1008.41671875, 1009.69671875,
  1004.903984375, 1006.133984375, 1007.373984375, 1008.443984375,
  1005.203984375, 1006.493984375, 1007.613984375, 1008.873984375,
  1005.723984375, 1006.923984375, 1008.143984375, 1009.453984375,
  1004.388203125, 1005.568203125, 1006.738203125, 1007.858203125,
  1004.588203125, 1005.858203125, 1006.958203125, 1008.268203125,
  1005.058203125, 1006.288203125, 1007.458203125, 1008.838203125,
  1003.715625, 1004.910625, 1006.010625, 1007.080625,
  1003.900625, 1005.050625, 1006.110625, 1007.380625,
  1004.310625, 1005.420625, 1006.590625, 1007.940625,
  1002.994296875, 1004.289296875, 1005.329296875, 1006.379296875,
  1003.179296875, 1004.359296875, 1005.349296875, 1006.569296875,
  1003.609296875, 1004.649296875, 1005.749296875, 1006.999296875,
  1002.453671875, 1003.668671875, 1004.773671875, 1005.843671875,
  1002.553671875, 1003.733671875, 1004.783671875, 1005.913671875,
  1003.008671875, 1004.043671875, 1005.093671875, 1006.263671875,
  1002.0765625, 1003.4015625, 1004.4115625, 1005.5415625,
  1002.2115625, 1003.4165625, 1004.4215625, 1005.5615625,
  1002.6465625, 1003.7715625, 1004.7815625, 1005.8615625,
  1001.51421875, 1002.70421875, 1003.85921875, 1005.01921875,
  1001.56921875, 1002.77421875, 1003.85921875, 1004.99921875,
  1001.97921875, 1003.16921875, 1004.27921875, 1005.38921875,
  1000.9146875, 1001.9396875, 1002.8746875, 1004.1346875,
  1000.7971875, 1001.9096875, 1002.9096875, 1004.1946875,
  1001.1596875, 1002.2246875, 1003.4146875, 1004.6146875,
  1000.33609375, 1001.52359375, 1002.33359375, 1003.47359375,
  1000.34359375, 1001.48359375, 1002.30859375, 1003.47359375,
  1000.60609375, 1001.74359375, 1002.75859375, 1003.85859375,
  999.769375, 1001.161875, 1002.136875, 1003.196875,
  999.946875, 1001.166875, 1002.091875, 1003.136875,
  1000.236875, 1001.286875, 1002.431875, 1003.516875,
  999.28578125, 1000.72015625, 1001.78515625, 1002.89015625,
  999.42265625, 1000.81515625, 1001.72515625, 1002.88015625,
  999.95140625, 1001.05265625, 1002.01015625, 1003.16015625,
  998.91203125, 1000.18203125, 1001.44953125, 1002.64953125,
  998.99515625, 1000.29703125, 1001.46953125, 1002.55453125,
  999.48453125, 1000.79953125, 1001.84953125, 1002.85453125,
  998.856171875, 999.988203125, 1001.038203125, 1002.288203125,
  998.900703125, 1000.011953125, 1001.123203125, 1002.348203125,
  999.234453125, 1000.423203125, 1001.638203125, 1002.678203125,
  998.95609375, 1000.06046875, 1000.89296875, 1001.92046875,
  998.90984375, 1000.04921875, 1000.85546875, 1002.04046875,
  999.162109375, 1000.21296875, 1001.30046875, 1002.37046875,
  998.643515625, 999.631484375, 1000.464765625, 1001.301015625,
  998.713515625, 999.681328125, 1000.417265625, 1001.416015625,
  999.006640625, 999.932890625, 1000.753515625, 1001.733515625,
  997.93921875, 998.84296875, 999.63859375, 1000.37890625,
  997.93171875, 998.97421875, 999.63171875, 1000.53234375,
  998.37421875, 999.34796875, 999.94171875, 1000.84546875,
  997.7465625, 998.3365625, 999.1365625, 999.7928125,
  997.5615625, 998.4915625, 999.1640625, 999.9203125,
  997.9715625, 998.9415625, 999.5990625, 1000.2465625,
  998.406640625, 998.336640625, 998.991640625, 999.709140625,
  998.036640625, 998.471640625, 999.209140625, 999.874140625,
  998.241640625, 998.904140625, 999.751640625, 1000.280390625,
  999.378125, 999.080625, 999.138125, 999.638125,
  998.920625, 998.875625, 999.298125, 999.895625,
  998.803125, 999.225625, 999.803125, 1000.363125,
  1000.43390625, 1000.07515625, 999.64515625, 999.82265625,
  999.89515625, 999.61765625, 999.66765625, 1000.05765625,
  999.51265625, 999.82015625, 1000.13765625, 1000.48765625,
  1001.44125, 1001.210625, 1000.7425, 1000.51625,
  1001.0175, 1000.71125, 1000.3675, 1000.59125,
  1000.4425, 1000.53875, 1000.7775, 1001.03875,
  1002.287578125, 1002.196953125, 1001.756015625, 1001.205703125,
  1001.972265625, 1001.730859375, 1001.150703125, 1001.094453125,
  1001.319453125, 1001.282578125, 1001.315703125, 1001.491328125 ;

 lat = 40, 40.5, 41 ;

 lon = -88, -87.3333333333333, -86.6666666666667, -86 ;

 time = 1136161800, 1136165400, 1136169000, 1136172600, 1136176200, 
    1136179800, 1136183400, 1136187000, 1136190600, 1136194200, 1136197800, 
    1136201400, 1136205000, 1136208600, 1136212200, 1136215800, 1136219400, 
    1136223000, 1136226600, 1136230200, 1136233800, 1136237400, 1136241000, 
    1136244600 ;
}