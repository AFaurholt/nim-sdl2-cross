# Package

version       = "0.1.0"
author        = "AF"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
installExt    = @["nim"]
bin           = @["nim_sdl2_cross"]


# Dependencies

requires "nim >= 2.0.0"
requires "sdl2"

task foo, "foo":
  echo commandLineParams
  var
    verSdl = "2.19.3"
    verTtf = "2.19.2"
  for idx, param in commandLineParams:
    if "--sdl" in param: verSdl = param.split({':', '='})[1]
    if "--ttf" in param: verTtf = param.split({':', '='})[1]
  echo "sdl: ", verSdl, " ttf: ", verTtf

task getsdl, "wget sdl stuff and unzip":
  var
    verSdl = "2.28.3"
    verTtf = "2.20.2"
  for idx, param in commandLineParams:
    if "--sdl" in param: verSdl = param.split({':', '='})[1]
    if "--ttf" in param: verTtf = param.split({':', '='})[1]
  
  exec "mkdir -p " & binDir
  exec "wget -O " & binDir & "/zip1 https://github.com/libsdl-org/SDL_ttf/releases/download/release-" & verTtf & "/SDL2_ttf-" & verTtf & "-win32-x64.zip"
  exec "unzip -o " & binDir & "/zip1 -d " & binDir
  exec "wget -O " & binDir & "/zip2 https://github.com/libsdl-org/SDL/releases/download/release-" & verSdl & "/SDL2-" & verSdl & "-win32-x64.zip"
  exec "unzip -o " & binDir & "/zip2 -d " & binDir
  exec "rm " & binDir & "/zip1" 
  exec "rm " & binDir & "/zip2" 

task buildw, "Build for windows":
  exec "nim c -d:mingw -o:" & binDir & "/app.exe " & srcDir & "/nim_sdl2_cross.nim"