
use App::snippet;
use Getopt::Advance;

unit module App::snippet::C;

#`(
class App::snippet::C::Target is Target::Common is export { }

class App::snippet::C::Compiler does Compiler is export {
	has $!optset;
	has @!incode;
	has @!infile;

	submethod TWEAK() {
		$!optset = &init_c_optionset();
	}

	method compile() of Target {
		self.generate-code();
		App::snippet::C::Target.new;
	}

	method optionset() is rw {
		$!optset;
	}

	method style() {
		"gnu";
	}

	method generate-code() {
		my $prompt = qq:to/EOF/;
Please input your code, make sure your code correct.
Enter $!optset<end> input.
EOF
		if $!optset<r> {
			@!incode = &prompt-code($prompt, $!optset<end>);
		} else {
			@!incode = $!optset<e>;
		}
	}
}

sub main($optset, @args) {
	@args.shift;

}

sub init_c_optionset() {
	my $optset = OptionSet.new;
		$optset.insert-main(&main);
		$optset.insert-cmd("c");
		$optset.append(
			'h|help=b'    => 'print this help.',
			'v|version=b' => 'print program version.',
		);
		$optset.append(
			:radio,
			'S=b' => 'pass -S to compiler.',
			'E=b' => 'pass -E to compiler.',
		);
		$optset.append(
			:multi,
			'l|=a' => 'pass -l<l> to compiler, i.e. link library.',
			'L|=a' => 'add library search path.',
			'i|=a' => 'append include file.',
			'I|=a' => 'add include search path.',
			'D|=a' => 'pass -D<D> to compiler, i.e. add macro define.',
		);
		$optset.append(
			:radio,
			'astyle=s' 		=> 'set astyle style',
			'clang-format=s'=> 'set clang-format style',
			'uncrustify=s'  => 'set uncrustify style',
		);
		$optset.push(
			'|main=s',
			'chang main header.',
			value => 'int main(void)',
		);
		$optset.push(
			'|end=s',
			'change user input code terminator.',
			value => '@@CODEEND',
		);
		$optset.push(
			'f|flag=a',
			'pass -<flags> to compiler.',
			value => <Wall Wextra>
		);
		$optset.push(
			'|std=s',
			'set c standard version.',
			:value<c11>
		);
		$optset.push(
			'c|compiler=s',
			'set compiler.',
			value => 'gcc'
		);
		$optset.push(
			'e=a',
			'add code to generator.'
		);
		$optset.push(
			'r=b',
			'ignore -e, allow user input code from stdin.',
		);
		$optset.push(
			'p|=b',
			'print code read from -e or -r.'
		);
		$optset.push(
			'|debug=b',
			'open debug mode.'
		);
		$optset;
}
)
