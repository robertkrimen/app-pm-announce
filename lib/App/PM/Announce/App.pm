package App::PM::Announce::App;

use warnings;
use strict;

use Getopt::Chain;
use App::PM::Announce;
use DateTime;
use Text::Table;

my $app;
sub app {
    return $app ||= App::PM::Announce->new;
}

sub run {
    Getopt::Chain->process(
        run => sub {
            my ($context, @arguments) = @_;
            return if @arguments;
            print <<_END_;

The only thing you can do right now:

    $0 test

Which will submit an announcement to:

    robert...krimen\@gmail.com / test8378 \@ http://www.meetup.com/The-San-Francisco-Beta-Tester-Meetup-Group/calendar/?action=new
    robertkrimen+alice8378\@gmail.com / test8378 \@ http://www.linkedin.com/groupAnswers?start=&gid=1873425
    alice8378 / test8378 \@ http://72.14.179.195/cgi-bin/greymatter/gm.cgi

_END_
        },
        commands => {
            test => sub {
                my ($context, @arguments) = @_;
                $app = App::PM::Announce->new(config_default => {
                    feed => {
                        meetup => {qw{
                            username robert...krimen@gmail.com
                            password test8378
                            uri http://www.meetup.com/The-San-Francisco-Beta-Tester-Meetup-Group/calendar/?action=new
                        }},
                        linkedin => {qw{
                            username robertkrimen+alice8378@gmail.com
                            password test8378
                            uri http://www.linkedin.com/groupAnswers?start=&gid=1873425
                        }},
                        greymatter121c => {qw{
                            username alice8378
                            password test8378
                            uri http://72.14.179.195/cgi-bin/greymatter/gm.cgi
                        }},
                    },
                });

                my $key = int rand $$;
                my $description = join ' ', @arguments;
                $description ||= 'Default description';
                app->announce(
                    title => "$description ($key)",
                    description => "$description ($key)",
                    venue => 920502,
                    datetime => DateTime->now->add(days => 10),
                );
            },
            template => sub {
                my ($context, @arguments) = @_;
                print STDOUT app->template;
            },
            announce => sub {
                my ($context, @arguments) = @_;
                app->announce( \*STDIN );
            },
            history => sub {
                my ($context, @arguments) = @_;
                my $query = shift @arguments;
                if ($query) {
                    my $event = app->history->find( $query );
                    my $data = $event->{data};
                    {
                        no warnings 'uninitialized';
                        print <<_END_;

$event->{uuid}
$data->{title}
$data->{meetup_uri}

_END_
                    }
                }
                else {
                    my @all = app->history->all;
                    my @table = map {
                        my $data = $_->{data};
                        my $did;
                        $did += $data->{"did_$_"} ? 1 : 0 for qw/meetup linkedin greymatter121c/;
                        [ join ' | ', $_->{uuid}, $data->{title}, $_->{insert_datetime}, "$did/3" ];
                    } app->history->all;
                    print "\n", Text::Table->new->load( @table ), "\n";
                }
            },
        },
    );
}

1;
