use Log::Contextual;
use Log::Contextual::SimpleLogger;
use Test;
my $l = Log::Contextual::SimpleLogger.new(levels => [<debug>]);

set-logger $l;
ok(!$l.is-trace, 'is-trace is false on SimpleLogger');
ok($l.is-debug, 'is-debug is true on SimpleLogger');
ok(!$l.is-info, 'is-info is false on SimpleLogger');
ok(!$l.is-warn, 'is-warn is false on SimpleLogger');
ok(!$l.is-error, 'is-error is false on SimpleLogger');
ok(!$l.is-fatal, 'is-fatal is false on SimpleLogger');

my %ran;
log-trace { %ran<trace>++ };
ok(!defined %ran<trace>, 'trace does not get called');

log-debug { %ran<debug>++ };
ok(defined  %ran<debug>, 'debug gets called');

log-info { %ran<info>++ };
ok(!defined %ran<info>, 'info does not get called');

log-warn { %ran<warn>++ };
ok(!defined %ran<warn>, 'warn does not get called');

log-error { %ran<error>++ };
ok(!defined %ran<error>, 'error does not get called');

log-fatal { %ran<fatal>++ };
ok(!defined %ran<fatal>, 'fatal does not get called');

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
   set-logger($l2);
#}
log-trace { 'trace' };
is($response, "[trace] trace\n", 'trace renders correctly');
log-debug { 'debug' };
is($response, "[debug] debug\n", 'debug renders correctly');
log-info  { 'info'  };
is($response, "[info] info\n", 'info renders correctly');
log-warn  { 'warn'  };
is($response, "[warn] warn\n", 'warn renders correctly');
log-error { 'error' };
is($response, "[error] error\n", 'error renders correctly');
log-fatal { 'fatal' };
is($response, "[fatal] fatal\n", 'fatal renders correctly');

log-debug { 'line 1', 'line 2' };
is($response, "[debug] line 1\nline 2\n", 'multiline log renders correctly');

my $u = Log::Contextual::SimpleLogger.new(levels-upto => 'debug');

ok(!$u.is-trace, 'is-trace is false on SimpleLogger');
ok($u.is-debug, 'is-debug is true on SimpleLogger');
ok($u.is-info, 'is-info is true on SimpleLogger');
ok($u.is-warn, 'is-warn is true on SimpleLogger');
ok($u.is-error, 'is-error is true on SimpleLogger');
ok($u.is-fatal, 'is-fatal is true on SimpleLogger');

