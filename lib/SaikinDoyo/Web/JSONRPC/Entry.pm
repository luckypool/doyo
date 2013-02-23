package SaikinDoyo::Web::JSONRPC::Entry;
use strict;
use warnings;
use utf8;
use Mojo::Base 'MojoX::JSON::RPC::Service';

use Params::Validate;
use SaikinDoyo::Model::Doyo::Entry;

__PACKAGE__->register_rpc_method_names( 'lookup' );

sub lookup {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        id => { regex => qr/^\d+$/ },
    });
    my $model = SaikinDoyo::Model::Doyo::Entry->new;
    my $find_row = $model->select_by_id(
        id => $params->{id},
    );
    return $find_row;
}


1;
