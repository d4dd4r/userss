package Users::Controller::Websocket;
use Mojo::Base 'Mojolicious::Controller';

my $clients = {};


sub ws {
	my $self = shift;

	$self->inactivity_timeout(3600);

	my $id = sprintf "%s", $self->tx;
	$clients->{$id} = $self->tx;

	$self->on(message => sub {
		my ($self, $lol) = @_;

		for (keys %$clients) {
		  $clients->{$_}->send($lol);
		}

	});
}



1;
