class Log::Contextual::SimpleLogger;

has Code $.coderef is rw; # = sub (*@_) { $*ERR.print(@_) };

has %!levels;

my $?CLASS = Log::Contextual::SimpleLogger;
for <trace debug info warn error fatal> -> $name {
  my $is-name = "is-$name";

  $?CLASS.^add_method($name, method (*@_) { self!log( $name, @_ ) if self."$is-name"() });
  $?CLASS.^add_method($is-name, method { %!levels{$name} });
}


submethod BUILD(:$coderef, :@levels, :$levels-upto) {
  $.coderef = $coderef;

  %!levels{$_} = 1 for @levels;

  if $levels-upto {
    my @levels-list = <trace debug info warn error fatal>;
    my $i = 0;
    for @levels-list {
      last if $levels-upto eq $_;
      $i++
    }

    %!levels{@levels-list[$_]} = 1 for $i..^+@levels-list
  }
}

method !log($level, *@_) {
  my $message = @_.join("\n");
  $message ~= "\n" unless $message ~~ /\n$/;

  $.coderef.("[$level] $message");
}

1;
