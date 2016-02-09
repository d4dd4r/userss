package Users::Controller::Api;
use Mojo::Base 'Mojolicious::Controller';

my $clients = {};


sub search {
	my $self = shift;

	my $search = $self->param('search');
	my $json = $self->param('json');
	my %user_hash;

	$search ? (my $user_query = "SELECT * FROM users WHERE name LIKE ? or email LIKE ?") : "";

	my $sth = $self->bd_con->prepare($user_query);
	$sth->execute('%'.$search.'%', '%'.$search.'%');

	while(my $user = $sth->fetchrow_hashref()){     
   		  $user_hash{$user->{id}} = {id => $user->{id}, name => $user->{name},
   		  email => $user->{email}, pass => $user->{pass}, sex => $user->{sex},
   		  money => $user->{money}, updated => $user->{updated}, 
   		  created => $user->{created}, img => $user->{img}};
	  }
	  $sth->finish;

	#Вариант 1 (поиск апи при условии)
	($json == 1) ? ($self->render(json => {status => 'ok', list => \%user_hash})) : ($self->render(userhash => \%user_hash));
}

sub api {
	my $self = shift;

	my $search = $self->param('search');

	#Вариант 2 (поиск апи)
	if ($search ne "") {
		my %user_hash;

		my $user_query = ("SELECT * FROM users WHERE name LIKE ? or email LIKE ?");

		my $sth = $self->bd_con->prepare($user_query);
		$sth->execute('%'.$search.'%', '%'.$search.'%');

		while(my $user = $sth->fetchrow_hashref()){     
	   		  $user_hash{$user->{id}} = {id => $user->{id}, name => $user->{name},
	   		  email => $user->{email}, pass => $user->{pass}, sex => $user->{sex},
	   		  money => $user->{money}, updated => $user->{updated}, 
	   		  created => $user->{created}, img => $user->{img}};
		  }
		  $sth->finish;

		#пробеложесть
		my $render = "                                                                                                                                                                                                                   status => 'ok',                                                                                                                                                                                                                    list => [";
		for (reverse (sort keys %user_hash)) {
			$render .= "{id:$user_hash{$_}{id} name:$user_hash{$_}{name} email:$user_hash{$_}{email} pass:$user_hash{$_}{pass} sex:$user_hash{$_}{sex} money:$user_hash{$_}{money} updated:$user_hash{$_}{updated} created:$user_hash{$_}{created} img:$user_hash{$_}{img}},                                                                                                         ";
		}
		$render =~ s/(.*)(\,\s*$)/$1/;
		$render .= "]";

		$self->render(json => '{'.$render.'                                                                                                                                                                                                                   }');
	}
}

1;
