use Log::Contextual;
use Log::Contextual::SimpleLogger;
use Test;
my $var1;
my $var2;
my $var3;
my $var-logger1 = Log::Contextual::SimpleLogger.new(
   levels  => [<trace debug info warn error fatal>],
   coderef => sub { $var1 = $^a },
);

my $var-logger2 = Log::Contextual::SimpleLogger.new(
   levels  => [<trace debug info warn error fatal>],
   coderef => sub { $var2 = $^a },
);

my $var-logger3 = Log::Contextual::SimpleLogger.new(
   levels  => [<trace debug info warn error fatal>],
   coderef => sub { $var3 = $^a },
);

#SETLOGGER:
{
   set-logger sub { $var-logger3 };
   log-debug { 'set_logger' };
   is( $var3, "[debug] set_logger\n", 'set logger works' );
}

#SETLOGGERTWICE: {
   #my $foo;
   #local $SIG{__WARN__} = sub { $foo = shift };
   #set_logger(sub { $var_logger3 });
   #like(
      #$foo, qr/set_logger \(or -logger\) called more than once!  This is a bad idea! at/,
      #'set_logger twice warns correctly'
   #);
#}

#WITHLOGGER:
{
   with-logger sub { $var-logger2 }, sub {

      with-logger $var-logger1, sub {
         log-debug { 'nothing!' }
      };
      log-debug { 'frew!' };

   };

   is( $var1, "[debug] nothing!\n", 'inner scoped logger works' );
   is( $var2, "[debug] frew!\n", 'outer scoped logger works' );
}

#SETWITHLOGGER:
{
   with-logger $var-logger1, sub {
      log-debug { 'nothing again!' };
      # do this just so the following set_logger won't warn
      #local $SIG{__WARN__} = sub {};
      set-logger(sub { $var-logger3 });
      log-debug { 'this is a set inside a with' };
   };

   is( $var1, "[debug] nothing again!\n",
      'inner scoped logger works after using set_logger'
   );

   is( $var3, "[debug] this is a set inside a with\n",
      'set inside with works'
   );

   log-debug { 'frioux!' };
   is( $var3, "[debug] frioux!\n",
      q{set_logger's logger comes back after scoped logger}
   );
}

#VANILLA:
{
   log-trace { 'fiSMBoC' };
   is( $var3, "[trace] fiSMBoC\n", 'trace works');

   log-debug { 'fiSMBoC' };
   is( $var3, "[debug] fiSMBoC\n", 'debug works');

   log-info { 'fiSMBoC' };
   is( $var3, "[info] fiSMBoC\n", 'info works');

   log-warn { 'fiSMBoC' };
   is( $var3, "[warn] fiSMBoC\n", 'warn works');

   log-error { 'fiSMBoC' };
   is( $var3, "[error] fiSMBoC\n", 'error works');

   log-fatal { 'fiSMBoC' };
   is( $var3, "[fatal] fiSMBoC\n", 'fatal works');

}

#ok(!eval { Log::Contextual->import; 1 }, 'Blank Log::Contextual import dies');

#PASSTHROUGH:
#{
   my @vars;

   @vars = log-trace { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[trace] fiSMBoC: bar\n", 'log-trace works with input');
   ok( @vars ~~ <foo bar baz>, 'log-trace passes data through correctly');

   @vars = log-debug { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[debug] fiSMBoC: bar\n", 'log-debug works with input');
   ok( @vars ~~ <foo bar baz>, 'log-debug passes data through correctly');

   @vars = log-info { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[info] fiSMBoC: bar\n", 'log_info works with input');
   ok( @vars ~~ <foo bar baz>, 'log_info passes data through correctly');

   @vars = log-warn { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[warn] fiSMBoC: bar\n", 'log-warn works with input');
   ok( @vars ~~ <foo bar baz>, 'log-warn passes data through correctly');

   @vars = log-error { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[error] fiSMBoC: bar\n", 'log-error works with input');
   ok( @vars ~~ <foo bar baz>, 'log-error passes data through correctly');

   @vars = log-fatal { "fiSMBoC: @_[1]" }, <foo bar baz>;
   is( $var3, "[fatal] fiSMBoC: bar\n", 'log-fatal works with input');
   ok( @vars ~~ <foo bar baz>, 'log-fatal passes data through correctly');



   #my $val;
   #$val = logS-trace { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[trace] fiSMBoC: foo\n", 'logS_trace works with input');
   #is( $val, 'foo', 'logS_trace passes data through correctly');

   #$val = logS-debug { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[debug] fiSMBoC: foo\n", 'logS_debug works with input');
   #is( $val, 'foo', 'logS_debug passes data through correctly');

   #$val = logS-info { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[info] fiSMBoC: foo\n", 'logS_info works with input');
   #is( $val, 'foo', 'logS_info passes data through correctly');

   #$val = logS-warn { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[warn] fiSMBoC: foo\n", 'logS_warn works with input');
   #is( $val, 'foo', 'logS_warn passes data through correctly');

   #$val = logS-error { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[error] fiSMBoC: foo\n", 'logS_error works with input');
   #is( $val, 'foo', 'logS_error passes data through correctly');

   #$val = logS-fatal { 'fiSMBoC: ' . $_[0] } 'foo';
   #is( $var3, "[fatal] fiSMBoC: foo\n", 'logS_fatal works with input');
   #is( $val, 'foo', 'logS_fatal passes data through correctly');

   #ok(!eval "logS_error { 'frew' } 'bar', 'baz'; 1", 'logS_$level dies from too many args');
#}
