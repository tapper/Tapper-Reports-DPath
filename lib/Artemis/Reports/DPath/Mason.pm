use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath::Mason {
        use HTML::Mason;
        use Cwd 'cwd';
        use Data::Dumper;
        use File::ShareDir 'module_file';

        method render (:$file?, :$template?) {
                return $self->render_file     ($file)     if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                #say "template: $template";
                my $outbuf;
                my $incfile = module_file('Artemis::Reports::DPath::Mason', 'mason_include.pl');
                my $interp = new HTML::Mason::Interp
                    (
                     use_object_files => 1,
                     #comp_root        => cwd(),
                     comp_root        => '/',
                     out_method       => \$outbuf,
                     preloads         => [ $incfile ],
                    );
                my $anon_comp = eval {
                        $interp->make_component
                            (
                             comp_source => $template,
                             name        => '/virtual/artemis_reports_dpath_mason',
                            );
                };
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
                eval { $interp->exec($file) };
                if ($@) {
                        print STDERR "Artemis::Reports::DPath::Mason::render_file: ".$@;
                        return '';
                }
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

