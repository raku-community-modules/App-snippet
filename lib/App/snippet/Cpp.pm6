
use App::snippet;
use Getopt::Advance;

unit module App::snippet::Cpp;

class App::snippet::Cpp::Target is Target::Common is export { }

#`(
class App::snippet::Cpp::Compiler does Compiler is export {
	has $!optset;
	has @!incode;
	has @!infile;

	submethod TWEAK() {
		$!optset = OptionSet.new;
        $!optset.insert-cmd("cpp");
		$!optset.append(
			'h|help=b'    => 'print this help.',
			' |version=b' => 'print program version.',
		);
	}

	method compile() of Target {
		App::snippet::Cpp::Target.new;
	}

	method optionset() is rw {
		$!optset;
	}

	method style() {
		"gnu";
	}
}
)
