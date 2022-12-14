#$Id: Giovanni-WorldLongitude_Animation.t,v 1.3 2014/02/27 21:53:23 csmit Exp $
#-@@@ GIOVANNI,Version $Name:  $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Giovanni-Algorithm-GridNormalizer.t'

#########################

use Test::More tests => 3;
BEGIN { use_ok('Giovanni::WorldLongitude') }

#########################

use File::Temp qw/ tempdir /;
use Giovanni::Data::NcFile;
use Giovanni::Logger;

# create a working directory
my $dir = tempdir( CLEANUP => 1 );

# create the input data file
my ( $sourceCdl, $correctCdl ) = readCdlData();

my $dataFile
    = "$dir/subsetted.G4P0_1DA_2D_du_aot_006_tauf2d_du_00550.20030102.162E_51S_173W_27S.nc";
Giovanni::Data::NcFile::write_netcdf_file( $dataFile, $sourceCdl )
    or die "Unable to write input file.";

# create a logger
my $logger = Giovanni::Logger->new(
    session_dir       => $dir,
    manifest_filename => "mfst.blah+whatever.xml"
);

my $outFile = "$dir/out.nc";
Giovanni::WorldLongitude::normalize(
    logger       => $logger,
    in           => [$dataFile],
    out          => [$outFile],
    startPercent => 50,
    endPercent   => 100,
    sessionDir   => $dir,
);

ok( -e $outFile, "Output file exists" ) or die;

# write the correct data file
my $correctNc
    = "$dir/subsettedWorldLon.G4P0_1DA_2D_du_aot_006_tauf2d_du_00550.20030102.162E_51S_173W_27S.nc";
Giovanni::Data::NcFile::write_netcdf_file( $correctNc, $correctCdl )
    or die "Unable to write test output file.";

my $out
    = Giovanni::Data::NcFile::diff_netcdf_files( $outFile, $correctNc, $dir,
    "history" );

is( $out, 0, "Same output: $out" );

sub readCdlData {

    # read block at __DATA__ and write to a CDL file
    #(stolen from Chris...)
    my @cdldata;
    while (<DATA>) {
        push @cdldata, $_;
    }
    my $allCdf = join( '', @cdldata );

    # now divide up
    my @cdl = ( $allCdf =~ m/(netcdf .*?\}\n)/gs );
    return @cdl;
}

