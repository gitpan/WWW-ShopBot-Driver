package WWW::ShopBot::TW::tenlong;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.03';

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar},
				    );
    $agent->get('http://www.tenlong.com.tw/');
    $agent->forms(0);
    $agent->field('oldbook_keyword:nb', $pkg->{product});
    $agent->click();

    $content = $agent->content;

    my $linkpatt = qr'view_oldbook_html\?oldbook_isbn=.+?';

    $pkg->linkextor(\$content, \%links, $linkpatt);

    while(1){
	unless($content =~ m,</table>[\t\s\n]+?<a href="(http://www.tenlong.com.tw/catalog/oldbook_keyword_html\?.+?&query_start=\d+)".+?\Q(後 \E\d+\Q 筆結果)\E,s){
	    $pkg->linkextor(\$content, \%links, $linkpatt);
	    last;
	}
	$agent->get($1);
	$content = $agent->content;
	$pkg->linkextor(\$content, \%links, $linkpatt);
    };

    my $specpatt =  {
	product => qr'<h2><font color="green">[\s\t\n]+(.+?)[\s\t\n]+</font></h2>'o,
	price => qr'新台幣 (\d+) 元正<br>',
	photo => qr'<img src="(http://www.tenlong.com.tw/catalog/cover/.+?)"'o,
    };

    foreach (map{"http://www.tenlong.com.tw/catalog/$_"} keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;
        if($pkg->specextor(\$content, $item, $specpatt)){
	    $item->{link} = $_;
	    push @result, $item;
	}
    }

    # return an anonymous array of hashes
    \@result;
}
1;
__END__


0.01 xern <xern@cpan.org>
    - template created using bin/shopbot.pl
         Wed, 12 Mar 2003 18:20:35 +0800

0.02 xern
    - Thu, 13 Mar 2003 20:53:14 +0800

0.03 xern
    - Sat, 15 Mar 2003 12:38:09 +0800
