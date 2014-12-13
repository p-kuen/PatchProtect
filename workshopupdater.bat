@echo off
set /p changes="Changes: "
"../../../bin/gmad.exe" create -out "D:\Daten\Workshop\PProtect.gma" -folder "D:\Daten\Server\Valve Server\steamapps\common\GarrysModDS\garrysmod\addons\PatchProtect"
"../../../bin/gmpublish" update -addon "D:\Daten\Workshop\PProtect.gma" -id "183047564" -changes "%changes%"
PAUSE