use Log::Contextual::WarnLogger;
use Test;
my $l = Log::Contextual::WarnLogger.new(env-prefix => 'BAR');

{
   #%*ENV<BAR_TRACE> = 0;
   #%*ENV<BAR_DEBUG> = 1;
   #%*ENV<BAR_INFO>  = 0;
   #%*ENV<BAR_WARN>  = 0;
   #%*ENV<BAR_ERROR> = 0;
   #%*ENV<BAR_FATAL> = 0;

   ok(!$l.is-trace, 'is-trace is false on WarnLogger');
   ok($l.is-debug, 'is-debug is true on WarnLogger');
   ok(!$l.is-info, 'is-info is false on WarnLogger');
   ok(!$l.is-warn, 'is-warn is false on WarnLogger');
   ok(!$l.is-error, 'is-error is false on WarnLogger');
   ok(!$l.is-fatal, 'is-fatal is false on WarnLogger');
}

{
   #local $ENV{BAR_UPTO} = 'TRACE';

   ok($l.is-trace, 'is-trace is true on WarnLogger');
   ok($l.is-debug, 'is-debug is true on WarnLogger');
   ok($l.is-info, 'is-info is true on WarnLogger');
   ok($l.is-warn, 'is-warn is true on WarnLogger');
   ok($l.is-error, 'is-error is true on WarnLogger');
   ok($l.is-fatal, 'is-fatal is true on WarnLogger');
}

{
   #local $ENV{BAR_UPTO} = 'warn';

   ok(!$l.is-trace, 'is-trace is false on WarnLogger');
   ok(!$l.is-debug, 'is-debug is false on WarnLogger');
   ok(!$l.is-info, 'is-info is false on WarnLogger');
   ok($l.is-warn, 'is-warn is true on WarnLogger');
   ok($l.is-error, 'is-error is true on WarnLogger');
   ok($l.is-fatal, 'is-fatal is true on WarnLogger');
}

#{
   #local $ENV{FOO_TRACE} = 0;
   #local $ENV{FOO_DEBUG} = 1;
   #local $ENV{FOO_INFO} = 0;
   #local $ENV{FOO_WARN} = 0;
   #local $ENV{FOO_ERROR} = 0;
   #local $ENV{FOO_FATAL} = 0;
   #ok(eval { log_trace { die 'this should live' }; 1}, 'trace does not get called');
   #ok(!eval { log_debug { die 'this should die' }; 1}, 'debug gets called');
   #ok(eval { log_info { die 'this should live' }; 1}, 'info does not get called');
   #ok(eval { log_warn { die 'this should live' }; 1}, 'warn does not get called');
   #ok(eval { log_error { die 'this should live' }; 1}, 'error does not get called');
   #ok(eval { log_fatal { die 'this should live' }; 1}, 'fatal does not get called');
#}

#{
   #local $ENV{FOO_TRACE} = 1;
   #local $ENV{FOO_DEBUG} = 1;
   #local $ENV{FOO_INFO} = 1;
   #local $ENV{FOO_WARN} = 1;
   #local $ENV{FOO_ERROR} = 1;
   #local $ENV{FOO_FATAL} = 1;
   #my $cap;
   #local $SIG{__WARN__} = sub { $cap = shift };

   #log_debug { 'frew' };
   #is($cap, "[debug] frew\n", 'WarnLogger outputs to STDERR correctly');
   #log_trace { 'trace' };
   #is($cap, "[trace] trace\n", 'trace renders correctly');
   #log_debug { 'debug' };
   #is($cap, "[debug] debug\n", 'debug renders correctly');
   #log_info  { 'info'  };
   #is($cap, "[info] info\n", 'info renders correctly');
   #log_warn  { 'warn'  };
   #is($cap, "[warn] warn\n", 'warn renders correctly');
   #log_error { 'error' };
   #is($cap, "[error] error\n", 'error renders correctly');
   #log_fatal { 'fatal' };
   #is($cap, "[fatal] fatal\n", 'fatal renders correctly');

#}
