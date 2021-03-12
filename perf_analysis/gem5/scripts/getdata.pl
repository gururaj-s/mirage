#!/usr/bin/perl -w

require ( "./bench_common.pl");

$base_ipc_dir = "../RESULTS/A.BASE.01MBL3/" ;
$stat      = "SYS_CYCLES";
$wsuite    = "spec2k6";
$max_dirs  = 1024;
$norm_dir  = -1;

#####################################
######### USAGE OPTIONS      ########
#####################################

$ipc       = 0;
$numcores  = 4;
$ws        = 0;
$fairness  = 0;
$print_max = 0;
$max_start = 0;
$max_end   = 0;
$min_start = 0;
$min_end   = 0;
$print_no_stats   = 0;
$print_no_header  = 0;
$scurve    = 0;
$wlimit    = 0;
$amean     = 0;
$gmean     = 0;
$hmean     = 0;
$invert    = 0;
$printmask = ""; 
$nowarn    = 0;
$precint   = 0;
$dstat     = "";
$nstat     = "";
$numstat1  = "";
$numstat2  = "";
$mstat     = 0;
$astat     = 0;
$slist     = "";
$cstat     = "";
$debug     = 0;
$noxxxx    = 0;


#####################################
######### USAGE OPTIONS      ########
#####################################

sub usage(){

    $USAGE = "Usage:  '$0 <-option> '";
    
    print(STDERR "$USAGE\n");
    print(STDERR "\t-h                     : help -- print this menu. \n");
    print(STDERR "\t-t                     : throughput. \n");
    print(STDERR "\t-ws                    : weighted speedup. \n");
    print(STDERR "\t-ipc <numcores>        : calculate ipc. \n");
    print(STDERR "\t-hf                    : fairness. \n");
    print(STDERR "\t-b <basedir>           : base directory for ws and fairness \n");
    print(STDERR "\t-n <pos>               : print stats normalized to this dir <num> in dir list \n");
    print(STDERR "\t-d <statdirs>          : directory for stats (more than one ok) \n");
    print(STDERR "\t-s <statname>          : name of the stat (wild card ok) \n");
    print(STDERR "\t-nstat <statname>      : name of the numerator stat (X in X/Y ) \n");
    print(STDERR "\t-dstat <statname>      : name of the denominator stat (Y in X/Y ) \n");
    print(STDERR "\t-numstat1 <statname>   : name of the num1 stat (X in X-Y ) \n");
    print(STDERR "\t-numstat2 <statname>   : name of the num2 stat (Y in X-Y ) \n");
    print(STDERR "\t-mstat <val>           : value for multiplying stat \n");
    print(STDERR "\t-cstat <str>           : complex stat: A separate function computes stats for each string \n");
    print(STDERR "\t-ds <statname>         : name of the denominator stat (Y in X/Y ) \n");
    print(STDERR "\t-w <workload/suite>    : name of the workload suite from bench_common \n");
    print(STDERR "\t-wlimit <num>          : limit the number of workloads in suite to <num> \n");
    print(STDERR "\t-ns                    : print no individual stats. \n");
    print(STDERR "\t-nh                    : print no header. \n");
    print(STDERR "\t-max <start><end>      : print max vals of row from col start to col end. \n");
    print(STDERR "\t-min <start><end>      : print min vals of row from col start to col end. \n");
    print(STDERR "\t-scurve                : first directory must be base, second data. \n");
    print(STDERR "\t-amean                 : print arithmetic mean. \n");
    print(STDERR "\t-gmean                 : print geometric mean. \n");
    print(STDERR "\t-hmean                 : print harmonic mean. \n");

    print(STDERR "\t-invert                : print inverted values (useful for CPI) \n");
    print(STDERR "\t-printmask <str>       : print mask for columns ( 1-0-1-0 prints first and third col) \n");
    print(STDERR "\t-nowarn                : supress any warnings (be careful with this option) \n");
    print(STDERR "\t-precint               : precesion of integer for print values (default 3 digits after decimal) \n");
    print(STDERR "\t-slist <list>          : stats list ( separated by : \"stats1:stats2:stats3\") \n");
    print(STDERR "\t-debug                 : verbose mode for debugging. \n");
    print(STDERR "\t-noxxxx                : Print 0 for no data instead of xxxx. \n");

    print(STDERR "\n");

    exit(1);
}

######################################
########## PARSE COMMAND LINE ########
######################################

