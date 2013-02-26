package Doyo::Model::Doyo::Entry;
use strict;
use warnings;
use utf8;

use parent qw/Doyo::Model::Base/;
use Date::Calc qw/Localtime/;

use constant {
    TABLE_NAME           => 'entry',
    DEFAULT_LIMIT        => 30,
    DEFAULT_OFFSET       => 0,
    DEFAULT_ORDER        => 'DESC',
    DEFAULT_TIME_TO_FIND => 60 * 60 * 24,
};

sub table {
    return TABLE_NAME;
};

sub validate_basic_params {
    my $self = shift;
    return Params::Validate::validate(@_, {
        nickname => { type  => Params::Validate::SCALAR },
        body     => { type  => Params::Validate::SCALAR },
    });
}

sub get_update_params {
    my $self = shift;
    my ($params) = @_;
    return {
        map { $_ => $params->{$_} } qw/nickname body/
    };
}

sub find_by_nickname {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        nickname => 1,
        offset => { regex => qr/^\d+$/, default => DEFAULT_OFFSET() },
        limit  => { regex => qr/^\d+$/, default => DEFAULT_LIMIT() },
        order  => { regex => qr/^(DESC|ASC)$/, default => DEFAULT_ORDER() },
    });
    my $row = $self->slave->search(
        $self->table, {
            nickname => $params->{nickname}
        }, {
            limit    => $params->{limit},
            offset   => $params->{offset},
            order_by => {
                id => $params->{order}
            },
        }
    )->all;
    return unless $row;
    return [ map {$_->get_columns} @$row ];
}

sub find {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        offset => { regex => qr/^\d+$/, default => DEFAULT_OFFSET() },
        limit  => { regex => qr/^\d+$/, default => DEFAULT_LIMIT() },
        order  => { regex => qr/^(DESC|ASC)$/, default => DEFAULT_ORDER() },
    });
    my $row = $self->slave->search(
        $self->table, undef, {
            limit    => $params->{limit},
            offset   => $params->{offset},
            order_by => {
                id => $params->{order}
            },
        }
    )->all;
    return unless $row;
    return [ map {$_->get_columns} @$row ];
}


# --
# Utils
sub time_to_mysqldatetime {
    my $self = shift;
    my ($time) = @_;
    my @datetime = defined $time ? Localtime($time) : split '', (0 x 6);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", @datetime);
};

1;
