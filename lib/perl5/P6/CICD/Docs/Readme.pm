package P6::CICD::Docs::Readme;
use parent 'P6::Object';

## core
use strict;
use warnings FATAL => 'all';
use Carp;

use File::Basename ();

## Std

## CPAN

## Globals

## SDK
use P6::IO   ();
use P6::Util ();

## Constants

## methods

## private
sub _fields {

    {
        module => "",
        funcs  => {},
    }
}

sub _post_init {
    my $self = shift;
    my %args = @_;

    $self->parse();
    $self->readme_gen();

    return;
}

sub readme_gen() {
    my $self = shift;
    my %args = @_;

    my $module = $self->module();
    $module = File::Basename::basename($module);

    print "# $module\n\n";

    print "## Table of Contents\n\n";
    print "
### $module
- [$module](#$module)
  - [Badges](#badges)
  - [Distributions](#distributions)
  - [Summary](#summary)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
  - [Changes](#changes)
    - [Usage](#usage)
  - [Author](#author)

### Badges

[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/p6m7g8/$module)
[![Mergify](https://img.shields.io/endpoint.svg?url=https://gh.mergify.io/badges/p6m7g8/$module/&style=flat)](https://mergify.io)
[![codecov](https://codecov.io/gh/p6m7g8/$module/branch/master/graph/badge.svg?token=14Yj1fZbew)](https://codecov.io/gh/p6m7g8/$module)
[![Known Vulnerabilities](https://snyk.io/test/github/p6m7g8/$module/badge.svg?targetFile=package.json)](https://snyk.io/test/github/p6m7g8/$module?targetFile=package.json)

## Summary

## Contributing

- [How to Contribute](CONTRIBUTING.md)

## Code of Conduct

- [Code of Conduct](CODE_OF_CONDUCT.md)

## Changes

- [Change Log](CHANGELOG.md)

### Usage

";

    my $funcs = $self->funcs();
    foreach my $file ( sort keys %{ $self->funcs() } ) {
        my $section = ( split /\//, $file )[-1];

        print "#### $section:\n\n";

        my @funcs = sort @{ $funcs->{$file} };
        foreach my $func (@funcs) {
            next if $func =~ /__/;
            print "- $func\n";
        }
        print "\n";
    }

    print "
## Author

Philip M . Gollucci <pgollucci\@p6m7g8.com>
";

    return;
}

sub files() {
    my $self = shift;

    my $module_dir = $self->module();
    my $lib_dir    = "$module_dir/lib";
    P6::Util::debug("lib_dir: $lib_dir\n");

    my $files = P6::IO::scan( $lib_dir, qr/\.sh$|\.zsh$/, files_only => 1 );
    push @$files, "$module_dir/init.zsh" if -e "$module_dir/init.zsh";

    P6::Util::debug_dumper( "FILES", $files );

    $files;
}

sub parse {
    my $self = shift;

    my $files = $self->files();

    my $funcs = {};
    foreach my $file ( sort @$files ) {

        #    P6::Util::debug("FILE: $file\n");

        my $lines = P6::IO::dread($file);
        foreach my $line (@$lines) {

            #      P6::Util::debug(" LINE: $line\n");
            if ( $line =~ /# Function: (.*)/ ) {
                push @{ $funcs->{$file} }, $1;
            }
        }
    }

    $self->funcs($funcs);

    # P6::Util::debug_dumper "FUNCS", $funcs;

    return;
}

sub tmpl_paths { "$ENV{PERL5LIB}/../../tt" }

1;
