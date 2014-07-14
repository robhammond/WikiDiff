#!/usr/bin/env perl
use strict;
use Modern::Perl;
use Search::Elasticsearch;

open PAGE, "<pagecounts-20140327-130000" or die $!;

my $re = qr/^en/;

while (<PAGE>) {
	next unless /$re/;
	my $line = $_;
	chomp($line);

	if ($line =~ m{^(en[^ ]*) ([^ ]+) ([^ ]+) ([^ ]+)$}) {
		my $token = $1;
		my $title = $2;
		my $hits  = $3;
		my $size  = $4;

		next unless $hits > 500;
		say "$title - $hits";
		say $line;
	} else {
		say "No Match::: $line";
	}

	# say $line;
}