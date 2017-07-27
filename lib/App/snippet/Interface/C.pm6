
use PathTools;
use App::snippet;
use Getopt::Advance;

class App::snippet::Interface::C does Interface is export {
    submethod TWEAK() {
        sub main($optset, @args) {
            my $compiler = @!compilers.first({ .name eq $optset<c> });

            # generate compile arguments
            @compile-args.append(&argsFromOV($optset, '-', 'f'));
            @compile-args.append(&argsFromOV($optset, '--', 'flag'));
            @compile-args.append(&argsFromOV($optset, '-I', 'I'));
            @compile-args.append(&argsFromOV($optset, '-D', 'D'));
            @compile-args.append(&argsFromOV($optset, '-L', 'L'));
            @compile-args.append(&argsFromOV($optset, '-l', 'l'));
            @compile-args.push("-std={$optset<std>}");
            @compile-args.append('-Wall', '-Wextra', '-Werror') if $optset<w>;
            @compile-args.push($optset<E> ?? '-E' !! '-S') if $optset<E> || $optset<S>;

            # generate code or file
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
                $compiler.compileCode(
                    @incode,
                    $optset<o> // tmppath('snippet-c'),
                    :out($optset<quite>),
                    :err($optset<quite>),
                );
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
        $!optset.append(
            'f=a'    => 'pass -<f> to compiler.',
            'flag=a' => 'pass --<flag> to compiler.'
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
    		"set compiler, availname compiler are {@!compilers>>.name}.",
    		value => 'gcc',
    	);
    	$!optset.append(
    		'e=a' => 'add code to generator.',
            'r=b' => 'ignore -e, allow user input code from stdin.',
            'o=s' => 'set output file, or will be auto generate',
    	);
    	$!optset.append(
    		'p|=b' => 'print code read from -e or -r.',
            '|debug=b' => 'open debug mode.',
            'temp=b' => 'don\'t remove output file.',
    	);
        $!optset.push(
            'quite=b/',
            'disable quite mode, open stdout and stderr.',
        );
    	$!optset;
    }

    method lang() {
        Language::C;
    }

    method optionset() is rw {
        $!optset;
    }
}
