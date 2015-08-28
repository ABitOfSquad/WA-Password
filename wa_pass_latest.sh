#!/bin/bash

# Your phone number without the + from the country code or any starting 0s, but with the country code itself in numbers
PHONE='3112334567'
if ! [ -r pw ]; then exit 1; fi

# get the salt
# 4 byte number found within offset 0x1D and 0x20. Offsets start from 0x00.
dd if=pw of=pw_salt bs=1 skip=29 count=4
# Hex dump the salt
hexdump -e '2/1 "%02x"' pw_salt
# The initialisation vector is a 16-byte or 128-bit value found within offset 0x21 and 0x30.
dd if=pw of=pw_iv bs=1 skip=33 count=16
#The encrypted key is a 20-byte or 160-bit number. Offset is between 0x31 and 0x44.
dd if=pw of=pw_ekey bs=1 skip=49 count=20

# Create binary files from a hex dump, using a static value and the phone number using xxd
echo -n 'c2991ec29b1d0cc2b8c3b7556458c298c29203c28b45c2973e78c386c395' | xxd -r -p > pbkdf2_pass.bin
echo -n $PHONE | hexdump -e '2/1 "%02x"' | xxd -r -p >> pbkdf2_pass.bin

#A Simple C program that uses openssl for pbkdf2 function
#OpenSSL does not seem to support it from the command line.
echo -ne 'I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPG9wZW5zc2wv
eDUwOS5oPgojaW5jbHVkZSA8b3BlbnNzbC9ldnAuaD4KI2luY2x1ZGUgPG9wZW5zc2wvaG1hYy5o
PgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkKewoJdW5zaWduZWQgY2hhciBwYXNz
WzEwMjRdOyAgICAgIC8vIHBhc3NwaHJhc2UgcmVhZCBmcm9tIHN0ZGluCgl1bnNpZ25lZCBjaGFy
IHNhbHRbMTAyNF07ICAgICAgLy8gc2FsdCAKCWludCBzYWx0X2xlbjsgICAgICAgICAgICAgICAg
ICAvLyBzYWx0IGxlbmd0aAoJaW50IGljOyAgICAgICAgICAgICAgICAgICAgICAgIC8vIGl0ZXJh
dGlvbgoJdW5zaWduZWQgY2hhciByZXN1bHRbMTAyNF07ICAgIC8vIHJlc3VsdAoJRklMRSAqZnBf
c2FsdDsKCglpZiAoIGFyZ2MgIT0gMyApIHsKCQlmcHJpbnRmKHN0ZGVyciwgInVzYWdlOiAlcyBz
YWx0X2ZpbGUgaXRlcmF0aW9uIDwgcGFzc3dkX2ZpbGUgPiBiaW5hcnlfa2V5X2ZpbGUgXG4iLCBh
cmd2WzBdKTsKCQlleGl0KDEpOwoJfQoKCWljID0gYXRvaShhcmd2WzJdKTsKICAKCWZwX3NhbHQg
PSBmb3Blbihhcmd2WzFdLCAiciIpOwoJaWYoIWZwX3NhbHQpIHsKCQlmcHJpbnRmKHN0ZGVyciwg
ImVycm9yIG9wZW5pbmcgc2FsdCBmaWxlOiAlc1xuIiwgYXJndlsxXSk7CgkJZXhpdCgyKTsKCX0K
CglzYWx0X2xlbj0wOwoJaW50IGNoOwkKCXdoaWxlKChjaCA9IGZnZXRjKGZwX3NhbHQpKSAhPSBF
T0YpIHsJCQoJCXNhbHRbc2FsdF9sZW4rK10gPSAodW5zaWduZWQgY2hhciljaDsJCQoJfQkKCiAg
ICBmY2xvc2UoZnBfc2FsdCk7CQogICAKICAgIGZnZXRzKHBhc3MsIDEwMjQsIHN0ZGluKTsKICAg
IGlmICggcGFzc1tzdHJsZW4ocGFzcyktMV0gPT0gJ1xuJyApCgkJcGFzc1tzdHJsZW4ocGFzcykt
MV0gPSAnXDAnOwogIAoJUEtDUzVfUEJLREYyX0hNQUNfU0hBMShwYXNzLCBzdHJsZW4ocGFzcyks
IHNhbHQsIHNhbHRfbGVuLCBpYywgMTYsIHJlc3VsdCk7CgoJZndyaXRlKHJlc3VsdCwgMSwgMTYs
IHN0ZG91dCk7CgoJcmV0dXJuKDApOwp9Cg==' | base64 -d > pbkdf2.c

#compile the program
gcc -o pbkdf2 pbkdf2.c -lcrypto
#when this throws an error use the following line, and comment the above out:
#gcc -o pbkdf2 pbkdf2.c -lcrypto

chmod +x pbkdf2

#decrypt it, using the salt, and the 2 binaries
./pbkdf2 pw_salt 16 < pbkdf2_pass.bin > pbkdf2_key.bin

#This uses AES OFB 128-bit decryption. We need two variables, K and IV to decrypt, we found these earlier in the pw file.
K=`hexdump -e '2/1 "%02x"' pbkdf2_key.bin`
IV=`hexdump -e '2/1 "%02x"' pw_iv`
openssl enc -aes-128-ofb -d -nosalt -in pw_ekey -K $K -iv $IV -out password.key

#echo the password string used in packets, this is the actual password
base64 password.key
