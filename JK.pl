#!/usr/bin/perl -w
# After you download a mod unzip it and rename the mods directory to mods.<modname>
# (eg. mods.ascension). Inside the mods folder create a blank file with the name of
# <modname>.mod (eg. ascension.mod) inside of which should be a single
# line of the mod's name (eg. Babe of Ascension). Finally move the mods.<modname>
# directory to your Jump King\Content directory.

use strict;
use warnings;

my $JK = 'H:\Games\Steam\steamapps\common\Jump King';

my @mods = rD('Content', 'mod');

my %mods;
for my $mod (@mods) {
    my $modF = rD("Content/$mod", '\.mod$');

    open MODF, "$JK/Content/$mod/$modF" or die "Couldn't open file: $!\n";
    chomp ( my $modN = <MODF> );
    close MODF;

    $modF =~ s/\.mod$//;
    $mods{$mod} = { name => $modN, modf => $modF };
}

print "JUMP KING MODS MANAGER.\n\n";
if ($mods{mods}) {
    print "Mod Enabled: $mods{mods}{name}\n\n";
}

print "Mods Avaiable: \n";

my $i = 0;
my @options;

for (sort keys %mods) {
    unless (/^mods$/) {
        ++$i;
        print "[ $i ] $mods{$_}{name}\n";
        push @options, $mods{$_}{modf};
    }
}
if ($mods{mods}) {
    print "[ 3 ] DISABLE MOD.\n";
    push @options, $mods{mods}{modf};
}

print ": ";
chomp ( my $option = <STDIN> );
if ($option =~ /^\d+$/ && $option > 0 && $options[--$option]) {
    my $m = $options[$option];
    if ($option == $#options) {
        rename "$JK/Content/mods", "$JK/Content/mods.$m" or die $!;
        print "DISABLED!\n";
    } else {
        if ($mods{mods}) {
            rename "$JK/Content/mods", "$JK/Content/mods.$mods{mods}{modf}" or die $!;
        }
        
        rename "$JK/Content/mods.$m", "$JK/Content/mods" or die $!;
        print "Mod Enabled.\n" ;
    }
}


sub rD {
    my ($d, $t) = @_;
    my @d;
    opendir JK, "$JK/$d" or die "Couldn't open directory: $!\n";
    while (readdir JK) {
        push @d, $_ if /$t/;
    }
    closedir JK;
    return $#d > 0 ? @d : shift @d;
}