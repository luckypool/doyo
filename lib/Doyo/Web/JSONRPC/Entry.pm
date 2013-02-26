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
    DEFAULT_LIMIT  => 30,
    DEFAULT_OFFSET => 0,
    DEFAULT_ORDER  => 'DESC',
};

__PACKAGE__->register_rpc_method_names( 'find_by_nickname', 'find', 'lookup', 'create' );

sub find_by_nickname {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        nickname => [qw/NOT_BLANK/, [qw/LENGTH 1 32/]],
        offset => [qw/UINT/],
        limit  => [qw/UINT/],
        order  => [[qw/IN_ARRAY DESC ASC/]],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 1 } qw/nickname/,
            map { $_ => 0 } qw/offset limit order/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $offset = defined $params->{offset} ? $params->{offset} : DEFAULT_OFFSET();
    my $limit  = defined $params->{limit}  ? $params->{limit}  : DEFAULT_LIMIT();
    my $order  = defined $params->{order}  ? $params->{order}  : DEFAULT_ORDER();
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->find_by_nickname({
        nickname => $params->{nickname},
        offset => $offset,
        limit  => $limit,
        order  => $order,
    });
    return $find_row;
}


sub find {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        offset => [qw/UINT/],
        limit  => [qw/UINT/],
        order  => [[qw/IN_ARRAY DESC ASC/]],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 0 } qw/offset limit order/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $offset = defined $params->{offset} ? $params->{offset} : DEFAULT_OFFSET();
    my $limit  = defined $params->{limit}  ? $params->{limit}  : DEFAULT_LIMIT();
    my $order  = defined $params->{order}  ? $params->{order}  : DEFAULT_ORDER();
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->find({
        offset => $offset,
        limit  => $limit,
        order  => $order,
    });
    return $find_row;
}

sub lookup {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        id => [qw/NOT_BLANK UINT/],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 1 } qw/id/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $model = Doyo::Model::Doyo::Entry->new;
    my $find_row = $model->select_by_id({
        id => $params->{id}
    });
    return $find_row;
}

sub create {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        nickname => [qw/NOT_BLANK/, [qw/LENGTH 1 32/]],
        body     => [qw/NOT_BLANK/, [qw/LENGTH 1 500/]],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 1 } qw/body nickname/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $model = Doyo::Model::Doyo::Entry->new;
    $model->insert({
        nickname => $params->{nickname},
        body     => $params->{body},
    });
    return 1;
}

1;
