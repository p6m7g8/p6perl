#!/usr/bin/env perl

## core
use strict;
use warnings FATAL => 'all';
use Carp;

## Std

## CPAN

## Globals

## SDK
use P6::CLI ();
use P6::Util ();

## Me
use P6::CICD::Docs::Readme ();

## Custom Args w/ defaults
our $Module = "";

## Custom Constants

## Globals

## Functions
sub valid_args {

    my $errors = 0;

    $errors++, P6::Util::error("--module=<module> is required\n") unless $Module;

    $errors;
}

sub getopts {

    {
	"Module=s" => \$Module,
    }
}

# main()
MAIN: { exit P6::CLI->run() }

# Entry Point
sub work {

    P6::CICD::Docs::Readme->new(module => $Module);

    return P6::Const::EXIT_SUCCESS;
}

__END__

=head1 NAME

readme.pl - Generates API Docs for README.md

=head1 SYNOPSIS

readme.pl --module=<module> [--debug] [--verbose [1-4]] [--no-execute] | [--version | --help]

=head1 OPTIONS

=over 4

=item B<--module=<module>>

Which module to work on [REQUIRED]

=back

=head1 DESCRIPTION

Extract comment docs into README.md section

=heaad1 AUTHOR

Philip M. Gollucci E<lt><pgollucci@p6m7g8.com>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Philip M. Gollucci

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
