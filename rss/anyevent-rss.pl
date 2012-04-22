#!/usr/bin/env perl

use strict;
use warnings;

use Smart::Comments;

use XML::OPML;
use AnyEvent::HTTP;

my $opml_file = shift;

usage() if not defined $opml_file;

my $opml      = new XML::OPML;
my $opml_data = $opml->parse( $opml_file );

my @rss_urls;
foreach my $item ( @$opml_data ) {
  my $rss_items = parse_opml( $item );
  push @rss_urls, @$rss_items;
}

my $method = 'GET';

foreach my $rss_task ( @rss_urls ) {
  my $request_url = $rss_task->{xmlUrl};
  print "Get $request_url\n";
  my $reqs = http_request( $method => $request_url, sub {
				  my ($data, $hdr) = @_;
				  print $hdr->as_string, "\n";
				}
			  );
  undef $reqs;
}

sub handler {
  my ($data, $hdr) = @_;
  if ( $hdr->{Status} =~ /^2/ ) {
	print "OK!\n";
  }
  else {
   print "Not OK: $hdr->{Status}!\n";
  }
}

sub usage {
  print "Usage:\n$0 ompl-file\n";
  exit 1;
}

sub parse_opml {
  my $data = shift;

  my $ref_type = ref $data;

  my @rss;
  if ( $ref_type eq 'HASH' ) {
	if ( exists $data->{type} ) {
	  push @rss, $data;
	}
	else {
	  foreach my $sub_item ( keys %$data ) {
		if ( ref $data->{$sub_item} eq 'HASH' ) {
		  if ( exists $data->{$sub_item}->{type} ) {
			push @rss, $data->{$sub_item};
		  }
		}
	  }
	}
  }

  return \@rss;
}
