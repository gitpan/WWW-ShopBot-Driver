package WWW::ShopBot::TW::lailai;
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
    $agent->get('http://www.lailai.com.tw/tchinese/');
    $agent->form(1);
    $agent->field('keywords', $pkg->{product});
    $agent->click();

    $content = $agent->content;

    my $linkpatt = qr'http://www.lailai.com.tw/tchinese/product_info.php\?products_id=.+?'o;
    my $nextpatt = qr'http://www.lailai.com.tw/tchinese/advanced_search_result.php\?keywords=.+?page=.+?';

    $pkg->linkextor(\$content, \%links, $linkpatt);
    $pkg->nextextor(\$content, \%next, $nextpatt);

    foreach (grep { $_ !~ /action=/o } keys %next){
	$agent->get($_);
	$content = $agent->content;
	$pkg->linkextor(\$content, \%links, $linkpatt);
    }

    foreach (keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;

	$pkg->specextor(\$content, $item,
			{
			    product => qr'<td class="pageHeading">(.+?)</td>'o,
			    price => qr'»ù®æ :</font> NT\$(.+?)</td>'o,
			    photo => qr'href="(http://www.lailai.com.tw/tchinese/images/.+?)\?osCsid=.+?"'o,
			});
	push @result, $item;
    }

    # return an anonymous array of hashes
    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - Wed, 12 Mar 2003 13:45:49 +0800

0.02 xern
    - Thu, 13 Mar 2003 20:01:40 +0800
