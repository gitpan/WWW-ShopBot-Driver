package WWW::ShopBot::TW::mren;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

sub query {
    my $pkg = shift;
    my ($content, $item, @result);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://mren.com.tw/menu.html');
    $agent->form_name('allform');
    $agent->field('keyword', $pkg->{product});
    $agent->click();
    my %detail;
    $content = $agent->content;
    while($content =~ /href="(show\.php3\?id=.+?)">/mgo){
	$detail{'http://www.mren.com.tw/product/'.$1} = 1;
    }
    foreach (keys %detail){
        undef $item;
	$agent->get($_);
	$content = $agent->content;
	if($content =~ m,<p align="center">&nbsp;<font color="#FFFFFF"><b>(.+?)</b></font></p>,){
	    $item->{product} = $1;

	    if($content =~ m!<font color="white">«ØÄ³»ù.+?face=".+?sans-serif">([\d\.]+?)</font>!s){
		$item->{price} = $1;
		if($content =~ /"javascript:window\.open\('showimage\.php3\?(pid=\d+)',/){
                    $agent->get("http://www.mren.com.tw/product/showns.php3?$1");
                    $content = $agent->content;
                    if( $content =~ /img src=(.+?) width/o){
                        $item->{photo} = "http://www.mren.com.tw/product/$1";
                    }
                }
	    }
	}
	push @result, $item;
    }

    \@result;
}
1;


__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800
