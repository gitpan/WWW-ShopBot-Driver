use Test;
BEGIN { plan tests => 1 }
use WWW::ShopBot;
use Data::Dumper;
ok(1);

unshift @INC, "./lib";

@drivers = qw();
$bot = new WWW::ShopBot(
			drivers => \@drivers,
			);

print Dumper $bot->query('');
