use Test;
BEGIN { plan tests => 1 }
use WWW::ShopBot ;
use Data::Dumper;
ok(1);
$bot = new WWW::ShopBot(
			drivers => [
				    ],
			);

Dumper $bot->query('');
