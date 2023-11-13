echo off
for %%* in (.) do set folderName=%%~nx*
echo Making exec for %folderName%

set fileName=%folderName%_exec

del %~dp0\%fileName%.zip
7z a -tzip %~dp0\%fileName%.zip %~dp0\

mkdir %~dp0\..\%folderName%_build
xcopy /s /y %~dp0\..\_build\libs %~dp0\..\%folderName%_build
move /y %~dp0\%fileName%.zip %~dp0\..\%folderName%_build

cd ..\%folderName%_build
rem in build folder


ren *.zip *.love

del %fileName%.zip
del %fileName%_dis.zip
del %fileName%_dis.love

del %fileName%.exe

copy /b ..\_build\love.exe+%fileName%.love .\%fileName%.exe

del %fileName%.love
rem now we make a zip file to share
7z a -tzip %fileName%_dis.zip .\


cd ..\%folderName%
rem go back to not anger