<div>
    <a target="_blank" rel="noopener noreferrer" href="https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/plack-test.yml">
    	<img src="https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/plack-test.yml/badge.svg" alt="Automated Plack::Test" style="max-width:100%;">
    </a>
    <!--
    [![Automated Plack::Test](https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/plack-test.yml/badge.svg)](https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/plack-test.yml)
    -->

    <a target="_blank" rel="noopener noreferrer" href="https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/phantomjs-test.yml">
    	<img src="https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/phantomjs-test.yml/badge.svg" alt="Integration Test with PhantomJS" style="max-width:100%;">
    </a>
    <!--
    [![Integration Test with PhantomJS](https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/phantomjs-test.yml/badge.svg)](https://github.com/bodo-hugo-barwich/plack-pwa-web/actions/workflows/phantomjs-test.yml)
    -->
</div>

# NAME

Plack Twiggy PWA

# DESCRIPTION

The Objective of this development is the Exercise of modern web technologies (Progressive Web Apps) with `Perl Plack`
on a non-blocking `Twiggy` Web Server.

The inspiration of the Product and the `JavaScript` base were taken from the tutorial:
[How to build a PWA from scratch](https://github.com/ibrahima92/pwa-with-vanilla-js)

The running Version is hosted on _Glitch_ at:
[Plack Twiggy PWA](https://plack-twiggy-pwa.glitch.me/)

# REQUIREMENTS

To rebuild this web site the **Minimum Requirements** are to have _Perl_ and `cpanminus` installed.
The site uses the libraries `Plack`, `Twiggy` and `Template Toolkit`.
The `Twiggy` Web Server requires the `AnyEvent` library.

# INSTALLATION

- cpanminus

    The `cpanm` Script will install the dependencies on local user level as they are found in the `cpanfile`.
    To run the installation call the `cpanm` Command within the project directory:

            cpanm -vn --installdeps .
