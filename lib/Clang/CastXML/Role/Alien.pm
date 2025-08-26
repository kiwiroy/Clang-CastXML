package Clang::CastXML::Role::Alien;

use Moo::Role;
use Text::Shellwords qw();
use experimental     qw( signatures );

# ABSTRACT: Clang::CastXML::Wrapper Role to inject cflags into castxml command
# VERSION

=head1 SYNOPSIS

  package Clang::CastXML::Wrapper::aliens;
  use Moo;
  use experimental qw(signatures);
  extends qw(Clang::CastXML::Wrapper);
  with 'Clang::CastXML::Role::Alien';
  1;

=head1 DESCRIPTION

This role is applied to the C<Clang::CastXML::Wrapper> class to modify the castxml command with the appropriate
C<cflags> from alien packages.

=head1 ATTRIBUTES

The C<Clang::CastXML::Role::Alien> provides the following attributes for a C<Clang::CastXML::Wrapper> class:

=head2 aliens

An array reference of alien packages.

  $wrapper = Wrapper::Class->new(aliens => ['Alien::FooBarPlusPlus']);

=head1 METHODS

The C<Clang::CastXML::Role::Alien> role provides no additional methods.

=cut

has aliens => (is => 'ro', default => sub { [] },);

around raw => sub ($orig, $self, @args) {
  return $self->$orig(@args) unless @args > 1;
  my $file = pop @args;

  push @args, map { Text::Shellwords::shellwords $_->cflags } @{$self->aliens};

  return $self->$orig(@args, $file);
};

1;