while (@ARGV) {
    $option = shift;
 
    if ($option eq "-ipc") {
        $ipc = 1;
	$numcores = shift;
    }elsif ($option eq "-ws") {
        $ws = 1;
    }elsif ($option eq "-hf") {
        $fairness = 1;
    }elsif ($option eq "-b") {
        $base_ipc_dir = shift;
    }elsif ($option eq "-n") {
        $norm_dir = shift;
    }
    elsif ($option eq "-h"){
	usage();
    }elsif ($option eq "-d") {
        while(@ARGV){
	    $mydir = shift;
	    $mydir .= "/";
	    push (@dirs, $mydir);
	}
    }elsif ($option eq "-s") {
        $stat = shift;
    }elsif ($option eq "-w") {
        $wsuite = shift;
    }elsif ($option eq "-wlimit") {
        $wlimit = shift;
    }elsif ($option eq "-ns") {
        $print_no_stats = 1;
    }elsif ($option eq "-nh") {
        $print_no_header = 1;
    }elsif ($option eq "-max") {
        $print_max = 1;
        $max_start = shift;    
        $max_end   = shift;    
    }elsif ($option eq "-min") {
        $print_min = 1;
        $min_start = shift;    
        $min_end   = shift;    
    }elsif ($option eq "-scurve") {
        $scurve = 1;
    }elsif ($option eq "-amean") {
        $amean = 1;
    }elsif ($option eq "-gmean") {
        $gmean = 1;
    }elsif ($option eq "-hmean") {
        $hmean = 1;
    }elsif ($option eq "-invert") {
        $invert = 1;
    }elsif ($option eq "-printmask") {
        $printmask = shift;
    }elsif ($option eq "-precint") {
        $precint = 1;
    }elsif ($option eq "-nowarn") {
        $nowarn = 1;
    }elsif ($option eq "-nstat") {
        $nstat = shift;
    }elsif ($option eq "-dstat") {
        $dstat = shift;
    }elsif ($option eq "-numstat1") {
        $numstat1 = shift;
    }elsif ($option eq "-numstat2") {
        $numstat2 = shift;
    }elsif ($option eq "-mstat") {
        $mstat = shift;
    }elsif ($option eq "-astat") {
        $astat = shift;
    }elsif ($option eq "-slist") {
        $slist = shift;
    }elsif ($option eq "-cstat") {
        $cstat = shift;
    }elsif ($option eq "-debug") {
        $debug = 1;
    }elsif ($option eq "-noxxxx") {
        $noxxxx = 1;
    }else{
	usage();
        die "Incorrect option ... Quitting\n";
    }
}
             


##########################################################
# get the suite names, num_w, and num_p from bench_common

die "No benchmark set '$wsuite' defined in bench_common.pl\n"
        unless $SUITES{$wsuite};
    
my (@w) = split(/\s+/, $SUITES{$wsuite});
$num_w = scalar @w;
@bmks = split/-/,$w[0];
$num_p = scalar @bmks;
$num_p = 4;

$num_w = $wlimit if($wlimit && $wlimit < $num_w);

init_stats();
get_stats();

get_ipc_stats() if($ipc); # calculate IPC
get_cstats() if($cstat); # complex stats
get_nstats() if($nstat);
get_dstats() if($dstat);
divide_n_by_d()if($nstat || $dstat);
sub_m_from_n()if($numstat1 || $numstat2);
multiply_stats() if($mstat);
add_stats() if($astat);

process_stats();  # normalization, max etc.

print_header()    unless $print_no_header;
print_stats()     unless $print_no_stats;

print_amean()        if($amean);
print_gmean()        if($gmean);
print_hmean()        if($hmean);
print_scurve_stats() if($scurve);
print_slist_stats()  if($slist);


########################## INIT STATS ####################

sub init_stats{
  for($ii=0; $ii< $max_dirs; $ii++){
    for($jj=0; $jj< $num_w; $jj++){
      $data[$ii][$jj]=0;
    }
  }

  @print_dir = "";
  if($printmask){
      @print_dir = split/-/,$printmask;
  }
}


########################## GET STATS ####################

