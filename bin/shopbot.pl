#!/usr/local/bin/perl
eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}' if 0;

our $VERSION = '0.03';

use WWW::ShopBot qw(list_drivers list_drivers_paths);
use Data::Dumper;

sub version {
    print "$0 version: $VERSION$/";
}

sub list {
    @drivers = list_drivers;
    print map({"- $_\n"} @drivers), "\n", scalar(@drivers)." driver(s) found\n"; 
}

sub list_paths {
    @drivers = list_drivers_paths;
    print map({"- $_\n"} @drivers), "\n", scalar(@drivers)." driver(s) found\n";
}

sub newdriver {
    my $dn = shift;
    my $dd = shift || '.';
    my @array = ($dd,, 'WWW', 'ShopBot', (split /::/, $dn));
    mkdir join q,/,, @array[0..$_] foreach (0..$#array-1);
    my $fullname = join q,/,, @array[0..$#array-1], $array[-1].'.pm';
    die "$fullname already exists. Please use another name or just delete it.\n"if (-e $fullname);
    open F, '>', $fullname or die $!;
    print F "package WWW::ShopBot::$dn;\n";
    print F <<'TMPL';
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

use HTML::Entities ();

sub linkextor {
    my($textref, $collector) = @_;
    while($$textref =~ /pattern here/g){
        $collector->{$1} = 1;
    }
}

sub nextextor {
    my($textref, $collector) = @_;
    while($$textref =~ /pattern here/g){
        $collector->{$1} = 1;
    }
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://shhhhhh/');
    $agent->form_name('shhhhh');
    $agent->field('shhhhhh', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    # extract links
    linkextor(\$content, \%links);

    # extract next pages
    nextextor(\$content, \%next);

    # .......

    foreach (keys %next){
	# ......
    }

    foreach (keys %links){
	print $_.$/;
        undef $item;

        # ......

	push @result, $item;
    }

    # return an anonymous array of hashes
    \@result;
}
1;
TMPL
    print F "__END__\n\n";
print F <<TMPL;

0.01 a.u.thor <a.u.thor\@shhhhhh.com>
    - template created using $0
         @{[ `date -R` ]}

TMPL
    close F;
}

sub action {
    my $query = shift;
    list and exit unless @_;
    my $bot = new WWW::ShopBot(drivers => \@_);
    print Dumper [ $bot->query($query) ];
}

sub help { system "perldoc $0 | less" }


my %cmdtbl =
    (
     list => \&list,
     list_paths => \&list_paths,
     newdriver => \&newdriver,
     action => \&action,
     version => \&version,
     help => \&help,
     );
my $cmd = shift @ARGV;
$cmdtbl{$cmd || 'help'}->(@ARGV);

__END__

=pod

=head1 NAME

shopbot.pl - Shopping Agent

=head1 SYNOPSIS

 % shopbot.pl version

 % shopbot.pl list

 % shopbot.pl list_path

 % shopbot.pl newdriver COM::Shhhhhh

 % shopbot.pl action query drivers

=head1 DESCRIPTION

It is a script for you to list existent shopbot drivers, generate driver's template, or go grab price info.

=head1 USAGE

=head2 Print version number

 % shopbot.pl version

=head2 List drivers in your library paths

 % shopbot.pl list

Or use

 % shopbot.pl list_paths

It prints names of existent drivers with their paths.

=head2 Generate driver template

 % shopbot.pl newdriver driver_name [ dest_dir ]

It creates a driver template, and then you can edit the newborn file to make a new driver. By default, it creates the new driver at current directory. Please specify another destination directory if you need it to be somewhere else.

Example,

 % shopbot.pl newdriver COM::Shhhhhh ~/.shopbot_drivers/

It creates a driver template WWW/ShopBot/COM/Shhhhhh.pm in your home's .shopbot_drivers

=head2 ACTION!

Of course, you can use it to get products' data, and obtained data will be dumped to STDOUT with Data::Dumper.

 % shopbot.pl action query drivers

Example:

 % shopbot.pl action 'shhhhhh dot com' TW::answer168 COM::froogle

=head1 SEE ALSO

L<WWW::ShopBot>, L<WWW::ShopBot::Driver>

=cut

