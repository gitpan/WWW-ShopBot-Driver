use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'WWW::ShopBot::Driver',
    'VERSION_FROM'	=> 'Driver.pm', 
    'PREREQ_PM'		=> {
	'WWW::Mechanize' => '0.37',
	'LWP::UserAgent' => '2.003',
	'WWW::ShopBot'   => '0.04',
	'HTML::TableContentParser' => '0.13',
    }, 
    'EXE_FILES'          => [ <bin/*> ],
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Driver.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
);
