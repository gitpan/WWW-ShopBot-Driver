#!/usr/local/bin/perl
eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}' if 0;

our $VERSION = '0.01';

use WWW::ShopBot qw(list_drivers);
use Data::Dumper;

sub list {
    @drivers = list_drivers;
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

sub query {
    my $pkg = shift;
    my ($content, $item, @result, @contents);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://shhhhhh/');
    $agent->form_name('shhhhh');
    $agent->field('shhhhhh', $pkg->{product});
    $agent->click();


    # .......


    foreach (@contents){
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
    - @{[`date -R`]}

TMPL
    close F;
}

sub action {
    my $query = shift;
    list unless @_;
    my $bot = new WWW::ShopBot(drivers => \@_);
    print Dumper [ $bot->query($query) ];
}

sub help { system "perldoc $0 | less" }


my %cmdtbl =
    (
     list => \&list,
     newdriver => \&newdriver,
     action => \&action,
     help => \&help,
     );
my $cmd = shift @ARGV;
$cmdtbl{$cmd || 'help'}->(@ARGV);

__END__

=pod

=head1 NAME

shopbot.pl - Shopping Agent

=head1 SYNOPSIS

 % shopbot.pl list

 % shopbot.pl newdriver COM::Shhhhhh

 % shopbot.pl query drivers

=head1 DESCRIPTION

It is a script for you to list existent shopbot drivers, generate driver's template, or go grab price info.

=head1 USAGE

=head2 List drivers in your library paths

 % shopbot.pl list

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

