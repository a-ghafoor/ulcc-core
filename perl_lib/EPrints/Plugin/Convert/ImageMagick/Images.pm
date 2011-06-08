package EPrints::Plugin::Convert::ImageMagick::Images;

=pod

=head1 NAME

EPrints::Plugin::Convert::ImageMagick::Images - Example conversion plugin

=cut

use strict;
use warnings;

use Carp;

use EPrints::Plugin::Convert;
our @ISA = qw/ EPrints::Plugin::Convert /;

our (%FORMATS, @ORDERED, %FORMATS_PREF);
@ORDERED = %FORMATS = qw(
bmp image/bmp
gif image/gif
ief image/ief
jpeg image/jpeg
jpe image/jpeg
jpg image/jpeg
png image/png
tiff image/tiff
tif image/tiff
pnm image/x-portable-anymap
pbm image/x-portable-bitmap
pgm image/x-portable-graymap
ppm image/x-portable-pixmap
pdf application/pdf
);
# formats pref maps mime type to file suffix. Last suffix
# in the list is used.
for(my $i = 0; $i < @ORDERED; $i+=2)
{
	$FORMATS_PREF{$ORDERED[$i+1]} = $ORDERED[$i];
}
our $EXTENSIONS_RE = join '|', keys %FORMATS;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "ImageMagick";
	$self->{visible} = "all";

	return $self;
}

sub can_convert
{
	my ($plugin, $doc) = @_;

	return () unless $plugin->get_repository->can_execute( "convert" );

	my %types;

	# Get the main file name
	my $fn = $doc->get_main() or return ();

	if( $fn =~ /\.($EXTENSIONS_RE)$/oi ) 
	{
		for(values %FORMATS) 
		{
			$types{$_} = {
				plugin => $plugin,
				phraseid => "document_typename_" . $_,
				preference => 1,
			};
		}
	}

	return %types;
}

sub export
{
	my ( $plugin, $dir, $doc, $type ) = @_;

	return () unless $plugin->get_repository->can_execute( "convert" );

	my $convert = $plugin->get_repository->get_conf( 'executables', 'convert' );

	# What to call the temporary file
	my $ext = $FORMATS_PREF{$type};
	my $fn = $doc->get_main() or return ();
	$fn =~ s/\.\w+$/\.$ext/;
	
	my $src = $doc->get_stored_file( $doc->get_main() );

	# Call imagemagick to do the conversion
	my $cmd = sprintf("%s - %s", EPrints->system->quotemeta($convert), EPrints->system->quotemeta("$dir/$fn"));
	open( my $out, "|$cmd" ) or return;
	binmode($out);

	$src->write_copy_fh( $out );

	close($out);

	unless( -e "$dir/$fn" ) {
		return ();
	}

	EPrints::Utils::chown_for_eprints( "$dir/$fn" );
	
	return ($fn);
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
