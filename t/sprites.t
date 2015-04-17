use t::Helper;

my $t = t::Helper->t({minify => 1});

plan skip_all => 'Could not find preprocessors for sprites' unless $t->app->asset->preprocessors->can_process('png');

$t->app->asset('my-sprites.png' => qw( /images/sprite/media-skip-forward.png /images/sprite/media-stop.png ));

is(Mojolicious::Plugin::AssetPack::Preprocessor::Image->_url, 'https://metacpan.org/release/Imager', '_url');

done_testing;

__DATA__
@@ test1.html.ep
%= asset 'my-sprites.css', {inline => 1}
