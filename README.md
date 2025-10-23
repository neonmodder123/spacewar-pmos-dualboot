Just a git action repo to generate bootable rootfs + boot.img for Nothing Phone 1 (spacewar)

How to install ?

1. Login to your github account
2. Go to Actions tab
3. Download the most recent build (new build every friday night). Choose the desktop environment (DE) you want (Plasma, Phosh, Gnome-Mobile)
4. Extract the archive
5. Flash boot to boot partition
6. Flash rootfs to userdata partition
7. Delete dtbo and vendor_boot : "fastboot delete dtbo" and then "fastboot delete vendor_boot"
8. Reboot

If one DE doesn't work well, just try another one...
