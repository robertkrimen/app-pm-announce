package App::PM::Announce;

use warnings;
use strict;

=head1 NAME

App::PM::Announce -

=head1 VERSION

Version 0.01_1

=cut

our $VERSION = '0.01_1';

use Moose;
with 'MooseX::LogDispatch';

use File::HomeDir;
use Path::Class;
use Config::JFDI;
use Config::General;
use String::Util qw/trim/;

use App::PM::Announce::Feed::meetup;
use App::PM::Announce::Feed::linkedin;
use App::PM::Announce::Feed::greymatter121c;

sub BUILD {
    my $self = shift;
    $self->startup;
}

has home_dir => qw/is ro lazy_build 1/;
sub _build_home_dir {
    my @home_dir;
    @home_dir = map { exists $ENV{$_} && defined $ENV{$_} ? $ENV{$_} : () } qw/APP_PM_ANNOUNCE_HOME/; # Don't want to write $ENV{...} twice
    @home_dir = ( File::HomeDir->my_data, '.app-pm-announce' ) unless @home_dir;
    return dir( @home_dir );
}

has config_file => qw/is ro lazy_build 1/;
sub _build_config_file {
    return shift->home_dir->file( 'config' );
}

has config_default => qw/is ro isa HashRef lazy_build 1/;
sub _build_config_default {
    return {};
}

#has _config => qw/is ro isa Config::JFDI lazy_build 1/;
#sub _build__config {
#    my $self = shift;
#    return Config::JFDI->new(file => $self->config_file);
#}

#sub config {
#    return shift->_config->get;
#}

has config => qw/is ro isa HashRef lazy_build 1/;
sub _build_config {
    my $self = shift;
    return { Config::General->new(
        -ConfigFile => $self->config_file,
        -DefaultConfig => $self->config_default,
    )->getall };
}

has feed => qw/is ro isa HashRef lazy_build 1/;
sub _build_feed {
    my $self = shift;
    return { 
        meetup => $self->_build_meetup_feed,
        linkedin => $self->_build_linkedin_feed,
        greymatter121c => $self->_build_greymatter121c_feed,
    };
}

sub _build_meetup_feed {
    my $self = shift;
    return undef unless my $given = $self->config->{feed}->{meetup};
    return App::PM::Announce::Feed::meetup->new(
        app => $self,
        username => $given->{username},
        password => $given->{password},
        uri => $given->{uri},
        venue => $given->{venue},
    );
}

sub _build_greymatter121c_feed {
    my $self = shift;
    return undef unless my $given = $self->config->{feed}->{greymatter121c};
    return App::PM::Announce::Feed::greymatter121c->new(
        app => $self,
        username => $given->{username},
        password => $given->{password},
        uri => $given->{uri},
    );
}

sub _build_linkedin_feed {
    my $self = shift;
    return undef unless my $given = $self->config->{feed}->{linkedin};
    return App::PM::Announce::Feed::linkedin->new(
        app => $self,
        username => $given->{username},
        password => $given->{password},
        uri => $given->{uri},
    );
}

sub startup {
    my $self = shift;

    my $home_dir = $self->home_dir;
    $self->logger->debug( "home_dir is $home_dir" );

    unless (-d $home_dir) {
        $self->logger->debug( "making $home_dir because it does not exist" );
        $home_dir->mkpath;
    }

    my $config_file = $self->config_file;
    $self->logger->debug( "config_file is $config_file" );

    unless (-f $config_file) {
        $self->logger->debug( "making $config_file stub because it does not exist" );
        $config_file->openw->print( <<_END_ );
# This is a config stub
_END_
    }
}



sub announce {
    my $self = shift;
    my %event = @_;

    { # Validate, parse, and filter.

        $event{$_} = trim $event{$_} for qw/title venue/;

        die "Wasn't given a title for the event" unless $event{title};

        die "Wasn't given a venue for the event" unless $event{venue};

        die "Wasn't given a date & time for the event" unless $event{datetime};
        die "The date & time isn't a DateTime object" unless $event{datetime}->isa( 'DateTime' );
    }

    my $result;

    $result = $self->feed->{meetup}->announce( %event );

    $event{description} = [ $event{description}, $result->{meetup_uri} ];

    $result = $self->feed->{linkedin}->announce( %event );

    $result = $self->feed->{greymatter121c}->announce( %event );
}

=head1 SYNOPSIS

    # From the command-line
    ./pm-announce test

=head1 DESCRIPTION

App::PM::Announce is a tool for creating and advertising PM meetings. More soon

=cut

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-pm-announce at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-PM-Announce>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::PM::Announce


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-PM-Announce>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-PM-Announce>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-PM-Announce>

=item * Search CPAN

L<http://search.cpan.org/dist/App-PM-Announce/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of App::PM::Announce
