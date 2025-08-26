package Alien::corpus;
use strict;
use warnings;
use Path::Tiny qw( path );
sub cflags { return join '', -I => path('corpus/include')->absolute->stringify }

package main;
use Test2::V0 -no_srand => 1;

use Clang::CastXML;
use Clang::CastXML::Wrapper::darwin;
use Config;
use Path::Tiny qw( path );
use Test::XML;

plan skip_all => 'This test is for macOS only' unless $^O eq 'darwin';

subtest basic => sub {

  my $wrapper = Clang::CastXML::Wrapper::darwin->new(cc => undef);
  isa_ok $wrapper, 'Clang::CastXML::Wrapper::darwin';

  my $exe = $wrapper->exe;
  note "exe = $exe";
  ok -x $exe, "exe is executable";

  my $version = $wrapper->version;
  note "version = $version";
  is $version, D();

};

subtest 'attributes' => sub {

  my $wrapper = Clang::CastXML::Wrapper::darwin->new(cc => 'clang++');
  isa_ok $wrapper, 'Clang::CastXML::Wrapper::darwin';

  is(
    $wrapper->castxml_cc,
    array {
      item '--castxml-cc-gnu-c';
      item '(';
      item match qr{^/.+/clang\+\+$};
      item '-isysroot';
      item match qr{^/Applications/.+\.sdk$};
      item ')';
    },
    'correct castxml preprocessor option (clang++)'
  );

  $wrapper = Clang::CastXML::Wrapper::darwin->new(cc => 'c++', cc_args => ['-march=native'], cc_id => 'gnu');
  isa_ok $wrapper, 'Clang::CastXML::Wrapper::darwin';

  is(
    $wrapper->castxml_cc,
    array {
      item '--castxml-cc-gnu';
      item '(';
      item match qr{^/.+/c\+\+$};
      item '-isysroot';
      item match qr{^/Applications/.+\.sdk$};
      item '-march=native';
      item ')';
    },
    'correct castxml preprocessor option (c++)'
  );


};

subtest 'raw version' => sub {

  my $wrapper = Clang::CastXML::Wrapper::darwin->new();
  isa_ok $wrapper, 'Clang::CastXML::Wrapper::darwin';

  my $exe = $wrapper->exe;
  note "exe = $exe";
  ok -x $exe, "exe is executable";

  my $version = $wrapper->raw('--version');

  is(
    $version,
    object {
      call [isa => 'Clang::CastXML::Wrapper::Result'] => T();
      call wrapper                                    => object {
        call [isa => 'Clang::CastXML::Wrapper::darwin'] => T();
      };
      call args       => ['--version'];
      call is_success => T();
      call out        => match qr/castxml version/;
      call err        => D();
      call ret        => 0;
      call sig        => 0;
    },
    'success'
  );

};

subtest 'introspect header' => sub {
  my $castxml = Clang::CastXML->new(wrapper =>
      Clang::CastXML::Wrapper::darwin->new(cc => 'c++', cc_args => ['-std=c++17'], aliens => ['Alien::corpus']));
  my $xml = $castxml->introspect(path('corpus/src/header.hpp'));

  is(
    $xml,
    object {
      call [isa => 'Clang::CastXML::Container'] => T();

    },
    'successfully created container'
  );

  is_well_formed_xml($xml->to_xml, 'xml is well formed');

};

done_testing;
