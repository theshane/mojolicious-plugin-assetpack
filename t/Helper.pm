package t::Helper;
use Mojo::Base -strict;
use Mojolicious;
use Test::Mojo;
use Test::More;
use Cwd ();
use File::Basename 'dirname';
use File::Spec;

sub t {
  my ($class, $args) = @_;
  my $t = Test::Mojo->new(Mojolicious->new);

  $t->app->static->paths([Cwd::abs_path(File::Spec->catdir(dirname($0), 'public'))]);
  $t->app->plugin(AssetPack => $args || {});
  $t->app->routes->get("/test1" => 'test1');
  $t;
}

sub import {
  my $class  = shift;
  my $caller = caller;

  unlink glob 't/public/packed/*' unless $ENV{TEST_KEEP_FILES};

  strict->import;
  warnings->import;

  eval <<"  CODE" or die $@;
  package $caller;
  use Test::More;
  use Test::Mojo;
  1;
  CODE
}

1;
