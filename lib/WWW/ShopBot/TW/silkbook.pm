package WWW::ShopBot::TW::silkbook;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.02';

use HTML::Entities ();

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://www.silkbook.com.tw/');
    $agent->form('form1');
    $agent->field('text', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $linkpatt = qr'http://www.silkbook.com.tw/content/4th.asp\?goods_ser=.+?';
    my $nextpatt = qr'Search_List_Book.asp\?Sort_flag=8&.+?';

    # extract links
    $pkg->linkextor(\$content, \%links, $linkpatt);

    # extract next pages
    $pkg->nextextor(\$content, \%next, $nextpatt);

    foreach (
	     map{HTML::Entities::decode("http://www.silkbook.com.tw/function/$_")}
	       grep {$_!~/page=1&/o} keys %next){
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
			    product => qr'<font COLOR="#BD0000">�� </font><font COLOR="#0000A0">\s*(.+?)\s*</font>'o,
			    price => qr'����G<FONT FACE="Arial" COLOR="#BD0000">(.+?)</FONT>��<BR>'o,
			    photo => qr'<img src="(.+?)" ALT='o,
			});
	$item->{product} =~ s/--$//o;
	$item->{photo} = "http://www.silkbook.com.tw".$item->{photo};
	push @result, $item;
    }

    \@result;
}
1;
__END__


0.01 xern <xern@cpan.com>
    - template created using bin/shopbot.pl
         Wed, 12 Mar 2003 14:41:19 +0800

0.02 xern
    - Thu, 13 Mar 2003 20:34:35 +0800

