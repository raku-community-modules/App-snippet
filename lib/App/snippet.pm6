
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
	proto method compile(|) { * }
	
	multi method compile(Str $code)       of Target { ... }
	multi method compile(Str @codes)      of Target { ... }
	multi method compile(IO::Path $dir)   of Target { ... }
	multi method compile(IO::Path @files) of Target { ... }

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

	say $prompt;
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


