# NextCloudPi for Android (NextCloud v24.0.5)

- Lightly-forked edition of [NextCloudPi](https://github.com/nextcloud/nextcloudpi/compare/master...DesktopECHO:master) 
- [Video](https://www.youtube.com/watch?v=RuHJ_S9DcG4) of NextCloudPi deployment on a Kindle HD 8 (2017) running LineageOS

![image](https://user-images.githubusercontent.com/33142753/175468814-855abd7e-309e-41f9-aafc-869ff4ac5b21.png)

**Hardware Requirements** 
--
NextCloudDroid requires a **rooted** ARMv7 or ARMv8 Android device from 2013-onward.  Form factor is unimportant; it could be a phone, tablet, HDMI stick, TV box, toaster, **any** device running Android.

Many ARM-based devices are becoming hard to come by due to supply chain woes.  Those searching online for a reasonably-priced SBC may already have one gathering dust in a desk drawer, unused and ready for a project.  

# Instructions:

- Open web browser on device and download+install the Linux Deploy APK.  You can also download this from the Play Store if preferred:

  - Get the latest version at: **https://github.com/meefik/linuxdeploy/releases**

-  Download the NextCloudDroid disk image: (**v1.2 / June 20, 2022**)

   - **https://github.com/DesktopECHO/linuxdeploy-images/raw/main/ncd12.tgz**

- Open **Linux Deploy** and change these settings:
     -  Open Properties Menu (Usually at the bottom or right of the screen)
     -  Distribution: **rootfs.tar**
     -  Installation Type -> **File**
     -  Image Size (MB) -> **4000** (as a minimum, more if you have the space)
     -  Source Path - This varies by device, ie: **${EXTERNAL_STORAGE}/Download/ncd12.tgz**
     -  Set password for user **android**
     -  Init -> **Enable** 
     -  Init system -> **SysV**
     -  Go back to the main window, open the 'Hamburger menu' (Three dashes at top left) and touch **Settings**
     -  Place checkmark on **Lock Wi-Fi** if your device has Wi-Fi
     -  Place checkmark on **Wake Lock** to prevent your device from sleeping     
     -  Place checkmark on **Autostart** to start NextCloud when the Android device is powered-on.
    
 - Go back to the main window, click **Options** Menu (Three dots, usually at top right of screen) and click **Install**

[ncd12.tgz](https://github.com/DesktopECHO/linuxdeploy-images) will automatically launch the NextCloudPi installer at first run.  If the installaion is successful, you will be prompted to contune setup in the web interface:
![image](https://user-images.githubusercontent.com/33142753/175468710-89c06b31-8754-4d0d-90f6-34e74048bd76.png)

If you're using [debian.tgz](https://github.com/DesktopECHO/linuxdeploy-images/raw/main/debian.tgz) instead, login to the container and run: 
```
# curl -sSL https://raw.githubusercontent.com/DesktopECHO/nextcloudpi/master/install.sh | bash
```
**If your Android device has a battery and was unused for months or longer, replace its battery.** Old, worn, or abused Li-ion batteries can fail when pushed back into service. Failure appears as a bulge in the battery, or worse a “thermal event” - Replacing it serves as a UPS for your device.

![Screenshot_20220624-032001_Chromium](https://user-images.githubusercontent.com/33142753/175473301-e20e7de0-84f6-4580-9ede-98bffb11c817.png)

## Features (Some are untested)

 * Debian 11 Bullseye
 * Nextcloud 24.0.5
 * Apache 2.4.25, with HTTP2 enabled
 * PHP 8.1
 * MariaDB 10.5
 * Redis memory cache
 * ncp-config for easy setup 
 * Automatic redirection to HTTPS
 * ACPU PHP cache
 * PHP Zend OPcache enabled with file cache
 * HSTS
 * Cron jobs for Nextcloud
 * Sane configuration defaults
 * Full emoji support
 * Postfix email
 * Secure

## Extras (Some are untested)

 * Setup wizard
 * NextCloudPi Web Panel
 * Wi-Fi ready
 * Ram logs
 * Automatic security updates, activated by default.
 * Let’s Encrypt for trusted HTTPS certificates.
 * Fail2Ban protection against brute force attacks.
 * UFW firewall
 * Dynamic DNS support for no-ip.org
 * Dynamic DNS support for freeDNS
 * Dynamic DNS support for duckDNS
 * Dynamic DNS support for spDYN
 * Dynamic DNS support for Namecheap
 * dnsmasq DNS server with DNS cache
 * ModSecurity Web Application Firewall
 * NFS ready to mount your files over LAN
 * SAMBA ready to share your files with Windows/Mac/Linux
 * Remote updates
 * Automatic NCP updates
 * Automatic Nextcloud updates
 * Update notifications
 * NextCloud backup and restore
 * NextCloud online installation
 * scheduled rsync
 * UPnP automatic port forwarding
 * Security audits with Lynis and Debsecan
 * ZRAM
 * Prometheus metrics monitoring

Extras can be activated and configured using the web interface at HTTPS port 4443, or from the command line from

```
sudo ncp-config
```
Find the full documentation at [docs.nextcloudpi.com](http://docs.nextcloudpi.com)
---
