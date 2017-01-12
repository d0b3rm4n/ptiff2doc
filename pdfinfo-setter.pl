#!/usr/bin/perl
#
# Copyright (C) 2017 - Reto Zingg <g.d0b3rm4n@gmail.com>
#
# This file is part of ptiff2doc
#
# ptiff2doc is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# ptiff2doc is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

use warnings;
use PDF::API2;
use utf8;
use Getopt::Long qw(GetOptions);
use Encode::Locale;
use Encode;
use Date::Format;

@ARGV = map { decode(locale => $_, 1) } @ARGV;

my $author = $title = $subject = $keywords = "";
my $help = 0;

sub usage {
    my $exitcode = shift(@_);

    print<<"END_TXT";

    Perl script to set the PDF metadata in a .pdf file, depends on PDF::API2

    Usage: $0 [OPTIONS] file.pdf

    Options [default value]:
        -h | --help         This help
        -a | --author       Author to be set in .pdf []
        -t | --title        Title to be set in .pdf []
        -s | --subject      Subject to be set in .pdf []
        -k | --keywords     Keywords to be set in .pdf []
    
END_TXT

    exit $exitcode;
};

GetOptions(
    'help|h'       => \$help,
    'author|a=s'   => \$author,
    'title|t=s'    => \$title,
    'subject|s=s'  => \$subject,
    'keywords|k=s' => \$keywords
) or usage(1);

if ($help) {usage(0);}
if (not $ARGV[0]) {
    print "\n\nPDF file name is required!\n\n";
    usage(1);
};

my $pdf_file = $ARGV[0];

my $date = time2str("%Y%m%d%H%M%S%z", time());
$date =~ s/(..$)/'$1'/;

$pdf = PDF::API2->open($pdf_file);

$pdf->info(
        "Author"       => $author,
        "CreationDate" => $date,
        "ModDate"      => $date,
        "Creator"      => "ptiff2doc",
        "Producer"     => "PDF::API2",
        "Title"        => $title,
        "Subject"      => $subject,
        "Keywords"     => $keywords
);

$pdf->saveas($pdf_file);

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
