package WWW::ShopBot::TW::silkbook;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

use HTML::Entities ();

sub linkextor {
    my($textref, $collector) = @_;
    while($$textref =~ m,HREF="(http://www.silkbook.com.tw/content/4th.asp\?goods_ser=.+?)",go){
        $collector->{$1} = 1;
    }
}


sub nextextor {
    my($textref, $collector) = @_;
    while($$textref =~ /HREF="(Search_List_Book.asp\?Sort_flag=8&.+?)"/go){
	next if $1 =~ /page=1&/o;
        $collector->{HTML::Entities::decode("http://www.silkbook.com.tw/function/$1")} = 1;
    }
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://www.silkbook.com.tw/');
    $agent->form('form1');
    $agent->field('text', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    # extract links
    linkextor(\$content, \%links);

    # extract next pages
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
	if($content =~ m,<font COLOR="#BD0000">¡´ </font><font COLOR="#0000A0">\s*(.+?)\s*</font>,){
	    $item->{product} = $1;
	    $item->{product} =~ s/--$//;
	    if($content =~ m,°â»ù¡G<FONT FACE="Arial" COLOR="#BD0000">(.+?)</FONT>¤¸<BR>,){
		$item->{price} = $1;
		if($content =~ m,<img src="(.+?)" ALT=,){
		    $item->{photo} = "http://www.silkbook.com.tw".$1;
		}
	    }
	}
	push @result, $item;
    }

    \@result;
}
1;
__END__


0.01 xern <xern@cpan.com>
    - template created using bin/shopbot.pl
         Wed, 12 Mar 2003 14:41:19 +0800


