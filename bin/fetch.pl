#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::DOM;
use Mojo::JSON;
use Mojo::Log;
use DateTime;
use Data::Dumper;
use Getopt::Long;
use FindBin;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;


our $data_dir = "$FindBin::Bin/../wiki-data/";
# increase max d/l size to 1GB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 1073741824;

my $log = Mojo::Log->new;

my $ua = Mojo::UserAgent->new;
$ua->transactor->name("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:27.0) Gecko/20100101 Firefox/27.0");


my $dt = DateTime->now(time_zone => 'Europe/London');
my $year = $dt->year;
my $month = sprintf("%02d", $dt->month);
my $day = sprintf("%02d", $dt->day);
my $hour = sprintf("%02d", $dt->hour);

my $url = "http://dumps.wikimedia.org/other/pagecounts-raw/$year/$year-$month/";

my $tx = $ua->get($url);

if (my $res = $tx->success) {
	# just look for last li in first list
	my $li = $res->dom->at("ul li:last-child a");

	if ($li =~ m{pagecounts}) {
		my $fn = $li->all_text;
		
		my $u = Mojo::URL->new($li->{'href'})->to_abs(Mojo::URL->new($url));
		$tx = $ua->get($u->to_string);
		# print $u->to_string . "\n";
		# print Dumper($tx->res);
		$tx->res->content->asset->move_to($data_dir . $fn);

		my $output = $fn;
		$output =~ s!..$!!;
		$output .= 'txt';
		gunzip $data_dir . $fn => $output or die "gunzip failed: $GunzipError\n";
	}
} else {
	# add '1' on end of url & try again
}

