package CS::Command::flags;
use Mojo::Base 'Mojolicious::Command';

has description => 'Get flags';

sub run {
  my $self = shift;
  my $app  = $self->app;

  Mojo::IOLoop->server(
    {port => $app->config->{cs}{flags}{port}, reuse => 1} => sub {
      my ($loop, $stream, $id, $do, $lock) = @_;
      return $stream->close unless $app->model('util')->game_status == 1;

      my $buffer = '';
      $stream->timeout($app->config->{cs}{flags}{timeout});

      $stream->on(error => sub { $app->log->error("[flags] [$id] stream error: $_[1]") });
      $stream->on(close => sub { undef $do; $app->log->info("[flags] [$id] close stream") });
      $stream->on(read  => sub { $buffer .= $_[1]; $do->(); });

      my $checked = 0;
      my $team_id = 0;
      $stream->write("Enter your team ip in the first line (or empty line to exit)\n");

      $do = sub {
        return if $lock;
        if ((my $index = index $buffer, "\n") != -1) {
          if ($checked == 1) {
            my $flag = substr $buffer, 0, $index + 1, '';
            $flag =~ s/\r?\n$//;
            return $stream->write("Goodbye!\n" => sub { $stream->close }) unless length $flag;

            $lock = 1;
            $app->model('flag')->accept(
              $team_id, $flag,
              sub {
                my $msg = $_[0]->{ok} ? $_[0]->{message} : $_[0]->{error};
                $app->log->info("[flags] [$team_id:$id] input flag '$flag' result '$msg'");
                $stream->write("$msg\n");
                undef $lock;
                $do->() if $do;
              }
            );
          } else {
            my $ip = substr $buffer, 0, $index + 1, '';
            $ip =~ s/\r?\n$//;
            return $stream->write("Goodbye!\n" => sub { $stream->close }) unless length $ip;
            $lock = 1;

            $team_id = $app->model('util')->team_id_by_address($ip);
            return $stream->write("Your IP address $ip is unknown\n" => sub { $stream->close }) unless $team_id;

            $checked = 1;
            $stream->write("Enter your flags, finished with newline (or empty line to exit)\n");
            undef $lock;
            $do->() if $do;
          };
        }
      };
    }
  );
  Mojo::IOLoop->start;
}

1;
