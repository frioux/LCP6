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

sub set-logger($logger is copy) is export {
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

for <debug info warn error fatal> {
   eval 'sub log-' ~ $_ ~ ' (Code $fn, *@_) is export { do-log( q<' ~ $_ ~ '>, get-logger( caller ), $fn, @_) }';
}


sub Dlog-trace (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<trace>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

sub Dlog-debug (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<debug>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

sub Dlog-info (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<info>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

sub Dlog-warn (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<warn>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

sub Dlog-error (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<error>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

sub Dlog-fatal (Code $code, *@_) is export {
  my $old_ = $_;
  $_ = @_??@_.perl!!q<()>;
  my @ret = do-log( q<fatal>, get-logger( caller ), $code, @_ );
  $_ = $old_;
  return @ret;
}

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
