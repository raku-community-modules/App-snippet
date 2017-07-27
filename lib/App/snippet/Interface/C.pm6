
use App::snippet;
use Getopt::Advance;

class App::snippet::Interface::C does Interface is export {
    submethod TWEAK() {
        sub main($optset, @args) {
            if +@args == 1 {
                my @incode = [];

                @incode.append(&incodeFromOV($optset, '#include <', '>', 'i'));
                @incode.append(&incodeFromOV($optset, '#', '', 'pp'));
                if $optset<r> {
                    my $prompt = qq:to/EOF/;
Please input your code, make sure your code correct.
Enter $!optset<end> input.
EOF
                    @incode.append(&prompt-input-code($prompt, $optset<end>));
                } else {
                    @incode.push($optset<main>);
                    @incode.push('{');
                    @incode.push($_.Str) for $optset<e>;
                    @incode.push('return 0;');
                    @incode.push('}');
                }
            } else {

            }
        }
        $!optset = OptionSet.new;
        $!optset.insert-main(&main);
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
    		'D|=a' => 'pass -D<D> to compiler, i.e. add macro define.',
            'pp=a' => 'add preprocess command to the code.',
    	);
    	$!optset.append(
    		:radio,
    		'astyle=s' 		=> 'set astyle style',
    		'clang-format=s'=> 'set clang-format style',
    		'uncrustify=s'  => 'set uncrustify style',
    	);
    	$!optset.push(
    		'|main=s',
    		'chang main header.',
    		value => 'int main(void)',
    	);
    	$!optset.push(
    		'|end=s',
    		'change user input code terminator.',
    		value => '@@CODEEND',
    	);
    	$!optset.push(
    		'f|flag=a',
    		'pass -<flags> to compiler.',
    	);
        $!optset.push(
            'w|=b',
            'pass -Wall -Wextra -Werror to compiler.',
        );
    	$!optset.push(
    		'|std=s',
    		'set c standard version.',
    		:value<c11>
    	);
    	$!optset.push(
    		'c|compiler=s',
    		'set compiler.',
    		value => @!compiler[0].name
    	);
    	$!optset.push(
    		'e=a',
    		'add code to generator.'
    	);
    	$!optset.push(
    		'r=b',
    		'ignore -e, allow user input code from stdin.',
    	);
    	$!optset.push(
    		'p|=b',
    		'print code read from -e or -r.'
    	);
    	$!optset.push(
    		'|debug=b',
    		'open debug mode.'
    	);
    	$!optset;
    }

    method language() {
        Language::C;
    }

    method optionset() is rw {
        $!optset;
    }
}