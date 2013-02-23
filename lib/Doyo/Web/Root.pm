package Doyo::Web::Root;
use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious::Controller';

sub home {
    my $self = shift;
    $self->render(
        footer_text => 'footer text',
    );
}

1;
