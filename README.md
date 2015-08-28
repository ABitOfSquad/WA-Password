# WA-password
Cracks the PW file that is included with a Whatsapp installation

### Tutorial
*__Heads Up!__ This method requires a linux installation with GCC and OpenSSL installed.*
#### Obtaining the password (Android)
First, you want to pull the password from your android device, this can be done using ```adb```. You should have developer/root access to your device!

First copy the PW file to your sdcard. Do this by executing the following commands in the SDB shell.
```shell
$ adb shell
android$ su
android# cp /data/data/com.whatsapp/files/pw /sdcard
android# exit
android$ exit
```
If you've copied your files, you are ready to download the file by executing the following command:
```shell
$ adb pull /sdcard/pw
```
This file should be copied to the same directory as the ```wa_pass_latest.sh```
#### Decrypting the PW file
**Heads up! this shell script requires you to edit a variable in the code with your phone number**

All you need to do now is, running ```wa_pass_latest.sh``` and it will do lots of magic and witchcraft, and after a few moments return your password in a string.