#http://s4ptu-ts2.ecs.nasa.gov/~csmit/giovanni/#service=MAP_ANIMATION&starttime=2003-01-01T00:00:00Z&endtime=2003-01-02T23:59:59Z&bbox=162.4219,-51.8203,-173.6719,-27.9141&data=G4P0_1DA_2D_du_aot_006_tauf2d_du_00550&dataKeyword=GOCART
__DATA__
netcdf subsetted.G4P0_1DA_2D_du_aot_006_tauf2d_du_00550.20030102.162E_51S_173W_27S {
dimensions:
    time = UNLIMITED ; // (1 currently)
    lat = 12 ;
    lon = 10 ;
variables:
    float G4P0_1DA_2D_du_aot_006_tauf2d_du_00550(time, lat, lon) ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:_FillValue = -9999.f ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:long_name = "Aerosol Optical Depth of Dust (fine) 550 nm, GOCART model, 2.0 x 2.5 deg." ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:units = "1" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:cell_methods = "time: mean" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:coordinates = "time lat lon" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:standard_name = "tauf2d_du_00550" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:quantity_type = "Component Aerosol Optical Depth" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:product_short_name = "G4P0_1DA_2D_du_aot" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:product_version = "006" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:latitude_resolution = 2. ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:longitude_resolution = 2.5 ;
    int dataday(time) ;
        dataday:long_name = "Standardized Date Label" ;
    float lat(lat) ;
        lat:borders = "ilat" ;
        lat:long_name = "Latitude" ;
        lat:standard_name = "latitude" ;
        lat:units = "degrees_north" ;
    float lon(lon) ;
        lon:borders = "ilon" ;
        lon:long_name = "Longitude" ;
        lon:standard_name = "longitude" ;
        lon:units = "degrees_east" ;
    double time(time) ;
        time:calendar = "gregorian" ;
        time:long_name = "time" ;
        time:standard_name = "time" ;
        time:units = "seconds since 1970-01-01 00:00:00" ;

// global attributes:
        :Conventions = "CF-1.4" ;
        :NCO = "4.3.1" ;
        :nco_openmp_thread_number = 1 ;
        :start_time = "2003-01-02T00:00:00Z" ;
        :end_time = "2003-01-02T23:59:59Z" ;
        :temporal_resolution = "daily" ;
        :title = "G4P0_1DA_2D_du_aot_006_tauf2d_du_00550 (162.4219E_51.8203S_173.6719W_27.9141S)" ;
        :plot_hint_title = "Aerosol Optical Depth of Dust (fine) 550 nm, GOCART model, 2.0 x 2.5 deg. [G4P0_1DA_2D_du_aot v6] for 2003-01-02" ;
data:

 G4P0_1DA_2D_du_aot_006_tauf2d_du_00550 =
  0.001340172, 0.001000789, 0.0009473476, 0.001244472, 0.001734158, 
    0.002701232, 0.004535938, 0.006523491, 0.007372783, 0.006261359,
  0.001115028, 0.0008352952, 0.001025153, 0.001566388, 0.001955316, 
    0.002019559, 0.002271405, 0.004201824, 0.006595898, 0.007478667,
  0.0009381972, 0.0007838539, 0.001269807, 0.002109332, 0.002549383, 
    0.002378247, 0.002052776, 0.00227389, 0.004165669, 0.006371399,
  0.0007966374, 0.0007773475, 0.001408108, 0.002414078, 0.003048897, 
    0.002967834, 0.002530145, 0.002339969, 0.00301776, 0.004589448,
  0.0007009125, 0.0007016332, 0.001226878, 0.002533295, 0.003443629, 
    0.003745636, 0.00384857, 0.003590306, 0.003705635, 0.00456157,
  0.0006401443, 0.000587384, 0.000783266, 0.002147726, 0.003723813, 
    0.003874394, 0.0040634, 0.004320564, 0.004727891, 0.005306609,
  0.0005865264, 0.0005344236, 0.0005400981, 0.001326715, 0.003227753, 
    0.003789946, 0.004206548, 0.004645488, 0.004801119, 0.005724245,
  0.0005359765, 0.0004932894, 0.0004727794, 0.0006111941, 0.001895483, 
    0.003174242, 0.004057697, 0.00465368, 0.005109546, 0.005683203,
  0.0005003428, 0.0004473991, 0.000427717, 0.0004208816, 0.0005110732, 
    0.0008319237, 0.001612482, 0.002937737, 0.004162773, 0.005135695,
  0.0004690744, 0.0004290042, 0.0004022027, 0.0003812764, 0.0003839651, 
    0.0004151502, 0.0005481563, 0.0009833412, 0.001412988, 0.001804969,
  0.0004346218, 0.0003959413, 0.000374079, 0.0003415162, 0.000330049, 
    0.000355132, 0.0003915739, 0.0004373627, 0.0005459355, 0.0007662898,
  0.0003992331, 0.0003301121, 0.0003051617, 0.0002652371, 0.0002579764, 
    0.0002878674, 0.000352169, 0.0003911989, 0.0004101109, 0.0004190664 ;

 dataday = 2003002 ;

 lat = -50, -48, -46, -44, -42, -40, -38, -36, -34, -32, -30, -28 ;

 lon = 162.5, 165, 167.5, 170, 172.5, 175, 177.5, -180, -177.5, -175 ;

 time = 1041465600 ;
}
netcdf subsettedWorldLon.G4P0_1DA_2D_du_aot_006_tauf2d_du_00550.20030102.162E_51S_173W_27S {
dimensions:
    time = UNLIMITED ; // (1 currently)
    lat = 12 ;
    lon = 144 ;
variables:
    float G4P0_1DA_2D_du_aot_006_tauf2d_du_00550(time, lat, lon) ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:_FillValue = -9999.f ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:cell_methods = "time: mean" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:coordinates = "time lat lon" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:latitude_resolution = 2. ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:long_name = "Aerosol Optical Depth of Dust (fine) 550 nm, GOCART model, 2.0 x 2.5 deg." ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:longitude_resolution = 2.5 ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:product_short_name = "G4P0_1DA_2D_du_aot" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:product_version = "006" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:quantity_type = "Component Aerosol Optical Depth" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:standard_name = "tauf2d_du_00550" ;
        G4P0_1DA_2D_du_aot_006_tauf2d_du_00550:units = "1" ;
    int dataday(time) ;
        dataday:long_name = "Standardized Date Label" ;
    float lat(lat) ;
        lat:borders = "ilat" ;
        lat:long_name = "Latitude" ;
        lat:standard_name = "latitude" ;
        lat:units = "degrees_north" ;
    float lon(lon) ;
        lon:borders = "ilon" ;
        lon:long_name = "Longitude" ;
        lon:standard_name = "longitude" ;
        lon:units = "degrees_east" ;
    double time(time) ;
        time:calendar = "gregorian" ;
        time:long_name = "time" ;
        time:standard_name = "time" ;
        time:units = "seconds since 1970-01-01 00:00:00" ;

// global attributes:
        :Conventions = "CF-1.4" ;
        :NCO = "4.3.1" ;
        :nco_openmp_thread_number = 1 ;
        :start_time = "2003-01-02T00:00:00Z" ;
        :end_time = "2003-01-02T23:59:59Z" ;
        :temporal_resolution = "daily" ;
        :title = "G4P0_1DA_2D_du_aot_006_tauf2d_du_00550 (162.4219E_51.8203S_173.6719W_27.9141S)" ;
        :plot_hint_title = "Aerosol Optical Depth of Dust (fine) 550 nm, GOCART model, 2.0 x 2.5 deg. [G4P0_1DA_2D_du_aot v6] for 2003-01-02" ;

data:

 G4P0_1DA_2D_du_aot_006_tauf2d_du_00550 =
  0.006523491, 0.007372783, 0.006261359, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.001340172, 0.001000789, 0.0009473476, 0.001244472, 0.001734158, 
    0.002701232, 0.004535938,
  0.004201824, 0.006595898, 0.007478667, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.001115028, 0.0008352952, 0.001025153, 0.001566388, 0.001955316, 
    0.002019559, 0.002271405,
  0.00227389, 0.004165669, 0.006371399, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0009381972, 0.0007838539, 0.001269807, 0.002109332, 0.002549383, 
    0.002378247, 0.002052776,
  0.002339969, 0.00301776, 0.004589448, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0007966374, 0.0007773475, 0.001408108, 0.002414078, 0.003048897, 
    0.002967834, 0.002530145,
  0.003590306, 0.003705635, 0.00456157, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0007009125, 0.0007016332, 0.001226878, 0.002533295, 0.003443629, 
    0.003745636, 0.00384857,
  0.004320564, 0.004727891, 0.005306609, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0006401443, 0.000587384, 0.000783266, 0.002147726, 0.003723813, 
    0.003874394, 0.0040634,
  0.004645488, 0.004801119, 0.005724245, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0005865264, 0.0005344236, 0.0005400981, 0.001326715, 0.003227753, 
    0.003789946, 0.004206548,
  0.00465368, 0.005109546, 0.005683203, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0005359765, 0.0004932894, 0.0004727794, 0.0006111941, 
    0.001895483, 0.003174242, 0.004057697,
  0.002937737, 0.004162773, 0.005135695, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0005003428, 0.0004473991, 0.000427717, 0.0004208816, 
    0.0005110732, 0.0008319237, 0.001612482,
  0.0009833412, 0.001412988, 0.001804969, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, 0.0004690744, 0.0004290042, 0.0004022027, 0.0003812764, 
    0.0003839651, 0.0004151502, 0.0005481563,
  0.0004373627, 0.0005459355, 0.0007662898, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, 0.0004346218, 0.0003959413, 0.000374079, 0.0003415162, 
    0.000330049, 0.000355132, 0.0003915739,
  0.0003911989, 0.0004101109, 0.0004190664, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, 
    _, _, _, 0.0003992331, 0.0003301121, 0.0003051617, 0.0002652371, 
    0.0002579764, 0.0002878674, 0.000352169 ;

 dataday = 2003002 ;

 lat = -50, -48, -46, -44, -42, -40, -38, -36, -34, -32, -30, -28 ;

 lon = -180, -177.5, -175, -172.5, -170, -167.5, -165, -162.5, -160, -157.5, 
    -155, -152.5, -150, -147.5, -145, -142.5, -140, -137.5, -135, -132.5, 
    -130, -127.5, -125, -122.5, -120, -117.5, -115, -112.5, -110, -107.5, 
    -105, -102.5, -100, -97.5, -95, -92.5, -90, -87.5, -85, -82.5, -80, 
    -77.5, -75, -72.5, -70, -67.5, -65, -62.5, -60, -57.5, -55, -52.5, -50, 
    -47.5, -45, -42.5, -40, -37.5, -35, -32.5, -30, -27.5, -25, -22.5, -20, 
    -17.5, -15, -12.5, -10, -7.5, -5, -2.5, 0, 2.5, 5, 7.5, 10, 12.5, 15, 
    17.5, 20, 22.5, 25, 27.5, 30, 32.5, 35, 37.5, 40, 42.5, 45, 47.5, 50, 
    52.5, 55, 57.5, 60, 62.5, 65, 67.5, 70, 72.5, 75, 77.5, 80, 82.5, 85, 
    87.5, 90, 92.5, 95, 97.5, 100, 102.5, 105, 107.5, 110, 112.5, 115, 117.5, 
    120, 122.5, 125, 127.5, 130, 132.5, 135, 137.5, 140, 142.5, 145, 147.5, 
    150, 152.5, 155, 157.5, 160, 162.5, 165, 167.5, 170, 172.5, 175, 177.5 ;

 time = 1041465600 ;
}
