package WWW::ShopBot::COM::froogle;
use strict;
use WWW::Mechanize;
use HTML::TableContentParser;
use Data::Dumper;
use WWW::ShopBot::Driver;
our @ISA = qw(WWW::ShopBot::Driver);
our $VERSION = '0.01';

sub query {
    my $pkg = shift;
    my ($content, $item, @result);
    my $agent = WWW::Mechanize->new(proxy=> $pkg->{proxy}, cookie_jar => $pkg->{jar});
    $agent->get('http://froogle.google.com/');
    $agent->form_name('f');
    $agent->field('q', $pkg->{product});
    $agent->click();
    $content = $agent->content;

    $content =~ m,<b>(\d+)</b> results in,;
    my $num_items = $1 > 100 ? 100 : $1;
    my @urls;
    for (my $i=10; $i < $num_items; $i+=10){
	push @urls, "http://froogle.google.com/froogle?q=".$pkg->{product}."&btnG=Froogle+Search&sa=N&start=$i";
    }

    my @contents;
    push @contents, $content, map{$agent->get($_); $agent->content()} @urls;

    foreach $content (@contents){
	my $p = HTML::TableContentParser->new();
	my $tables = $p->parse($content);
	for my $t (@{$tables}[3..12]) {
	    for my $r (@{$t->{rows}}) {
		undef $item;
		for my $c (@{$r->{cells}}) {
		    if($c->{data} =~ m,"/froogle_image\?q=(http://.+(?:jpg|gif|png))&dhm=.+?",i){
			$item->{photo} = $1;
		    }
		    elsif($c->{data} =~ m,<a href="/froogle_url\?q=(http://.+?)" >(.+?)</a><br><font size=-1><font color=#993366><b>\$([\d\.]+)</b></font>&nbsp;,){
			  my ($product, $price) = ($2, $3);
			  $product =~ s,<b>(.+)</b>,$1,o;
			  $price =~ s,\.00,,;
			  $item->{product} = $product;
			  $item->{price} = $price;
		      }
		}
		push @result, $item;
	    }
	}
    };
    \@result;
}
1;

__END__


0.01 xern <xern@cpan.org>
    Tue, 11 Mar 2003 18:39:39 +0800

