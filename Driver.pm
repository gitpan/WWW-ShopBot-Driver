package WWW::ShopBot::Driver;1;
our $VERSION = '0.001';
sub new { bless $_[1], $_[0] }
sub query { [] }


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

WWW::ShopBot::Driver - Basic class for shopbot drivers

=head1 DESCRIPTION

L<WWW::ShopBot> is trying to become a powerful shopping agent. You can use it to grab any product's information all over the world with an easy script.

And that's what drivers do.

L<WWW::ShopBot::Driver> comes with multiple drivers for various merchants' sites. When you need to grab information on certain sites, invoke drivers and the bot will automatically retrieve data.

There are some things to be noted.

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

=item *

If you want to use a driver which is not distributed with the module, please be sure that your driver, say C<TW::Buzz.pm>, dwells in ${one of you @INC path}/WWW/ShopBot/TW/Buzz.pm

=back

=head1 SEE ALSO

L<WWW::ShopBot>

L<HTML::TableExtract>, L<HTML::TableExtractor>, L<HTML::TableParser>, L<HTML::TableContentParser> 

L<HTML::LinkExtractor>, L<HTML::LinkExtor>, L<HTML::SimpleLinkExtor>

L<HTML::Parser>, L<HTML::TokeParser>, L<HTML::SimpleParse>,


=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut
