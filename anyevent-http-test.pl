#!/usr/bin/perl
# anyevent for http test

use warnings;
use strict;

use Smart::Comments;

use Time::HiRes qw(time);

use AnyEvent;
use AnyEvent::HTTP;

my $scheme = 'https?';
my $ip     = 'ipaddr';
my $port   = 'port';
my $path   = '/path/to/resquest';
my $query  = 'parmas';

my $url = $scheme. '://'. $ip. ':'. $port. $path . '?'. $query;

my $cv = AnyEvent->condvar;
my $start = time;

my $result;
$cv->begin( sub { shift->send($result) } );

my $count = 0;
my $max   = 2;
my $timeout = 2;

while ( $count++ < $max ) {
    $cv->begin;

    my $now = time;
    my $request;  
    $request = http_request(
            GET     => $url, 
            timeout => $timeout,
            sub {
                my ($body, $hdr) = @_;
                push @$result, [ $url, $hdr->{Status}, $hdr->{Reason} ];
                undef $request;
                $cv->end;
            }
    );
}

$cv->end;

my $foo = $cv->recv;
### $foo
# find the non 2xx status code and retry resquest

print "Total elapsed time: ", time-$start, "ms\n";
