use strict;
use warnings;

use lib 't/lib';
use VarLogger;
use Log::Contextual qw{:log with_logger set_logger};
use Test::More qw(no_plan);
my $var_logger1 = VarLogger->new;
my $var_logger2 = VarLogger->new;
my $var_logger3 = VarLogger->new;

WITHLOGGER: {
   with_logger sub { $var_logger2 } => sub {

      with_logger $var_logger1 => sub {
         log_debug { 'nothing!' }
      };
      log_debug { 'frew!' };

   };

   is( $var_logger1->var, 'dnothing!', 'inner scoped logger works' );
   is( $var_logger2->var, 'dfrew!', 'outer scoped logger works' );
}

SETLOGGER: {
   set_logger(sub { $var_logger3 });
   log_debug { 'set_logger' };
   is( $var_logger3->var, 'dset_logger', 'set logger works' );
}

SETWITHLOGGER: {
   with_logger $var_logger1 => sub {
      log_debug { 'nothing again!' }
   };

   is( $var_logger1->var, 'dnothing again!',
      'inner scoped logger works after using set_logger'
   );

   log_debug { 'frioux!' };
   is( $var_logger3->var, 'dfrioux!',
      q{set_logger's logger comes back after scoped logger}
   );
}

ok(!eval { Log::Contextual->import; 1 }, 'Blank Log::Contextual import dies');
