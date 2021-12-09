#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

my $configf = "$ENV{HOME}/.twitch";
my %config;

open CONFIG, $configf or die $!;
while (<CONFIG>) {
    chomp;
    my ($k, $v) = split / = /, $_;
    $config{$k} = $v;
}

my @channels = split / /, $config{channels};
printf "Loaded [ %s ] channels. [ %s ]\n", $#channels+1, join ', ', @channels;
my %online;

while (1) {
    for my $channel (@channels) {

        if (getS($channel)) {
            if (!$online{$channel}) {
                $online{$channel} = 1;
                print "$channel is online.\n";
                pushOver($channel);
            }
        } else {
            if ($online{$channel}) {
                print "$channel went offline.\n"
            }
            delete $online{$channel};
        }

    }

    sleep 60;
}

sub pushOver {
    my $msg = shift;
    my $res = LWP::UserAgent->new->post('https://api.pushover.net/1/messages.json', [
            token => $config{token},
            user => $config{user},
            message => "$msg is ONLINE."
    ]);
}

sub getS {
    my $channel = shift;
    my $url = "https://api.twitch.tv/helix/streams?user_login=$channel";
    my $res = LWP::UserAgent->new->get($url,
        'client-id' => $config{cid},
        'Authorization' => "Bearer $config{oauth}",
        );


    return $res->content =~ /^\{"data":\[\]/ ? 0 : 1;
}

