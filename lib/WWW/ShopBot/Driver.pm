package WWW::ShopBot::Driver;
our $VERSION = '0.004';


sub new { bless $_[1], $_[0] }
sub query { [] }

use HTML::LinkExtractor;
use HTML::Entities ();
use LWP::Simple;

sub linkextor {
    my $pkg = shift;
    my($textref, $collector, $pattern) = @_;
    return unless $$textref;
    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($_->{href} =~ /$pattern/){
	    $collector->{$_->{href}} = 1;
	    $cnt++;
	}
    }
    $cnt;
}

sub nextextor {
    my $pkg = shift;
    my($textref, $collector, $pattern) = @_;
    return unless $$textref;
    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($_->{href} =~ /$pattern/){
	    $collector->{$_->{href}} = 1;
	    $cnt++;
	}
    }
    $cnt;
}

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



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

WWW::ShopBot::Driver - Basic class for shopbot drivers

=head1 DESCRIPTION

L<WWW::ShopBot::Driver>, which comes with multiple drivers for various merchants' sites, is a co-module released for L<WWW::ShopBot>. When you need to grab information on certain sites, invoke L<WWW::ShopBot> with drivers and the bot will automatically retrieve data.

There are some things to be noted for driver development.

=over 4

=item *

Since there are innumerable shops online, it is important to have a clear hierarchy for drivers. Each driver must be under L<WWW::ShopBot> the namespace, and be organized according to country code in domain name or company's residence.

For example,

  WWW::ShopBot::TW::yahoo

  WWW::ShopBot::UK::ebay

If domain name doesn't contain country's information, use the last piece instead. For example,

  WWW::ShopBot::COM::ebay

  WWW::ShopBot::COM::froogle

=item *

Also because there are lots of EC sites, L<WWW::ShopBot::Driver> is isolated from L<WWW::ShopBot> to prevent from rapid-growing version number.

=item *

Every driver inherits from L<WWW::ShopBot::Driver>, and every query request will pass to C<query> in every driver. So, please remember to let C<query> be the retrieving subroutine. Or more simply, you can use the accompanying C<shopbot.pl> to generate a driver template.

You can use various modules to get data and extract them. Shopbot the module (does|can) not confine you to any fixed way. There are many modules for dealing with this; you can try them all.

Driver.pm also defines three common method ready for inheritance: C<nextextor>, C<linkextor>, and C<specextor>, which you can use in C<query>.

=over 3

=item * nextextor is defined for grabbing links to next pages

  $pkg->nextextor(\$content, \%next, qr/pattern here/);

C<nextextor> use L<HTML::LinkExtractor> to extract links in a page. Any link matches the given pattern is stored in %next

=item * linkextor is defined for grabbing links to pages of products' details

  $pkg->linkextor(\$content, \%next, qr/pattern here/);

Same as C<nextextor>, any link matches the given pattern is stored in %links

=item * specextor is defined for analyzing pages of products' details

    $pkg->specextor(\$content, $item,
		    {
			product => qr'<a href="blah">(.+?)</a>',
			price => qr'<b>(.+?)</b>',
			photo => qr'<img src="(.+?)">',
		    });

It extracts the data that all match the given criteria and store them in $item.


=back 

=item *

If you want to use a driver which is not distributed with the module, please be sure that your driver, say C<TW::Buzz.pm>, dwells in ${one of you @INC path}/WWW/ShopBot/TW/Buzz.pm

=back

=head1 CAVEAT

The drivers are far from perfection; you should edit the code for any specific or advanced use.

I<Of course, contributions are always welcomed.>

=head1 SEE ALSO

L<WWW::ShopBot>

L<HTML::TableExtract>, L<HTML::TableExtractor>, L<HTML::TableParser>, L<HTML::TableContentParser> 

L<HTML::LinkExtractor>, L<HTML::LinkExtor>, L<HTML::SimpleLinkExtor>

L<HTML::Parser>, L<HTML::TokeParser>, L<HTML::SimpleParse>,


=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut
