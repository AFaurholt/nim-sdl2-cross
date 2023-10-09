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

# the files are at https://www.kenney.nl/assets/pixel-shmup

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
    verImage = "2.6.3"
  for idx, param in commandLineParams:
    if "--sdl" in param: verSdl = param.split({':', '='})[1]
    if "--ttf" in param: verTtf = param.split({':', '='})[1]
    if "--image" in param: verImage = param.split({':', '='})[1]
  
  exec "mkdir -p " & binDir

  var 
    url = "SDL_ttf"
    name = "SDL2_ttf"
    ver = verTtf
  exec "wget -O " & binDir & "/zip1 https://github.com/libsdl-org/" & url & "/releases/download/release-" & ver & "/" & name & "-" & ver & "-win32-x64.zip"
  exec "unzip -o " & binDir & "/zip1 -d " & binDir
  exec "rm " & binDir & "/zip1"

  url = "SDL"
  name = "SDL2"
  ver = verSdl
  exec "wget -O " & binDir & "/zip1 https://github.com/libsdl-org/" & url & "/releases/download/release-" & ver & "/" & name & "-" & ver & "-win32-x64.zip"
  exec "unzip -o " & binDir & "/zip1 -d " & binDir
  exec "rm " & binDir & "/zip1"

  url = "SDL_image"
  name = "SDL2_image"
  ver = verImage
  exec "wget -O " & binDir & "/zip1 https://github.com/libsdl-org/" & url & "/releases/download/release-" & ver & "/" & name & "-" & ver & "-win32-x64.zip"
  exec "unzip -o " & binDir & "/zip1 -d " & binDir
  exec "rm " & binDir & "/zip1"

task buildw, "Build for windows":
  exec "nim c -d:mingw -o:" & binDir & "/app.exe " & srcDir & "/nim_sdl2_cross.nim"