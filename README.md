# Process IP Addresses from a Log File

This repository contains a script for extracting, processing, and analyzing IP addresses from log files. The script reads through a log file, filters out the IP addresses, and performs various operations on them, such as counting occurrences and identifying unique addresses.

## Features

- **Extract IP Addresses**: Efficiently extract IP addresses from a specified log file.
- **Count Occurrences**: Count the number of times each IP address appears in the log file.
- **Identify Unique IPs**: List all unique IP addresses found in the log file.
- **Configuration File**: Easily configurable through the `script.conf` file for custom log file paths and other settings.

## Requirements

- Bash (Unix Shell)
- Basic understanding of shell scripting

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/blade34242/Process-IP-addresses-from-a-log-file.git
   cd Process-IP-addresses-from-a-log-file
   ```

2. **Configure the Script**

   Edit the `script.conf` file to specify the path to your log file and any other configurations.

3. **Run the Script**

   ```bash
   ./script.sh
   ```

## Configuration

The `script.conf` file allows you to configure:

- `LOG_FILE_PATH`: Path to the log file to be processed.
- Any other custom settings needed for your specific use case.

## Example

Assume you have a log file `example.log` with the following content:

```
192.168.1.1 - - [24/Jun/2024:10:10:10] "GET /index.html HTTP/1.1" 200 1024
192.168.1.2 - - [24/Jun/2024:10:10:11] "POST /form HTTP/1.1" 200 512
192.168.1.1 - - [24/Jun/2024:10:10:12] "GET /about.html HTTP/1.1" 200 2048
```

Running the script will output:

```
IP Addresses found:
192.168.1.1
192.168.1.2

IP Address Count:
192.168.1.1: 2
192.168.1.2: 1
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any improvements or bugs.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or suggestions, feel free to open an issue or contact the repository owner.
