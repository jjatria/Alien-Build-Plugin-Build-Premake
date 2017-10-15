use strict;
use warnings;

package Alien::Build::Plugin::Build::Premake;
# ABSTRACT: Premake build plugin for Alien::Build

our $VERSION = '0.001';

use Alien::Build::Plugin;

has os           => sub { undef };
has cc           => sub { undef };
has dc           => sub { undef };
has dotnet       => sub { undef };
has fatal        => sub { undef };
has file         => sub { undef };
has insecure     => sub { undef };
has scripts      => sub { undef };
has systemscript => sub { undef };

has action => 'gmake';

sub init {
  my ($self, $meta) = @_;

  $meta->add_requires( 'share', Alien::premake => '0.001' );
  $meta->add_requires( 'configure',
    Alien::Build::Plugin::Build::Premake => '0.001'
  );

  $meta->interpolator->add_helper(
    premake => sub {
      my @cmd = 'premake5';

      foreach my $key (qw( cc dc dotnet file os scripts systemscript )) {
        my $val = $self->$key;
        push @cmd, "--$key=$val" if defined $val;
      }

      foreach my $key (qw( fatal insecure )) {
        push @cmd, "--$key" if defined $self->$key;
      }

      return join ' ', @cmd;
  );

  $meta->default_hook(
    build => [
      '%{premake} ' . $self->action,
      '%{make}',
      '%{make} install',
    ]
  );

}

1;
