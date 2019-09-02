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
use P6::AWS::ELB ();

## Custom Args w/ defaults
our $LoadBalancerName = "";

## Custom Constants

## Globals

## Functions
sub valid_args {

    my $errors = 0;

    $errors++, P6::Util::error("--load-balancer-name=<load_balancer_name> is required\n") unless $LoadBalancerName;

    $errors;
}

sub getopts {

    {
	"load-balancer-name=s" => \$LoadBalancerName,
    }
}

# main()
MAIN: { exit P6::CLI->run() }

# Entry Point
sub work {

  P6::AWS::ELB->new(load_balancer_name => $LoadBalancerName)->display();

  return P6::Const::EXIT_SUCCESS;
}

__END__

=head1 NAME

sg_show.pl - Display A Security Group for HUMANS

=head1 SYNOPSIS

sg_show.pl --load-balancer-name=<load_balancer_name> [--debug] [--verbose [1-4]] [--no-execute] | --version | --help

=head1 OPTIONS

=over 4

=item B<--load-balancer-name=<load_balancer_name>>

Display the listeners for this load-balancer [REQUIRED]

=back

=head1 DESCRIPTION

Displays the requested listeners for the load balancer for humans

=heaad1 AUTHOR

Philip M. Gollucci E<lt><pgollucci@p6m7g8.com>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Philip M. Gollucci

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
