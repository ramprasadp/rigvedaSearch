#!perl.exe
#
# Generate the panchanga
#
use Data::Dumper;
use Template;
use Time::ParseDate;
use POSIX;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
require DBI;
require DBD::mysql;
use strict;
use Storable;


my %tag;
my $dbh = DBI->connect("dbi:mysql:panchanga:localhost:3306","root","") || die;
my $tt = new Template;
my $q = new CGI;
my $t = $q->param('time') || time();
my $time = Time::ParseDate::parsedate(POSIX::strftime('%Y/%m/01',localtime($t)));
my $date = POSIX::strftime("%Y-%m-%%",localtime($time));
$tag{'month'}=POSIX::strftime("%b %Y",localtime($time));
print "Content-type: text/html\n\n";
my $rec = $dbh->selectall_arrayref("select pdate,weekday,thiti,nakshatra,yoga,karna from panchanga where pdate like '$date'");
my @wk = qw(Sun Mon Tue Wed Thu Fri Sat);
my $day=1;
my %daterec;
my $p = shift(@$rec);
my @records = ();
while(@$rec) { 
    foreach my $weekday(@wk){
#	print "Weekday $weekday ". $p->[1] . "\n";
	next unless($weekday eq $p->[1]);
	$daterec{$weekday}=format_date($p);
	$p=shift(@$rec);
    }
    push @records , Storable::dclone(\%daterec);
#    print Dumper(\%daterec);
    %daterec=();
    
}
#print Dumper(@records);
$tag{next} = Time::ParseDate::parsedate("1 month",NOW => $time);
$tag{prev} = Time::ParseDate::parsedate("-1 month",NOW => $time);
$tag{RECORDS}=\@records;
$tt->process(\*DATA,\%tag);

sub format_date {
    my($p)=@_;
    my $date = $p->[0];
    $date =~s/^\d\d\d\d\-\d\d\-//;
    my $thiti= $p->[2];
    my $nakshatra = $p->[3];
    my $yoga = $p->[4];
    my $karna = $p->[5];
    my $ret = "<b>$date</b><br/>$thiti<br/>$nakshatra<br/>$yoga<br/>$karna";
    return $ret;
}
    



#print Dumper(\%tag); exit;



__DATA__
<HTML>
<HEAD>
    <title>Panchanga for month [% month %]</title>
    <style>
        p {
          background-color: yellow;
	  color: red;
          }
        table
        {
            margin:10px 0;
            border:solid 2px #333;
            padding:2px 4px;
            border-color:#111;
        }
        td {
            border:solid 1px #333;
            font:15px Verdana;
        }
       
   .nostyle {
    margin: 0;
    border: 0;
    }
    </style>

  </HEAD>
  <body>
   <center> <a href=/rambin/panchanga.pl?time=[% prev %]> Prev </a>  <bold> &nbsp; &nbsp; &nbsp; &nbsp; [% month %] &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</bold><a href=/rambin/panchanga.pl?time=[% next %]> Next </a> </center>
    <table width=100% >
    <tr>
<th>    Sun </th>
<th>	Mon </th>
<th>	Tue </th>
<th>	Wed </th>
<th>	Thu </th>
<th>	Fri </th>
<th>	Sat </th>
</tr>
[% FOREACH item = RECORDS - %]
<tr>
<td>    [% item.Sun %] </td>
<td>	[% item.Mon %] </td>
<td>	[% item.Tue %] </td>
<td>	[% item.Wed %] </td>
<td>	[% item.Thu %] </td>
<td>	[% item.Fri %] </td>
<td>	[% item.Sat %] </td>
</tr>
[% END %]



</table>
 </body>
</html>


