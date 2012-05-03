use MooseX::Declare;

use 5.010;

## no critic (RequireUseStrict)
class Tapper::Reports::DPath::TT {
        use Template;
        use Cwd 'cwd';
        use Data::Dumper;

        use Template::Stash;
        # BEGIN needed inside the TT template for vmethods
        use Tapper::Reports::DPath 'reportdata';
        use Tapper::Model 'model';
        use Data::Dumper;
        use Data::DPath 'dpath';
        use DateTime;
        use JSON;
        use YAML::XS;
        use Data::Structure::Util 'unbless';
        # END needed inside the TT template for vmethods

        has debug           => ( is => 'rw');
        has puresqlabstract => ( is => 'rw', default => 0);
        has include_path    => ( is => 'rw', default => "");
        has substitutes     => ( is => 'rw', default => undef);
        has eval_perl       => ( is => 'rw', default => 0);

        method get_template()
        {
                my $tt = Template->new({EVAL_PERL => $self->eval_perl,
                                       $self->include_path ? (INCLUDE_PATH => $self->include_path) : (),
                                      });
                $Template::Stash::SCALAR_OPS->{reportdata} = sub { reportdata($_[0]) };
                $Template::Stash::SCALAR_OPS->{dpath_match}= sub { my ($path, $data) = @_; dpath($path)->match($data); };
                $Template::Stash::LIST_OPS->{to_json}      = sub { JSON->new->pretty->encode(unbless $_[0]) };
                $Template::Stash::LIST_OPS->{to_yaml}      = sub { YAML::XS::Dump(unbless $_[0])    };
                $Template::Stash::LIST_OPS->{Dumper}       = sub { Dumper @_ };
                return $tt;
        }

        sub testrundb_hostnames {
                my $host_iter = model('TestrunDB')->resultset("Host")->search({ });
                my %hosts = ();
                while (my $h = $host_iter->next) {
                        $hosts{$h->name} = { id         => $h->id,
                                             name       => $h->name,
                                             free       => $h->free,
                                             active     => $h->active,
                                             comment    => $h->comment,
                                             is_deleted => $h->is_deleted,
                                         };
                }
                return \%hosts;
        }

        method render (:$file?, :$template?) {
                return $self->render_file     ($file) if $file;
                return $self->render_template ($template) if $template;
        }
        method render_template ($template) {
                my $outbuf;
                my $tt = $self->get_template();

                local $Tapper::Reports::DPath::puresqlabstract = $self->puresqlabstract;
                if(not $tt->process(\$template, {reportdata => \&reportdata,
                                                 testrundb_hostnames => \&testrundb_hostnames,
                                                 defined $self->substitutes ? ( %{$self->substitutes} ) : (),
                                                }, \$outbuf)) {
                        my $msg = "Error in Tapper::Reports::DPath::TT::render_template: ".$tt->error."\n";
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
                        my $msg = "Tapper::Reports::DPath::TT::render_template: $Template::ERROR\n";
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

AMD OSRC Tapper Team, C<< <tapper at amd64.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008-2011 AMD OSRC Tapper Team, all rights reserved.

This program is released under the following license: proprietary


=cut

