package WWW::ShopBot::TW::lailai;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

sub linkextor {
    my($textref, $collector) = @_;

    while($$textref =~ m,href="(http://www.lailai.com.tw/tchinese/product_info.php\?products_id=.+?)",mgo){
	$collector->{$1} = 1;
    }
    
}

sub nextextor {
    my($textref, $collector) = @_;
    while($$textref =~ m,href="(http://www.lailai.com.tw/tchinese/advanced_search_result.php\?keywords=.+?page=.+?)",sgo){
        next if $1 =~ /action=/o;
        $collector->{$1} = 1;
    }
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://www.lailai.com.tw/tchinese/');
    $agent->form(1);
    $agent->field('keywords', $pkg->{product});
    $agent->click();

    $content = $agent->content;
    linkextor(\$content, \%links);
    nextextor(\$content, \%next);

    foreach (keys %next){
	$agent->get($_);
	$content = $agent->content;
	linkextor(\$content, \%links);
    }
    foreach (keys %links){
        undef $item;
	$agent->get($_);
	$content = $agent->content;
	if( $content =~ m,<td class="pageHeading">(.+?)</td>,o){
	    $item->{product} = $1;
	    if($content =~ m,»ù®æ :</font> NT\$(.+?)</td>,o){
		$item->{price} = $1;
		if($content =~ m,href="(http://www.lailai.com.tw/tchinese/images/.+?)\?osCsid=.+?",o){
		    $item->{photo} = $1;
		}
	    }
	}
	push @result, $item;
    }

    # return an anonymous array of hashes
    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - Wed, 12 Mar 2003 13:45:49 +0800


