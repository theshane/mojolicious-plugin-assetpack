use warnings;
use strict;
use Test::More;
use Test::Mojo;

plan skip_all => 'Not ready for alien host' unless $^O eq 'linux';

{
  use Mojolicious::Lite;
  plugin 'Compress';
  get '/js' => 'js';
  get '/less' => 'less';
  get '/sass' => 'sass';
  get '/css' => 'css';
}

my $t = Test::Mojo->new;

if($Mojolicious::Plugin::Compress::APPLICATIONS{js}) {
  $t->get_ok('/js')
    ->status_is(200)
    ->content_like(qr{<script src="/js/a\.js".*<script src="/js/b\.js"}m)
    ;
}

if($Mojolicious::Plugin::Compress::APPLICATIONS{less}) {
  $t->get_ok('/less')
    ->status_is(200)
    ->content_like(qr{<link href="/css/a\.css".*<link href="/css/b\.css"}m)
    ;

  unlink 't/public/css/a.css', 't/public/css/b.css';
}

if($Mojolicious::Plugin::Compress::APPLICATIONS{scss}) {
  $t->get_ok('/sass')
    ->status_is(200)
    ->content_like(qr{<link href="/css/a\.css".*<link href="/css/b\.css"}m)
    ;

  unlink 't/public/css/a.css', 't/public/css/b.css';
}

{
  $t->get_ok('/css')
    ->status_is(200)
    ->content_like(qr{<link href="/css/a\.css".*<link href="/css/b\.css"}m)
    ;
}

done_testing;
__DATA__
@@ js.html.ep
%= compress '/js/a.js', '/js/b.js'
@@ less.html.ep
%= compress '/css/a.less', '/css/b.less'
@@ sass.html.ep
%= compress '/css/a.scss', '/css/b.scss'
@@ css.html.ep
%= compress '/css/a.css', '/css/b.css'