#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-09-04
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

use POSIX qw(strftime);
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use Data::Dump qw(dump);

use YAML;

use AnyEvent;
use Twiggy::Server;
use Plack::Builder;
use Plack::Request;
use Template;



#----------------------------------------------------------------------------
#Auxiliary Functions


sub  loadConfiguration
{
  my $smndir = $_[0];
  my $scnfdir = $smndir . '/config/';
  my $scomp = $ENV{'COMPONENT'} || 'default';
  my $splkenv = $ENV{'PLACK_ENV'} || 'deployment';
  my $scnfhstnm = '';
  my $scnfflnm = '';
  my $scnfext = '.yml';
  my $rscnf = undef;


  $scnfhstnm = $scomp;
  $scnfhstnm =~ tr/\./-/;

  $scnfdir = $smndir . '/' unless(-d $scnfdir);

  $scnfflnm = $scnfhstnm . '-' . $splkenv . $scnfext;

  $scnfflnm = $scnfhstnm . $scnfext unless(-f $scnfdir . $scnfflnm);

  $scnfflnm = 'default' . $scnfext unless(-f $scnfdir . $scnfflnm);

  if(-f $scnfdir . $scnfflnm)
  {
    eval
    {
      $rscnf = YAML::LoadFile($scnfdir . $scnfflnm);

      $rscnf->{'component'} = $scomp;
      $rscnf->{'maindirectory'} = $smndir;
      $rscnf->{'configfile'} = $scnfdir . $scnfflnm;
    };

    if($@)
    {
      $rscnf = undef;

      print STDERR "Component '$scomp': Configuration could not be loaded!\n"
        , "Configuration File '${scnfdir}${scnfflnm}': Read Open failed.\n"
        , "File '${scnfdir}${scnfflnm}' - Message: '", $@, "'\n";
    } #if($@)
  }
  else  #Configuration File does not exist
  {
    print STDERR "Component '$scomp': Configuration could not be loaded!\n"
      , "Configuration File '${scnfdir}${scnfflnm}': File does not exist.\n";
  } #if(-f $scnfdir . $scnfflnm)


  return $rscnf;
}


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

sub dispatchHomePage
{
  my ($req, $res, $cnf) = @_ ;
  my $stmplnm = 'index';
  my $rhshtmpldata = {'pagetitle' => $cnf->{'project'}
    , 'projectname' => $cnf->{'project'}
    , 'vmainpath' => $cnf->{'vmainpath'}
  };
  my $rsout = undef;


  #------------------------
  #Index Page

  eval
  {
    #Render the HTML Template
    $rsout = render_template_html($cnf->{'maindirectory'}, $stmplnm, $rhshtmpldata);
  };

  if($@)
  {
    $rsout = undef;

    $rhshtmpldata->{'title'} = 'Exception';
    $rhshtmpldata->{'statuscode'} = 500;
    $rhshtmpldata->{'errorcode'} = 0 + $! ;
    $rhshtmpldata->{'errormessage'} = 'Template Rendering failed!';
    $rhshtmpldata->{'errormessage'} = "Template '$stmplnm': Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]";

    my $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    print STDERR "Template '$stmplnm' - Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]: ", $@ ;
  } #if($@)

  if(defined $rsout)
  {
    #Set the rendered HTML
    $res->code(200);
    $res->content($$rsout);
  }
  else
  {
    return dispatchErrorResponse($res, $cnf, $rhshtmpldata);
  } #if(defined $rsout)


  return $res->finalize;
}


