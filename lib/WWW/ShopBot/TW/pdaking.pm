package WWW::ShopBot::TW::pdaking;
use strict;
use LWP::UserAgent;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);

our $VERSION = '0.02';

use LWP::Simple;
use HTML::LinkExtractor;

sub nextextor {
    shift;
    my($textref, $collector, $pattern) = @_;
    return unless $$textref;
    while($$textref =~ m,(http://www.pdaking.com.tw/cgi-bin/shop/search.cgi\?cart_id=\d+&keywords=.+?&page=\d+),sgo){
	$collector->{$1} = 1;
    }

}

sub specextor {
    my $pkg = shift;
    my ($textref, $collector, $pattern) = @_;

    if($$textref =~ /${$pattern}{product}/){
       $collector->{product} = $1;
       if($$textref =~ /${$pattern}{price}/){
	  $collector->{price} = $1;
	  if($$textref =~ /${$pattern}{photo}/){
	   $collector->{photo} = $1;
          }
       }
    }
}


our $firsturl = 'http://www.pdaking.com.tw/cgi-bin/shop/search.cgi?search';

sub query {
    my $pkg = shift;
    my (@result, %links, %next, $item);
    my $ua = new LWP::UserAgent(proxy => $pkg->{proxy}, cookie_jar => $pkg->{jar});
    my $content = ($ua->post($firsturl, {keywords=> $pkg->{product}}))->{_content};

    $pkg->nextextor(\$content, \%next);

    foreach (keys %next){
	my $content = get($_);
	next unless $content;
	$pkg->linkextor(\$content, \%links, qr,http://www.pdaking.com.tw/cgi-bin/shop/shop.cgi\?action=imgbi,);
    }

    foreach (keys %links){
	$item = {};
	my $content = get $_;
	next unless $content;
	$pkg->specextor(
			\$content,
			$item,
			{
			    product => qr,商品.+?color="#.+?">(.+?)</font>,m,
			    price   => qr,特價.+?color="#.+?">(\d+)元,m,
			    photo   => qr,<table width="100%" border="0" cellspacing="0" cellpadding="3">.+?<tr valign="top"><td align="center" WIDTH=50%>.+?<img src="(.+?)" border=0>.+?</td><td WIDTH=50%>,s,
			}
			);
	push @result, $item;
    }
    return \@result;
}
1;

__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

0.02 xern
    Thu, 13 Mar 2003 18:53:27 +0800
