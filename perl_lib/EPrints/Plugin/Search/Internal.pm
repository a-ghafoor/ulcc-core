=head1 NAME

EPrints::Plugin::Search::Internal

=cut

package EPrints::Plugin::Search::Internal;

@ISA = qw( EPrints::Search EPrints::Plugin::Search );

sub new
{
	my( $class, %params ) = @_;

	# needs a bit of hackery to wrap EPrints::Search
	my $self = defined $params{dataset} ?
		$class->SUPER::new( %params ) :
		$class->EPrints::Plugin::Search::new( %params )
	;

	$self->{id} = $class;
	$self->{id} =~ s/^EPrints::Plugin:://;
	$self->{qs} = 0; # internal search is default
	$self->{search} = [qw( simple/* advanced/* )];
	$self->{session} = $self->{repository} = $self->{session} || $self->{repository};

	return $self;
}

sub from_form
{
	my( $self ) = @_;

	return map { $_->from_form() } $self->get_non_filter_searchfields;
}

sub from_string
{
	my( $self, $exp ) = @_;

	$self->SUPER::from_string( $exp );

	return 1;
}

sub from_string_raw
{
	my( $self, $exp ) = @_;

	$self->SUPER::from_string_raw( $exp );

	return 1;
}

sub render_simple_fields
{
	my( $self ) = @_;

	return ($self->get_non_filter_searchfields)[0]->render;
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
