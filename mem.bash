#!/usr/bin/bash


function die() {
    echo "Error: $1"
    exit 1
}

function printUsage() {
    echo "
Usage: $PROGRAM mem [-h|-v] [--] <passfile>

<passfile>              Pass file to practice on
-h, --help, help        Print this help
-v, --version           Prints the version info
--                      Stop processing arguments (like -v and -h)
                        use if your pass file has leading dashes
                        (like \"--my--secret--passwd\")

"
}

function dieUsage() {
    printUsage
    die "invalid usage"
}

function readPassword() {
    echo GETPIN | pinentry-curses --ttyname $GPG_TTY | grep -Po '^D .+' | sed 's/^D //' | tr -d '\n'
}

function getRealPassword() {
    $GPG -d "${GPG_OPTS[@]}" "$passFile" | head -n 1 | tr -d '\n'
}

function testPassword() {
    if [[ "$(readPassword)" == "$(getRealPassword)" ]]; then
        echo "GOOD!"
        timesGood=$((timesGood + 1))
    else
        echo "FAIL!"
        timesBad=$((timesBad + 1))
    fi
}

[[ ! (  $# -eq 1 ) ]] && dieUsage

case "$1" in
    help|-h|--help) printUsage; exit 0;;
    -v|--version) printVersion; exit 0;;
    --) shift; [[ ! $# -eq 2 ]] && dieUsage;;
esac

timesGood=1
timesBad=1
passFile="${1%/}"
passFile="$PREFIX/$passFile.gpg"

while true; do
    testPassword
    echo "--------------------------------------------"
    echo "Stats:"
    echo "Good = $((timesGood -  1))"
    echo "Bad = $((timesBad - 1))"
    ratio=$((timesGood / timesBad))
    echo "Ratio = $ratio"
    read -p "Continue?[Y/n]" result
    [[ "$result" -eq "n" ]] && break
done

ratio=$((timesGood / timesBad))
echo "FINAL RATIO = $ratio"
echo "Not bad."

