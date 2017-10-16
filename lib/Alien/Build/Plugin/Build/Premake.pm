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

  $meta->add_requires( 'share', 'Alien::premake' => '0.001' );
  $meta->add_requires( 'configure',
    'Alien::Build::Plugin::Build::Premake' => '0.001'
  );

  $meta->interpolator->add_helper(
    premake => sub {
      my @cmd = 'premake5';

      foreach my $key (qw( cc dc dotnet file os scripts systemscript )) {
        my $val = $self->$key;
        next unless defined $val;
        next if $key eq 'os' and $val eq $self->os_string;
        push @cmd, "--$key=$val" if $val;
      }

      foreach my $key (qw( fatal insecure )) {
        push @cmd, "--$key" if defined $self->$key;
      }

      return join ' ', @cmd;
    },
  );

  $meta->default_hook(
    build => [
      '%{premake} ' . $self->action,
      '%{make}',
      '%{make} install',
    ]
  );

}

sub os_string {
  my ($self) = shift;

  my $os = '';
  for ($^O) {
       if (/aix/i)     { $os = 'aix' }
    elsif (/bsd/i)     { $os = 'bsd' }
    elsif (/darwin/i)  { $os = 'macosx' }
    elsif (/haiku/i)   { $os = 'haiku' }
    elsif (/hurd/i)    { $os = 'hurd' }
    elsif (/linux/i)   { $os = 'linux' }
    elsif (/mswin32/i) { $os = 'windows' }
    elsif (/solaris/i) { $os = 'solaris' }
  }

  return $os;
}

1;
