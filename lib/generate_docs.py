@echo off
REM Save as generate_docs.bat
echo ^<documents^>> output.xml
setlocal enabledelayedexpansion
set /a index=1

for %%F in (*.dart) do (
    echo   ^<document index="!index!"^>>> output.xml
    echo     ^<source^>%%F^</source^>>> output.xml
    echo     ^<document_content^>>> output.xml
    type "%%F">> output.xml
    echo     ^</document_content^>>> output.xml
    echo   ^</document^>>> output.xml
    set /a index+=1
)

echo ^</documents^>>> output.xml