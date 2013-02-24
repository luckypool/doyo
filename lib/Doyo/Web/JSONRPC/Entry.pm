package Doyo::Web::JSONRPC::Entry;
use strict;
use warnings;
use utf8;
use Mojo::Base 'MojoX::JSON::RPC::Service';

use Params::Validate;
use Doyo::Model::Doyo::Entry;

use constant {
    DEFAULT_LIMIT        => 30,
    DEFAULT_OFFSET       => 0,
    DEFAULT_ORDER        => 'DESC',
};

__PACKAGE__->register_rpc_method_names( 'lookup', 'find' );

sub find {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        offset => { regex => qr/^\d+$/, default => DEFAULT_OFFSET() },
        limit  => { regex => qr/^\d+$/, default => DEFAULT_LIMIT() },
        order  => { regex => qr/^(DESC|ASC)$/, default => DEFAULT_ORDER() },
    });
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->find(
        offset => $params->{offset},
        limit  => $params->{limit},
        order  => $params->{order},
    );
    return $find_row;
}


sub lookup {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        id => { regex => qr/^\d+$/ },
    });
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->select_by_id(
        id => $params->{id},
    );
    return $find_row;
}


1;
