#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-09-12
# @package Plack Twiggy PWA
# @subpackage /t/test_controller.t



use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);

use Test::More;
use Plack::Test;
use Plack::Util qw(load_psgi);
use HTTP::Request;

use JSON qw(decode_json);



#------------------------
#Load Controller

#Mark for using Test Environment
$ENV{'PLACK_ENV'} = 'test';


my $smaindir = dirname(dirname( abs_path(__FILE__) ));
my $test_web = Plack::Util::load_psgi($smaindir . '/scripts/web.psgi');


#------------------------
#Build Test Site

my $test = Plack::Test->create($test_web);



subtest 'home' => sub {
  #------------------------
  #Test Home Page

  my $url     = "/";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);


  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'text/html', "Content-Type: 'HTML'");

  isnt index($res->content, '</html>'), -1, 'Page is complete';
  ok $res->content =~ qr/plack twiggy pwa/i, 'Project Title is present';

};  #subtest 'home'


subtest 'manifest' => sub {
  #------------------------
  #Test PWA Manifest

  my $url     = "/manifest.json";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);
  my $content = undef;


  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  is ref($content), 'HASH', 'response is a JSON object';
  isnt $content->{'name'}, undef, "Manifest has Field 'name'";
  isnt $content->{'short_name'}, undef, "Manifest has Field 'short_name'";
  is $content->{'name'}, 'Plack Twiggy PWA', "Manifest - Field 'name' is 'Plack Twiggy PWA'";

};  #subtest 'manifest'


subtest 'ServiceWorker' => sub {
  #------------------------
  #Test Home Page

  my $url     = "/service-worker";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);


  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/javascript', "Content-Type: 'JavaScript'");

  ok $res->content =~ qr/Version Request done/i, 'Script is complete';
  ok $res->content =~ qr/var staticDevCoffee/i, 'Static Cache Key is present';

};  #subtest 'ServiceWorker'


subtest 'no-page' => sub {
  #------------------------
  #Test Non Existent Page

  my $url     = "/no-page";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);
  my $content = undef;


  ok( $res, "GET $url" );
  is( $res->code, 404, "Status Code [404] as expected" );
  is($res->header('content-type'), 'text/html', "Content-Type: 'HTML'");

  isnt index($res->content, '</html>'), -1, 'Page is complete';
  ok $res->content =~ qr/Error 404: Not Found/i, "Error Title 'Error 404' is present";

};  #subtest 'no-page'


done_testing;
