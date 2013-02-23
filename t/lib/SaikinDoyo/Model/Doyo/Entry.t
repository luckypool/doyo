use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::MockTime;

use SaikinDoyo::Test::DB qw/DB_DOYO/;

# for debug
use Devel::Peek qw/Dump/;
use Data::Dumper;

my $class;
BEGIN {
    use_ok($class='SaikinDoyo::Model::Doyo::Entry');
}

my $obj = new_ok $class;

sub create_dummy_data {
    my $id = int rand 1000000;
    return {
        nickname  => "nickname:$id",
        body      => qq{bodyボディ本文だああああああああ$id},
    };
}

subtest q/crud/ => sub {
    my $now = time();
    Test::MockTime::set_fixed_time($now);

    my $dummy_data1 = create_dummy_data();
    my $id_data1 = $dummy_data1->{id};

    subtest q/insert/ => sub {
        my $row = $obj->insert($dummy_data1);
        my $expected = {%$dummy_data1};
        $expected->{id} = 1;
        $expected->{created_at} = $obj->time_to_mysqldatetime($now);
        cmp_deeply $row, $expected;
    };

    subtest q/select/ => sub {
        my $expected = {%$dummy_data1};
        $expected->{id} = 1;
        $expected->{created_at} = $obj->time_to_mysqldatetime($now);
        $expected->{updated_at} = $obj->time_to_mysqldatetime();

        my $row = $obj->select_by_id(id=>$expected->{id});
        ok $row;
        cmp_deeply $expected, $row;
    };

    subtest q/update/ => sub {
        my $update_time = $now+600;
        Test::MockTime::set_fixed_time($update_time);
        my $expected = {%$dummy_data1};
        $expected->{id} = 1;
        $expected->{body} = 'ほげええ';
        $expected->{created_at} = $obj->time_to_mysqldatetime($now);
        $expected->{updated_at} = $obj->time_to_mysqldatetime($update_time);
        ok $obj->update(
            map { $_ => $expected->{$_} } qw/id nickname body/
        );
        my $row = $obj->select_by_id(id=>1);
        cmp_deeply $expected, $row;
    };

    Test::MockTime::restore_time();

    subtest q/delete/ => sub {
        is $obj->exists(id=>1), 1;
        ok $obj->delete_by_id(id=>1);
        is $obj->exists(id=>1), 0;
    };
};

subtest q/find/ => sub {
    ok 1;
    my @dummy_data_list = map { create_dummy_data() } (1..50);
    my @expected_list;
    my $current = time - 60 * 60 * 50;

    # THE WORLD!!!
    Test::MockTime::set_fixed_time($current);

    # WRYYYYYYY!!!!!
    for my $dummy (@dummy_data_list){
        my $expected = {%$dummy};
        $expected->{created_at} = $obj->time_to_mysqldatetime($current);
        unshift @expected_list, $expected;
        $obj->insert($dummy);
        $current = $current + 60 * 60;
        Test::MockTime::set_fixed_time($current);
    };

    # 時は動き出す・・・！
    # default では 24 時間前までのものをDESCで最大30件とってくる
    my $rows = $obj->find();

    map {
        $_->{updated_at}=$obj->time_to_mysqldatetime();
        my $got = shift @$rows;
        delete $got->{id};
        cmp_deeply $_, $got, "ok $_->{created_at}";
    } splice @expected_list, 0, 24;
    is_deeply $rows, [], 'length ok';

    Test::MockTime::restore_time();
};


done_testing;
