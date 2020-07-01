function error() {
    COLOR_REST="$(tput sgr0)"
    COLOR_RED="$(tput setaf 1)"
    printf "%s%s%s\n" $COLOR_RED "$1" $COLOR_REST
}