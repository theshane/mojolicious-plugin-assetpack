package Mojolicious::Plugin::AssetPack::Preprocessor::Scss;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AssetPack::Preprocessor::Scss - Preprocessor for .scss files

=head1 DESCRIPTION

L<Mojolicious::Plugin::AssetPack::Preprocessor::Scss> is a preprocessor for
C<.scss> files. This module inherite all the functionality from
L<Mojolicious::Plugin::AssetPack::Preprocessor::Sass>.

You need either the "sass" executable or the cpan module L<CSS::Sass> to make
this module work:

  $ sudo apt-get install rubygems
  $ sudo gem install sass

  ...

  $ sudo cpanm CSS::Sass

You can force using the executable by setting the environment variable
C<ENABLE_LIBSASS_BINDINGS> to a false value.

=head1 COMPASS

Compass is an open-source CSS Authoring Framework built on top of L</sass>.
See L<http://compass-style.org/> for more information.

Installation on Ubuntu and Debian:

  $ sudo apt-get install rubygems
  $ sudo gem install compass

This module will try figure out if "compass" is required to process your
C<*.scss> files. This is done with this regexp on the top level sass file:

  m!\@import\W+compass\/!;

NOTE! Compass support is experimental and you probably have to set
C<ENABLE_LIBSASS_BINDINGS> to a false value to make it work.

You can disable compass detection by setting the environment variable
C<MOJO_ASSETPACK_NO_COMPASS> to a true value.

=cut

use Mojo::Base 'Mojolicious::Plugin::AssetPack::Preprocessor';
use Mojo::Util qw( slurp md5_sum );
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';
use File::Which ();
use File::Which ();
use constant LIBSASS_BINDINGS => defined $ENV{ENABLE_LIBSASS_BINDINGS}
  ? $ENV{ENABLE_LIBSASS_BINDINGS}
  : eval 'require CSS::Sass;1';

$ENV{SASS_PATH} ||= '';

=head1 ATTRIBUTES

=head2 executable

  $path = $self->executable;

Holds the path to the "sass" executable. Default to just "sass".

=cut

has executable => sub { File::Which::which('sass') || 'sass' };

=head1 METHODS

=head2 can_process

Returns true if L</executable> points to an actual file.

=cut

sub can_process { LIBSASS_BINDINGS || -f $_[0]->executable }

=head2 checksum

Returns the checksum for the given C<$text>, but also checks for any
C<@import> statements and includes those files in the checksum.

See L<Mojolicious::Plugin::AssetPack::Preprocessor/process>.

=cut

sub checksum {
  my ($self, $text, $path) = @_;
  my $ext      = $path =~ /\.(s[ac]ss)$/ ? $1 : $self->_extension;
  my $dir      = dirname $path;
  my $re       = qr{ \@import \s+ (["']) (.*?) \1 }x;
  my @checksum = md5_sum $$text;

  local $self->{checked} = $self->{checked} || {};

  while ($$text =~ /$re/gs) {
    my $path = $self->_file($dir, $2, $ext) or next;
    $self->{checked}{$path}++ and next;
    push @checksum, $self->checksum(\slurp($path), $path);
  }

  return Mojo::Util::md5_sum(join '', @checksum);
}

sub _file {
  my ($self, $dir, $name, $ext) = @_;
  my $path;
  return $path if -r ($path = catfile $dir, "$name.$ext");
  return $path if -r ($path = catfile $dir, "_$name.$ext");
  return;
}

=head2 process

This method use "sass" to process C<$text>.

See L<Mojolicious::Plugin::AssetPack::Preprocessor/process>.

=cut

sub process {
  my ($self, $assetpack, $text, $path) = @_;
  my $err;

  if (LIBSASS_BINDINGS) {
    my %args = (include_paths => [dirname($path), split /:/, $ENV{SASS_PATH}]);
    $args{output_style} = CSS::Sass::SASS_STYLE_COMPRESSED() if $assetpack->minify;
    ($$text, $err, my $srcmap) = CSS::Sass::sass_compile($$text, %args);
    die $err if $err;
  }
  else {
    my @cmd = ($self->executable, '--stdin', '--scss', '-I' => dirname $path);
    push @cmd, qw( -t compressed) if $assetpack->minify;
    push @cmd, qw( --compass ) if !$ENV{MOJO_ASSETPACK_NO_COMPASS} and $$text =~ m!\@import\W+compass\/!;
    $self->_run(\@cmd, $text, $text);
  }

  return $self;
}

sub _extension {'scss'}
sub _url       {'http://sass-lang.com/install'}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Jan Henning Thorsen

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
