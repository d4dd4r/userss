package Users::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use Digest::MD5 qw(md5_hex);

sub authorize {
	my $self = shift;

	return 1 if ($self->session('authorized') eq 'authorized');
	$self->redirect_to('/login');
}

sub login {
	my $self = shift;
	my %check = $self->email_name;
	my $email = $self->param('email');
	my $password = md5_hex($self->param('password'));

	delete $self->session->{authorized};
	delete $self->session->{user};

	if (($check{$email} eq $password) and ($email ne "")) {
		$self->session(user => $email);
		$self->session(authorized => 'authorized');
		$self->redirect_to('/users');
	} 
}

1;
