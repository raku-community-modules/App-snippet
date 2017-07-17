
use Readline;

enum TargetType (
	:EXECUTABLE(1),
	:TEXT(2),
);


#####################################################
## role Target and Compiler
#####################################################
role Target {
	has TargetType $.type;

	method process() {
		given $!type {
			when TargetType::EXECUTABLE {
				self.run();
			}
			when TargetType::TEXT {
				self.say();
			}
			default {
				die "Not recongnize target type!";
			}
		}
	}

	method run() { ... }
	method say() { ... }
	method clean() { ... }
}

role Compiler {
	method compile() of Target { ... }

	method optionset() is rw { ... }

	method style() of Str { ... }
}

class Target::Common is export does Target {
	has $.target;
	has @.args;

	method run() {
		given $*KERNEL {
			when /win32/ {
				run('start', $!target, @!args);
			}

			default {
				run($!target, @!args);
			}
		}
	}

	method say() {
		print($!target.IO.slurp);
	}

	method clean() {
		unlink $!target;
	}
}

#####################################################
## helper sub
#####################################################
sub prompt-code(Str $prompt, Str $end, Str $readline-prompt = "") of Array is export {
	my @code = [];
	my $readline = Readline.new;

	print $prompt;
	$readline.using-history;
	loop {
		if $readline.readline($readline-prompt) -> $code {
			$readline.add-history($code);
			last if $code ~~ /^ $end $/;
			@code.push($code);
		}
	}
	@code;
}

multi sub do_compile($compile, @args) of IO::Path {
	try {
		run $compile, @args;
		CATCH {
			default {
				note "Compile failed: $compile {@args}";
				...
			}
		}
	}
}

multi sub do_compile($compile, @args, @incode) of IO::Path {
	try {
		my $proc = run $compile, @args, :in;

		$proc.in.say($_) for @incode;
		$proc.in.close();
		CATCH {
			default {
				note "Compile failed: $compile {@args}";
				...
			}
		}
	}
}
