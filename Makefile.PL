use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Parallel::DownloadQueue',
    AUTHOR => 'Sebastian Stumpf <sepp@cpan.org>',
    VERSION_FROM => 'lib/Parallel/DownloadQueue.pm',
    ABSTRACT => 'Fetch URLs parallel via Thread::Queue',
    LICENSE => 'artistic_2',
    MIN_PERL_VERSION => '5.014000.',
    PREREQ_PM => {
        'Moo' => 0,
        'MooX::Types::MooseLike' => 0,
        'Thread::Queue' => 0,
        'LWP::UserAgent' => 0,
    }
);
