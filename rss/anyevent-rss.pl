#!/usr/bin/env perl

use strict;
use warnings;

use Smart::Comments;

use XML::OPML;
use XML::Simple;

use AnyEvent;
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

my $cv = AnyEvent->condvar(
   cb => sub {
	 warn "done";
   },
);

my $result;
$cv->begin( sub { shift->send( $result )} );

foreach my $rss_task ( @rss_urls ) {
  $cv->begin;
  my $request;
  my $request_url = $rss_task->{xmlUrl};
  $request = http_request(
	GET        => $request_url,
	timeout    => 10,
	sub {
	  my ($body, $hdr) = @_;
	  if ( $hdr->{Status} =~ /^2/ ) {
		my $data;
		eval {
		  $data = XMLin( $body );
		  };
		if ( $@ ) {
		  print $@;
		}
		else {
		  ### $data
		}
	  }
	  else {
	   ### 48: $hdr->{Status}, $hdr->{Reason}
	  }

	  undef $request;
	  $cv->end;
	}
  );
}

$cv->end;
warn "End of loop.\n";
my $foo = $cv->recv;
if ( defined $foo ) {
  print foreach @$foo;
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