sub get_stats{


  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    $dir = $dirs[$dirnum];
    
    for($ii=0; $ii< $num_w; $ii++){
      $wname   = $w[$ii];
      @bmks = split/-/,$wname;
      
      
      $fname   = $dir . $wname . "/stats.txt";
      $readable = 1;
      
      open(IN, $fname) or $readable=0;
      
      print "cannot open $fname for read\n" unless $readable||$nowarn;

      $found=0;

      while( ($readable) && ($found<$num_p) && ($_ = <IN>) ){
          @words = split/\s+/, $_;
          $num_words = scalar(@words);
          
          for($jj=0; $jj<$num_words-1; $jj++){
              printf "$words[$jj]\n" if($debug);
              
              if($words[$jj] && ($words[$jj] =~ $stat) ){
                  $pos = $jj+1;
                  $val = $words[$pos];      
                  $data[$dirnum][$ii] += $val;
                  printf "stat match for $stat found for $_" if($debug);
                  $found++;
              }
          }
          
      }
      close(IN);
    }
  }

}

################# NORMALIZE WORKLOAD STATS ######################

sub process_stats{

  if($fairness){
    for($ii=0; $ii< $num_w; $ii++){
      $dirnum=0;
      $norm_val = $data[$norm_dir][$ii];
      for($dirnum=0; $dirnum<@dirs; $dirnum++){
	$data[$dirnum][$ii] = $num_p/$data[$dirnum][$ii];
      }
    }
    
  }
  
  if($norm_dir != -1){
    
    for($ii=0; $ii< $num_w; $ii++){
      $norm_val = $data[$norm_dir][$ii];
      for($dirnum=0; $dirnum<@dirs; $dirnum++){
	  $data[$dirnum][$ii] /= $norm_val;   
      }
    }
    
  }


  if($print_max){
    
    for($ii=0; $ii< $num_w; $ii++){
      
      $max_val = $data[$max_start][$ii];
      for($jj=$max_start; $jj<$max_end; $jj++){
	$max_val = $data[$jj][$ii] if($max_val < $data[$jj][$ii]);
      }
      $dir_maxs[$ii] = $max_val;
      
    }

  }

  if($print_min){
    
    for($ii=0; $ii< $num_w; $ii++){
      
      $min_val = $data[$min_start][$ii];
      for($jj=$min_start; $jj<$min_end; $jj++){
	$min_val = $data[$jj][$ii] if($min_val > $data[$jj][$ii]);
      }
      $dir_mins[$ii] = $min_val;
      
    }

  }
}


########################## INIT HEADER ####################

sub print_header{

  $header = "";

  for($dirnum=0; $dirnum< @dirs; $dirnum++){
    $dir = $dirs[$dirnum];
    chop $dir;
    $len = length($dir);
    unless ($printmask && $print_dir[$dirnum]==0){
        $mystring = substr($dir, ($len-20), 20);
        $header .= $mystring."\t";
    }
  }

  if($print_max){
    $header .= "MAX".$max_start."-".$max_end."\t";
  }

  if($print_min){
    $header .= "MIN".$min_start."-".$min_end."\t";
  }
  
  printf("\n%20s\t", "Expts" );
  print "$header\n";
}


################# PRINT WORKLOAD STATS ######################

