#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-06-05
# @package Plack Twiggy PWA Web
# @subpackage /scripts/web.psgi

# This Module creates the callable Function to respond to Plack Requests.
# This is the Entry Point of the Web Site.
#
#---------------------------------
# Requirements:
# - The Perl Module "Plack" must be installed
# - The Perl Module "Twiggy" must be installed
# - The Perl Module "Template" must be installed
#
#---------------------------------
# Features:
# - Create ServiceWorker Script from Template
# - Create PWA Manifest from Template
# - Render Error Page as HTML
#



use warnings;
use strict;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use Data::Dump qw(dump);

use AnyEvent;
use Plack::Builder;
use Plack::Request;
use Template;


#----------------------------------------------------------------------------
#Auxiliary Functions


sub render_template_html
{
  my ($webroot, $smodulename, $rvars) = @_;
  my $pageheader = "includes/header_${smodulename}.tt";


  $pageheader = "includes/header.tt" unless(-f $webroot . '/tt/' . $pageheader);


  my $tt = Template->new(
    INCLUDE_PATH => "${webroot}/tt",
    INTERPOLATE  => 1,
    POST_CHOMP   => 1,
    EVAL_PERL    => 1,
    #START_TAG    => '<%',
    #END_TAG      => '%>',
    PRE_PROCESS  => $pageheader,
    POST_PROCESS => 'includes/footer.tt',
  );
  my $out;


  $tt->process( "${smodulename}.tt", $rvars, \$out )
    || die $tt->error();


  return \$out
}

sub render_template_headless
{
  my ($webroot, $smodulename, $rvars) = @_;


  my $tt = Template->new(
    INCLUDE_PATH => "${webroot}/tt",
    INTERPOLATE  => 1,
    POST_CHOMP   => 1,
    EVAL_PERL    => 1,
    #START_TAG    => '<%',
    #END_TAG      => '%>',
  );
  my $out;


  $tt->process( "${smodulename}.tt", $rvars, \$out )
    || die $tt->error();


  return \$out
}




#----------------------------------------------------------------------------
#Executing Section

my $webroot = dirname(dirname( abs_path(__FILE__) ));
my $svmainpath = '/';

my $app = sub {
  my $env = shift;
  my $request = Plack::Request->new($env);


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/'
    || $request->path_info() eq '/index.html')
  {
    #------------------------
    #Index Page

    return sub {
      my $responder = shift;
      my $writer = $responder->([ 200, [ 'Content-Type', 'text/html' ]]);
      my $watcher;
      my $rhshtmpldata = {'pagetitle' => 'Plack Twiggy PWA'
        , 'projectname' => 'Plack Twiggy PWA'
        , 'vmainpath' => $svmainpath
      };

      my $fwriteIndexPage = sub {
        #------------------------
        #HTML Render Callback

        my $message = shift;
        my $rsout = undef;


        eval
        {
          #Render the HTML Template
          $rsout = render_template_html($webroot, 'index', $rhshtmpldata);
        };

        if($@)
        {
          $rsout = undef;
        }

        if(defined $rsout)
        {
          #Print the rendered HTML
          $writer->write($$rsout);
        }

        $writer->write("Finishing: $message\n");
        $writer->close;

      };  #$fwriteIndexPage


     $writer->write("Starting: ${\scalar(localtime)}\n");

     $watcher = AnyEvent->timer(
      after => 0,
      cb => sub {
        $fwriteIndexPage->(scalar localtime);
        undef $watcher; # cancel circular-ref
      });

    };
  }
  elsif($request->path_info() eq '/manifest.json')
  {
    #------------------------
    #Manifest Page

    return sub {
      my $responder = shift;
      my $writer = $responder->([ 200, [ 'Content-Type', 'application/json' ]]);
      my $watcher;
      my $rhshtmpldata = {'projectname' => 'Plack Twiggy PWA'
        , 'projectcodename' => 'PlackPWA'
        , 'vmainpath' => $svmainpath
      };

      my $frwriteManifest = sub {
        #------------------------
        #HTML Render Callback

        my $rsout = undef;


        eval
        {
          #Render the Template
          $rsout = render_template_headless($webroot, 'manifest', $rhshtmpldata);
        };

        if($@)
        {
          $rsout = undef;
        }

        if(defined $rsout)
        {
          #Print the rendered HTML
          $writer->write($$rsout);
        }

        $writer->close;

      };  #$frwriteManifest

     $watcher = AnyEvent->timer(
      after => 0,
      cb => sub {
        $frwriteManifest->();
        undef $watcher; # cancel circular-ref
      });

    };
  }
  elsif($request->path_info() eq '/service-worker')
  {
    #------------------------
    #Service Worker Script

    return sub {
      my $responder = shift;
      my $writer = $responder->([ 200, [ 'Content-Type', 'text/javascript' ]]);
      my $watcher;
      my $rhshtmpldata = {'sversion' => '0.0.2', 'vmainpath' => $svmainpath};

      my $fwriteServiceWorkerScript = sub {
        #------------------------
        #HTML Render Callback

        my $rsout = undef;


        eval
        {
          #Render the Template
          $rsout = render_template_headless($webroot, 'service-worker', $rhshtmpldata);
        };

        if($@)
        {
          $rsout = undef;
        }

        if(defined $rsout)
        {
          #Print the rendered HTML
          $writer->write($$rsout);
        }

        $writer->close;

      };  #$fwriteServiceWorkerScript

     $watcher = AnyEvent->timer(
      after => 0,
      cb => sub {
        $fwriteServiceWorkerScript->();
        undef $watcher; # cancel circular-ref
      });

    };
  } #if($request->path_info() eq '/')


  #------------------------
  #Any other Page: Not Found Error

  return sub {
    #------------------------
    #Error Page

    my $responder = shift;
    my $writer = $responder->([ 404, [ 'Content-Type', 'text/html' ]]);
    my $watcher;
    my $rhshtmpldata = {'pagetitle' => 'Plack Twiggy - Error'
      , 'vmainpath' => $svmainpath
      , 'statuscode' => 404
      , 'errormessage' => 'Not Found.'
      , 'errordescription' => 'The Page does not exist.'
    };

    my $fwriteErrorPage = sub {
      #------------------------
      #HTML Render Callback

      my $rsout = undef;


      eval
      {
        #Render the HTML Template
        $rsout = render_template_html($webroot, 'error', $rhshtmpldata);
      };

      if($@)
      {
        $rsout = undef;
      }

      if(defined $rsout)
      {
        #Print the rendered HTML
        $writer->write($$rsout);
      }

      $writer->close;

    };  #$fwriteErrorPage


   $watcher = AnyEvent->timer(
    after => 0,
    cb => sub {
      $fwriteErrorPage->();
      undef $watcher; # cancel circular-ref
    });

  };
};  #$app



#----------------------------------------------------------------------------
#URL Mapping


builder {
  #Graphic Elements Mapping
  enable "Static", path => qr#^/(images|css|js|html)#, root => $webroot;
  #Any other Content
  $app;
}



