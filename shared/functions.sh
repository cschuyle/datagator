is_installed() {
    required_command="$1"

    if [[ "$required_command" == "Text::Autoformat" ]]; then

        if ! perldoc -l Text::Autoformat 2>/dev/null; then
            echo "
        You need to install the Text:Autoformat Perl module. Try:
        
        cpan

        (answer 'yes' to the question about setting up if this is the first time you're running cpan)
        cpan[1]> install Text::Autoformat
        cpan[2]> exit 
" 1>&2
            exit 1
        fi
    elif ! type "$required_command" >/dev/null; then
        echo "The required command '$required_command' isn't installed."

        case "$required_command" in

        csvformat)
            echo "Try 'brew install csvkit'"
            ;;

        aws)
            echo "Try 'brew install awscli'"
            ;;

        magick | convert)
            echo "Try 'brew install imagemagick'"
            ;;
        esac

        exit 1
    fi
}

lines2json() {
    set -ex

    input_file="$1"
    trove_id="$2"
    trove_name="$3"
    trove_short_name="$4"
    output_file="$5"

    titles=$(echo '{"titles": ' && jq --raw-input --slurp 'split("\n") | .[0:-1]' "${input_file}" && echo '}')

    echo $titles | jq ". + {id: \"$trove_id\", name: \"$trove_name\", \"shortName\": \"$trove_short_name\"}" >"$output_file"

    # cat "$output_file"
}
