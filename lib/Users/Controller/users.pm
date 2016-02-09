package Users::Controller::Users;
use Mojo::Base 'Mojolicious::Controller';

sub list {
	my $self = shift;

	my %user_hash = $self->user_hash;
	$self->render(userhash => \%user_hash);
}

sub form {
	my $self = shift;

	my $username = $self->param('username');
	my $email = $self->param('email');
	my $pass = $self->param('pass');
	my $money = $self->param('money');
	$money =~ (s/([0-9]*)?(\,+([0-9]*))/$1\.$3/);
	my $date = $self->param('date');
	my $id = $self->param('id');
	my $user_email = $self->param('user_email');
	my $hidden_form = $self->param('hidden_form');
	my $hidden_list = $self->param('hidden_list');
	my ($title, $std, $filename, $fileuploaded, $filename, $error_name, $error_email, $error_email_v, $error_pass);
	my %user_hash = $self->user_hash;
	my %email_name = $self->email_name;
	my $img = $self->param('upload_file');

	if($img ne "") {
		$fileuploaded = $self->req->upload('upload_file');

		$filename = $fileuploaded->filename;

		if ($filename ne '') {
		my $user_file_name;

	   	 ($user_email) ? ($user_file_name = $user_email) : ($user_file_name = $email);
	     $fileuploaded->move_to("public/userfiles/$user_file_name.png");
	     $filename = "$user_file_name.png";
	    }
	    ($filename ne "") ? $filename = 'userfiles/'.$filename : "";
	}



	($hidden_list == 0) ? ($title = 'Редактирование пользователя:') : ($title = 'Добавление пользователя:'); 

	if ($title eq 'Добавление пользователя:') {
		#Добавление пользователя
		#validacia
		if ($hidden_form == 1) {
			($username eq "") ? ($error_name = 'name') : ($error_name = 1);
			($email_name{$email}) ? ($error_email_v = 'email_v') : ($error_email_v = 1);
			($email eq "") ? ($error_email = 'email') : ($error_email = 1);
			((length $pass) <= 5) ? ($error_pass = 'pass') : ($error_pass = 1);
			#($filename ne "") ? $filename = 'userfiles/'.$filename : "";
		} 

		#vstavka
		if (($error_name == 1) and ($error_email == 1) and ($error_email_v == 1) and ($error_pass == 1)) {
			#insert
			$std = $self->bd_con->prepare("INSERT INTO users (name, email, pass, money, created, img) 
								VALUES ('$username', '$email', md5('$pass'), '$money', '$date', '$filename')");
			$std->execute();
			$std->finish;

			$self->flash(new_user_name => $username, new_user_email => $email, new_user_money => $money);
			$self->redirect_to('/users');
		}
	} 

	if ($title eq 'Редактирование пользователя:') {
		#Редактирование пользователя
		#vstavka 
		if ($username or $email or $pass or $money or $date or $filename) {
			$self->flash(new_user_name => $user_hash{$id}{name}, new_user_email => $user_hash{$id}{email},
			new_user_money => $user_hash{$id}{money});
		}

		if ($username ne "") {
			$std = $self->bd_con->prepare(" UPDATE users set name='$username' where id='$id' "); 
			$std->execute(); 
			$std->finish; 
			$self->flash(new_user_name => $username);
		}

		if ($email ne "") {
			$std = $self->bd_con->prepare(" UPDATE users set email='$email' where id='$id' "); 
			$std->execute(); 
			$std->finish;
			$self->flash(new_user_email => $email);
		}

		if ((length $pass) >= 6) {
			$std = $self->bd_con->prepare(" UPDATE users set pass=md5('$pass') where id='$id' "); 
			$std->execute(); 
			$std->finish;
		} elsif ((length $pass) == 0) {
		} else {
			$hidden_form == 1 ? $error_pass = 'pass' : "";
		}

		if ((length $money) >= 1) {
			$std = $self->bd_con->prepare(" UPDATE users set money='$money' where id='$id' "); 
			$std->execute(); 
			$std->finish;
			$self->flash(new_user_money => $money);
		}

		if ($date ne "") {
			$std = $self->bd_con->prepare(" UPDATE users set created='$date' where id='$id' "); 
			$std->execute(); 
			$std->finish;
		}

		if ($filename ne "") {
			#($filename ne "") ? $filename = 'userfiles/'.$filename : "";
			$std = $self->bd_con->prepare(" UPDATE users set img='$filename' where id='$id' "); 
			$std->execute(); 
			$std->finish;
		}

		if (($username ne "") or ($email ne "") or ((length $pass) >= 6) or ($money ne "") or ($date ne "") or ($img ne "")) {
			$self->flash(flash_check => 'check');
			$self->redirect_to('/users');
		}
	}

	$self->render(error_name => $error_name, error_email => $error_email, error_email_v => $error_email_v,
	error_pass => $error_pass, title => $title, user_id => $id, user_email => $user_email);
}

sub remove {
	my $self = shift;

	my $id = $self->param('id');
	my %user_hash = $self->user_hash;
	$self->flash(new_user_name => $user_hash{$id}{name}, new_user_email => $user_hash{$id}{email},
		new_user_money => $user_hash{$id}{money});
	$self->flash(flash_check_remove => 'check');

	my $std = $self->bd_con->prepare("DELETE FROM users WHERE id='$id' ");
	$std->execute();
	$std->finish;
	$self->redirect_to('/users');
}

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

sub check {
	my $self = shift;

	my @user_check = $self->user_info;
	$self->render(text => "id: $user_check[0]<br>name: $user_check[1]<br>email: $user_check[2]<br>
		password: $user_check[3]<br>sex: $user_check[4]<br>money: $user_check[5]<br>
		updated: $user_check[6]<br>created: $user_check[7]<br>img:<br>
		<img src=\"$user_check[8]\" width=100 heigth=100 alt=\"\"> ");
}

1;
