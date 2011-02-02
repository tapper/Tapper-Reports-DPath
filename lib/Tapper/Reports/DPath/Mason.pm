use MooseX::Declare;

use 5.010;

## no critic (RequireUseStrict)
class Tapper::Reports::DPath::Mason {
        use HTML::Mason;
        use Cwd 'cwd';
        use Data::Dumper;
        use File::ShareDir 'module_dir';

        has debug => ( is => 'rw');

        method render (:$file?, :$template?) {
                return $self->render_file     ($file) if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                my $outbuf;
                my $comp_root = module_dir('Tapper::Reports::DPath::Mason');
                my $interp = new HTML::Mason::Interp
                    (
                     use_object_files => 1,
                     comp_root        => $comp_root,
                     out_method       => \$outbuf,
                     preloads         => [ '/mason_include.pl' ],
                    );
                my $anon_comp = eval {
                        $interp->make_component
                            (
                             comp_source => $template,
                             name        => '/virtual/tapper_reports_dpath_mason',
                            );
                };
                if ($@) {
                        my $msg = "Tapper::Reports::DPath::Mason::render_template::make_component: ".$@;
                        print STDERR $msg;
                        return $msg if $self->debug;
                        return '';
                }
                eval {
                        $interp->exec($anon_comp);
                };
                if ($@) {
                        my $msg = "Tapper::Reports::DPath::Mason::render_template::exec(anon_comp): ".$@;
                        print STDERR $msg;
                        return $msg if $self->debug;
                        return '';
                }
                return $outbuf;
        }

        method render_file ($file) {

                # must be absolute to mason, although meant relative in real world
                $file = "/$file" unless $file =~ m(^/);

                my $outbuf;
                my $interp;
                eval {
                        $interp = new HTML::Mason::Interp(
                                                          use_object_files => 1,
                                                          comp_root => cwd(),
                                                          out_method       => \$outbuf,
                                                         );
                };
                if ($@) {
                        my $msg = "Tapper::Reports::DPath::Mason::render_file::new_Interp: ".$@;
                        print STDERR $msg;
                        return $msg if $self->debug;
                        return '';
                }
                eval { $interp->exec($file) };
                if ($@) {
                        my $msg = "Tapper::Reports::DPath::Mason::render_file::exec(file): ".$@;
                        print STDERR $msg;
                        return $msg if $self->debug;
                        return '';
                }
                return $outbuf;
        }
}

1;

__END__

=head1 NAME

Tapper::Reports::DPath::Mason - Mix DPath into Mason templates

=head1 SYNOPSIS

    use Tapper::Reports::DPath::Mason 'render';
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

