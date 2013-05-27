#!/usr/bin/env perl
package Parallel::DownloadQueue;
use 5.14.0;
use strict;
use warnings;
use threads;

our $VERSION = '0.0.1';

=head1 NAME

Parallel::DownloadQueue - Fetch multiple URLs via Thread::Queue

=head1 SYNOPSIS

  my $pdq = Parallel::DownloadQueue->new(threads => 10);
  my @results = $pdq->load(@urls);

=head1 DESCRIPTION

L<Parallel::DownloadQueue> fetches multiple URLs via L<LWP::UserAgent>
and L<Thread::Queue> and returns a list containing all L<HTTP::Response>
responses.

=head1 PARAMETERS

L<Parallel::DownloadQueue> requires the following constructor parameters:

=head2 B<threads>

The number of threads (default: 6)

=head2 B<ua>

An instance of LWP::UserAgent (default: create a new user agent automatically)

=head2 B<log>

A CODEREF that will be called before each request is executed. It receives two
parameters: The current thread id and the url which will be fetched.

  my $pdq = Parallel::DownloadQueue->new(
      log => sub {
          my ($thread, $url) = @_;
          say "[$thread] $url";
      }
  );

=cut

use Moo;
use MooX::Types::MooseLike::Base qw(Int InstanceOf CodeRef);
use Thread::Queue;
use LWP::UserAgent;
use Carp;

has threads => (
    is => 'ro',
    isa =>  Int,
    required => 1,
    default => sub { 6 }
);

has ua => (
    is => 'ro',
    isa => InstanceOf['LWP::UserAgent'],
    required => 1,
    default => sub { LWP::UserAgent->new; }
);

has log => (
    is => 'ro',
    isa =>  CodeRef,
    required => 0,
    predicate => 1
);

=head1 METHODS

=head2 load

Fetches all specified URLs and returns the result B<after> the last
request is done.

  my @results = $pdq->load('http://cpan.org', 'http://perl.com');

=cut

sub load {
    my $self = shift;
    my @urls = @_;

    if($#urls == -1) {
        return ();
    }
    elsif($#urls == 0) {
        return $self->ua->get(shift @urls);
    }

    my $out = Thread::Queue->new;
    my $in = Thread::Queue->new(@urls);
    $in->enqueue(undef) for 1 .. $self->threads;

    my $code = sub {
        while(my $link = $in->dequeue) {
            &{$self->log}(threads->tid, $link) if $self->has_log;
            $out->enqueue($self->ua->get($link));
        }
    };

    my @threads;
    push @threads, threads->create($code) for(1 .. $self->threads);
    $_->join for @threads;
    return @{$out->{queue}};
}

=head1 SEE ALSO

L<threads>, L<Thread::Queue>, L<LWP::UserAgent>, L<Moo>.

=head1 AUTHOR

Sebastian Stumpf, S<E<lt>sepp AT perlhacker DOT orgE<gt>>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1
