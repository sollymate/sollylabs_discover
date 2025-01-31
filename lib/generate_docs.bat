@echo off
REM This script generates XML documentation of your dart files

REM Create or clear the output file
echo ^<documents^>> output.xml

REM Initialize counter
setlocal enabledelayedexpansion
set /a index=1

REM Loop through all .dart files
for /R %%F in (*.dart) do (
    echo Processing: %%F
    echo   ^<document index="!index!"^>>> output.xml
    echo     ^<source^>%%~nxF^</source^>>> output.xml
    echo     ^<document_content^>>> output.xml
    type "%%F">> output.xml
    echo     ^</document_content^>>> output.xml
    echo   ^</document^>>> output.xml
    set /a index+=1
)

REM Close the documents tag
echo ^</documents^>>> output.xml

echo Done! Check output.xml file.
pause