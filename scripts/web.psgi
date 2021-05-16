use warnings;
use strict;

use Cwd qw(abs_path);
use File::Basename qw(dirname);

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
      my $writer = (my $responder = shift)->(
        [ 200, [ 'Content-Type', 'text/html' ]]);
      my $watcher;
      my $rhshtmpldata = {'pagetitle' => 'Plack Twiggy PWA'
        , 'projectname' => 'Plack Twiggy PWA'
        , 'vmainpath' => $svmainpath
      };

      my $cb = sub {
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

      };  #$cb


     $writer->write("Starting: ${\scalar(localtime)}\n");

     $watcher = AnyEvent->timer(
      after => 0,
      cb => sub {
        $cb->(scalar localtime);
        undef $watcher; # cancel circular-ref
      });

    };
  }
  elsif($request->path_info() eq '/manifest')
  {
    #------------------------
    #Manifest Page

    return sub {
      my $writer = (my $responder = shift)->(
        [ 200, [ 'Content-Type', 'application/json' ]]);
      my $watcher;
      my $rhshtmpldata = {'projectname' => 'Plack Twiggy PWA'
        , 'projectcodename' => 'PlackPWA'
        , 'vmainpath' => $svmainpath
      };

      my $cb = sub {
        #------------------------
        #HTML Render Callback

        my $message = shift;
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

      };  #$cb

     $watcher = AnyEvent->timer(
      after => 0,
      cb => sub {
        $cb->();
        undef $watcher; # cancel circular-ref
      });

    };
  } #if($request->path_info() eq '/')


  #------------------------
  #Any other Page: Not Found Error

  return sub {
    #------------------------
    #Error Page

    my $writer = (my $responder = shift)->(
      [ 404, [ 'Content-Type', 'text/html' ]]);
    my $watcher;
    my $rhshtmpldata = {'pagetitle' => 'Plack Twiggy - Error'
      , 'vmainpath' => $svmainpath
      , 'statuscode' => 404
      , 'errormessage' => 'Not Found.'
      , 'errordescription' => 'The Page does not exist.'
    };

    my $cb = sub {
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

    };  #$cb


   $watcher = AnyEvent->timer(
    after => 0,
    cb => sub {
      $cb->();
      undef $watcher; # cancel circular-ref
    });

  };
};



#----------------------------------------------------------------------------
#URL Mapping


builder {
  #Graphic Elements Mapping
  enable "Static", path => qr#^/(images|css|js)#, root => $webroot;
  #Any other Content
  $app;
}



