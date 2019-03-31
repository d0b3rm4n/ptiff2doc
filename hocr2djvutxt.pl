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
use Log::Log4perl qw(:easy);
use Gscan2pdf::Page;
use File::Slurp;
use File::Temp qw/ tempdir /;
use File::Basename;
my $dirname = dirname(__FILE__);

Log::Log4perl->easy_init($ERROR);
$logger = Log::Log4perl::get_logger();

Gscan2pdf::Page->set_logger($logger);

my $hocr_file = $ARGV[0];
my $dummy_file = $dirname . "/dummy.tif";
my $djvutxt_file = $ARGV[0].".djvutxt_file";

my $tmpdir = tempdir('hocr2djvutxt.XXXXXXXXX', CLEANUP => 1);

my $gs_page = Gscan2pdf::Page->new(
    filename => $dummy_file,
    dir      => $tmpdir,
    delete   => 0,
    format   => 'Tagged Image File Format',
);

$gs_page->{hocr} = read_file($hocr_file);

open(DJVUTXT, ">", $djvutxt_file);
print DJVUTXT $gs_page->djvu_text();
close(DJVUTXT);

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
