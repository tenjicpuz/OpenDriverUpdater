# Open Source Windows Driver Updater

A completely transparent, zero-dependency batch script for managing, backing up, and updating Windows 10/11 drivers using native Windows APIs.

## Why this exists (The Trust Factor)
Most driver updaters are closed-source, bundle bloatware, or trigger antivirus software. This project is different:
* **100% Transparent:** It is written entirely in Batch and PowerShell. You can read every single line of code.
* **No Compiled Executables:** We never use `.exe` wrappers, which prevents Antivirus false-positives.
* **Native Windows Tools Only:** Relies strictly on Microsoft's built-in `pnputil.exe` and `WMI`.
* **Fail-Safe:** Automatically creates System Restore points and backs up existing drivers before making any changes.

## Features
1. **Backup All Drivers:** Exports current drivers to `C:\DriverBackup`.
2. **Safe Restore Points:** Triggers native Windows System Protection.
3. **Hardware ID Scanner:** Extracts HWIDs to help you find the exact OEM driver you need.
4. **Offline Driver Installer:** Recursively installs `.inf` files from any folder you provide.

## Usage
1. Download `open_driver_updater.bat`.
2. Right-click the file and select **Run as Administrator** (required for `pnputil`).
3. Follow the on-screen menu.

## Security & VirusTotal
This script is 100% clean. Verify the latest version here: 
[[VirusTotal Link Here](https://www.virustotal.com/gui/file/2fc4be42ecc47f0aa9bd3bcf5ea3c152fd5243983a3d7ff7fe5862c9d2f8210d?nocache=1)]
