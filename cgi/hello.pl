#!perl.exe
#!/usr/bin/perl
use Data::Dumper;
use Template;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use strict;
use lib 'C:/ram/perl/Ram';
use lib '/home/ram/perl/myperls';
use Ram::Sudoku;

print "Content-type: text/plain\n\n";
print "Hello world\n";
