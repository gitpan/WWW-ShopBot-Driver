package WWW::ShopBot::TW::mren;
use strict;
use WWW::Mechanize;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.02';

sub specextor {
    my $pkg = shift;
    my ($textref, $collector, $pattern) = @_;
    return unless $$textref;
    if($$textref =~ m/${$pattern}{product}/){
       $collector->{product} = $1;
    
       if($$textref =~ m/${$pattern}{price}/){
	  $collector->{price} = $1;

	  if($$textref =~ m/${$pattern}{photo}/){
	   $collector->{photo} = $1;
          }
       }
    }
    1 if defined $collector->{price} && defined $collector->{product};
}

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

    foreach (map{"http://www.mren.com.tw/product/$_"} keys %links){
	$item = {};
	$agent->get($_);
	$content = $agent->content;

	$pkg->specextor
	    (
	     \$content, $item,
	     {
		 product => qr'<p align="center">&nbsp;<font color="#FFFFFF"><b>(.+?)</b></font></p>'o,
		 price => qr'<font color="white">«ØÄ³»ù.+?face=".+?sans-serif">([\d\.]+?)</font>'so,
		 photo => qr/"javascript:window\.open\('showimage\.php3\?(pid=\d+)',/o
             }
            );

        $agent->get("http://www.mren.com.tw/product/showns.php3?".$item->{photo});
        $content = $agent->content;
        if( $content =~ /img src=(.+?) width/o){
            $item->{photo} = "http://www.mren.com.tw/product/$1";
        }

	push @result, $item;
    }

    \@result;
}
1;


__END__

0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

0.02 xern
    Thu, 13 Mar 2003 20:06:22 +0800