sub print_stats{


for($ii=0; $ii< $num_w; $ii++){
    $wname   = $w[$ii];
    $wname =  "db1" if($wname eq "B4");
    $wname =  "oltp" if($wname eq "I4");
    $wname =  "db2" if($wname eq "W4");
    $wname =  "fft" if($wname eq "fft.med");
    $wname =  "stride" if($wname eq "stride16");
    $wname =  "stress" if($wname eq "mprog.2r");

    $wname =  "db1"   if($wname eq "B4-B4-B4-B4-B4-B4-B4-B4");
    $wname =  "oltp"  if($wname eq "I4-I4-I4-I4-I4-I4-I4-I4");
    $wname =  "db2"   if($wname eq "W4-W4-W4-W4-W4-W4-W4-W4");


    $wname =  "cactus_r"  if($wname eq "cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06");
    $wname =  "mcf_r"     if($wname eq "mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06");
    $wname =  "zeusmp_r"  if($wname eq "zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06");
    $wname =  "astar_r"   if($wname eq "astar_06-astar_06-astar_06-astar_06-astar_06-astar_06-astar_06-astar_06");
    $wname =  "Gems_r"    if($wname eq "GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06");
    $wname =  "leslie_r"  if($wname eq "leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06");
    $wname =  "soplex_r"  if($wname eq "soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06");
    
    $wname =  "mix1"    if($wname eq "zeusmp_06-soplex_06-omnetpp_06-leslie3d_06-GemsFDTD_06-cactusADM_06-bwaves_06-astar_06");
    $wname =  "mix2"    if($wname eq "zeusmp_06-soplex_06-omnetpp_06-mcf_06-leslie3d_06-GemsFDTD_06-bwaves_06-astar_06");
    $wname =  "mix3"    if($wname eq "soplex_06-omnetpp_06-mcf_06-leslie3d_06-GemsFDTD_06-cactusADM_06-bwaves_06-astar_06");

    $wname =  "mix_1"    if($wname eq "cactusADM_06-leslie3d_06-soplex_06-zeusmp_06-cactusADM_06-leslie3d_06-soplex_06-zeusmp_06");
    $wname =  "mix_2"    if($wname eq "astar_06-cactusADM_06-leslie3d_06-soplex_06-astar_06-cactusADM_06-leslie3d_06-soplex_06");
    $wname =  "mix_3"    if($wname eq "cactusADM_06-GemsFDTD_06-soplex_06-zeusmp_06-cactusADM_06-GemsFDTD_06-soplex_06-zeusmp_06");
    $wname =  "mix_4"    if($wname eq "astar_06-GemsFDTD_06-soplex_06-zeusmp_06-astar_06-GemsFDTD_06-soplex_06-zeusmp_06");
    $wname =  "mix_5"    if($wname eq "astar_06-cactusADM_06-soplex_06-zeusmp_06-astar_06-cactusADM_06-soplex_06-zeusmp_06");
    $wname =  "mix_6"    if($wname eq "astar_06-cactusADM_06-GemsFDTD_06-soplex_06-astar_06-cactusADM_06-GemsFDTD_06-soplex_06");

	
    $wname =  "bwaves_r" if($wname eq "BWaves-BWaves-BWaves-BWaves-BWaves-BWaves-BWaves-BWaves");
    $wname =  "cactus_r" if($wname eq "CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM");
    $wname =  "lbm_r"    if($wname eq "lbm-lbm-lbm-lbm-lbm-lbm-lbm-lbm");
    $wname =  "mcf_r"    if($wname eq "mcf-mcf-mcf-mcf-mcf-mcf-mcf-mcf");
    $wname =  "gems_r"   if($wname eq "GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD");
    $wname =  "leslie_r" if($wname eq "leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d");
    $wname =  "milc_r"   if($wname eq "milc-milc-milc-milc-milc-milc-milc-milc");
    $wname =  "zeusmp_r" if($wname eq "zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp");
    $wname =  "mix_1"    if($wname eq "GemsFDTD-GemsFDTD-mcf-mcf-milc-milc-BWaves-BWaves");
    $wname =  "mix_2"    if($wname eq "GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-mcf-mcf-mcf-mcf");



#    $wname =~ s/.lrg//g ;
    $wname =~ s/_00//g ;
    $wname =~ s/_06//g ;

    $wstring = substr($wname, 0, 20);

    
    printf("\n%20s\t", $wstring);

    for($dirnum=0; $dirnum < @dirs ; $dirnum++){

	unless ($printmask && $print_dir[$dirnum]==0){
	    $val     = $data[$dirnum][$ii];
	    $val     = 1/$val if($invert);
	    if($val){ 
		if ($precint) {printf("%12llu \t", $val);} 
		else { printf("%12.3f \t", $val);  }
	    }
	    else { 
		printf("xxxxxxxxxxx \t") unless($noxxxx); 
		printf("0           \t") if($noxxxx); 
	    }
	}
    }
    
    if($print_max){
	$val     = $dir_maxs[$ii];
	$val     = 1/$val if($invert);
	if ($precint) {printf("%12llu \t", $val);} 
	else { printf("%12.3f \t", $val);  }

    }

    if($print_min){
	$val     = $dir_mins[$ii];
	$val     = 1/$val if($invert);
	if ($precint) {printf("%12llu \t", $val);} 
	else { printf("%12.3f \t", $val);  }

    }

}

print "\n";

}


################# PRINT AMEAN STATS ######################

sub print_amean{

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    $dir_sums[$dirnum]=0;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_sums[$dirnum] += $data[$dirnum][$ii];
    }
}

if($print_min){
    $dir_mins_sum  =0;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_mins_sum  += $dir_mins[$ii];
    }
}


printf("\n%20s\t", "Amean");

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    unless ($printmask && $print_dir[$dirnum]==0){
	$val = $dir_sums[$dirnum]/$num_w;
	$val = 1/$val if($invert);
	if ($precint) {printf("%12llu \t", $val);} 
	else { printf("%12.3f \t", $val);  }
    }
}

