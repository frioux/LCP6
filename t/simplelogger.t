use Log::Contextual::SimpleLogger;
use Test;
my $l = Log::Contextual::SimpleLogger.new(levels => [<debug>]);

ok(!$l.is-trace, 'is-trace is false on SimpleLogger');
ok($l.is-debug, 'is-debug is true on SimpleLogger');
ok(!$l.is-info, 'is-info is false on SimpleLogger');
ok(!$l.is-warn, 'is-warn is false on SimpleLogger');
ok(!$l.is-error, 'is-error is false on SimpleLogger');
ok(!$l.is-fatal, 'is-fatal is false on SimpleLogger');

#ok(eval { log_trace { die 'this should live' }; 1}, 'trace does not get called');
#ok(!eval { log_debug { die 'this should die' }; 1}, 'debug gets called');
#ok(eval { log_info { die 'this should live' }; 1}, 'info does not get called');
#ok(eval { log_warn { die 'this should live' }; 1}, 'warn does not get called');
#ok(eval { log_error { die 'this should live' }; 1}, 'error does not get called');
#ok(eval { log_fatal { die 'this should live' }; 1}, 'fatal does not get called');

#{
   #my $cap;
   #local *STDERR = do { open my $fh, '>', \$cap; $fh };

   #log_debug { 'frew' };
   #is($cap, "[debug] frew\n", 'SimpleLogger outputs to STDERR correctly');
#}

my $response;
my $l2 = Log::Contextual::SimpleLogger.new(
   levels => [<trace debug info warn error fatal>],
   coderef => sub { $response = $^a },
);
$l2.debug('station');
is($response, "[debug] station\n", 'logger runs');
#{
   #local $SIG{__WARN__} = sub {}; # do this just to hide warning for tests
   #set_logger($l2);
#}
#log_trace { 'trace' };
#is($response, "[trace] trace\n", 'trace renders correctly');
#log_debug { 'debug' };
#is($response, "[debug] debug\n", 'debug renders correctly');
#log_info  { 'info'  };
#is($response, "[info] info\n", 'info renders correctly');
#log_warn  { 'warn'  };
#is($response, "[warn] warn\n", 'warn renders correctly');
#log_error { 'error' };
#is($response, "[error] error\n", 'error renders correctly');
#log_fatal { 'fatal' };
#is($response, "[fatal] fatal\n", 'fatal renders correctly');

#log_debug { 'line 1', 'line 2' };
#is($response, "[debug] line 1\nline 2\n", 'multiline log renders correctly');

my $u = Log::Contextual::SimpleLogger.new(levels-upto => 'debug');

ok(!$u.is-trace, 'is-trace is false on SimpleLogger');
ok($u.is-debug, 'is-debug is true on SimpleLogger');
ok($u.is-info, 'is-info is true on SimpleLogger');
ok($u.is-warn, 'is-warn is true on SimpleLogger');
ok($u.is-error, 'is-error is true on SimpleLogger');
ok($u.is-fatal, 'is-fatal is true on SimpleLogger');

