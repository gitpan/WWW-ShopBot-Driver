#!/usr/local/bin/perl
eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}' if 0;

our $VERSION = '0.04';

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


sub driver {
    my $driver = shift or die "Driver's name?\n";
    my @hier = split /::/, $driver;
    foreach (sort @INC){
	my $drpath = $_.'/WWW/ShopBot/'.join('/', @hier).'.pm';
	if(-f $drpath){
	    local $/;
	    open F, $drpath or die "Cannot open driver $drpath\n";
	    my $content = <F>;
	    $content =~ /\$VERSION.+=[\t\s\n]*(.+?)[\s\t\n]*;/;
	    print <<OUTPUT;
- driver  => $driver
  path    => $drpath
  version => $1

OUTPUT
	    close F;
	}
    }
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

# delete the following modules if you do not need them
use HTML::LinkExtractor;
use HTML::Entities ();
use LWP::Simple;


sub linkextor {

    # defined for extracting links to detail pages

    # This subroutine is inherited from WWW::ShopBot::Driver
    # and is the same as the one in parent class

    # You can delete this part if you just want to inherit from 
    # the parent

    my($textref, $collector, $pattern) = @_;
    return unless $$textref;
    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
        if($_->{href} =~ /$pattern/){
            $collector->{$_->{href}} = 1;
            $cnt++;
        }
    }
    $cnt;
}

sub nextextor {

    # defined for extracting links to next pages

    # This subroutine is inherited from WWW::ShopBot::Driver
    # and is the same as the one in parent class

    # You can delete this part if you just want to inherit from 
    # the parent

    my($textref, $collector, $pattern) = @_;
    return unless $$textref;
    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
        if($_->{href} =~ /$pattern/){
            $collector->{$_->{href}} = 1;
            $cnt++;
        }
    }
    $cnt;
}

sub specextor {

    # defined for extracting detailed information of products

    # This subroutine is inherited from WWW::ShopBot::Driver
    # and is the same as the one in parent class

    # You can delete this part if you just want to inherit from
    # the parent

    my $pkg = shift;
    my ($textref, $collector, $pattern) = @_;
    return unless $$textref;
    if($$textref =~ m/${$pattern}{product}/){
        $collector->{product} = $1;

        if($$textref =~ m/${$pattern}{price}/){
            $collector->{price} = $1;

            if($$textref =~ m/${$pattern}{photo}/){
                $collector->{photo} = $1;
            }
        }
    }
    1 if defined $collector->{price} && defined $collector->{product};
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('FIRST_URL');
    $agent->form_name('shhhhh');
    $agent->field('shhhhhh', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $linkpatt = qr'';
    my $nextpatt = qr'';

    # extract links
    $pkg->linkextor(\$content, \%links, $linkpatt);

    # extract next pages
    $pkg->nextextor(\$content, \%next, $nextpatt);

    # .......

    foreach (keys %next){
	# ......
    }

    foreach (keys %links){
	print $_.$/;
	$item = {};
	$agent->get($_);
	$pkg->specextor(\$content, $item, {
	    product => qr'',
	    price => qr'',
	    photo => qr'',
	});

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
     driver => \&driver,
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

 % shopbot.pl list_paths

 % shopbot.pl newdriver   COM::Shhhhhh

 % shopbot.pl driver      COM::Shhhhhh

 % shopbot.pl action      query   COM::Shhhhhh

=head1 DESCRIPTION

It is a script for you to list existent shopbot drivers, generate driver's template, or go grab price info, etc.

=head1 USAGE

=head2 Print version of shopbot.pl

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

=head2 List driver's information

 % shopbot.pl driver driver_name

Example:

 % shopbot.pl driver COM::Shhhhhh

=head2 ACTION!

Of course, you can use it to get products' data, and obtained data will be dumped to STDOUT with Data::Dumper.

 % shopbot.pl action query drivers

Example:

 % shopbot.pl action 'shhhhhh dot com' TW::answer168 COM::froogle

=head1 SEE ALSO

L<WWW::ShopBot>, L<WWW::ShopBot::Driver>

=cut

