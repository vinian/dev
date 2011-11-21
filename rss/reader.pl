#!/usr/bin/perl
# vim: set et sta ts=4 sw=4 sts=4:
# vi: set ts=4:
# #
use strict;
use warnings;

use Devel::Comments;
use Data::Dumper; use LWP::UserAgent;
use XML::OPML;
use XML::RSS;

my $opml = new XML::OPML;

my $opml_file = shift;
$opml->parse( $opml_file );

my $content = $opml->outline;
my $agent   = 'lwp/0.10';
my $timeout = 50;

my $html_file = './test.html';
open my $html_handle, '>', $html_file
    or die $!;
print $html_handle <<"HTML";
<html>
    <title>rssreader</title>
    <body>
HTML

foreach my $rss_info ( @$content ){
    my $url = $rss_info->{xmlUrl};
    my $ua  = LWP::UserAgent->new();

    $ua->timeout( $timeout );
    my $res = $ua->get( $url );

    my $rss = XML::RSS->new();
    $rss->parse( $res->content );

    if ( @{ $rss->{items} } ){
       foreach my $feeds ( @{ $rss->{items} } ){
           print $html_handle "<a href=$feeds->{link}>$feeds->{title}</a><br>\n"; 
       } 
    } 
}

print $html_handle <<"HTML";
    </body>
</html>
HTML
