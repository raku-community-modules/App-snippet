
use App::snippet;
use Getopt::Advance;

unit module App::snippet::C;

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
			'v|version=b' => 'print program version.',
		);
		$!optset.append(
			:radio,
			'S=b' => 'pass -S to compiler.',
			'E=b' => 'pass -E to compiler.',
		);
		$!optset.append(
			:multi,
			'l|=a' => 'pass -l<l> to compiler, i.e. link library.',
			'L|=a' => 'add library search path.',
			'i|=a' => 'append include file.',
			'I|=a' => 'add include search path.',
		);
		$!optset.push(
			'f|flag=a',
			'pass -<flags> to compiler.',
			value => <Wall Wextra>
		);
		$!optset.push(
			'c=s',
			'set c standard version.',
			:11value
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
