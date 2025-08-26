package Clang::CastXML::Role::Preprocessor;

use Moo::Role;
use Config       qw(%Config);
use File::Which  qw();
use experimental qw(signatures);

# ABSTRACT: Clang::CastXML::Wrapper Role to inject --castxml-cc-<id> <cc> into castxml command
# VERSION

=head1 SYNOPSIS

  package Clang::CastXML::Wrapper::clang;
  use Moo;
  use experimental qw(signatures);
  extends qw(Clang::CastXML::Wrapper);
  with 'Clang::CastXML::Role::Preprocessor';
  1;

=head1 DESCRIPTION

This role is applied to the C<Clang::CastXML::Wrapper> class to modify the castxml command with the appropriate
C<--castxml-cc-<id> <cc>> arguments based on the configured compiler.

From the castxml documentation:

  --castxml-cc-<id> <cc>
  --castxml-cc-<id> "(" <cc> <cc-opt>... ")"
    Configure the internal Clang preprocessor and target
    platform to match that of the given compiler command.
    The <id> must be "gnu", "msvc", "gnu-c", or "msvc-c".
    <cc> names a compiler (e.g. "gcc") and <cc-opt>... specifies
    options that may affect its target (e.g. "-m32").

=head1 ATTRIBUTES

The C<Clang::CastXML::Role::Preprocessor> provides the following attributes for a C<Clang::CastXML::Wrapper> class:

=head2 cc_id

The compiler ID to use for the castxml command. Must be one of "gnu", "msvc", "gnu-c", or "msvc-c".

=head2 cc

The compiler command to use for the castxml command.

=head2 cc_args

Additional arguments to pass to the compiler.

=cut

has cc_id => (
  is      => 'ro',
  isa     => sub { die "Invalid castxml_cc_id" unless $_[0] =~ /^(gnu|msvc|gnu-c|msvc-c)$/ },
  default => sub {'gnu-c'},
);
has cc      => (is => 'ro', lazy => 1, default => sub { $Config{cc} });
has cc_args => (is => 'ro', lazy => 1, default => sub { [] });

around raw => sub ($orig, $self, @args) {
  return $self->$orig(@args) unless @args > 1;
  my $file = pop @args;

  unshift @args, @{$self->castxml_cc};

  return $self->$orig(@args, $file);
};

=head1 METHODS

The C<Clang::CastXML::Role::Preprocessor> role provides the following attributes for a C<Clang::CastXML::Wrapper> class:

=head2 castxml_cc

Returns the castxml cc arguments as an array reference.

=cut

sub castxml_cc ($self) {
  return [] unless my $cc = $self->cc;
  $cc = File::Which::which($cc);
  return [] unless $cc;
  my $id_arg = join '-', qw(- castxml cc), $self->cc_id;
  return [$id_arg => '(', $cc, @{$self->cc_args}, ')'];
}


1;
