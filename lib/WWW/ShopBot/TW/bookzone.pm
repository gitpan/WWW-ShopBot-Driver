package WWW::ShopBot::TW::bookzone;
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
    $agent->get('http://www.bookzone.com.tw/book/seek.asp#t1');
    $agent->form_name('form1');
    $agent->field('text1', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    my $linkpatt = qr'showbook.asp\?bookno'o;
    my $nextpatt = qr'pageno='o;
    $pkg->linkextor(\$content, \%links, $linkpatt);
    $pkg->nextextor(\$content, \%next, $nextpatt);

    foreach (map{"http://www.bookzone.com.tw/book/$_"} grep {$_!~/pageno=[01]/o} keys %next){
	$agent->get($_);
	$content = $agent->content;
	$pkg->linkextor(\$content, \%links, $linkpatt);
    }

    my $specpatt = {
	product => qr'<b><font color="#214327" size="3">(.+?)</font></b><br>'o,
	price   => qr'網站特惠價.+?<font class="pfont">(\d+)</font>元<br>'so,
	photo   => qr'<img border="0" src=".(/bkimages/book/.+?)"></td>'o,
    };

    foreach (map{ s,\./,,;s/showbook/showbook1/;"http://www.bookzone.com.tw/book/".$_} keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;

	if( $pkg->specextor(\$content, $item, $specpatt) ){
	    $item->{link} = $_;
	    $item->{photo} = "http://www.bookzone.com.tw".$item->{photo};
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
         Fri, 14 Mar 2003 21:36:53 +0800


