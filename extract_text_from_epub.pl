#!/usr/bin/perl

use 5.014;

use HTML::TagParser;
use File::Temp qw(tempdir);

use File::Basename;


my ($file, $text_file) = @ARGV;

if (not defined $file or $file !~ /epub$/) {
    say "Usage: $0 file.epub [output]";
    exit 1;
}

if (not defined $text_file) {
    my ($name, $path, $suffix) = fileparse($file, '.epub');
    $text_file = "$name.txt";
}

if (not -e $file) {
    say "file: $file not existed.";
    exit 2;
}

my $tmp_dir = tempdir( CLEANUP => 1);
`unzip $file -d $tmp_dir`;
my @htmls = glob("$tmp_dir/OEBPS/Text/*xhtml");


open my $fh, '>', $text_file
    or die "Can't open $text_file: $!";
for my $page (
    sort {
        my ($a_num) = $a =~ /s(\d+)\.xhtml/;
        my ($b_num) = $b =~ /s(\d+)\.xhtml/;
        $a_num <=> $b_num;
    } @htmls) {

    my $html = HTML::TagParser->new( $page );
    for my $div ( $html->getElementsByTagName('div') ) {
        my $text = $div->innerText;
        print $fh $text;
    }
}

close $fh;
