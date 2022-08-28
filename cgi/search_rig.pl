#!/usr/bin/perl
use Data::Dumper;
use Template;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use strict;
use JSON;
require DBD::mysql;
my $dbh = DBI->connect("dbi:mysql:rigveda:localhost:3306","root","") || die;
print "Content-type: application/json\n\n";
my $q=new CGI;
my $term= process_lines($q->param("term"));
my $arr = $dbh->selectcol_arrayref("select instring from rgindex where instring like '$term%'");
print JSON::encode_json($arr);


sub process_lines {
    my($ind)=@_;
    $ind=~s/[q# ]//g;
    $ind=~s/A/aa/g;
    $ind=~s/I/ee/g;
    $ind=~s/U/oo/g;
    $ind=~s/^(.{50}).*$/$1/;
    return($ind);
    
}
