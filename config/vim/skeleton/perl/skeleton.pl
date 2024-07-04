use strict;
use warnings;
use diagnostics;

my $var1;
our $var2;

sub function1 {
	my ($arg1, $arg2) = @_;
	printf("arg1 = %0d\n", $arg1);
	printf("arg2 = %0d\n", $arg2);
}

$var1 = 1;
$var2 = 2;

function1($var1, $var2);

=begin comment

Dispatch perl %

=end comment

