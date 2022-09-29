set a=NULL
FOR /F %%I IN ('dir /B "C:\Program Files (x86)\Microsoft\Edge\Application" ^| findstr [0-9]') DO set a=%%I
echo find is %a%
IF "%a%" == "NULL" GOTO hell
set b="C:\Program Files (x86)\Microsoft\Edge\Application\%a%\Installer\setup.exe"
%b% --uninstall --force-uninstall --system-level --delete-profile
RMDIR "C:\Program Files (x86)\Microsoft\Edge" /S /Q
:hell
for /f "tokens=8 delims=\" %%T in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" ^| findstr "Microsoft-Windows-Internet-Browser-Package" ^| findstr "~~"') do (set "edge_legacy_package_version=%%T")
if defined edge_legacy_package_version (
		echo Removing %edge_legacy_package_version%...
		reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\%edge_legacy_package_version%" /v Visibility /t REG_DWORD /d 1 /f
		reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\%edge_legacy_package_version%\Owners" /va /f
		dism /online /Remove-Package /PackageName:%edge_legacy_package_version%
		powershell.exe -Command "Get-AppxPackage *edge* | Remove-AppxPackage" >nul
)
set b=NULL
for /F "tokens=1 delims=," %%A in ('schtasks.exe /query /fo csv ^| findstr MicrosoftEdgeUpdateTaskMachineUA') do ( set b=%%A)
IF "%b%" == "NULL" GOTO next
schtasks /Change /TN %b% /Disable
:next
sc config "edgeupdate" start=disabled
sc config "edgeupdatem" start=disabled
exit 0
