<?php
$alpha = 'CC';
$colors = array(
    '#ff5c00' . $alpha,
    '#0000ff' . $alpha,
    '#FFDB87' . $alpha,
    '#25345C' . $alpha,
    '#88008A' . $alpha,
    '#4F7774' . $alpha,
);

$ds_name[1] = "Check Nowsms Status";
$opt[1] = sprintf('-T 55 -l 0 --vertical-label "number" --title "%s / Nowsms"', $hostname);
$def[1] = '';
$count = 0;

foreach ($DS as $i) {
    $def[1]  .=  rrd::def("var$i", $RRDFILE[$i] , $DS[$i], "AVERAGE") ;
    $def[1] .= rrd::line2("var$i", $colors[$count],rrd::cut(ucfirst($NAME[$i]), 25)) ;
    $def[1] .= rrd::gprint  ("var$i", array('LAST','MAX','AVERAGE'), "%6.2lf");
    $count++;
}
?>