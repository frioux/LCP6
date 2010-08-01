module Log::Contextual;

#sub import {
   #my $package = shift;
   #die 'Log::Contextual does not have a default import list'
      #unless @_;

   #for my $idx ( 0 .. $#_ ) {
      #my $val = $_[$idx];
      #if ( defined $val && $val eq '-logger' ) {
         #set_logger($_[$idx + 1]);
         #splice @_, $idx, 2;
      #} elsif ( defined $val && $val eq '-package_logger' ) {
         #_set_package_logger_for(scalar caller, $_[$idx + 1]);
         #splice @_, $idx, 2;
      #} elsif ( defined $val && $val eq '-default_logger' ) {
         #_set_default_logger_for(scalar caller, $_[$idx + 1]);
         #splice @_, $idx, 2;
      #}
   #}
   #$package->export_to_level(1, $package, @_);
#}

sub caller { return 'foo' }

our $Get-Logger;
our %Default-Logger;
our %Package-Logger;

sub set-default-logger-for {
   my $logger = $_[1];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   %Default-Logger{$_[0]} = $logger
}

sub set_package_logger_for {
   my $logger = $_[1];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   %Package-Logger{$_[0]} = $logger
}

sub get-logger ($package) {
   (
      %Package-Logger{$package} ||
      $Get-Logger ||
      %Default-Logger{$package} ||
      die q<no logger set!  you can't try to log something without a logger!>
   )();
}

sub set-logger($logger) is export {
   unless $logger.isa(Code) {
      # I can't seem to get this typecheck to work :-/
      #die 'logger was not a CodeRef or a logger object.  Please try again.'
         #unless $logger.does(Log::Contextual::Logger);
      $logger = do { my $l = $logger; sub { $l } }
   }

   warn 'set-logger (or -logger) called more than once!  This is a bad idea!'
      if $Get-Logger;
   $Get-Logger = $logger;
}

sub with-logger($logger is copy, Code $fn) is export {
   unless $logger.isa(Code) {
      # I can't seem to get this typecheck to work :-/
      #die 'logger was not a CodeRef or a logger object.  Please try again.'
         #unless $logger.does(Log::Contextual::Logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   # fake temp (local) scoping
   my $old = $Get-Logger;
   $Get-Logger = $logger;
   $fn();
   $Get-Logger = $old;
}

sub do-log ($level, $logger, $code, *@values) {
   $logger."$level"($code(|@values)) if $logger."is-$level"();
   @values
}

sub do-logS {
   my $level  = shift;
   my $logger = shift;
   my $code   = shift;
   my $value  = shift;

   my $is-level = "is-$level";

   $logger.$level($code($value)) if $logger.$is-level();
   $value
}

sub log-trace (Code $fn, *@_) is export { do-log( 'trace', get-logger( caller ), $fn, @_) }
sub log-debug (Code $fn, *@_) is export { do-log( 'debug', get-logger( caller ), $fn, @_) }
sub log-info (Code $fn, *@_) is export { do-log( 'info', get-logger( caller ), $fn, @_) }
sub log-warn (Code $fn, *@_) is export { do-log( 'warn', get-logger( caller ), $fn, @_) }
sub log-error (Code $fn, *@_) is export { do-log( 'error', get-logger( caller ), $fn, @_) }
sub log-fatal (Code $fn, *@_) is export { do-log( 'fatal', get-logger( caller ), $fn, @_) }

#sub logS_trace is export (&$) { _do_logS( trace => _get_logger( caller ), $_[0], $_[1]) }
#sub logS_debug is export (&$) { _do_logS( debug => _get_logger( caller ), $_[0], $_[1]) }
#sub logS_info  is export (&$) { _do_logS( info  => _get_logger( caller ), $_[0], $_[1]) }
#sub logS_warn  is export (&$) { _do_logS( warn  => _get_logger( caller ), $_[0], $_[1]) }
#sub logS_error is export (&$) { _do_logS( error => _get_logger( caller ), $_[0], $_[1]) }
#sub logS_fatal is export (&$) { _do_logS( fatal => _get_logger( caller ), $_[0], $_[1]) }


#sub Dlog_trace is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( trace => _get_logger( caller ), $code, @_ );
#}

#sub Dlog_debug is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( debug => _get_logger( caller ), $code, @_ );
#}

#sub Dlog_info is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( info => _get_logger( caller ), $code, @_ );
#}

#sub Dlog_warn is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( warn => _get_logger( caller ), $code, @_ );
#}

#sub Dlog_error is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( error => _get_logger( caller ), $code, @_ );
#}

#sub Dlog_fatal is export (&@) {
  #my $code = shift;
  #local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  #return _do_log( fatal => _get_logger( caller ), $code, @_ );
#}


#sub DlogS_trace is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( trace => _get_logger( caller ), $_[0], $_[1] )
#}

#sub DlogS_debug is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( debug => _get_logger( caller ), $_[0], $_[1] )
#}

#sub DlogS_info is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( info => _get_logger( caller ), $_[0], $_[1] )
#}

#sub DlogS_warn is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( warn => _get_logger( caller ), $_[0], $_[1] )
#}

#sub DlogS_error is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( error => _get_logger( caller ), $_[0], $_[1] )
#}

#sub DlogS_fatal is export (&$) {
  #local $_ = Data::Dumper::Concise::Dumper $_[1];
  #_do_logS( fatal => _get_logger( caller ), $_[0], $_[1] )
#}

1;
