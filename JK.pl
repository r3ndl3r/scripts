#!/usr/bin/perl -w
# After you download a mod unzip it and rename the mods directory to mods.<modname>
# (eg. mods.ascension). Inside the mods folder create a blank file with the name of
# <modname>.mod (eg. ascension.mod) inside of which should be a single
# line of the mod's name (eg. Babe of Ascension). Finally move the mods.<modname>
# directory to your Jump King\Content directory.

use strict;
use warnings;
use Term::ANSIColor;
use Term::ReadKey;

my $JK = 'H:\Games\Steam\steamapps\common\Jump King';

cls();
while (1) {
    print blue("\n\n    JUMP KING CONFIGURATOR.\n\n");

    print "[ ", green(1), " ] Mods Manager\n";
    print "[ ", green(2), " ] Configs Manager\n\n ";

    my $i = input();
    $i =~ /^[1_2]$/ ? cls() : next;

    if ($i == 1) {
        cls();
        mod();
        cls();
    } else {
        config();
    }
}

sub input {
    ReadMode('cbreak');
    chomp (my $in = ReadKey(0));
    ReadMode('normal');
    return  $in;
}
sub mod {
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

    print blue("\n\n    JUMP KING MODS MANAGER.\n\n");
    if ($mods{mods}) {
        print "Mod Enabled: ", green($mods{mods}{name}), "\n\n";
    } else {
        print "Mod Enabled: ", red('None.'), "\n\n";
    }

    print "Mods Avaiable: \n";

    my $i = 0;
    my @options;

    for (sort keys %mods) {
        unless (/^mods$/) {
            ++$i;
            print "[ ", green($i)," ] $mods{$_}{name}\n";
            push @options, $mods{$_}{modf};
        }
    }
    if ($mods{mods}) {
        print "[ ", red(++$i), " ] ", red("Disable mod."), "\n";
        push @options, $mods{mods}{modf};
    }

    print "[ ", red(++$i), " ] ", red("Do nothing."), "\n";

    print "\n";
    my $option = input();

    if ($option =~ /^\d+$/ && $option > 0 && $options[--$option]) {
        my $m = $options[$option];
        if ($option == $#options) {
            print "rename $JK/Content/mods, $JK/Content/mods.$m\n";
            rename "$JK/Content/mods", "$JK/Content/mods.$m" or die $!;
            cls();
            print red("Mod diabled!\n");
        } else {
            if ($mods{mods}) {
                rename "$JK/Content/mods", "$JK/Content/mods.$mods{mods}{modf}" or die $!;
            }
            
            rename "$JK/Content/mods.$m", "$JK/Content/mods" or die $!;
            cls();
            print green("Mod enabled.\n") ;
        }
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


sub config {
    my %configD = (
        'discord-rpc' => 'Discord Rich Presence Client',
        cheats => 'Cheats',
        npcSpeech => 'NPC Speech',
        locationIntro => 'Location Introduction',
        preciseTimer => 'Precise Timer',
        buildHelper => 'Build Helper',
        gameProgress => 'Game Progress',
        quickLoad => 'Quick Load',
        boomerProofRestart => 'Boomer Proof Restart',
    );
    
    my %configs;

    open CONFIG, "$JK/JumpKing.exe.Config" or die $!;
    while (<CONFIG>) {
        if (my ($key, $value) = /key="([^"]+)" value="(True|False)/) {
            $configs{$key} = $value;
        }
    }
    close CONFIG;

my $in;
    my @configs;
    while (1) {
        cls();
        print blue("    CURRENT CONFIG:\n\n");
        my $i;
        for (sort keys %configs) {
            ++$i;
            push @configs, $_;
            print "[ $i ] $configD{$_} = ", $configs{$_} eq 'True' ? green('Enabled') : red('Disabled'), "\n";
        }
        
        print "\nToggle ('s' to save and exit) [id]: \n";
        my $in = input();

        if ($in =~ /^\d+$/ && $configs[--$in]) {
            $configs{$configs[$in]} = $configs{$configs[$in]} eq 'True' ? 'False' : 'True';
        } elsif ($in eq 's') {
            last;
        }
    }
    my $config = <<END;
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<startup>
		<supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5"/>
	</startup>
	<appSettings>
  <add key="preset" value="1" />
  <add key="discord-rpc" value="$configs{'discord-rpc'}" />
  <add key="cheats" value="$configs{cheats}" />
  <add key="npcSpeech" value="$configs{npcSpeech}" />
  <add key="locationIntro" value="$configs{locationIntro}" />
  <add key="preciseTimer" value="$configs{preciseTimer}" />
  <add key="buildHelper" value="$configs{buildHelper}" />
  <add key="gameProgress" value="$configs{gameProgress}" />
  <add key="quickLoad" value="$configs{quickLoad}" />
  <add key="boomerProofRestart" value="$configs{boomerProofRestart}" />
  <add key="savedPositonX" value="205.75" />
  <add key="savedPositonY" value="-29570" />
  <add key="savedPositonScreen" value="83" />
 </appSettings>
</configuration>
END

    open CONFIG, ">$JK/JumpKing.exe.Config" or die $!;
    print CONFIG $config;
    close CONFIG;

    cls();
    print green('Config file written.');
}

sub red {
    return color('red') . shift . color('reset');
}

sub blue {
    return color('blue') . shift . color('reset');
}

sub green {
    return color('green') . shift . color('reset');
}

sub cls {
    system "cls";
}