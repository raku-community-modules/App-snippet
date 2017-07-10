
use App::snippet;
use Getopt::Advance;

unit class App::snippet::Cpp is export;

class App::snippet::Cpp::Target is Target::Common is export { }

class App::snippet::Cpp::Compiler does Compiler is export {
	has $!optset;
	has @!incode;
	has @!infile;

	submethod TWEAK() {
		$!optset = OptionSet.new;
		$!optset.append(
			'h|help=b'    => 'print this help.',
			' |version=b' => 'print program version.',
		);
	}

	multi method compile(Str $code) of Target {
		App::snippet::Cpp::Target.new;
	}

	multi method compile(Str @codes) of Target {
		App::snippet::Cpp::Target.new;
	}

	multi method compile(IO::Path $dir) of Target {
		App::snippet::Cpp::Target.new;
	}

	multi method compile(IO::Path @files) of Target {
		App::snippet::Cpp::Target.new;
	}

	method optionset() is rw {
		$!optset;
	}

	method style() {
		"gnu";
	}
}
