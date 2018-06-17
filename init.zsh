p6df::modules::p6perl::version() { echo "0.0.1" }
p6df::modules::p6perl::deps()    { }
p6df::modules::p6perl::external::brew() { }

p6df::modules::p6perl::init() {

    p6_perl_init $P6_DFZ_DATA_DIR/p6m7g8/p6perl
}

p6_perl_init() {
    local dir="$1"

    p6df::util::path_if "$dir/bin"
    export PERL5LIB=$dir/lib/perl5
}
