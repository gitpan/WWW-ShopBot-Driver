package WWW::ShopBot::TW::olbook;
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
    $agent->get('http://www.olbook.com.tw/');
    $agent->form(2);
    $agent->field('k', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $link_accept    = qr'view.php\?id='o;

    $pkg->linkextor(\$content, \%links, $link_accept);

    my $specpatt = {
	product => qr'<font color="#FF6600" class="idx-black">(.+?)</font><br>'o,
	price   => qr'Àu´f»ù¡G<b><font color="#CC0000"> (\d+)</font></b>'o,
	photo   => qr'<img src="(http://www.olbook.com.tw/picture/.+?)"'o,
    };

    foreach my $link (map{"http://www.olbook.com.tw/books/$_"} keys %links){
	print $link.$/;
	$item = {};
	$agent->get($link);
	$content = $agent->content;
        if($pkg->specextor(\$content, $item, $specpatt)){
          $item->{link} = $link;
	  push @result, $item;
        }

    }

    # return an anonymous array of hashes
    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - template created using shopbot.pl
         Sun, 16 Mar 2003 00:18:10 +0800