if($print_max){
    $val = $dir_maxs_sum/$num_w;
    $val     = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

if($print_min){
    $val = $dir_mins_sum/$num_w;
    $val     = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

print "\n";

}

########################## PRINT GMEAN STATS ######################
   
sub print_gmean{

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    $dir_prods[$dirnum]=1;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_prods[$dirnum] *= $data[$dirnum][$ii];
    }
}

if($print_max){
    $dir_maxs_prod =1;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_maxs_prod *= $dir_maxs[$ii];
    }
}

if($print_min){
    $dir_mins_prod =1;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_mins_prod *= $dir_mins[$ii];
    }
}

printf("\n%20s\t", "Gmean");

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    unless ($printmask && $print_dir[$dirnum]==0){
	$val = $dir_prods[$dirnum] ** (1/$num_w);
	$val     = 1/$val if($invert);
	if ($precint) {printf("%12llu \t", $val);} 
	else { printf("%12.3f \t", $val);  }	
    }
}

if($print_max){
    $val = $dir_maxs_prod ** (1/$num_w);
    $val = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

if($print_min){
    $val = $dir_mins_prod ** (1/$num_w);
    $val = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

print "\n";

}


################# PRINT HMEAN STATS ######################

sub print_hmean{

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    $dir_sums[$dirnum]=0;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_sums[$dirnum] += (1/$data[$dirnum][$ii]);
    }
}

if($print_max){
    $dir_maxs_sum  =0;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_maxs_sum  += (1/$dir_maxs[$ii]);
    }
}


if($print_min){
    $dir_mins_sum  =0;
    for($ii=0; $ii< $num_w; $ii++){
	$dir_mins_sum  += (1/$dir_mins[$ii]);
    }
}


printf("\n%20s\t", "Hmean");

for($dirnum=0; $dirnum < @dirs; $dirnum++){
    unless ($printmask && $print_dir[$dirnum]==0){
	$val = $num_w/$dir_sums[$dirnum];
	$val = 1/$val if($invert);
	if ($precint) {printf("%12llu \t", $val);} 
	else { printf("%12.3f \t", $val);  }
    }
}

if($print_max){
    $val = $num_w/$dir_maxs_sum;
    $val = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

if($print_min){
    $val = $num_w/$dir_mins_sum;
    $val = 1/$val if($invert);
    if ($precint) {printf("%12llu \t", $val);} 
    else { printf("%12.3f \t", $val);  }
}

print "\n";

}
   

########################## SUBROUTINES ######################

########################## SUBROUTINES ######################

sub get_nstats{
  
  $stat = $nstat; 
  init_stats();
  get_stats();

  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    for($ii=0; $ii< $num_w; $ii++){
      $ndata[$dirnum][$ii] = $data[$dirnum][$ii];
    }
  }

}
   
########################## SUBROUTINES ######################

sub get_dstats{
  
  $stat = $dstat; 
  init_stats();
  get_stats();

  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    for($ii=0; $ii< $num_w; $ii++){
      $ddata[$dirnum][$ii] = $data[$dirnum][$ii];
    }
  }

}
   
########################## SUBROUTINES ######################

sub divide_n_by_d{


  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    for($ii=0; $ii< $num_w; $ii++){
      $numerator = 1;
      $numerator = $ndata[$dirnum][$ii] if($ndata[$dirnum][$ii]);
      $denominator = 1;
      $denominator = $ddata[$dirnum][$ii] if($ddata[$dirnum][$ii]);
      $data[$dirnum][$ii] = $numerator/$denominator;
    }
  }

}

########################## SUBROUTINES ######################

sub sub_m_from_n{


  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    for($ii=0; $ii< $num_w; $ii++){
      $numerator = 1;
      $numerator = $numstat1[$dirnum][$ii] if($numstat1[$dirnum][$ii]);
      $denominator = 1;
      $denominator = $numstat2[$dirnum][$ii] if($numstat2[$dirnum][$ii]);
      $data[$dirnum][$ii] = $numerator-$denominator;
    }
  }

}
########################## SUBROUTINES ######################

sub multiply_stats{
  $mult_factor = eval($mstat);

  for($dirnum=0; $dirnum<@dirs; $dirnum++){
    for($ii=0; $ii< $num_w; $ii++){
      $data[$dirnum][$ii] *= $mult_factor;
    }
  }
}

########################## SUBROUTINES ######################

sub add_stats{
    $add_factor = eval($astat);

    for($dirnum=0; $dirnum<@dirs; $dirnum++){
        for($ii=0; $ii< $num_w; $ii++){
            $data[$dirnum][$ii] += $add_factor;
        }
    }
}
   

