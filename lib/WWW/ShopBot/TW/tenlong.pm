package WWW::ShopBot::TW::tenlong;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

use HTML::Entities ();

sub linkextor {
    my($textref, $collector) = @_;
    while($$textref =~ m,<td><a href="(view_oldbook_html\?oldbook_isbn=.+?)",g){
        $collector->{"http://www.tenlong.com.tw/catalog/".$1} = 1;
    }
}

sub nextextor {
    my($textref, $collector) = @_;
    while($$textref =~ /pattern here/g){
        $collector->{$1} = 1;
    }
}

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://www.tenlong.com.tw/');
    $agent->forms(0);
    $agent->field('oldbook_keyword:nb', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    # extract links
    linkextor(\$content, \%links);

    while(1){
	unless($content =~ m,</table>[\t\s\n]+?<a href="(http://www.tenlong.com.tw/catalog/oldbook_keyword_html\?.+?&query_start=\d+)".+?\Q(後 \E\d+\Q 筆結果)\E,s){
	    linkextor(\$content, \%links);
	    last;
	}
	$agent->get($1);
	$content = $agent->content;
	linkextor(\$content, \%links);
    };

    foreach (keys %links){
        undef $item;
	$agent->get($_);
	$content = $agent->content;
	if($content =~ m,<h2><font color="green">[\s\t\n]+(.+?)[\s\t\n]+</font></h2>,s){
	    $item->{product} = $1;
	    if($content =~ /\Q定價： 新台幣 \E(\d+)\Q 元正<br>\E/){
		$item->{price} = $1;
		if($content =~ m,<img src="(http://www.tenlong.com.tw/catalog/cover/.+?)" alt,){
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
    - template created using bin/shopbot.pl
         Wed, 12 Mar 2003 18:20:35 +0800


