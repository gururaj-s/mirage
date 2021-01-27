#!/usr/bin/perl -w
use Cwd;
require ( "./bench_common.pl");
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };

#$trace_dir = "/home/gattaca4/gururaj/sc_exp/POST_ISCA_CC/sim_resetstats_test_dualcomp/";

#####################################
######### USAGE OPTIONS      ########
#####################################

$wsuite   = "exception";
$sim_opt   = "  ";
$debug     = 0;
$firewidth = 30; # num parallel jobs at a time
$sleep     = 0;
$run_spec = "./runscript.sh";
$scheme = "Baseline";
$run_config = "default";
#$setterm_output = 0;

#####################################
######### USAGE OPTIONS      ########
#####################################

sub usage(){

    $USAGE = "Usage:  '$0 <-option> '";
    
    print(STDERR "$USAGE\n");
    print(STDERR "\t--h                    : help -- print this menu. \n");
    print(STDERR "\t--w <workload/suite>   : workload suite from bench_common \n");
    print(STDERR "\t--e <run_spec>         : script to execute \n");
    print(STDERR "\t--s <scheme>           : scheme to execute sript with \n");
    print(STDERR "\t--c <run_config>       : directory_name for config being run \n");    
    print(STDERR "\t--o <sim_options>      : simulator options \n");
    print(STDERR "\t--dbg                  : debug \n");
    print(STDERR "\t--f <val>              : firewidth, num of parallel jobs \n");
    print(STDERR "\t--z <val>              : sleep for z seconds \n");
    print(STDERR "\n");

    exit(1);
}

######################################
########## PARSE COMMAND LINE ########
######################################

while (@ARGV) {
    $option = shift;
 
    if ($option eq "--dbg") {
        $debug = 1;
    }elsif ($option eq "--w") {
        $wsuite = shift;
    }elsif ($option eq "--e") {
        $run_spec = shift;
        $run_spec = "./".$run_spec;
    }elsif ($option eq "--s") {
        $scheme = shift;
    }elsif ($option eq "--c") {
        $run_config = shift;
    }elsif ($option eq "--o") {
        $sim_opt = shift;
    }elsif ($option eq "--f") {
        $firewidth = shift;
    }elsif ($option eq "--z") {
        $sleep = shift;
    } else{
        usage();
        die "Incorrect option ... Quitting\n";
    }
}


##########################################################
# get the suite names, num_w, and num_p from bench_common

die "No benchmark set '$wsuite' defined in bench_common.pl\n"
    unless $SUITES{$wsuite};
@w = split(/\n/, $SUITES{$wsuite});
$num_w = scalar @w;


##########################################################

for($ii=0; $ii< $num_w; $ii++){
    $wname = ltrim( rtrim($w[$ii]) );

    #redirect temrinal output
    $output_string = "";
    #if($setterm_output == 0){
    #    $output_string = ">$curr_dir/runout/${run_config}_${scheme_invisispec}_${scheme_cleanupcache}/$wname.out 2>&1";
    #}
    
    #create execute string
    $exe = "$run_spec $wname $run_config $scheme $output_string";
 
    #background all jobs except the last one (acts as barrier)
    $exe .= " &" unless($ii%$firewidth==($firewidth-1));

    print "$exe\n";
    system("$exe") unless($debug);    

}
