import std/math
import sdl2
import sdl2/image

type
  SDLException = object of Defect
  WindowPtrWrapper = object
    x*: WindowPtr
  RendererPtrWrapper = object
    x*: RendererPtr
  TexturePtrWrapper = object
    x*: TexturePtr

proc `=destroy`(x: WindowPtrWrapper) =
  if x.x != nil:
    x.x.destroy()

proc `=destroy`(x: RendererPtrWrapper) =
  if x.x != nil:
    x.x.destroy()

proc `=destroy`(x: TexturePtrWrapper) =
  if x.x != nil:
    x.x.destroy()

proc clearRender(renderer: RendererPtr) =
  renderer.setDrawColor(200, 200, 200)
  renderer.clear()

proc blit(renderer: RendererPtr, texture: TexturePtr, x, y: cint, angle: cdouble) =
  let rect: Rect = (x: x, y: y, w: 32, h: 32)
  texture.queryTexture(nil, nil, rect.w.addr, rect.h.addr)
  renderer.copyEx(texture, nil, rect.addr, angle, nil)

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
  const REND_FLAGS = Renderer_Accelerated
  const GAME_TITLE = "Foo"
  const WINDOW_FLAGS = SDL_WINDOW_SHOWN
  const TIME_STEP = 60

  #Init
  try:
    sdlFailIf(not sdl2.init(INIT_BITS)): "SDL2 init failed"

    #Window
    let window = WindowPtrWrapper(x: createWindow(
        title = GAME_TITLE,
        x = SDL_WINDOWPOS_CENTERED,
        y = SDL_WINDOWPOS_CENTERED,
        w = SCREEN_W,
        h = SCREEN_H,
        flags = WINDOW_FLAGS
    ))
    sdlFailIf(window.x == nil, "Window init failed")
    sdlFailIf(not sdl2.setHint(HINT_RENDER_SCALE_QUALITY, "linear"), "Set hint scale qual fail")
    let renderer = RendererPtrWrapper(x: createRenderer(
      window = window.x,
      index = -1,
      flags = REND_FLAGS
    ))
    sdlFailIf(renderer.x == nil, "Rend init failed")

    try:
      sdlFailIf(image.init() == 0, "Image init failed")

      let texture = TexturePtrWrapper(x: loadTexture(
        renderer = renderer.x,
        "./kenney_pixel-shmup/Ships/ship_0012.png"
      ))
      sdlFailIf(texture.x == nil, "Failed texture load")

      var isRunning = true
      var x,y: cint = 0
      var angle: cdouble = 0
      var angleFlag = false
      var currentTime = getTicks()
      var accumulator = 0.00
      while isRunning:
        var event = defaultEvent
        while pollEvent(event):
          case event.kind
          of QuitEvent:
            isRunning = false
            break
          of KeyDown:
            #x = (x + 2) mod 20
            #y = (y + 2) mod 20
            angleFlag = true
          of KeyUp:
            angleFlag = false
          else:
            discard

        let newTime = getTicks()
        var frameDelta = newTime - currentTime
        currentTime = newTime
        accumulator += (float)frameDelta
        debugEcho(accumulator)

        while accumulator >= TIME_STEP:
          debugEcho("Logic")
          if angleFlag: 
            let rotSpeed = 1.00 * TIME_STEP
            angle = (angle + rotSpeed) mod 360
          
          accumulator -= TIME_STEP

        renderer.x.clearRender()
        renderer.x.blit(texture.x, x, y, angle)
        renderer.x.present()


    finally:
      image.quit()
  except AssertionDefect:
    prExcept()
  except SDLException:
    prExcept()
  finally:
    debugEcho("Bye")
    sdl2.quit()