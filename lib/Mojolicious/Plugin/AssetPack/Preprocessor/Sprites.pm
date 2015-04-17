package Mojolicious::Plugin::AssetPack::Preprocessor::Sprites;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AssetPack::Preprocessor::Sprites - Create image sprites

=head1 DESCRIPTION

L<Mojolicious::Plugin::AssetPack::Preprocessor::Sprites> is a preprocessor for
making sprites from image files.

This module require L<Imager> to be installed.

=head1 SYNOPSIS

  # specify a directory to look for image files
  $app->asset("my-sprite.png" => "images/sprites");

  # the asset above will also make a css
  $app->asset("app.css" => "/packed/my-sprite.css");

=cut

use Mojo::Base 'Mojolicious::Plugin::AssetPack::Preprocessor';
use constant IMAGER => eval 'use Imager;1' ? 1 : 0;

=head1 METHODS

=head2 can_process

Returns true if the L<Imager> module is installed.

=cut

sub can_process {IMAGER}

=head2 process

This method use L<Imager> to process the assets.

=cut

sub process {
  my ($self, $assetpack, $text, $path) = @_;

  warn length $$text;

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
