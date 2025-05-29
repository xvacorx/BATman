---

# Shutdown Timeout

Schedules a timed shutdown for your Windows system, perfect for automated power management, energy saving, or ensuring your PC shuts down after a period of inactivity.

---

## How it Works

This script acts as an **inactivity monitor** for your Windows system. It continuously tracks user activity (keyboard and mouse input) and performs actions based on configurable inactivity thresholds:

* **Initial Functionality Test**: On its first run, or if previous tests failed, the script performs a series of checks to ensure all necessary system components (like `powershell.exe`, `msg`, `shutdown`, and file system access) are available. The results are logged, and if any critical component is missing, the script won't proceed. This ensures reliable operation.
* **Activity Simulation**: If no activity is detected for a short period (default: 5 minutes), the script will subtly move the mouse cursor by a single pixel and then back to its original position. This is intended to prevent the system from entering sleep modes or screensavers due to minor inactivity, without interrupting the user.
* **Warning Notification**: If inactivity persists for a longer duration (default: 55 minutes), a warning message will pop up on the screen, notifying the user that the computer will shut down soon if no activity is detected.
* **Automatic Shutdown**: If inactivity continues and reaches the final threshold (default: 60 minutes), the script will initiate an immediate and forced shutdown of the system.
* **Logging**: All significant events, including startup, inactivity levels, mouse movements, warnings, and shutdowns, are recorded in a log file located in your temporary directory (`%TEMP%\shutdown_log.txt`).

This script is ideal for managing energy consumption, ensuring systems are turned off when not in use, or for environments where unattended machines should automatically power down.

---

## Usage

To use this script:

1.  **Save the script**: Save the provided code as a `.bat` file (e.g., `inactivity_shutdown.bat`).
2.  **First Run / Initial Setup**:
    * When you run the script for the first time, it will execute a series of **initial functionality tests**. These tests verify that all required commands (`powershell.exe`, `msg`, `shutdown`) and file system permissions are correctly set up.
    * The results of these tests will be logged to `%TEMP%\shutdown_log.txt`.
    * If all tests pass, the script will proceed to the main monitoring operation.
    * If any test fails, an error message will be displayed, and the script will exit. You should check the `%TEMP%\shutdown_log.txt` file for details on what failed.
3.  **Subsequent Runs**: After a successful initial test, the script will detect its previous successful run and **skip the tests**, directly starting the inactivity monitoring.
4.  **Background Operation**: Once running, the script operates silently in the background, continuously monitoring for user inactivity.
5.  **Monitoring Log**: You can review the activity and status of the script at any time by checking the log file: `%TEMP%\shutdown_log.txt`.
6.  **Configuration**: You can adjust the inactivity thresholds (`CHECK_INTERVAL`, `ACTIVITY_SIM_INTERVAL`, `WARNING_THRESHOLD`, `SHUTDOWN_THRESHOLD`) by editing the `SET` variables at the beginning of the `.bat` file.

---

### Created by

**xvacorx**

* **GitHub**: [https://github.com/xvacorx](https://github.com/xvacorx)
* **Itch.io**: [https://xvacorx.itch.io/](https://xvacorx.itch.io/)
* **LinkedIn**: [https://www.linkedin.com/in/victor-g-sanchez/](https://www.linkedin.com/in/victor-g-sanchez/)
