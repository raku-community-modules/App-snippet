
use App::snippet;
use Getopt::Advance;

unit class App::snippet::C is export;

class App::snippet::C::Target is Target::Common is export { }

class App::snippet::C::Compiler does Compiler is export {
	has $!optset;
	has @!incode;
	has @!infile;

	submethod TWEAK() {
		$!optset = OptionSet.new;
		$!optset.insert-cmd("c");
		$!optset.append(
			'h|help=b'    => 'print this help.',
			' |version=b' => 'print program version.',
		);
	}

	multi method compile(Str $code) of Target {
		App::snippet::C::Target.new;
	}

	multi method compile(Str @codes) of Target {
		App::snippet::C::Target.new;
	}

	multi method compile(IO::Path $dir) of Target {
		App::snippet::C::Target.new;
	}

	multi method compile(IO::Path @files) of Target {
		App::snippet::C::Target.new;
	}

	method optionset() is rw {
		$!optset;
	}

	method style() {
		"gnu";
	}
}
