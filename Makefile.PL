use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'WWW::ShopBot::Driver',
    'VERSION_FROM'	=> 'Driver.pm', 
    'PREREQ_PM'		=> {
	'WWW::Mechanize' => '0.37',
	'LWP::UserAgent' => '2.003',
	'WWW::ShopBot'   => '0.05',
	'HTML::TableContentParser' => '0.13',
	'HTML::Parser'   => '3.27',
	'Cwd'            => '2.06',
    }, 
    'EXE_FILES'          => [ <bin/*.pl> ],
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Driver.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
);
