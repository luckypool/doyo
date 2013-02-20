package SaikinDoyo::DB::Handler::Doyo;
use strict;
use warnings;
use utf8;

use parent qw/SaikinDoyo::DB::Handler::Base/;
use SaikinDoyo::DB::Config;
use SaikinDoyo::DB::Skinny::Doyo;
use SaikinDoyo::DB::Skinny::Doyo::Schema;

use Params::Validate;

# --
# override parent class method
sub get_dbh {
    my ($self, $user) = @_;
    my $config = SaikinDoyo::DB::Config->new;
    return SaikinDoyo::DB::Skinny::Doyo->new(+{
        dsn => $config->db_doyo,
        username=>$user,
        connect_options => {
            mysql_enable_utf8 => 1,
        }
    });
}

1;
