package WWW::ShopBot::TW::kingstone;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://www.kingstone.com.tw/');
    $agent->form(2);
    $agent->field('p', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $linkpatt = qr'http://WWW.KINGSTONE.COM.TW/product.asp\?ACTID=tornado&id=.+'i;
    my $nextpatt = qr'/searcher';

    $pkg->linkextor(\$content, \%links, $linkpatt);
    $pkg->nextextor(\$content, \%next, $nextpatt);

    foreach (map{"http://search.kingstone.com.tw".$_} keys %next){
	$agent->get($_);
	$content = $agent->content;
        $pkg->linkextor(\$content, \%links, $linkpatt);
    }

    my $specpatt = {
	product => qr'<tr bgcolor="#999999">.+?<td><font color="#FFFFFF">(.+?)</font></td>.+?</tr>'so,
	price => qr'<font size="2" color="#CC0000">定價/.+? 元　售價/ (\d+) 元<br>'o,
	photo => qr'<img src=(/images/.+?\.jpg) width'o,
    };

    foreach (keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;
	if($pkg->specextor(\$content, $item, $specpatt)){
	    $item->{link} = $_;
	    $item->{photo} = "http://www.kingstone.com.tw".$item->{photo};
	    push @result, $item;
	}
    }

    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - template created using /usr/local/bin/shopbot.pl
         Fri, 14 Mar 2003 17:35:35 +0800


