package WWW::ShopBot::Driver;
our $VERSION = '0.005';
use Carp qw(confess);
use Data::Dumper;
use strict;
sub new { bless $_[1], $_[0] }
sub query { [] }

use HTML::LinkExtractor;

sub transformarg {
    my $pkg = shift;
    my $pattern = {};
    if(@_ == 1 && ref($_[0]) =~ /^[HA]/o){
        if(ref($_[0]) eq 'HASH')   {
            $pattern = shift;
        }
        elsif(ref($_[0]) eq 'ARRAY'){
            @{$pattern}{qw(accept discard refine)} = @{$_[0]};
        }
    }
    else{
	@{$pattern}{qw(accept discard refine)} = @_;
    }
    $pattern;
}

sub match {
    my $pkg = shift;
    my $textref = shift;
    my $pattern = $pkg->transformarg(@_);
    return if $pattern->{discard} && $$textref =~ /$pattern->{discard}/;
    if($$textref =~ /$pattern->{accept}/){
	if(ref($pattern->{refine}) eq 'CODE' ){
	    $pattern->{refine}->($textref);
	}
	elsif(defined $pattern->{refine}){
	    eval '$$textref =~ '.$pattern->{refine}.';';
	    confess "Transformation error => $pattern->{refine}" if $@;
	}
	return 1;
    }
}

sub linkextor {
    my $pkg = shift;
    my $textref = shift;
    my $collector = shift;
    my $pattern = $pkg->transformarg(@_);
    return unless $$textref;

    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($pkg->match(\${$_}{href}, $pattern)){
	    $collector->{$_->{href}} = 1;
	    $cnt++;
	}
    }
    $cnt;
}

sub nextextor {
    my $pkg = shift;
    my $textref = shift;
    my $collector = shift;
    my $pattern = $pkg->transformarg(@_);
    return unless $$textref;

    my $LX = new HTML::LinkExtractor();
    $LX->parse($textref);

    my $cnt = 0;
    foreach (@{$LX->links()}){
	if($pkg->match(\${$_}{href}, $pattern)){
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
    if($$textref =~ m/$pattern->{product}/){
	$collector->{product} = $1;

	if($$textref =~ m/$pattern->{price}/){
	    $collector->{price} = $1;

	    if($$textref =~ m/$pattern->{photo}/){
		$collector->{photo} = $1;
	    }

	    foreach my $entry (keys %{$pattern}){
		next if /^p(?:roduct|rice|hoto)$/o;
		if($$textref =~ m/$pattern->{$entry}/){
		    $collector->{$entry} = $1;
		}
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

=over 5

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

Every driver inherits from L<WWW::ShopBot::Driver>, and every query request will pass to C<query> in every driver. So, please remember to let C<query> be the retrieving subroutine. Or more simply, you can use the accompanying L<shopbot.pl> to generate a driver template.

You can use various modules to get data and extract them. Shopbot the module (does|can) not confine you to any fixed way. There are many modules for dealing with this; you can try them all.

However, L<WWW::ShopBot::Driver> does presume a common convention, I think, which works with lots of sites. In general, following this convention may speed up your driver development.

See L<shopbot.pl>

=item *

L<WWW::ShopBot::Driver> defines three common method ready for inheritance: C<nextextor>, C<linkextor>, and C<specextor>, which you can use in C<query>.

=over 3

=item * nextextor is defined for grabbing links to next pages

  $pkg->nextextor(\$content, \%next, $next_accept, $next_discard);

C<nextextor> uses L<HTML::LinkExtractor> to extract links in a page. Any link matches the given $next_accpet is stored in %next, but is discarded if it matches $next_discard

=item * linkextor is defined for grabbing links to pages of products' details

  $pkg->linkextor(\$content, \%next, $link_accept, $link_discard);

Same as C<nextextor>, any link matches $link_accpet is stored in %links; discarded if it matches $link_discard

=item * specextor is defined for analyzing pages of products' details

    $pkg->specextor(\$content, $item,
		    {
			product => qr'<a href="blah">(.+?)</a>',
			price => qr'<b>(.+?)</b>',
			photo => qr'<img src="(.+?)">',
		    });

It extracts the data that all match the given criteria and stores them in $item.


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