########################## SUBROUTINES ######################

sub print_scurve_stats{
  $scurve_stat = "IPC";
  
  for($mycore = 0; $mycore < $num_p; $mycore++){
    $stat = "CORE_". $mycore . "_" . "$scurve_stat";
    init_stats();
    get_stats();
    for($ii=0; $ii< $num_w; $ii++){
      $scurve_data[$mycore][$ii] = $data[1][$ii]/$data[0][$ii];
      @bmks = split/-/,$w[$ii];
      $mybmk = $bmks[$mycore];
      $mybmk =~ s/_00//g ;
      $mybmk =~ s/_06//g ;
      printf("%20s\t:\t%6.3f\n",$mybmk, $scurve_data[$mycore][$ii]);
    }
  }

}
   

########################## SUBROUTINES ######################

sub print_slist_stats{
    $print_amean_for_slist=0;
    $print_amean_for_slist_cols=1;
    @stats_list =  split/:/,$slist;
    $numstats = @stats_list;
    
    for($statsnum = 0; $statsnum < $numstats; $statsnum++){
      $slist_sum[$statsnum] =0;
    }


    for($statsnum = 0; $statsnum < $numstats; $statsnum++){
	$stat = $stats_list[$statsnum];
	init_stats();
	get_stats();
	for($ii=0; $ii< $num_w; $ii++){
	    $slist_data[$statsnum][$ii] = $data[0][$ii];
	    $slist_sum[$statsnum] += $data[0][$ii];
	}
    }

    # print new header
    printf("\n%20s\t", "Expts" );
    for($statsnum = 0; $statsnum < $numstats; $statsnum++){
	$stat = $stats_list[$statsnum];
	$statlen = length($stat);
	$mystring = substr($stat, ($statlen-20), 20);
	printf("%s\t", $mystring);
    }
    printf("\tAmean\t") if($print_amean_for_slist);
    printf("\n");

    # print data
    for($ii=0; $ii< $num_w; $ii++){
	$sum_stat = 0;
	$wname = $w[$ii];

	$wname =  "cactus_r"  if($wname eq "cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06-cactusADM_06");
	$wname =  "mcf_r"     if($wname eq "mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06-mcf_06");
	$wname =  "zeusmp_r"  if($wname eq "zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06-zeusmp_06");
	$wname =  "astar_r"   if($wname eq "astar_06-astar_06-astar_06-astar_06-astar_06-astar_06-astar_06-astar_06");
	$wname =  "Gems_r"    if($wname eq "GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06-GemsFDTD_06");
	$wname =  "leslie_r"  if($wname eq "leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06-leslie3d_06");
	$wname =  "soplex_r"  if($wname eq "soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06-soplex_06");
	
	$wname =  "mix1"    if($wname eq "zeusmp_06-soplex_06-omnetpp_06-leslie3d_06-GemsFDTD_06-cactusADM_06-bwaves_06-astar_06");
	$wname =  "mix2"    if($wname eq "zeusmp_06-soplex_06-omnetpp_06-mcf_06-leslie3d_06-GemsFDTD_06-bwaves_06-astar_06");
	$wname =  "mix3"    if($wname eq "soplex_06-omnetpp_06-mcf_06-leslie3d_06-GemsFDTD_06-cactusADM_06-bwaves_06-astar_06");
	
	$wname =  "mix_1"    if($wname eq "cactusADM_06-leslie3d_06-soplex_06-zeusmp_06-cactusADM_06-leslie3d_06-soplex_06-zeusmp_06");
	$wname =  "mix_2"    if($wname eq "astar_06-cactusADM_06-leslie3d_06-soplex_06-astar_06-cactusADM_06-leslie3d_06-soplex_06");
	$wname =  "mix_3"    if($wname eq "cactusADM_06-GemsFDTD_06-soplex_06-zeusmp_06-cactusADM_06-GemsFDTD_06-soplex_06-zeusmp_06");
	$wname =  "mix_4"    if($wname eq "astar_06-GemsFDTD_06-soplex_06-zeusmp_06-astar_06-GemsFDTD_06-soplex_06-zeusmp_06");
	$wname =  "mix_5"    if($wname eq "astar_06-cactusADM_06-soplex_06-zeusmp_06-astar_06-cactusADM_06-soplex_06-zeusmp_06");
	$wname =  "mix_6"    if($wname eq "astar_06-cactusADM_06-GemsFDTD_06-soplex_06-astar_06-cactusADM_06-GemsFDTD_06-soplex_06");
	
	$wname =  "bwaves_r" if($wname eq "BWaves-BWaves-BWaves-BWaves-BWaves-BWaves-BWaves-BWaves");
	$wname =  "cactus_r" if($wname eq "CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM-CactusADM");
	$wname =  "lbm_r"    if($wname eq "lbm-lbm-lbm-lbm-lbm-lbm-lbm-lbm");
	$wname =  "mcf_r"    if($wname eq "mcf-mcf-mcf-mcf-mcf-mcf-mcf-mcf");
	$wname =  "gems_r"   if($wname eq "GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD");
	$wname =  "leslie_r" if($wname eq "leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d-leslie3d");
	$wname =  "milc_r"   if($wname eq "milc-milc-milc-milc-milc-milc-milc-milc");
	$wname =  "zeusmp_r" if($wname eq "zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp-zeusmp");
	$wname =  "mix_1"    if($wname eq "GemsFDTD-GemsFDTD-mcf-mcf-milc-milc-BWaves-BWaves");
	$wname =  "mix_2"     if($wname eq "GemsFDTD-GemsFDTD-GemsFDTD-GemsFDTD-mcf-mcf-mcf-mcf");



	$wname =~ s/.lrg//g ;
	$wname =~ s/_00//g ;
	$wname =~ s/_06//g ;
	
	$wstring = substr($wname, 0, 20);

    
	printf("\n%20s\t", $wstring);

	for($statsnum = 0; $statsnum < $numstats; $statsnum++){
	    $val =  $slist_data[$statsnum][$ii];
	    $val = $val/$dstat if($dstat);
	    if($precint){
		printf("%12llu\t",$val);
	    }else{
	       printf("%6.3f\t", $val);
	    }
	    $sum_stat += $val;
	}

	if($print_amean_for_slist){
	    if($precint){
		printf("%12llu\t", $sum_stat/$numstats);
	    }else{
	       printf("%6.3f\t", $sum_stat/$numstats);
	    }
	}
    }

    if($print_amean_for_slist_cols){
        printf("\n\n%20s\t", "Amean");

        for($statsnum = 0; $statsnum < $numstats; $statsnum++){
            $val=$slist_sum[$statsnum]/$num_w;
            if($precint){
                printf("%12llu\t", $val);
            }else{
                printf("%6.3f\t", $val);
            }
        }
    }


    printf("\n");

}
   

