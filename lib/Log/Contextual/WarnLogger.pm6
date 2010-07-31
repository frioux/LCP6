class Log::Contextual::WarnLogger;

has Str $.env-prefix =
     die 'no env-prefix passed to Log::Contextual::WarnLogger.new';

{
  my @levels = <trace debug info warn error fatal>;
  my %level-num; %level-num{ @levels } = ^@levels;
  my $?CLASS = Log::Contextual::WarnLogger; # shim

  for @levels -> $name {
    my $is-name = "is-$name";

    $?CLASS.^add_method($name, method (*@_) { self!log(@_) if self.$is-name() });

    $?CLASS.^add_method($is-name, method {
      return 1 if %*ENV{$.env-prefix ~ '_' ~ uc $name};
      my $upto = %*ENV{$.env-prefix ~ '_UPTO'};
      return unless $upto;
      $upto = lc $upto;

      return %level-num{$name} >= %level-num{$upto};
    });
  }
}

method !log($level, *@_) {
  my $message = @_.join("\n");
  $message ~= "\n" unless $message ~~ /\n$/;
  warn "[$level] $message";
}

1;

