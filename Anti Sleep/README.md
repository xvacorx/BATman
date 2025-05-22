# Anti Sleep

A set of simple `.bat` files to prevent your Windows computer from sleeping or logging out due to inactivity.

## How it Works

* **`Anti_Sleep.bat`**: This script simulates user activity by moving the mouse cursor one pixel every 60 seconds. This subtle movement tricks Windows into thinking you're still active, preventing the system from entering sleep mode or automatically locking.
    * **Recommendation**: For continuous use, add `Anti_Sleep.bat` to your Windows Startup folder so it runs automatically when you log in.

* **`Allow_Sleep.bat`**: When you're ready for your computer to sleep normally, simply run this script. It kills the `Anti_Sleep.bat` process, allowing your device to enter sleep mode or lock without needing a system restart.

## Usage

1.  **To prevent sleep**: Double-click `Anti_Sleep.bat`.
2.  **To allow sleep again**: Double-click `Allow_Sleep.bat`.

---

### Created by

**xvacorx**

* **GitHub**: [https://github.com/xvacorx](https://github.com/xvacorx)
* **Itch.io**: [https://xvacorx.itch.io/](https://xvacorx.itch.io/)
* **LinkedIn**: [https://www.linkedin.com/in/victor-g-sanchez/](https://www.linkedin.com/in/victor-g-sanchez/)
