package WWW::ShopBot::TW::pchome;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.02';


sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://shopping.pchome.com.tw/');
    $agent->form(1);
    $agent->field('target', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $linkpatt = qr'.+?/detail.php\?pid=.+?'o;

    $pkg->linkextor(\$content, \%links, $linkpatt);

    $content =~ m,>(\d+)</font>&nbsp;筆</td>,;

    foreach my $p ( 2..int ($1/20)+1 ){
	$agent->get('http://shopping.pchome.com.tw/search.htm?target='.$pkg->{product}."&kind=index&page=$p");
	$content = $agent->content;
	$pkg->linkextor(\$content, \%links,);
    }
    
    foreach ( map{"http://shopping.pchome.com.tw$_"} keys %links ){
	$item = {};
	$agent->get($_);
	$content = $agent->content;
	$pkg->specextor(\$content, $item,
			{
			    product => qr'<!--- 品名 --->.+?<span class=item2>(.+?)</span>'s,
			    price => qr'特價</b>&nbsp;&nbsp;<b><font face=".+?" color=c90026>\$(.+?)</font></b>'m,
			    photo => qr'<img src="(.+?)" width=120 height=120 border=0 alt="點圖看大圖">'m,
			    });
	$item->{photo} = "http://shopping.pchome.com.tw".$item->{photo};
	push @result, $item;
    }

    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - Wed, 12 Mar 2003 13:12:23 +0800

0.02 xern
    - Thu, 13 Mar 2003 20:26:41 +0800

