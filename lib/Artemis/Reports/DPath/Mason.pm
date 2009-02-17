use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath::Mason {
        #use HTML::Mason;

#         use Sub::Exporter -setup => { exports =>           [ 'render' ],
#                                       groups  => { all  => [ 'render' ] },
#                                     };

        method render (:$file?, :$template?) {
                return $self->render_file     ($file)     if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                say "template: $template";
        }
        method render_file ($file) {
                say "file: $file";
                
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

