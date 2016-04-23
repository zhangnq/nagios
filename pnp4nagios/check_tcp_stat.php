<?php
#
# Copyright (c) 2006-2010 Joerg Linge (http://www.pnp4nagios.org)
# Plugin: check_tcp_stat.php
#
#
/***
$ds_name[1] = "Check Network";
$opt[1]  = "--lower-limit 0 --vertical-label \"Check Network\"  --title \"Check Network\" ";
$def[1]  =  rrd::def("var1", $RRDFILE[1], $DS[1], "AVERAGE") ;
$def[1] .=  rrd::gradient("var1", "ff5c00", "ffdc00", "Check Network", 10) ;
$def[1] .=  rrd::gprint("var1", array("LAST", "MAX", "AVERAGE"), "%.0lf $UNIT[1]") ;
$def[1] .=  rrd::line1("var1", "#000000") ;

$def[1]  =  rrd::def("var2", $RRDFILE[2], $DS[2], "AVERAGE") ;
$def[1] .=  rrd::gradient("var2", "ff5d00", "ffdc00", "Check Network", 10) ;
$def[1] .=  rrd::gprint("var2", array("LAST", "MAX", "AVERAGE"), "%.0lf $UNIT[2]") ;
$def[1] .=  rrd::line1("var2", "#000000") ;

if($WARN[1] != ""){
        if($UNIT[1] == "%%"){ $UNIT[1] = "%"; };
        $def[1] .= rrd::hrule($WARN[1], "#FFFF00", "Warning  ".$WARN[1].$UNIT[1]."\\n");
}
if($CRIT[1] != ""){
        if($UNIT[1] == "%%"){ $UNIT[1] = "%"; };
        $def[1] .= rrd::hrule($CRIT[1], "#FF0000", "Critical ".$CRIT[1].$UNIT[1]."\\n");
}
***/


$alpha = 'CC';
$colors = array(
    '#ff5c00' . $alpha,
    '#0000ff' . $alpha,
    '#FFDB87' . $alpha,
    '#25345C' . $alpha,
    '#88008A' . $alpha,
    '#4F7774' . $alpha,
);
$opt[1] = sprintf('-T 55 -l 0 --vertical-label \"Check Network\" --title "%s / Check Network"', $hostname);
$def[1] = '';
$count = 0;

foreach ($DS as $i) {
    $def[1]  .=  rrd::def("var$i", $RRDFILE[$i] , $DS[$i], "AVERAGE") ;
    $def[1] .= rrd::line1("var$i", $colors[$count],rrd::cut(ucfirst($NAME[$i]), 15)) ;
    $def[1] .= rrd::gprint  ("var$i", array('LAST','MAX','AVERAGE'), "%.0lf %s\\t");
    $count++;
}

/*
if($WARN[1] != ""){
        if($UNIT[1] == "%%"){ $UNIT[1] = "%"; };
        $def[1] .= rrd::hrule($WARN[1], "#FFFF00", "Warning  ".$WARN[1].$UNIT[1]."\\n");
}
if($CRIT[1] != ""){
        if($UNIT[1] == "%%"){ $UNIT[1] = "%"; };
        $def[1] .= rrd::hrule($CRIT[1], "#FF0000", "Critical ".$CRIT[1].$UNIT[1]."\\n");
}
*/
?>
