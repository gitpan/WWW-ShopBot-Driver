package WWW::ShopBot::TW::pdaking;
use strict;
use LWP::UserAgent;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);

our $firsturl = 'http://www.pdaking.com.tw/cgi-bin/shop/search.cgi?search';
our $VERSION = '0.01';

sub query {
    my $pkg = shift;
    my $ua = new LWP::UserAgent(proxy => $pkg->{proxy}, cookie_jar => $pkg->{jar});
    my $content = ($ua->post($firsturl, {keywords=> $pkg->{product}}))->{_content};
    my(@result, %detail, %nextpages, $item);
    while($content =~ m,(http://www.pdaking.com.tw/cgi-bin/shop/search.cgi\?cart_id=\d+&keywords=.+?&page=\d+),sgo){
	$nextpages{$1} = 1;
    }
    foreach (keys %nextpages){
	my $content = ($ua->get($_))->{_content};
	while($content =~ m,href="(http://www.pdaking.com.tw/cgi-bin/shop/shop.cgi\?action=imgbig.+?)",sg){
	    $detail{$1} = 1;
	}
    }
    foreach (keys %detail){
	undef $item;
	my $content = ($ua->get($_))->{_content};
	if($content =~ m,商品.+?color="#.+?">(.+?)</font>,m){
	    $item->{product} = $1;
	}
	if($content =~ m,特價.+?color="#.+?">(\d+)元,m){
	    $item->{price} = $1;
        }
	if($content =~ m,<table width="100%" border="0" cellspacing="0" cellpadding="3">.+?<tr valign="top"><td align="center" WIDTH=50%>.+?<img src="(.+?)" border=0>.+?</td><td WIDTH=50%>,s){
	    $item->{photo} = $1;
	}
	push @result, $item;
    }
    return \@result;
}
1;

__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800
