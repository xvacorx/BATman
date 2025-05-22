CREATED BY: xvacorx

GitHub: https://github.com/xvacorx

Itch.io: https://xvacorx.itch.io/

-----------------------------------------

This script is meant to shut down a computer after 1 hour without activity

ShutdownTimeout: This is the main script, needs to be placed on startup folder. This script checks if there's activity on the computer (mouse movement or keyboard inputs). If there's not, moves the cursor a few pixels every 5 minutes of no activity, preventing the computer to sleep.
Every 5 minutes of no activity, a counter is going to sum. When the counter comes up to 55 minutes without activity, a warning will appear. If 5 minutes more after the warning appeared, still no activity, the computer will be shutdown.
If there's any activity, the counter resets.

ShutdownTest: This script shuts down the computer, it's meant to test the privilege settings of the computer.

ShutdownPrivilegeTest: This script initiates a shutdown and then cancel that. It's meant to test the privilege settings of the computer.
