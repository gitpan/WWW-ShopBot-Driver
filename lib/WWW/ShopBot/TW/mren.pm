package WWW::ShopBot::TW::mren;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.03';

sub query {
    my $pkg = shift;
    my ($content, $item, @result, %next, %links);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://mren.com.tw/menu.html');
    $agent->form_name('allform');
    $agent->field('keyword', $pkg->{product});
    $agent->click();

    $content = $agent->content;

    $pkg->linkextor(\$content, \%links, qr'show\.php3\?id=.+'o);

    my $specpatt =  {
	product => qr'<p align="center">&nbsp;<font color="#FFFFFF"><b>(.+?)</b></font></p>'o,
	price => qr'<font color="white">«ØÄ³»ù.+?face=".+?sans-serif">([\d\.]+?)</font>'so,
	photo => qr/"javascript:window\.open\('showimage\.php3\?(pid=\d+)',/o
             };

    foreach (map{"http://www.mren.com.tw/product/$_"} keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;

	if($pkg->specextor(\$content, $item, $specpatt)){
          $item->{link} = $_;
          $agent->get("http://www.mren.com.tw/product/showns.php3?".$item->{photo});
          $content = $agent->content;
          if( $content =~ /img src=(.+?) width/o){
              $item->{photo} = "http://www.mren.com.tw/product/$1";
          }
	  push @result, $item;
        }
    }

    \@result;
}
1;


__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

0.02 xern
    Thu, 13 Mar 2003 20:06:22 +0800

0.03 xern
    Sat, 15 Mar 2003 13:34:27 +0800
