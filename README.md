# automatic_luks_decryption
Script to configure an automatic LUKS decryption

You can use this script for installing an automatic decryption for your root filesystem.

Requirements are 
- an unencrypted /boot filesystem
- a seperate encrypted root filesystem
- u have your luks passphrase

This skript try to check for the right paritions but you can set is manually.
Set the BOOTPART and ROOTPART variable add the beginning in the script.
Like

BOOTPARt=/dev/sda5

Run script and have fun!

- Script edit /etc/crypttab file
- Script create an keyfile to /boot/keyfile
- Script add keyfile to your luks device
