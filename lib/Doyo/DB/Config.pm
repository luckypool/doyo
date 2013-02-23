package Doyo::DB::Config;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;
__PACKAGE__->mk_ro_accessors(qw/
    db_doyo
/);

use constant {
    DB_DOYO => 'DBI:mysql:doyo',
};

sub new {
    my $class = shift;
    my $self = {
        db_doyo => DB_DOYO(),
    };
    return bless $self, $class;
}

1;
