package App::PM::Announce::Feed::greymatter121c;

use warnings;
use strict;

use Moose;
extends 'App::PM::Announce::Feed';

has uri => qw/is ro required 1/;

sub announce {
    my $self = shift;
    my %event = @_;

    my $username = $self->username;
    my $password = $self->password;
    my $uri = $self->uri;

    $self->logger->debug( "login as $username/$password" );

    $self->post(
        $uri => {
            authorname => $username,
            authorpassword => $password,
            newentrysubject => $self->format( \%event => 'title' ),
            newentrymaintext => $self->format( \%event => 'description' ),
            newentrymoretext => '',
            newentryallowkarma => 'no',
            newentryallowcomments => 'no',
            newentrystayattop => 'no',
            thomas => 'Add This Entry',
        },
    );

    die "Wasn't able to add a new greymatter entry" unless $self->content =~ m/Your new entry has been added/;

    $self->logger->debug( "submitted to greymatter121c at $uri" );

#    This isn't necessary since greymatter does this automatically
#    my $rebuild_uri = URI->new( $uri );
#    $rebuild_uri->query( "authorname=$username&authorpassword=$password&thomas=rebuildupdate&rebuilding=everything&rebuildfrom=1&connectednumber=" );
#    $self->get( $uri );
}

1;
