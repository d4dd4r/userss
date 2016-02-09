package Helper;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  $app->helper(bd_con => sub {
	  my $self = shift;

	  my $dsn = "dbi:mysql:test:10.0.0.126";
	  my $connect = DBI->connect($dsn, 'test', 111222);
	  #return $connect;
  });
  $app->helper(user_hash => sub {
	  my $self = shift;

	  my %user_hash;

	  my $sth = $self->bd_con->prepare('SELECT * FROM users');
	  $sth->execute();
 
	  while(my $user = $sth->fetchrow_hashref()){     
   		  $user_hash{$user->{id}} = {id => $user->{id}, name => $user->{name},
   		  email => $user->{email}, pass => $user->{pass}, sex => $user->{sex},
   		  money => $user->{money}, updated => $user->{updated}, 
   		  created => $user->{created}, img => $user->{img}};
	  }
	  
	  $sth->finish;
	  return %user_hash;
  });
  $app->helper(email_name => sub {
	  my $self = shift;

	  my %email;
	  my $sth = $self->bd_con->prepare('SELECT * FROM users');
	  $sth->execute();

	  while(my $user = $sth->fetchrow_hashref()) {     
	  	$email{$user->{email}} = $user->{pass}; 
	  }

	  $sth->finish;
	  return %email;
  });
  $app->helper(user_info => sub {
	  my $self = shift;

	  my (@user_info, $session);
	  $session = $self->session('user');
	  my $sth = $self->bd_con->prepare("SELECT * FROM users WHERE email='$session' ");
	  $sth->execute();
	  while(my @user = $sth->fetchrow_array) {   
	  	@user_info = @user;
	  }

	  return @user_info;
  });
}

1;