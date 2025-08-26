package Alien::corpus;
use strict;
use warnings;
use Path::Tiny qw( path );
sub cflags { return join '', -I => path('corpus/include')->absolute->stringify }

package main;
use Test2::V0 -no_srand => 1;

use Clang::CastXML;
use Clang::CastXML::Wrapper::darwin;
use Path::Tiny qw( path );
use Test::XML;

plan skip_all => 'This test is for macOS only'                 unless $^O eq 'darwin';
plan skip_all => 'This test requires macports to be installed' unless -d '/opt/local' && -d '/opt/local/var/macports';
plan skip_all => 'This test requires macports to be installed' unless -x '/opt/local/bin/port';

subtest 'introspect header' => sub {

  plan skip_all => 'This test requires llvm-19 port to be installed' unless -d '/opt/local/libexec/llvm-19';

  my $castxml = Clang::CastXML->new(
    wrapper => Clang::CastXML::Wrapper::darwin->new(
      cc      => '/opt/local/libexec/llvm-19/bin/clang++',
      cc_args => ['-march=native'],
      aliens  => ['Alien::corpus']
    )
  );
  my $xml = $castxml->introspect(path('corpus/src/header.hpp'));

  is(
    $xml,
    object {
      call [isa => 'Clang::CastXML::Container'] => T();

    },
    'container creation successful'
  );

  is_well_formed_xml($xml->to_xml, 'XML generated is well formed');
};

done_testing;
