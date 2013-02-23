package Doyo::DB::Handler::Doyo;
use strict;
use warnings;
use utf8;

use parent qw/Doyo::DB::Handler::Base/;
use Doyo::DB::Config;
use Doyo::DB::Skinny::Doyo;
use Doyo::DB::Skinny::Doyo::Schema;

use Params::Validate;

# --
# override parent class method
sub get_dbh {
    my ($self, $user) = @_;
    my $config = Doyo::DB::Config->new;
    return Doyo::DB::Skinny::Doyo->new(+{
        dsn => $config->db_doyo,
        username=>$user,
        connect_options => {
            mysql_enable_utf8 => 1,
        }
    });
}

1;