sub dispatchManifest
{
  my ($req, $res, $cnf) = @_ ;
  my $stmplnm = 'manifest';
  my $rhshtmpldata = {'projectname' => $cnf->{'project'}
    , 'projectcodename' => $cnf->{'codename'}
    , 'vmainpath' => $cnf->{'vmainpath'}
  };
  my $rsout = undef;


  #------------------------
  #Manifest Page

  eval
  {
    #Render the Template
    $rsout = render_template_headless($cnf->{'maindirectory'}, $stmplnm, $rhshtmpldata);
  };

  if($@)
  {
    $rsout = undef;

    $rhshtmpldata->{'title'} = 'Exception';
    $rhshtmpldata->{'statuscode'} = 500;
    $rhshtmpldata->{'errorcode'} = 0 + $! ;
    $rhshtmpldata->{'errormessage'} = 'Template Rendering failed!';
    $rhshtmpldata->{'errormessage'} = "Template '$stmplnm': Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]";

    my $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    print STDERR "Template '$stmplnm' - Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]: ", $@ ;
  } #if($@)

  if(defined $rsout)
  {
    #Set the rendered HTML
    $res->code(200);
    $res->content_type('application/json');
    $res->content($$rsout);
  }
  else  #Template Rendering has failed
  {
    return dispatchErrorResponse($res, $cnf, $rhshtmpldata);
  } #if(defined $rsout)


  return $res->finalize;
}


sub dispatchServiceWorker
{
  my ($req, $res, $cnf) = @_ ;
  my $stmplnm = 'service-worker';
  my $rhshtmpldata = {'sversion' => $cnf->{'version'}, 'vmainpath' => $cnf->{'vmainpath'}};
  my $rsout = undef;


  #------------------------
  #Service Worker Script

  eval
  {
    #Render the Template
    $rsout = render_template_headless($cnf->{'maindirectory'}, $stmplnm, $rhshtmpldata);
  };

  if($@)
  {
    $rsout = undef;

    $rhshtmpldata->{'title'} = 'Exception';
    $rhshtmpldata->{'statuscode'} = 500;
    $rhshtmpldata->{'errorcode'} = 0 + $! ;
    $rhshtmpldata->{'errormessage'} = 'Template Rendering failed!';
    $rhshtmpldata->{'errormessage'} = "Template '$stmplnm': Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]";

    my $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    print STDERR "Template '$stmplnm' - Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]: ", $@ ;
  } #if($@)

  if(defined $rsout)
  {
    #Set the rendered HTML
    $res->code(200);
    $res->content_type('application/javascript');
    $res->content($$rsout);
  }
  else  #Template Rendering has failed
  {
    return dispatchErrorResponse($res, $cnf, $rhshtmpldata);
  } #if(defined $rsout)


  return $res->finalize;
}

sub dispatchErrorPageHTML
{
  my ($req, $res, $cnf) = @_ ;
  my $stmplnm = 'error';
  my $rhshtmpldata = {'pagetitle' => $cnf->{'project'} . ' - Error'
    , 'vmainpath' => $cnf->{'vmainpath'}
    , 'statuscode' => 404
    , 'errormessage' => 'Not Found.'
    , 'errordescription' => 'The Page does not exist.'
  };
  my $rsout = undef;


  #------------------------
  #Error Page

  eval
  {
    #Render the HTML Template
    $rsout = render_template_html($cnf->{'maindirectory'}, $stmplnm, $rhshtmpldata);
  };

  if($@)
  {
    $rsout = undef;

    $rhshtmpldata->{'title'} = 'Exception';
    $rhshtmpldata->{'statuscode'} = 500;
    $rhshtmpldata->{'errorcode'} = 0 + $! ;
    $rhshtmpldata->{'errormessage'} = 'Template Rendering failed!';
    $rhshtmpldata->{'errormessage'} = "Template '$stmplnm': Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]";

    my $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    print STDERR "Template '$stmplnm' - Rendering failed with [" . $rhshtmpldata->{'errorcode'} . "]: ", $@ ;
  } #if($@)

  if(defined $rsout)
  {
    #Set the rendered HTML
    $res->code(404);
    $res->content($$rsout);
  }
  else  #Template Rendering has failed
  {
    return dispatchErrorResponse($res, $cnf, $rhshtmpldata);
  } #if(defined $rsout)


  return $res->finalize;
}


