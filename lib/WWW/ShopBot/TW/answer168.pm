package WWW::ShopBot::TW::answer168;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.03';


our $base = 'http://www.answer168.com';
sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);

    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get($base);
    $agent->form_name('searchprdt');
    $agent->field('searchword', $pkg->{product});
    $agent->click();

    my $content = $agent->content;
    if($content =~ m,href="(product.+?=all)",o){
	$agent->get($base."/goods/$1");
	$content = $agent->content;
    }
    $pkg->linkextor(\$content, \%links, qr'layout=0&class_no.+?goods'o);

    my $specpatt = {
	product => qr'<td><b><span class="text18">(.+?)</span></b>'o,
	price => qr'»ù¡G<b><font color="#.+?">\$(.+)</font></b>¤¸<br>'o,
	photo => qr'/(image/mall_image/.+?\.jpg)'o,
    };

    foreach (keys %links){
	$item = {};
	$agent->get($base.$_);
	$content = $agent->content;
	if($pkg->specextor(\$content, $item, $specpatt)){
	    $item->{link} = $base.$_;
	    $item->{photo} = $base.'/'.$item->{photo};
	    $item->{price} =~ s/,//o;
	    push @result, $item;
	}
    }
    \@result;
}
1;

__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

0.02 xern
    Thu, 13 Mar 2003 19:40:15 +0800

0.03 xern
    Sat, 15 Mar 2003 12:57:14 +0800
