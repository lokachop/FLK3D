function love.conf(t)
    t.version = "11.4"
    t.window.title = "FLK3D"
    t.window.borderless = false
    t.window.width = 256 * 3
    t.window.height = 192 * 3
    t.window.vsync = 1
    t.console = true
    t.modules.joystick = false
end