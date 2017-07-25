
use App::snippet;

class App::snippet::Interface::Cpp does Interface is export {
    method language() {
        Language::CXX
    }

    method optionset() is rw {
        $!optset;
    }
}
