package WWW::ShopBot::TW::4book;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

my $home = 'http://www.4book.com.tw';

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get($home);
    $agent->form(1);
    $agent->field('SearchKey', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $link_accept    = qr'/PublisherBookPage/ShowPublisherSingleBookPage.hi\?'o;
    my $link_refine    = 's/^\s+//';
    $pkg->linkextor(\$content, \%links,
		    {
			accept => $link_accept,
			refine => $link_refine,
		    });

    my $specpatt = {
	product => qr'<font class="fontsize12" color=#000000>.+?(.+?)</a><br>'so,
	price   => qr'«D·\|­û&nbsp;<font color=#0f0029><font color=red>(\d+)</font>&nbsp;'o,
	photo   => qr'<img src="(/image/publisherBookPage/.+?)"'o,
    };

    foreach my $link (map{"$home$_"} keys %links){
	print $link.$/;
	$item = {};
	$agent->get($link);
	$content = $agent->content;

        if($pkg->specextor(\$content, $item, $specpatt)){
	    $item->{product} =~ s/^\s+//o;
	    $item->{link} = $link;
	    $item->{photo} = $home.$item->{photo};
	    push @result, $item;
        }

    }

    # return an anonymous array of hashes
    \@result;
}
1;
__END__


0.01 author <author@shhhhhh.com>
    - template created using shopbot.pl
         Sun, 16 Mar 2003 01:15:46 +0800


