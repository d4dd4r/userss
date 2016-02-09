package Users;
use DBI;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  $self->plugin('Helper');

  my $r = $self->routes;

  #controller => websocket
  $r->websocket('/ws')->to(controller => 'websocket', action => 'ws');
  $r->any('/square')->  to(controller => 'websocket', action => 'square');


  #controller => login
  $r->any('/login')->         to(controller => 'login', action => 'login');
  my $auth = $r->under('/')-> to(controller => 'login', action => 'authorize');
  $auth->any('/')->           to(controller => 'login', action => 'authorize');


  #controller => users
  $auth->any('/users')->            to(controller => 'users', action => 'list');
  $auth->any('/users/add')->        to(controller => 'users', action => 'form');
  $auth->any('/users/:id/edit')->   to(controller => 'users', action => 'form');
  $auth->any('/users/:id/remove')-> to(controller => 'users', action => 'remove');
  $auth->any('/users/search')->     to(controller => 'users', action => 'search');
  $auth->any('/check')->            to(controller => 'users', action => 'check');

  #controller => api 2 варианта
  $r->any('/api/users')->           to(controller => 'api', action => 'search');
  $r->any('/api/users/search')->    to(controller => 'api', action => 'api');


  
  


}

1;
