use MooseX::Declare;

use 5.010;

## no critic (RequireUseStrict)
class Artemis::Reports::DPath::TT {
        use Template;
        use Cwd 'cwd';
        use Data::Dumper;

        use Template::Stash;
        # BEGIN needed inside the TT template for vmethods
        use Artemis::Reports::DPath 'reportdata';
        use Data::Dumper;
        use Data::DPath 'dpath';
        use DateTime;
        use JSON;
        use YAML;
        use Data::Structure::Util 'unbless';
        # END needed inside the TT template for vmethods


        has debug => ( is => 'rw');

        method get_template()
        {
                my $tt = Template->new(EVAL_PERL => 0);
                $Template::Stash::SCALAR_OPS->{reportdata} = sub { reportdata($_[0]) };
                $Template::Stash::SCALAR_OPS->{match}      = sub { my ($path, $data) = @_; dpath($path)->match($data); };
                $Template::Stash::LIST_OPS->{to_json}      = sub { JSON->new->pretty->encode(unbless $_[0]) };
                $Template::Stash::LIST_OPS->{to_yaml}      = sub { YAML::Dump(unbless $_[0])    };
                $Template::Stash::LIST_OPS->{Dumper}       = sub { Dumper @_ };
                return $tt;
        }


        method render (:$file?, :$template?) {
                return $self->render_file     ($file) if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                my $outbuf;
                my $tt = $self->get_template();

                if(not $tt->process(\$template, {}, \$outbuf)) {
                        die Template->error();
                        my $msg = "Artemis::Reports::DPath::TT::render_template: $Template::ERROR\n";
                        print STDERR $msg;
                        return $msg if $self->debug;
                        return '';
                }
                return $outbuf;
        }

        method render_file ($file) {
                my $outbuf;
                my $tt = $self->get_template();

                if(not $tt->process($file, {}, \$outbuf)) {
                        die Template->error();
                        my $msg = "Artemis::Reports::DPath::TT::render_template: $Template::ERROR\n";
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

