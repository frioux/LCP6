use 5.006;
use inc::Module::Install 0.91;
use strict;
use warnings FATAL => 'all';

all_from 'lib/Log/Contextual.pm';
requires 'Data::Dumper::Concise';

WriteAll;
