#!/usr/bin/perl
# vim: set et sta ts=4 sw=4 sts=4:
# vi: set ts=4:
# #
use strict;
use warnings;

use Devel::Comments;

use JSON;

use LWP::ConnCache;
use LWP::UserAgent;

my $method = 'GET';
my $url    = 'http://ifconfig.me/all.json';

my $timeout = 30;

my $cache = LWP::ConnCache->new();
my $ua    = LWP::UserAgent->new( conn_cache => $cache );
$ua->timeout( $timeout );

my $request = HTTP::Request->new( $method => $url );

my $response = $ua->request( $request );

my $perl_scalar;
if ($response->is_success) {
    $perl_scalar = from_json( $response->decoded_content, { utf8  => 1 } );
    print "Your Ip Address: ", $perl_scalar->{ip_addr}, "\n"; 
}
else {
    die $response->status_line;
}

