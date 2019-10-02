package P6::CICD::Docs::Inline;
use parent 'P6::Object';

## core
use strict;
use warnings FATAL => 'all';
use Carp;

## Std

## CPAN

## Globals

## SDK
use P6::Cmd ();
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
  $self->doc_gen();
  $self->splice_in();

  return;
}

sub doc_gen_func {
  my $func = shift;

  my $rvs = $func->{rvs};
  my $rv = $rvs->[0];

  my $args = $func->{args};

  my $str = "# Function:\n";
  $str .= "#\t";

  if ($rv && $rv->{type} ne "void") {
    no warnings qw(uninitialized);
    $str .= "$rv->{type} $rv->{name} = ";
  }

  $str .= "$func->{name}";

  $str .= "(";
  foreach my $arg (@$args) {
    $str .= "[" if exists $arg->{default};
    $str .= "$arg->{name}";
    $str .= "=$arg->{default}" if exists $arg->{default};
    $str .= "]" if exists $arg->{default};
    $str .= ", ";
  }
  $str =~ s/, $/)/;
  $str .= ")" unless $str =~ /\)$/;

  $str;
}

sub doc_gen_args {
  my $args = shift;

  my $str = "#  Args:\n";

  foreach my $arg (@$args) {
    no warnings qw(uninitialized);
    $str .= "#\t";
    $str .= "OPTIONAL " if exists $arg->{default};
    $str .= "$arg->{name} - $arg->{comment}";
    $str .= " [$arg->{default}]" if exists $arg->{default};
    $str .= "\n";
  }

  $str;
}

sub doc_gen_returns {
  my $rvs = shift;

  my @non_voids = grep { $_->{type} ne "void" } @$rvs;
  return unless @non_voids;

  my $str = "#  Returns:\n";

  foreach my $rv (@$rvs) {
    no warnings qw(uninitialized);
    next if $rv->{type} eq "void";
    $str .= "#\t$rv->{type} - $rv->{name}";
    $str .= ": $rv->{comment}\n" if $rv->{comment};
  }
  $str .= "\n" unless $str =~ /\n$/;
  $str .= "#\n";

  $str;
}

sub doc_gen() {
  my $self = shift;
  my %args = @_;

  my $module = $self->module();
  my $safe_module = (split /\//, $module)[-1];

  my $funcs = $self->funcs();
  foreach my $fname (sort keys %{$self->funcs()}) {
    my $func = $funcs->{$fname};

    ## build
    my @doc_lines = ();
    push @doc_lines, "#<";
    push @doc_lines, "#";
    push @doc_lines, doc_gen_func($func);
    push @doc_lines, "#";

    if ($func->{args}) {
      push @doc_lines, doc_gen_args($func->{args});
      push @doc_lines, "#";
    }
    if ($func->{rvs}) {
      push @doc_lines, doc_gen_returns($func->{rvs});
    }
    push @doc_lines, "#>";

    $func->{doc_lines} = \@doc_lines;
  }

  $self->funcs($funcs);

  return;
}

sub splice_in() {
  my $self = shift;
  my %args = @_;

  my $lib_dir = $self->module() . "/lib";
  my $files = P6::IO::scan($lib_dir, "\.sh\$", files_only => 1);
  my $mark = "#" x 70;

  my $funcs = $self->funcs();

  foreach my $file (sort @$files) {
    P6::Util::debug("$file\n");
    my $doc_in = 0;
    my $func = "";
    my @new_lines = ();

    my @lines = grep { chomp ; 1 } @{P6::IO::dread($file)};
    foreach my $line (@lines) {
      next if $line =~ /^$mark/;
      $doc_in = 1, next if $line =~ /^#</;
      $doc_in = 0, next if $line =~ /^#>/;
      next if $doc_in;
      next if $line =~ /^#\//;

      if ($line =~ /^p6_/) {
	my $fname = $line;
	$fname =~ s/\s+.*//g;
	P6::Util::debug("DEF: $fname\n");

	$func = $funcs->{$fname};
	push @new_lines, $mark;
	push @new_lines, grep { chomp ; 1 } @{$func->{doc_lines}};
	push @new_lines, grep { chomp ; 1 } @{$func->{extra_docs}};
	push @new_lines, $mark;
      }

      push @new_lines, $line;
    }

    my $content = join "\n", @new_lines;
    P6::IO::dwrite($file, \$content);
  }

  return;
}

sub parse {
  my $self = shift;

  my @types = (qw(array bool code false hash int list size str true void));
  my $types_re = join '|', @types;
  P6::Util::debug("types_re=[$types_re]\n");

  my $lib_dir = $self->module() . "/lib";
  P6::Util::debug("lib_dir: $lib_dir\n");

  my $files = P6::IO::scan($lib_dir, qr/\.sh$/, files_only => 1);

  my $funcs = {};
  my $extra_docs = [];
  foreach my $file (sort @$files) {
    P6::Util::debug("FILE: $file\n");
    my $func = "";
    my $in_func = 1;
    my $arg_end = 0;

    my $lines = P6::IO::dread($file);
    foreach my $line (@$lines) {
      if ($line =~ /^#\//) {
	push @$extra_docs, $line;
      }

      if ($line =~ /^p6_/) {
	$in_func = 1;

	$line =~ s/\s+.*//g;
	$func = $line;

	my $name = $func;
	$name =~ s/\(\)//;
	P6::Util::debug("\tFUNC: $name\n");

	$funcs->{$func}->{name} = $name;
	$funcs->{$func}->{file} = $file;
	$funcs->{$func}->{extra_docs} = $extra_docs;
	$extra_docs = [];
      }

      if ($in_func && $line =~ /^\s+$/) {
	$arg_end = 1;
      }

      if (!$arg_end && $line =~ /^\s+local ([a-zA-Z_][a-zA-z0-9_]+)=/) {
	my $arg = {};
	$arg->{name} = $1;

	$arg->{default} = $1 if $line =~ /:-([^}]*)\}/;
	$arg->{comment} = $1 if $line =~ /# (.*)$/;

#	P6::Util::debug_dumper("arg", $arg);
	push @{$funcs->{$func}->{args}}, $arg;
      }

      my $rv = {};
      if ($line =~ /^\s+p6_return_($types_re)/) {
	$rv->{type} = $1;
#	P6::Util::debug("\treturn: $line");

	$rv->{name} = $1 if $line =~ /\"([^\"]+)\"/;
      }
      if ($line =~ /^\s+p6_return /) {
	$rv->{type} = "unkown";
#	P6::Util::debug("\treturn_legacy: $line");

	$rv->{name} = $1 if $line =~ /\"([^\"]+)\"/;
      }

      if ($rv->{type}) {
	$rv->{name} = "" unless $rv->{name};
	$rv->{name} =~ s/^\$//;

	$rv->{comment} = $1 if $line =~ /# (.*)$/;

#	P6::Util::debug_dumper("rv", $rv);
	push @{$funcs->{$func}->{rvs}}, $rv;
      }

      if ($line =~ /^}$/) {
	$in_func = 0;
	$arg_end = 0;
      }
    }
  }

  delete $funcs->{""};

  $self->funcs($funcs);

  return;
}

1;
