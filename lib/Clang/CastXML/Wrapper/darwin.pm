package Clang::CastXML::Wrapper::darwin;

use Moo;
use experimental  qw( signatures );
use Capture::Tiny ();

extends qw(Clang::CastXML::Wrapper);

with qw(Clang::CastXML::Role::Alien Clang::CastXML::Role::Preprocessor);

# ABSTRACT: Darwin specialisation subclass of Clang::CastXML::Wrapper
# VERSION

=head1 SYNOPSIS

  $wrapper = Clang::CastXML::Wrapper::darwin->new(cc => 'clang++');
  $castxml = Clang::CastXML->new(wrapper => $wrapper);
  $castxml->introspect(path("header.hpp"));

=head1 DESCRIPTION

This is a Darwin-specific implementation of the Clang::CastXML::Wrapper class. It provides additional functionality and
optimizations for working with castxml and the Clang compiler on macOS which can improve compatibility with Xcode,
macports and homebrew ecosystems, especially for C++ projects.

=head1 ATTRIBUTES

C<Clang::CastXML::Wrapper::darwin> inherits all attributes from C<Clang::CastXML::Wrapper> and composes
C<Clang::CastXML::Role::Alien> and C<Clang::CastXML::Role::Preprocessor> roles.

=head1 METHODS

No additional methods are provided by C<Clang::CastXML::Wrapper::darwin>.

=cut


around BUILDARGS => sub ($orig, $self, @args) {
  return {cc_id => 'gnu', cc => 'clang++', cc_args => [_sdk_path()]} if @args == 1 && !ref $args[0];
  my %args = @args;
  $args{cc_args} ||= [];
  unshift @{$args{cc_args}}, _sdk_path() if $args{cc};
  return $self->$orig(%args);
};

sub _sdk_path {
  my ($out, $err, $ret, $sig) = Capture::Tiny::capture {
    system xcrun => '--show-sdk-path';
    ($? >> 8, $? & 127);
  };
  chomp $out;
  return (-isysroot => $out);
}


1;
