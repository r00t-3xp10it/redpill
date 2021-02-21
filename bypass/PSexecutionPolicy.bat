@echo off
echo Changes system powershell execution policy without user intervention!
@cmd /R echo Y|powershell Set-ExecutionPolicy UnRestricted -Scope CurrentUser