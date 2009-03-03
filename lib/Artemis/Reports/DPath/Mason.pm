use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath::Mason {
        use HTML::Mason;
        use Cwd 'cwd';
        use Data::Dumper;

        method render (:$file?, :$template?) {
                return $self->render_file     ($file)     if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                say "template: $template";
                my $outbuf;
                my $interp = new HTML::Mason::Interp
                    (
                     use_object_files => 1,
                     comp_root => cwd(),
                     out_method => \$outbuf,
                    );
                #my $anon_comp = eval { $interp->make_component( comp_source => $template ) };
                my $anon_comp = eval { $interp->make_component(comp_source => $template, name => '/temporary/template/for/artemis_reports_dpath_mason') };
                if ($@) {
                        print STDERR "Artemis::Reports::DPath::Mason::render_template: ".$@;
                        return '';
                }
                $interp->exec($anon_comp);
                return $outbuf;
        }

        method render_file ($file) {
                # must be absolute to mason, although meant relative in real world
                $file = "/$file" unless $file =~ m(^/);

                my $outbuf;
                my $interp = new HTML::Mason::Interp(
                                                     use_object_files => 1,
                                                     comp_root => cwd(),
                                                     out_method       => \$outbuf,
                                                    );
                $interp->exec($file);
                return $outbuf;
        }
}

1;

__END__

=head1 NAME

Artemis::Reports::DPath::Mason - Mix DPath into Mason templates

=head1 SYNOPSIS

    use Artemis::Reports::DPath::Mason 'render';
    $result = render file => $filename;
    $result = render template => $string;

=head1 EXPORT

=head1 METHODS and FUNCTIONS

=head2 render

Renders a template.

=head1 AUTHOR

OSRC SysInt Team, C<< <osrc-sysint at elbe.amd.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 OSRC SysInt Team, all rights reserved.

This program is released under the following license: proprietary


=cut

