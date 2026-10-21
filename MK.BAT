@echo off
tools\vasm -nomsg=2050 -nomsg=2054 -nomsg=2052 -quiet -devpac -Isongs -Isrc -Ftos -o hip.prg replay.asm
if errorlevel 1 goto error
:error
