package WWW::ShopBot::TW::pdaking;
use strict;
use LWP::UserAgent;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);

our $VERSION = '0.03';
use LWP::Simple;
use HTML::LinkExtractor;


our $firsturl = 'http://www.pdaking.com.tw/cgi-bin/shop/search.cgi?search';

sub query {
    my $pkg = shift;
    my (@result, %links, %next, $item);
    my $ua = new LWP::UserAgent(proxy => $pkg->{proxy}, cookie_jar => $pkg->{jar});
    my $content = ($ua->post($firsturl, {keywords=> $pkg->{product}}))->{_content};

    my $linkpatt = qr,http://www.pdaking.com.tw/cgi-bin/shop/shop.cgi\?action=imgbi,;
    my $nextpatt = qr'search.cgi\?cart_id=\d+&keywords=.+?&page=\d+'o;

    $pkg->nextextor(\$content, \%next, $nextpatt);

    foreach (keys %next){
	my $content = get($_);
	next unless $content;
	$pkg->linkextor(\$content, \%links, );
    }

    my $specpatt = {
	product => qr,商品.+?color="#.+?">(.+?)</font>,m,
	price   => qr,特價.+?color="#.+?">(\d+)元,m,
	photo   => qr,<table width="100%" border="0" cellspacing="0" cellpadding="3">.+?<tr valign="top"><td align="center" WIDTH=50%>.+?<img src="(.+?)" border=0>.+?</td><td WIDTH=50%>,s,
    };

    foreach (keys %links){
	$item = {};
	my $content = get($_);
	if($pkg->specextor(\$content, $item, $specpatt)){
	    $item->{link} = $_;
	    push @result, $item;
	}
    }
    return \@result;
}
1;

__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

0.02 xern
    Thu, 13 Mar 2003 18:53:27 +0800

0.03 xern
    Sat, 15 Mar 2003 13:50:02 +0800
