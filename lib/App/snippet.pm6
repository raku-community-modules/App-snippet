
use Readline;
use File::Which;

enum TargetType (
	:EXECUTABLE(1),
	:TEXT(2),
);

enum Language(
	:C("c"),
	:CXX("cpp"),
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

class Result {
	has $.output;
	has $.stdout;
	has $.stderr;
}

class Support {
	has $.lang;
	has $.bin;
}

role Compiler {
    has $.compiler;
    has @.args;
    has $.lang is rw;

	method name() { ... }

	method supports() { ... }

	method autoDetecte() {
		without $!compiler {
			$!compiler = which(self.supports().grep({ .lang eq $!lang }));
		}
		return defined($!compiler);
	}

	method setCompiler($compiler) {
		$!compiler = $compiler;
	}

    method compileCode(@codes, $output, :$out, :$err) {
        my @realargs = @!args;

        @realargs.append("-o", $output, "-x{$!lang}", "-");
        try {
            my $proc = run $!compiler, @realargs, :in, :$out, :$err;

            $proc.in.say($_) for @codes;
            $proc.in.close();
            return &fetchMessage($proc, $output, :$out, :$err);
            CATCH {
                default {
                    note "Catch exception when run \{ $!compiler {@realargs}\}";
                    ...
                }
            }
        }
    }

    method compileFile($file, $output, :$out, :$err) {
        my @realargs = @!args;

        @realargs.append("-o", $output, $file);
        try {
            my $proc = run $!compiler, @realargs, :$out, :$err;

            return &fetchMessage($proc, $output, :$out, :$err);
            CATCH {
                default {
                    note "Catch exception when run \{ $!compiler {@realargs}\}";
                    ...
                }
            }
        }
    }

    method setOptimizeLevel(int $level) {
        self.addArg("-O{$level}");
    }

    method setStandard(Str $std) {
        self.addArg("-std={$std}");
    }

	multi method addMacro($macro) {
        self.addArg("-D{$macro}");
    }

    multi method addMacro($macro, $value) {
        self.addArg("-D{$macro}={$value}");
    }

	method addIncludePath($path) {
        self.addArg("-I{$path}");
    }

	method addLibraryPath($path) {
        self.addArg("-L{$path}");
    }

	method linkLibrary($libname) {
        self.addArg("-l{$libname}");
    }

    multi method addArg(Str $option) {
        @!args.push($option);
    }

    multi method addArg(Str $option, Str $arg) {
        @!args.push($option);
        @!args.push($arg);
    }
}

role Interface {
	has $.optset;
	has @.compiler;

	method language() { ... }

	method optionset() is rw { ... }

	method setCompiler(@compiler) {
		@!compiler = @compiler;
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

sub fetchMessage($proc, $output, :$out, :$err) {
	if $*PERL.version ~~ v6.c {
		my $stdout = $out ?? $proc.out.slurp-rest() !! "";
		my $stderr = $err ?? $proc.err.slurp-rest() !! "";

		$proc.out.close() if $out;
		$proc.err.close() if $err;
		return Result.new(
			output => $output,
			stdout => $stdout,
			stderr => $stderr,
		);
	} else {
		return Result.new(
			output => $output,
			stdout => $out ?? $proc.out.slurp(:close) !! "",
			stderr => $err ?? $proc.err.slurp(:close) !! "",
		);
	}
}
