use strict;
use warnings;
use utf8;

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $class;
BEGIN {
    use_ok($class='SaikinDoyo::Web::Root');
}

done_testing;
