#!/usr/local/bin/perl

our $VERSION = '0.06';

use WWW::ShopBot qw(list_drivers list_drivers_paths);
use Data::Dumper;
use WWW::Mechanize;

# ----------------------------------------------------------------------
sub version { print "$0 version: $VERSION$/" }

# ----------------------------------------------------------------------
sub list {
    @drivers = list_drivers;
    print map({"- $_\n"} @drivers), "\n", scalar(@drivers)." driver(s) found\n"; 
}

# ----------------------------------------------------------------------
sub list_paths {
    @drivers = list_drivers_paths;
    print map({"- $_\n"} @drivers), "\n", scalar(@drivers)." driver(s) found\n";
}

# ----------------------------------------------------------------------
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

# ----------------------------------------------------------------------
sub newdriver {
    my $dn = shift;
    my $dd = shift || '.';
    die "Driver's name?\n" unless $dn;
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

    my $pkg = shift;
    my $textref = shift;
    my $collector = shift;
    my $pattern = $pkg->transformarg(@_);
    return unless $$textref;

    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($pkg->match(\${$_}{href}, $pattern)){
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

    my $pkg = shift;
    my $textref = shift;
    my $collector = shift;
    my $pattern = $pkg->transformarg(@_);
    return unless $$textref;

    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($pkg->match(\${$_}{href}, $pattern)){
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
    if($$textref =~ m/$pattern->{product}/){
        $collector->{product} = $1;

        if($$textref =~ m/$pattern->{price}/){
            $collector->{price} = $1;

            if($$textref =~ m/$pattern->{photo}/){
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

    my $link_accept    = qr''o;
    my $next_accept    = qr''o;

    my $link_discard   = qr''o;
    my $next_discard   = qr''o;

    # extract links
    $pkg->linkextor(\$content, \%links, $link_accept, $link_discard);

    # extract next pages
    $pkg->nextextor(\$content, \%next, $next_accept, $next_discard);

    # .......

    foreach (keys %next){
	$agent->get($_);
	$content = $agent->content;
	$pkg->linkextor(\$content, \%links, $link_accept, $link_discard);

	# ......
    }

    my $specpatt = {
	product => qr''o,
	price   => qr''o,
	photo   => qr''o,
    };

    foreach my $link (keys %links){
	print $link.$/;
	$item = {};
	$agent->get($link);
	$content = $agent->content;
        if($pkg->specextor(\$content, $item, $specpatt)){
          $item->{link} = $link;

	  # ......

	  push @result, $item;
        }

    }

    # return an anonymous array of hashes
    \@result;
}
1;
TMPL
    print F "__END__\n\n";
print F <<TMPL;

0.01 author <author\@shhhhhh.com>
    - template created using shopbot.pl
         @{[ `date -R` ]}

TMPL
    close F;
}

# ----------------------------------------------------------------------
sub action {
    my $query = shift;
    list and exit unless @_;
    my $bot = new WWW::ShopBot(drivers => \@_);
    print Dumper [ $bot->query($query) ];
}

# ----------------------------------------------------------------------
sub help { system "perldoc $0 | less" }

# ----------------------------------------------------------------------
sub analyze {
    my $url = shift or die "URL?\n";
    my $mecha = WWW::Mechanize->new();
    $mecha->get($url);
    use Data::Dumper;
    my $cnt = 1;
    print "<Forms>\n";
    foreach my $f (@{$mecha->forms}){
	print    "Form(@{[$cnt++]}): ", $f->{attr}->{name}, $/;
	foreach my $i (@{$f->{inputs}}){
	    printf "  %-20s  %-15s\n", $i->{name}.'='.$i->{value}, $i->{type};
	}
    }

    $cnt = 1;
    print "\n<Links>\n";
    foreach my $l (@{$mecha->links}){
	print "[@{[$cnt++]}] ";
	printf "%-15s  %s\n", $l->[1], $l->[0];
    }
    print "\n<Content>\n";
    print $mecha->content;
}

# ----------------------------------------------------------------------
use Cwd 'abs_path';
sub pattern {
    my $text;
    die "$0 pattern (URL | FILE) query)\n" unless $_[0];
    if ( -f abs_path($_[0]) ){
	open F, abs_path($_[0]) or die "$!\n";
	local $/;
	$text = <F>;
	close F;
    }
    else {
	my $mecha = WWW::Mechanize->new();
	$mecha->get($_[0]);
	$text = $mecha->content;
    }
    die "No content\n" unless $text;
    my $query = $_[1] || die "You query?\n";
    my @lines = split /\n/, $text;
    my $cnt = 1;
    my $pos = 0;

    foreach (map {join $/, @lines[$_..$_+5]} 0..$#lines){
	$pos = 0 if $pos >=5;
	$pos++ if /$query/;
	if( $pos == 3 && /$query/){
	    s/\?/\\?/go;
	    s/([\+\(\)\?\.])/\\$1/go;
	    if(s/$query/(.+?)/){
		s/([\$\^\*\[\]\{\}\\\|])/\\$1/go;
		s/\n+/\\n+/go;
		s/\s{1}/ /go;
		s/\s{2,}/\\s+/go;
		print "[$cnt]",$/, $_,$/x3;
		$cnt++;
	    }
	}
    }
}


# ======================================================================
my %cmdtbl =
    (
     list => \&list,
     list_paths => \&list_paths,
     newdriver => \&newdriver,
     driver => \&driver,
     analyze => \&analyze,
     pattern => \&pattern,
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

 % shopbot.pl analyze     URL

 % shopbot.pl pattern     URL     query

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

It lists full paths of existent drivers'

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

=head2 Analyze a URL

It fetches the content of the given URL and dumps related information parsed from it using WWW::Mechanize.

 % shopbot.pl analyze http://shhhhhhh.com/

It dumps result to STDOUT.

=head2 Generate recognition patterns

 % shopbot.pl pattern (URL | FILE) query

Shopbot.pl provides a rudimental function which can generate a pattern according to your query, and then you can cut'n'paste the thing to your driver and modify it. This may save some time.

=head2 ACTION!

Of course, you can use it to get products' data, and obtained data will be dumped to STDOUT with Data::Dumper.

 % shopbot.pl action query drivers

Example:

 % shopbot.pl action 'shhhhhh dot com' TW::answer168 COM::froogle

=head1 SEE ALSO

L<WWW::ShopBot>, L<WWW::ShopBot::Driver>

=cut

