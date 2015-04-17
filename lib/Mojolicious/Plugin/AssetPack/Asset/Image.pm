package Mojolicious::Plugin::AssetPack::Asset::Image;

=head1 NAME

Mojolicious::Plugin::AssetPack::Asset::Image - Image asset

=head1 VERSION

0.01

=head1 DESCRIPTION

L<Mojolicious::Plugin::AssetPack::Asset::Image> is a sub class
of L<Mojolicious::Plugin::AssetPack::Asset>.

=cut

use Mojo::Base 'Mojolicious::Plugin::AssetPack::Asset';

eval 'use Imager';

=head1 METHODS

=head2 process

=cut

sub process {
  my ($self, $assetpack, $sources) = @_;
  my $image = Imager->new(xsize => 400, ysize => 400, channels => 4);
  my ($x, $y) = (0, 0);

  $self->{content} = '';

  for my $source (@$sources) {
    my $src = Imager->new;
    $src->read(data => \$source->slurp, type => 'png') or die $src->errstr;
    $image->paste(src => $src, left => $x, top => $y) or die $image->errstr;
    $y += $src->getheight + 1;
  }

  $image->write(data => \$self->{content}, type => 'png') or die $image->errstr;

  return $self;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Jan Henning Thorsen

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
