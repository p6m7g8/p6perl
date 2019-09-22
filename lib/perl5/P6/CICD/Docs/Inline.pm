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
use P6::Template ();
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

sub tmpl_paths { "$ENV{PERL5LIB}/../../tt" }

sub doc_gen() {
  my $self = shift;
  my %args = @_;

  my $funcs = $self->funcs();
  foreach my $fname (sort keys %{$self->funcs()}) {
    my $func = $funcs->{$fname};

    my $opath = $func->{file} . "-" . $func->{name};
    $opath =~ s/\.//g;
    $opath =~ s#/#-#g;
    $opath =~ s/^-//;

    $opath = "/tmp/$opath.txt";

    my $rv1 = P6::Template->render(
				   $func,
				   %args,
				   paths  => $self->tmpl_paths(),
				   ifile  => "sh_doc.tt",
				   output => $opath,
				  );

    $func->{doc_lines} = P6::IO::dread("$opath");
    P6::Util::execute("$P6::Cmd::RM_F $opath", { silent => 1 });
    $self->funcs($funcs);
  }

  $self->funcs($funcs);

  return;
}

sub splice_in() {
  my $self = shift;
  my %args = @_;

  my $lib_dir = $self->module() . "/lib";
  my $files = P6::IO::scan($lib_dir, "\.sh\$");
  my $mark = "#" x 70;

  my $funcs = $self->funcs();

  foreach my $file (sort @$files) {
    P6::Util::debug("$file\n");
    my $doc_in = 0;
    my $func = "";
    my @new_lines = ();

    my @lines = grep { chomp } @{P6::IO::dread($file)};
    foreach my $line (@lines) {
      next if $line =~ /^$mark/;
      $doc_in = 1, next if $line =~ /^#</;
      $doc_in = 0, next if $line =~ /^#>/;
      next if $doc_in;

      if ($line =~ /^p6_/) {
	my $fname = $line;
	$fname =~ s/\s+.*//g;
	P6::Util::debug("DEF: $fname\n");

	$func = $funcs->{$fname};
	push @new_lines, $mark;
	push @new_lines, grep { chomp } @{$func->{doc_lines}};
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

  my $lib_dir = $self->module() . "/lib";
  P6::Util::debug("lib_dir: $lib_dir\n");

  my $files = P6::IO::scan($lib_dir, "\.sh\$");

  my $funcs = {};
  foreach my $file (sort @$files) {
    my $func = "";

    my $lines = P6::IO::dread($file);
    foreach my $line (@$lines) {
      if ($line =~ /^p6_/) {
	$line =~ s/\s+.*//g;
	$func = $line;

	my $name = $func;
	$name =~ s/\(\)//;

	$funcs->{$func}->{name} = $name;
	$funcs->{$func}->{file} = $file;
      }

      if ($line =~ /^\s+local ([a-zA-Z_][a-zA-z0-9_]+)="/) {
	my $arg = $1;

	my $default = "";
	$default = $1 if $line =~ /:-([^}]+)\}/;
	P6::Util::debug("$func: $arg - default[$default]\n");
	my $comment = "";
	$comment = $1 if $line =~ /# (.*)$/;

	push @{$funcs->{$func}->{args}}, { name => $arg, default => $default, comment => $comment };
      }

      if ($line =~ /p6_return(_bool|_int|_void)?(?: \"([^\"]+)\")?/) {
	my ($type, $val) = ($1, $2);
	$type =~ s/^_// if $type;

	my $comment = "";
	$comment = $1 if $line =~ /# (.*)$/;

	push @{$funcs->{$func}->{rvs}}, { name => $val, comment => $comment, type => $type };
      }
    }
  }

  $self->funcs($funcs);

  return;
}

1;
