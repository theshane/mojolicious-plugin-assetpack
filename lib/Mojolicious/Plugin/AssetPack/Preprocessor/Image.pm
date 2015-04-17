package Mojolicious::Plugin::AssetPack::Preprocessor::Image;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AssetPack::Preprocessor::Image - Process images

=head1 DESCRIPTION

L<Mojolicious::Plugin::AssetPack::Preprocessor::Image> is a preprocessor for
processing images.

This module require L<Imager> and L<Imager::File::PNG> to be installed.

  $ apt-get install libpng12-dev
  $ cpanm Imager::File::PNG

=head1 SYNOPSIS

  # specify a directory to look for image files
  $app->asset("my-sprite.png" => "images/sprites");

  # the asset above will also make a css
  $app->asset("app.css" => "/packed/my-sprite.css");

=cut

use Mojo::Base 'Mojolicious::Plugin::AssetPack::Preprocessor';
use Mojolicious::Plugin::AssetPack::Asset::Image;
use constant IMAGER => eval 'use Imager;1' ? 1 : 0;

=head1 METHODS

=head2 asset

Returns an instance of L<Mojolicious::Plugin::AssetPack::Asset::Image>.

=cut

sub asset { Mojolicious::Plugin::AssetPack::Asset::Image->new }

=head2 can_process

Returns true if the L<Imager> module is installed.

=cut

sub can_process {IMAGER}

=head2 process

This method does nothing.

=cut

sub process {
  my ($self, $assetpack, $data, $path) = @_;
  return $self;
}

sub _url {'https://metacpan.org/release/Imager'}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Jan Henning Thorsen

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
