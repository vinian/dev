#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use YAML::Syck;

use File::Slurp;

my ($input, $output) = @ARGV;

if (not defined $input or not defined $output) {
    print "Usage: $0 input output\n";
    exit 1;
}

if ( $input =~ /json/ ) {
    my $text = read_file($input);
    my $perl_data = from_json( $text, { utf8 => 1 } );
    YAML::Syck::DumpFile($output, $perl_data);
} elsif ( $input =~ /yaml/ ) {
    my $data = YAML::Syck::LoadFile( $input );
    write_file( $output, to_json($data));
}
