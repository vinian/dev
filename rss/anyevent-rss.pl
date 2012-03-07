#!/usr/bin/perl
# use anyevent for nonblock getting rss
# it's not finished so he can't run

use strict;
use warnings;

use Smart::Comments;

use Encode qw(encode decode);

use XML::Simple;
use AnyEvent::HTTP;

my $xml_file = shift;

die "Usage: $0 rss-xml-file\n" if ( not defined $xml_file );

my $ref = XMLin( $xml_file, ForceArray => 1 );

my $data_body = $ref->{body};

my $result = xml_parse( $data_body );

sub xml_parse {
	my $data = shift;

	my $type = ref $data;
	my @parseResult;

	if ( $type eq 'ARRAY' ){
		foreach my $item ( @$data ){
			my $middle = xml_parse( $item );
			push @parseResult, $middle;
		}
	}
	elsif( $type eq 'HASH' ) {
		my @found_keys = keys %$data;

		if ( grep { /outline/ } @found_keys ) {
			xml_parse( $data->{outline} );
		}
		else {
			push @parseResult, $data;
		}
	}

	return \@parseResult;
}
