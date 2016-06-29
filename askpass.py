#!/usr/bin/python
import sys
import os
import re
import keychain

def decode_hex(s):
    s = eval('"' + re.sub(r"(..)", r"\x\1", s) + '"')
    if "\0" in s: s = s[:s.index("\0")]
    return s

def findPass(svce, acct):
    cmd = ' '.join([
        "/usr/bin/security",
        " find-generic-password",
        "-g -s '%s' -a '%s'" % (svce, acct),
        "2>&1 >/dev/null"
    ])
    p = os.popen(cmd)
    s = p.read()
    p.close()
    m = re.match(r"password: (?:0x([0-9A-F]+)\s*)?\"(.*)\"$", s)
    if m:
        hexform, stringform = m.groups()
        if hexform:
            return decode_hex(hexform)
        else:
            return stringform