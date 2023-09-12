import sdl2

type
  SDLException = object of Defect
  WindowPtrScopeWrapper = object
    x*: WindowPtr

proc `=destroy`(x: WindowPtrScopeWrapper) =
  if x.x != nil:
    debugEcho("Destroying window")
    x.x.destroy()

template sdlFailIf(condition: typed, reason: string) =
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )

template prExcept() =
  when not defined release:
    let ex = getCurrentException()
    debugEcho("NAME: " & $ex.name)
    debugEcho("MSG: " & $ex.msg)
    debugEcho("STACK TRACE:")
    for idx, ele in ex.trace:
      debugEcho($idx & "\t" & $ele)


proc main*() =
  const SCREEN_W = 640
  const SCREEN_H = 480
  const INIT_BITS = INIT_VIDEO or INIT_TIMER or INIT_EVENTS
  const GAME_TITLE = "Foo"
  const WINDOW_FLAGS = SDL_WINDOW_SHOWN

  #Init
  try:
    debugEcho("Outer")
    sdlFailIf(not sdl2.init(INIT_BITS)): "SDL2 init failed"

    #Window
    let window = WindowPtrScopeWrapper(x: createWindow(
        title = GAME_TITLE,
        x = SDL_WINDOWPOS_CENTERED,
        y = SDL_WINDOWPOS_CENTERED,
        w = SCREEN_W,
        h = SCREEN_H,
        flags = WINDOW_FLAGS
      ))
    debugEcho("Inner")
    let surface = window.x.getSurface()
    debugEcho(surface != nil)
    sdlFailIf(window.x != nil, "window no good")

    assert false

    debugEcho("Inner final")
  except AssertionDefect:
    prExcept()
  except SDLException:
    prExcept()
  finally:
    debugEcho("Outer final")
    sdl2.quit()