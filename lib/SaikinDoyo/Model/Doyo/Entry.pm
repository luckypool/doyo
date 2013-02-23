package SaikinDoyo::Model::Doyo::Entry;
use strict;
use warnings;
use utf8;

use parent qw/SaikinDoyo::Model::Base/;
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

sub find {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        from   => { regex => qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, default => $self->time_to_mysqldatetime(time-DEFAULT_TIME_TO_FIND()) },
        to     => { regex => qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, default => $self->time_to_mysqldatetime(time) },
        offset => { regex => qr/^\d+$/, default => DEFAULT_OFFSET() },
        limit  => { regex => qr/^\d+$/, default => DEFAULT_LIMIT() },
        order  => { regex => qr/^(DESC|ASC)$/, default => DEFAULT_ORDER() },
        find_type => { regex => qr/^(updated_at|created_at)$/, default => 'created_at' },
    });

    my $row = $self->slave->search_named(
        q{
            SELECT * FROM %s WHERE %s BETWEEN :from AND :to ORDER BY %s %s LIMIT %s OFFSET %s
        },
        $params,
        [ $self->table, map { $params->{$_} } qw/find_type find_type order limit offset/]
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
