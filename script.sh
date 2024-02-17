#!/usr/bin/env bash
#: Script to process IP addresses from a log file.

# Set shell options for error handling
set -o errexit
set -o nounset
set -o pipefail

# Determine script's working directory
work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")

# Define script configuration file and error codes
readonly conf_file="${work_dir}/script.conf"
readonly error_reading_conf_file=80
readonly error_parsing_options=81
readonly script_name="${0##*/}"

# Initialize option flags
all_option_flag=1
local_option_flag=0
remote_option_flag=0

# Set up cleanup actions on script termination
trap clean_up ERR EXIT SIGINT SIGTERM

# Function to display script usage
usage() {
    cat <<USAGE_TEXT
Usage: ${script_name} [-h | --help] [-i | --input <Input File>] [-a | --all] [-l | --local] [-r | --remote]
DESCRIPTION
    This script processes IP addresses from a log file and performs cleanup actions based on specified options.
OPTIONS:
-h, --help
        Print this help and exit.
-i, --input
        Input File
-a, --all
        Remove all local and remotes IPS
-l  --local
        Remove all local IPS
-r  --remote
        Remove all remotes IPS
USAGE_TEXT
}

# Function to extract IP addresses from input file and prepare them for processing
prepare_file() {
  grep -Po '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' "$input_arg" >> allIPs.txt
  sort -u allIPs.txt | uniq -u >> "$1"
}

# Function to remove empty lines from a file
remove_newlines() {
  sed -i '/^$/d' "$1"
}

# Function to clean local IP addresses
local_clean() {
  sed -E "/${LOCAL_IP_PATTERN}/s///g" -i "$1"
  remove_newlines "$1"
}

# Function to clean remote IP addresses
remote_clean() {
  sed -E "/${REMOTE_IP_PATTERN}/s///g" -i "$1"
  remove_newlines "$1"
}

# Function to perform cleanup actions on script termination
clean_up() {
    # Add cleanup actions here, such as removing temporary files or directories.
     rm -f allIPs.txt allIPsUniq.txt
    exit 0
}

# Function to print error message and exit with specific error code
die() {
    local -r msg="${1}"
    local -r code="${2:-90}"
    echo "Error: ${msg}" >&2
    exit "${code}"
}

# Check if configuration file exists
if [[ ! -f "${conf_file}" ]]; then
    die "Configuration file not found: ${conf_file}" "${error_reading_conf_file}"
fi

# Source configuration file
. "${conf_file}"

# Initialize input argument
input_arg=""

# Function to parse user options and set flags accordingly
parse_user_options() {
    local -r args=("${@}")
    local opts

    opts=$(getopt --options i:alrh --long input:,all,local,remote,help -- "${args[@]}" 2> /dev/null) || {
        usage
        die "Error parsing options" "${error_parsing_options}"
    }
    eval set -- "${opts}"
    while true; do
        case "${1}" in
            --input|-i)
                input_arg="${2}"
                shift 2
                ;;
            --all|-a)
                all_option_flag=1
                shift
                ;;
            --local|-l)
                local_option_flag=1
                all_option_flag=0
                shift
                ;;
            --remote|-r)
                remote_option_flag=1
                all_option_flag=0
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done

    # If none of the -a, -l, or -r options are provided, set the all_option_flag by default
    if ((all_option_flag == 0 && local_option_flag == 0 && remote_option_flag == 0)); then
        all_option_flag=1
    fi
}

# Main part of the script
echo "Script called with arguments: $@"

# Parse user options
parse_user_options "${@}"

# Check if input_arg is not empty when using -a, -l, or -r options
if ((all_option_flag)) || ((local_option_flag)) || ((remote_option_flag)); then
    if [[ -z "${input_arg}" ]]; then
        die "Input file not provided" "${error_parsing_options}"
    fi
fi

# Define date format for filename
date_format=$(date +'%Y%m%d%H%M%S')

# Output filename with date
output_file="output_${date_format}.txt"

# Output filename for unique IPs with date
uniq_output_file="allIPsUniq_${date_format}.txt"

# Create the output files
touch "$uniq_output_file"

# Execute appropriate actions based on options provided
if ((all_option_flag)); then
    echo "Using -a option --all -> arg:"
    prepare_file "${uniq_output_file}"
    local_clean "${uniq_output_file}"
    remote_clean "${uniq_output_file}"
fi
if ((local_option_flag)); then
    echo "Using -l option --local -> arg:"
    prepare_file "${uniq_output_file}"
    local_clean "${uniq_output_file}"
fi
if ((remote_option_flag)); then
    echo "Using -r option --remote -> arg:"
    prepare_file "${uniq_output_file}"
    remote_clean "${uniq_output_file}"
fi
clean_up
exit 0