########################## SUBROUTINES ######################

############################## COMPLEX  ###########################

sub get_cstats{

}
############################## SUB COMPLEX  ###########################


############################## IPC  ###########################
sub get_base_ipc_gem5{
    $cycle_statname = "numCycles";
    $committedinst_statname = "committedInsts";
    $cpu_name = "system.switch_cpus";

    $nstat = $cpu_name . "." . $committedinst_statname;
    $dstat = $cpu_name . "." . $cycle_statname ;
    
    # Directory for reading the base_ipc.
    $dir = $base_ipc_dir . "/";
    
    # Populate the workloads for base-ipc. 
    for($ii=0; $ii< $num_w; $ii++){
	$wname   = $w[$ii];	
	my $base_wname = $wname;
	if ($wname =~ /mix/) {
	    #Add each of the benchmarks within a mix-workload
	    for my $wname_to_add (@{$mix_wls{$wname}}){
		push @base_wnames, $wname_to_add;
	    }	    
	} else {
	    push @base_wnames, $base_wname;
	}
    }
    # Uniquify the list of base_wnames
    use List::MoreUtils qw(uniq);
    my @uniq_base_wnames = uniq @base_wnames;    
    $base_wname_count = @uniq_base_wnames; 
    # For each workload, $wname
    for($ww=0; $ww< $base_wname_count; $ww++){
	$wname   = $uniq_base_wnames[$ww];
	$fname   = $dir . $wname . "/stats.txt";

	# Read nstat (instructions)
	$readable = 1;      
	open(IN, $fname) or $readable=0;
	$found=0;
	while( ($readable) && ($found<$num_p) && ($_ = <IN>) ){
	    @words = split/\s+/, $_;
	    $num_words = scalar(@words);
          
	    for($jj=0; $jj<$num_words-1; $jj++){
		printf "$words[$jj]\n" if($debug);
              
		if($words[$jj] && ($words[$jj] =~ $nstat) ){
		    $pos = $jj+1;
		    $val = $words[$pos];
		    $temp_ndata[$ww] += $val;
		    printf "stat match for $stat found for $_" if($debug);
		    $found++;
		}
	    }          
	}
	close(IN);

	# Read dstat (cycles)
	$readable = 1;      
	open(IN, $fname) or $readable=0;
	$found=0;
	while( ($readable) && ($found<$num_p) && ($_ = <IN>) ){
	    @words = split/\s+/, $_;
	    $num_words = scalar(@words);
          
	    for($jj=0; $jj<$num_words-1; $jj++){
		printf "$words[$jj]\n" if($debug);
              
		if($words[$jj] && ($words[$jj] =~ $dstat) ){
		    $pos = $jj+1;
		    $val = $words[$pos];
		    $temp_ddata[$ww] += $val;
		    printf "stat match for $stat found for $_" if($debug);
		    $found++;
		}
	    }          
	}
	close(IN);

	##Calculate the base_ipc if available and add it to base_ipc list.
	if($temp_ddata[$ww]) {
	    $base_ipc_wl = $temp_ndata[$ww] / $temp_ddata[$ww] ;
	    $base_ipc_gem5{$wname} = $base_ipc_wl;	    
	}
    }
}

