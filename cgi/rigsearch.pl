#!/usr/bin/perl
use Data::Dumper;
use Template;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use JSON;
use strict;
require DBD::mysql;
my $dbh = DBI->connect("dbi:mysql:rigveda:localhost:3306","root","") || die;
my $q=new CGI;
my $term= process_lines($q->param("term"));
if($term) { 
    print "Content-type: application/json\n\n";
    my $arr = $dbh->selectcol_arrayref("select instring from rgindex where instring like '$term%' limit 100");
    print JSON::encode_json($arr);
    exit;
}
print "Content-type: text/html\n\n";

my %tag;
my $rig = $q->param("rig");
if($rig){
    my ($s,$mandala,$sooktha) = ($rig=~m/^((\d+)\.(\d+)\.)\d+$/);
    my $d = $dbh->selectcol_arrayref("select devnagari from rgindex where rig like '$s%' limit 100");
    $tag{sooktha} = join("<br/>\n",@$d);
    ($tag{snext},$tag{sprev})=get_sooktha($dbh,$mandala,$sooktha);
} 



my $sterm=process_lines($q->param("sterm"));
if($sterm) {
    $tag{sterm}=$sterm;
    my $d = $dbh->selectall_arrayref("select rig,devnagari from rgindex where instring like '$sterm%' limit 100");
    foreach (@$d){
	$tag{devn}->[$tag{count}++] = { rig=> $_->[0], devnagari=>$_->[1] };
    }
}
#print Dumper([$tag{devn}]); exit;
my $tt = new Template;
$tt->process(\*DATA,\%tag) || die $tt->error();

sub get_sooktha {
    my ($dbh,$mandala,$sooktha) = @_;
    print "select n_mandala,n_sooktha from sindex where mandala=$mandala AND sooktha=$sooktha";
    my $dnext = $dbh->selectall_arrayref("select n_mandala,n_sooktha from sindex where mandala=$mandala AND sooktha=$sooktha");
    my $dprev = $dbh->selectall_arrayref("select mandala,sooktha from sindex where n_mandala=$mandala AND n_sooktha=$sooktha");
    
    return(sprintf("%d.%03d.01",@{$dnext->[0]}),sprintf("%d.%03d.01",@{$dprev->[0]}));
}

sub gen_rig {
    return ;
}
		


sub process_lines {
    my($ind)=@_;
    $ind=~s/[q# ]//g;
    $ind=~s/A/aa/g;
    $ind=~s/I/ee/g;
    $ind=~s/U/oo/g;
    $ind=~s/^(.{50}).*$/$1/;
    return($ind);
    
}



__DATA__
<HTML>
<title> Search Rigveda </title>
<HEAD>
<meta charset="utf-8">
      <title>jQuery UI Autocomplete functionality</title>
      <link href="http://code.jquery.com/ui/1.10.4/themes/ui-lightness/jquery-ui.css" rel="stylesheet">
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
      <script src="http://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
      <!-- Javascript -->
      <script>
       $(function() {
            $( "#autocomplete-5" ).autocomplete({
               source: "/rambin/rigsearch.pl",
               minLength: 2
            });
         });
      </script>
    </HEAD>
<body>
Search Rigveda
<br/><br/><br/>
<form>
Search <input name=sterm id="autocomplete-5" value="[% sterm %]">
<input type=submit value="Search">    <input type=button value=clear onClick="sterm.value=''" >
</form>

[% IF sooktha %]
<p>
<font face="Mangal">
[% sooktha %]
</font>
</p>
<a href="/rambin/rigsearch.pl?rig=[% sprev %]"> Previous </a>

 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
<a href="/rambin/rigsearch.pl?rig=[% snext %]"> Next </a>
[% END %]
<br/><br/><br/>
[% IF count > 0 %]
<ol>
[% FOREACH item IN devn %]
<li><font face="Mangal">[% item.devnagari %]</font> 
<a href="/rambin/rigsearch.pl?rig=[% item.rig %]"> Go </a>
[% END %]
</ol>
[% END %]
</body>
</html>



