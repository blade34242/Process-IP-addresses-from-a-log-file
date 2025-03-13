# Process IP Addresses from a Log File

This repository contains a Bash script that extracts, processes, and analyzes IP addresses from log files. The script reads a log file, filters IP addresses based on configurable patterns, and outputs a report listing the unique IP addresses along with their occurrence counts.

## Features

- **Extract IP Addresses:** Efficiently extracts all IP addresses from a specified log file.
- **Count Occurrences:** Counts how many times each IP address appears in the log file.
- **Filter Options:** Optionally filter out local and/or remote IP addresses based on patterns defined in the configuration file.
- **Configurable Settings:** Easily adjust IP patterns and other settings through the `script.conf` file.
- **Automatic Cleanup:** Removes temporary files after processing is complete.

## Requirements

- Unix-like operating system (Linux, macOS)
- Bash (version 4.0 or higher)
- Basic understanding of shell scripting

## Files

- **script.sh:** The main script to process the log file.
- **script.conf:** Configuration file where you define IP patterns and other settings.
- **README.md:** This documentation file.

## Installation

1. **Clone the Repository**

   Open a terminal and run:

   ```bash
   git clone https://github.com/blade34242/Process-IP-addresses-from-a-log-file.git
   cd Process-IP-addresses-from-a-log-file
   ```

2. **Configure the Script**

   Edit the file `script.conf` to adjust the IP filter patterns and any other settings required for your environment.

   Example `script.conf`:

   ```bash
   # Configuration file for processing IP addresses

   # Pattern for local IP addresses (adjust as needed)
   LOCAL_IP_PATTERN="^172\.[0-9]{1,3}(\.[0-9]{1,3}){2}"

   # Pattern for remote IP addresses (adjust as needed)
   REMOTE_IP_PATTERN="^192\.[0-9]{1,3}(\.[0-9]{1,3}){2}"
   ```

2. **Set Permissions**

   Make the script executable:

   ```bash
   chmod +x script.sh
   ```

## Usage

Run the script by specifying the input log file with the `-i` or `--input` option, along with one of the following processing options:

- `-a` or `--all`: Process all IP addresses (filter out both local and remote as defined).
- `-l` or `--local`: Process IP addresses and filter out local IPs only.
- `-r` or `--remote`: Process IP addresses and filter out remote IP addresses only.

### Example

Assuming you have a log file named `log.txt`, you can run:

```bash
./script.sh -i log.txt -a
```

The script will output a report similar to:

```
IP Addresses found:
192.168.1.1
192.168.1.2

IP Address Count:
192.168.1.1: 2
192.168.1.2: 1
```

## Contributing

Contributions and suggestions are welcome! If you find any issues or would like to improve the script, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

For any questions or suggestions, please open an issue or contact the repository owner.
