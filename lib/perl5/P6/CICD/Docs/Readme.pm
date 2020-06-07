package P6::CICD::Docs::Readme;
use parent 'P6::Object';

## core
use strict;
use warnings FATAL => 'all';
use Carp;

## Std

## CPAN

## Globals

## SDK
use P6::IO ();
use P6::Util ();

## Constants

## methods

## private
sub _fields {

	{
		module => "",
		funcs => {},
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

	my $funcs = $self->funcs();
	foreach my $file (sort keys %{$self->funcs()}) {
		my $section = (split /\//, $file)[-1];

		print "### $section:\n";

		my @funcs = sort @{$funcs->{$file}};
		foreach my $func (@funcs) {
			next if $func =~ /__/;
			print "- $func\n";
		}
		print "\n";
	}

	return;
}


sub files() {
	my $self = shift;

	my $module_dir = $self->module();
	my $lib_dir = "$module_dir/lib";
	P6::Util::debug("lib_dir: $lib_dir\n");

	my $files = P6::IO::scan($lib_dir, qr/\.sh$/, files_only => 1);
	push @$files, "$module_dir/init.zsh" if -e "$module_dir/init.zsh";

	P6::Util::debug_dumper("FILES", $files);

	$files;
}


sub parse {
	my $self = shift;

	my $files = $self->files();

	my $funcs = {};
	foreach my $file (sort @$files) {

		#    P6::Util::debug("FILE: $file\n");

		my $lines = P6::IO::dread($file);
		foreach my $line (@$lines) {

			#      P6::Util::debug(" LINE: $line\n");
			if ($line =~ /# Function: (.*)/) {
				push @{$funcs->{$file}}, $1;
			}
		}
	}

	$self->funcs($funcs);

	# P6::Util::debug_dumper "FUNCS", $funcs;

	return;
}

sub tmpl_paths { "$ENV{PERL5LIB}/../../tt" }

1;
