# Ping Check

A network utility to efficiently check the reachability of a list of IP addresses or hostnames and generate a detailed report.

## How it Works

This tool pings a list of devices specified in a text file (`ips.txt`) and then generates a `Results.txt` file summarizing which IPs are reachable and which are not. You have two options for the level of detail in the report:

* **`Ping.bat`**: Provides a concise report, simply indicating whether each IP responded successfully or not.
* **`Detailed_Ping.bat`**: Attempts to gather additional information about each device, such as MAC address and hostname, for a more comprehensive report.

## Usage

1.  **Prepare `ips.txt`**:
    * Open `ips.txt` (located in the same folder as the scripts).
    * Enter each IP address or hostname you want to ping on a new line.
        ```
        192.168.1.1
        google.com
        10.0.0.50
        ```
    * Save the `ips.txt` file.

2.  **Run the script**:
    * Double-click either `Ping.bat` for a basic check or `Detailed_Ping.bat` for more information.

3.  **View results**:
    * Once the script finishes, a `Results.txt` file will be created in the same folder, containing the ping report.

---

### Created by

**xvacorx**

* **GitHub**: [https://github.com/xvacorx](https://github.com/xvacorx)
* **Itch.io**: [https://xvacorx.itch.io/](https://xvacorx.io/)
* **LinkedIn**: [https://www.linkedin.com/in/victor-g-sanchez/](https://www.linkedin.com/in/victor-g-sanchez/)