sub dispatchErrorResponse
{
  my ($res, $cnf, $rhshdata) = @_ ;
  my $scomp = $ENV{'COMPONENT'} || 'default';
  my $sout = '';


  #------------------------
  #Error Response
  #Finalize Request with Plain Text Error Message

  $scomp .= ' - ';
  $scomp .= $ENV{'PLACK_ENV'} || 'deployment';

  $cnf = {'project' => $scomp} unless defined $cnf ;

  $rhshdata = {} unless defined $rhshdata ;
  $rhshdata->{'title'} = 'Error' unless defined $rhshdata->{'title'};
  $rhshdata->{'status'} = 500 unless defined $rhshdata->{'status'};
  $rhshdata->{'message'} = 'An Error has occurred!' unless defined $rhshdata->{'message'};
  $rhshdata->{'description'} = '' unless defined $rhshdata->{'description'};


  my $rhshrspdata = {'title' => $cnf->{'project'} . ' - ' . $rhshdata->{'title'}
    , 'statuscode' => $rhshdata->{'status'}
    , 'errormessage' => $rhshdata->{'message'}
    , 'errordescription' => $rhshdata->{'description'}
  };


  $sout .= $rhshrspdata->{'title'} . "\n==========================\n\n"
    . "Error " . $rhshrspdata->{'statuscode'} . ": " . $rhshrspdata->{'errormessage'} . "\n"
    . "------------------\n\n" . $rhshrspdata->{'errordescription'} . "\n";

  $res->code($rhshrspdata->{'statuscode'});
  $res->content_type('text/plain');
  $res->content($sout);


  return $res->finalize;
}




#----------------------------------------------------------------------------
#Executing Section


my $scomp = $ENV{'COMPONENT'} || 'default';
my $webroot = dirname(dirname( abs_path(__FILE__) ));
my $config = loadConfiguration($webroot);
my $svmainpath = $config->{'vmainpath'};


$scomp .= ' - ';
$scomp .= $ENV{'PLACK_ENV'} || 'deployment';

if(defined $config)
{
  print STDERR "Server '", $config->{'component'}, " / ", $scomp, "' - Configuration: loaded.\n";
}
else  #Configuration Loading failed
{
  print STDERR "Server '$scomp' - Configuration : Loading failed!\n";
} #if(defined $config)

print STDERR "ENV dmp:\n", dump %ENV ;
print STDERR "\n";


my $app = sub {
  my $env = shift;
  my $request = Plack::Request->new($env);
  my $response = $request->new_response(200);


  $response->content_type('text/html');


  #Exit on missing Configuration
  return dispatchErrorResponse($response, undef, {'description' => 'Server Configuration could not be loaded.'})
    unless(defined $config);


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/'
    || $request->path_info() eq '/index.html')
  {
    #------------------------
    #Dispatch Home Page

    return dispatchHomePage($request, $response, $config);
  }
  elsif($request->path_info() eq '/manifest.json')
  {
    #------------------------
    #Dispatch Manifest Page

    return dispatchManifest($request, $response, $config);
  }
  elsif($request->path_info() eq '/service-worker')
  {
    #------------------------
    #Dispatch Service Worker Script

    return dispatchServiceWorker($request, $response, $config);
  } #if($request->path_info() eq '/')


  #------------------------
  #Any other Page: Not Found Error

  return dispatchErrorPageHTML($request, $response, $config);
};  #$app



#----------------------------------------------------------------------------
#URL Mapping


#my $web = builder {
builder {
  #Graphic Elements Mapping
  enable "Static", path => qr#^/(images|css|js|html)#, root => $webroot;
  #Configure Logging
  enable "Plack::Middleware::AccessLog::Timed"
    , format => '%{X-FORWARDED-PROTO}i:%V (%h,%{X-FORWARDED-FOR}i) %{%F:%T}t [%D] '
      . '"Mime:%{Content-Type}o" "%r" %>s %b "%{Referer}i" "%{User-agent}i"';
  #Any other Content
  $app;
};



#----------------------------------------------------------------------------
#Create Service Instance


#print "args dmp:\n", dump @ARGV ;
#print "\n";

#my $host = '0.0.0.0';
#my $port = $ENV{'PORT'} || 3000;

#my $server = Twiggy::Server->new(
#    host => $host,
#    port => $port,
#    read_chunk_size => 32768,
#);


#Start Service
#$server->run($web);



