package WWW::ShopBot::TW::pchome;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

sub linkextor {
    my($textref, $collector) = @_;
    while($$textref =~ m,<a href="(.+?/detail.php\?pid=.+?)",go){
	$collector->{'http://shopping.pchome.com.tw'.$1} = 1;
    }
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://shopping.pchome.com.tw/');
    $agent->form(1);
    $agent->field('target', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    linkextor(\$content, \%links);

    $content =~ m,>(\d+)</font>&nbsp;筆</td>,;
    foreach my $p ( 2..int ($1/20)+1 ){
	$agent->get('http://shopping.pchome.com.tw/search.htm?target='.$pkg->{product}."&kind=index&page=$p");
	$content = $agent->content;
	linkextor(\$content, \%links);
    }

    foreach (keys %links){
        undef $item;

	$agent->get($_);
	$content = $agent->content;
	if($content =~ m,<!--- 品名 --->.+?<span class=item2>(.+?)</span>,s){
	    $item->{product} = $1;
	    if($content =~ m,特價</b>&nbsp;&nbsp;<b><font face=".+?" color=c90026>\$(.+?)</font></b>,m){
		$item->{price} = $1;
		if($content =~ m,<img src="(.+?)" width=120 height=120 border=0 alt="點圖看大圖">,){
		    $item->{photo} = "http://shopping.pchome.com.tw$1";
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
    - Wed, 12 Mar 2003 13:12:23 +0800


