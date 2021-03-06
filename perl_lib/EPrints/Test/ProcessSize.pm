package EPrints::Test::ProcessSize;

=head1 NAME

EPrints::Test::ProcessSize - track the increase in Apache process size

=head1 SYNOPSIS

	# Add to cfg/apache.conf
	PerlInitHandler EPrints::Test::ProcessSize

Then monitor the Perl apache error log.

=head1 DESCRIPTION

This module hooks into the PerlInit and PerlCleanup stages of mod_perl to test whether the Apache child process has increased its footprint (based on GTop's 'resident' memory).

The log entries look like this:

	[pid] before increase method uri

Where:

=over 4

=item [pid]

The child process id.

=item before

The resident size before running the request.

=item increase

The increase in memory size after running the request.

=item method

The HTTP method (GET/POST etc.).

=item uri

The URI that was requested.

=back

=cut

use GTop;

use strict;

sub handler
{
	my( $r ) = @_;

	my $uri = $r->unparsed_uri;
	my $size = GTop->new->proc_mem( $$ )->resident;
	my $method = $r->method;

	$r->set_handlers(PerlCleanupHandler => sub { &record( $uri, $size, $method ) });

	return Apache2::Const::OK;
}

sub record
{
	my( $uri, $size, $method ) = @_;

	my $proc_mem = GTop->new->proc_mem( $$ );
	my $new_size = GTop->new->proc_mem( $$ )->resident;
	my $real_size = $proc_mem->size - $proc_mem->share;

	my $diff = $new_size - $size;

	print STDERR "[$$] $real_size $size ".EPrints::Utils::human_filesize($diff)." $method $uri\n";
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

