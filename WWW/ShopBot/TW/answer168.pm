package WWW::ShopBot::TW::answer168;
use strict;
use WWW::Mechanize;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';
our $base = 'http://www.answer168.com/';

sub query {
    my $pkg = shift;
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get($base);
    $agent->form_name('searchprdt');
    $agent->field('searchword', $pkg->{product});
    $agent->click();

    my $content = $agent->content;
    if($content =~ m,href="(product.+?=all)",o){
	$agent->get($base."goods/$1");
	$content = $agent->content;
    }
    my(@result, %detail, $item);
    while($content =~ m,href="(/detail.asp\?layout=0&class_no=0&action=tempo&goods_no=.+?)",sgo){
	$detail{$1} = 1;
    }
    foreach (keys %detail){
	undef $item;
	$agent->get($base.$_);
	$content = $agent->content;
	if($content =~ m,<td><b><span class="text18">(.+?)</span></b>,){
	    $item->{product} = $1;
	}
	if($content =~ m,»ù¡G<b><font color="#.+?">\$(.+)</font></b>¤¸<br>,){
  	  $item->{price} = $1;
        }
	if($content =~ m,/(image/mall_image/.+?\.jpg),){
	    $item->{photo} = $base.$1;
	}
	push @result, $item;
    }
    \@result;
}
1;

__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800
