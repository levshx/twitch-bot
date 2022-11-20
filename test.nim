import os, strutils, re, sequtils

let text = "  https://google.com  googldsdse.com "

let reg = re"(https?:\/\/)?(www\.)?[-a-zA-Z0-9.]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)"

echo findAll(text, reg)      


