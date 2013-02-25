package Doyo::Web::JSONRPC::Entry;
use strict;
use warnings;
use utf8;
use Mojo::Base 'MojoX::JSON::RPC::Service';
use Mojo::Exception;

use Params::Validate;
use FormValidator::Simple;
use Doyo::Model::Doyo::Entry;
use Data::Dumper;

use constant {
    DEFAULT_LIMIT        => 30,
    DEFAULT_OFFSET       => 0,
    DEFAULT_ORDER        => 'DESC',
};

__PACKAGE__->register_rpc_method_names( 'find', 'lookup', 'create' );

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
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        id => [qw/NOT_BLANK INT/],
    ]);
    if($result->has_error){
        Mojo::Exception->throw(q/id is invalid/);
    }
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->select_by_id($params);
    return $find_row;
}

sub create {
    my $self = shift;
    my ($params) = @_;
    FormValidator::Simple->set_messages({
        create => {
            nickname => {
                NOT_BLANK => q/nickname absent/,
                LENGTH    => q/nickname must be less than 32/
            },
            body => {
                NOT_BLANK => q/body absent/,
                LENGTH    => q/body must be less than 500/
            },
        },
    });
    my $result = FormValidator::Simple->check($params => [
        nickname => [qw/NOT_BLANK/, [qw/LENGTH 1 32/]],
        body     => [qw/NOT_BLANK/, [qw/LENGTH 1 500/]],
    ]);
    if($result->has_error){
        my $error = $result->messages(q/create/);
        Mojo::Exception->throw($error);
    }
    my $model = Doyo::Model::Doyo::Entry->new;
    $model->insert($params);
    return 1;
}


1;
