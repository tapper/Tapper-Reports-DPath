## no critic (RequireUseStrict)
package Tapper::Reports::DPath::TT;
# ABSTRACT: Mix DPath into Template-Toolkit templates

        use 5.010;
        use Moose;
        use Template;
        use Cwd 'cwd';
        use Data::Dumper;

        use Template::Stash;

        # modules needed inside the TT template for vmethods
        use Tapper::Reports::DPath 'reportdata';
        use Tapper::Model 'model';
        use Data::Dumper;
        use Data::DPath 'dpath';
        use DateTime;
        use JSON;
        use YAML::XS;
        use Data::Structure::Util 'unbless';

        has debug           => ( is => 'rw');
        has puresqlabstract => ( is => 'rw', default => 0);
        has include_path    => ( is => 'rw', default => "");
        has substitutes     => ( is => 'rw', default => undef);
        has eval_perl       => ( is => 'rw', default => 0);

        sub get_template
        {
                my ($self) = @_;

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

        sub render {
                my ($self, %args) = @_;

                my $file     = $args{file};
                my $template = $args{template};

                return $self->render_file     ($file)     if $file;
                return $self->render_template ($template) if $template;
        }

        sub render_template {
                my ($self, $template) = @_;

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

        sub render_file {
                my ($self, $file) = @_;

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


1;

__END__

=head1 SYNOPSIS

    use Tapper::Reports::DPath::Mason 'render';
    $result = render file => $filename;
    $result = render template => $string;

=head1 METHODS

=head2 get_template

Render template processor with complete Tapper prelude set.

=head2 render

Render file or template.

=head2 render_file

Render file.

=head2 render_template

Render template.

=head2 testrundb_hostnames

Provide list of hosts from Tapper TestrunDB to be accessible in
templates.

=cut