sub get_ipc_stats{

    ## Define variable name for cycles, inst, cpu-name
    $cycle_statname = "numCycles";
    $committedinst_statname = "committedInsts";
    $cpu_name = "system.switch_cpus";

    # Caclulate IPC for each core.
    for(my $i = 0; $i < $numcores; $i++){
	$curr_cpu = $cpu_name ;
	if($numcores > 1) {
	    $curr_cpu = $cpu_name . $i;
	}
        # Divide inst/cycles for each core
	$nstat = $curr_cpu . "." . $committedinst_statname;
	$dstat = $curr_cpu . "." . $cycle_statname ;
	get_nstats(); 
	get_dstats() ;
	divide_n_by_d();
	
	# Save the IPC (data[DIR][WL]) for each core i
	for($dirnum=0; $dirnum<@dirs; $dirnum++){
	    for($ii=0; $ii< $num_w; $ii++){
		$data_ipc[$i][$dirnum][$ii] = $data[$dirnum][$ii];
	    }
	}
    }
    
    # For weighted-speedup:
    if($ws){	
	die "Base IPC Directory unspecified (-b) \n"
	    unless $base_ipc_dir;

	# Get single_prog_ipc for each workload.
	get_base_ipc_gem5();
	
        # Print the base_ipc
	print "Printing base_ipc_gem5 \n" if($debug);
	foreach $key (keys %base_ipc_gem5){
	    print "$key base_ipc $base_ipc_gem5{$key}\n" if($debug);
	}

	# Divide data_ipc by base_ipc: For each directory
	for($dirnum=0; $dirnum<@dirs; $dirnum++){
	    # For each workload
	    for($ii=0; $ii< $num_w; $ii++){
		$wname   = $w[$ii];
		print $wname . ":" if ($debug);
		# For each core
		for(my $i = 0; $i < $numcores; $i++){	                       
		    $base_ipc_wname = $wname;
		    {
			no warnings 'once';
			$base_ipc_wname = $mix_wls{$wname}[$i] if ($wname =~ /mix/) ;
		    }
		    print $base_ipc_wname . "-" if ($debug);
		    # Divide data_ipc by base_ipc
		    $data_ipc[$i][$dirnum][$ii] = $data_ipc[$i][$dirnum][$ii] / $base_ipc_gem5{$base_ipc_wname} if($base_ipc_gem5{$base_ipc_wname});
		}
		print "\n" if ($debug);
	    }
	}
    }

    # Reset nstat and dstat
    $nstat="";
    $dstat="";
   
    # Sum IPC of each of the cores.
    for($dirnum=0; $dirnum<@dirs; $dirnum++){
	for($ii=0; $ii< $num_w; $ii++){
	    #Initialize the data to 0.	    
	    $data[$dirnum][$ii] = 0 ;
	    # Add each core's data.
	    for(my $i = 0; $i < $numcores; $i++){	                       
		$data[$dirnum][$ii] += $data_ipc[$i][$dirnum][$ii];
	    }
	}
    }
    
    # for($dirnum=0; $dirnum<@dirs; $dirnum++){
    #	for($ii=0; $ii< $num_w; $ii++){
    #	    print $data[$dirnum][$ii] ; #Initialize the data to 0.
    #	}
    # }
}





