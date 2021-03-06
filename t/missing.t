use t::Helper;
use File::Spec::Functions qw( catdir catfile );

$ENV{PATH} = catdir(Cwd::getcwd, 't', 'bin');
plan skip_all => 'Require t/bin/coffee to make failing test' unless -x catfile $ENV{PATH}, 'coffee';

my @res = (
  {
    coffee  => '/packed/c-accff0dbd3d143a751e4d54eea182cfa.err.js',
    invalid => '/packed/dummy-81e6a22b62fc6e28e355713517fdc3d8.err.foo',
  },
  {
    coffee  => '/packed/coffee-accff0dbd3d143a751e4d54eea182cfa.err.js',
    invalid => '/packed/invalid-81e6a22b62fc6e28e355713517fdc3d8.err.foo',
  }
);

for my $x (0, 1) {
  $ENV{MOJO_MODE} = $x ? 'production' : 'development';
  my $t = t::Helper->t({minify => $x});

  $ENV{EXITCODE} = 42;
  $t->app->asset('coffee.js'   => '/js/c.coffee');
  $t->app->asset('invalid.foo' => '/dummy.foo');

  $t->get_ok('/test1')->status_is(200);

  my %src = (
    coffee  => eval { $t->tx->res->dom->at('script[src]')->{src} },
    invalid => eval { $t->tx->res->dom->find('link[href]')->[0]{href} },
  );

  is_deeply(\%src, shift(@res), 'found elements');

  $t->get_ok($src{coffee})->status_is(200)->content_unlike(qr{[\n\r]})
    ->content_like(qr{^alert\('c\.coffee: Failed to run .*coffee.*\(\$\?=42, \$!=\d+\) Whoopsie'\);console\.log},
    "coffee 42 ($x)");

  $t->get_ok($src{invalid})->status_is(200)
    ->content_like(qr/^html:before\{.*content:"dummy\.foo: No preprocessor defined for .*dummy\.foo";\}/,
    "invalid ($x)");

  # error files are always generated
  $ENV{EXITCODE} = 31;
  $t->app->asset('coffee.js' => '/js/c.coffee');
  $t->get_ok($src{coffee})->status_is(200)->content_unlike(qr{[\n\r]})
    ->content_like(qr{^alert\('c\.coffee: Failed to run .*coffee.*\(\$\?=31, \$!=\d+\) Whoopsie'\);console\.log},
    "coffee 31 ($x)");
}

done_testing;
__DATA__
@@ test1.html.ep
%= asset 'coffee.js'
%= asset 'invalid.foo'
