package App::PM::Announce::Feed::meetup;

use warnings;
use strict;

use Moose;
extends 'App::PM::Announce::Feed';

has venue => qw/is ro/;

sub announce {
    my $self = shift;
    my %event = @_;

    my $username = $self->username;
    my $password = $self->password;
    my $uri = $self->uri;
    my $venue = $event{venue} || $self->venue;
    my $datetime = $event{datetime};

    $self->get("http://www.meetup.com/login/");

    $self->logger->debug( "Login as $username / $password" );

    $self->submit_form(
        fields => {
            email => $username,
            password => $password,
        },
        form_number => 1,
        button => 'submitButton',
    );

    die "Wasn't logged in" unless $self->content =~ m/Your Meetup Groups/;

    $self->get($uri);

    my $hour12 = $datetime->hour;
    $hour12 -= 12 if $hour12 > 12;
    $hour12 = 12 unless $hour12;
    $self->submit_form(
        fields => {
            title => $self->format( \%event => 'title' ),
            description => $self->format( \%event => 'description' ),
            venueId => $venue,
            origId => $venue,
            'event.day' => $datetime->day,
            'event.month' => $datetime->month,
            'event.year' => $datetime->year,
            'event.hour12' => $hour12,
            'event.minute' => $datetime->minute,
            'event.ampm' => $datetime->hour >= 12 ? 'PM' : 'AM',
        },
        form_number => 1,
        button => 'submit_next',
    );

    my $tree = $self->tree;

    die "Unable to parse HTML" unless $tree;

    my $a = $tree->look_down( _tag => 'a', sub { $_[0]->as_text =~ m/Or, go straight to this Meetup's page/ } );

    die "Not sure if discussion was posted (couldn't find success link)" unless $a;

    my $href = $a->attr( 'href' );

    my $meetup_link = URI->new( $href );
    $meetup_link->query( undef );

    $self->logger->debug( "Submitted to meetup at $uri" );

    return { meetup_link => $meetup_link };
}

1;
