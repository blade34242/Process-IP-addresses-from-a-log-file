#!/usr/bin/env bash
#: Script to process IP addresses from a log file.

# Set shell options for error handling
set -o errexit
set -o nounset
set -o pipefail

# Determine the script's working directory
work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")

# Define configuration file and error codes
readonly conf_file="${work_dir}/script.conf"
readonly error_reading_conf_file=80
readonly error_parsing_options=81
readonly script_name="${0##*/}"

# Initialize option flags (default: process all IPs if no filter is provided)
all_option_flag=1
local_option_flag=0
remote_option_flag=0

# Setup cleanup actions on script termination
trap clean_up ERR EXIT SIGINT SIGTERM

# Function to display script usage
usage() {
    cat <<USAGE_TEXT
Usage: ${script_name} [-h | --help] [-i | --input <Input File>] [-a | --all] [-l | --local] [-r | --remote]
DESCRIPTION:
    This script processes IP addresses from a log file, filters them based on local and/or remote IP patterns,
    and outputs the list of IP addresses along with their occurrence count.
OPTIONS:
  -h, --help
        Show this help and exit.
  -i, --input
        Path to the input file (log file)
  -a, --all
        Process both local and remote IPs (filter both)
  -l, --local
        Process only local IP addresses (as defined in the configuration file)
  -r, --remote
        Process only remote IP addresses
USAGE_TEXT
}

# Function to extract IP addresses from the input file (including duplicates)
prepare_file() {
    grep -Po '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' "$input_arg" > allIPs.txt
}

# Function to remove empty lines from a file
remove_newlines() {
    sed -i '/^$/d' "$1"
}

# Function to filter out local IP addresses from a file using the configured pattern
local_clean() {
    if [[ -n "${LOCAL_IP_PATTERN:-}" ]]; then
        grep -vE "${LOCAL_IP_PATTERN}" "$1" > tmp && mv tmp "$1"
    fi
    remove_newlines "$1"
}

# Function to filter out remote IP addresses from the file based on the configuration pattern
remote_clean() {
    if [[ -n "${REMOTE_IP_PATTERN:-}" ]]; then
        grep -vE "${REMOTE_IP_PATTERN}" "$1" > tmp && mv tmp "$1"
    fi
    remove_newlines "$1"
}

# Function to perform cleanup actions upon script termination
clean_up() {
    rm -f allIPs.txt allIPsUniq.txt ip_counts.txt
    exit 0
}

# Function to print an error message and exit with a specific error code
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

# Source configuration file (should define LOCAL_IP_PATTERN and REMOTE_IP_PATTERN)
. "${conf_file}"

# Initialize input argument variable
input_arg=""

# Function to parse user options and set flags accordingly
parse_user_options() {
    local opts
    opts=$(getopt --options i:alrh --long input:,all,local,remote,help -- "$@" 2> /dev/null) || {
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
                local_option_flag=0
                remote_option_flag=0
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

    # If no filtering option is provided, default to processing all IPs
    if ((all_option_flag == 0 && local_option_flag == 0 && remote_option_flag == 0)); then
        all_option_flag=1
    fi
}

# Main script execution
echo "Script called with arguments: $@"

# Parse user options
parse_user_options "$@"

# Verify that an input file is provided when required
if ((all_option_flag)) || ((local_option_flag)) || ((remote_option_flag)); then
    if [[ -z "${input_arg}" ]]; then
        die "Input file not provided" "${error_parsing_options}"
    fi
fi

# Define date format for output filenames
date_format=$(date +'%Y%m%d%H%M%S')
output_file="output_${date_format}.txt"
uniq_output_file="allIPsUniq_${date_format}.txt"

# Create the output file for unique IP addresses
touch "$uniq_output_file"

# Process input file based on specified options
if ((all_option_flag)); then
    echo "Using -a option (--all): filtering out both local and remote IP addresses"
    prepare_file
    local_clean allIPs.txt
    remote_clean allIPs.txt
fi
if ((local_option_flag)); then
    echo "Using -l option (--local): filtering out local IP addresses"
    prepare_file
    local_clean allIPs.txt
fi
if ((remote_option_flag)); then
    echo "Using -r option (--remote): filtering out remote IP addresses"
    prepare_file
    remote_clean allIPs.txt
fi

# Create a sorted list of unique IP addresses
sort -u allIPs.txt > allIPsUniq.txt

# Count the occurrences of each IP address and prepare output
{
  echo "IP Addresses found:"
  cat allIPsUniq.txt
  echo ""
  echo "IP Address Count:"
  sort allIPs.txt | uniq -c | sed 's/^ *//g' | awk '{print $2": "$1}'
} > "${output_file}"

# Display the output
cat "${output_file}"

clean_up
exit 0

