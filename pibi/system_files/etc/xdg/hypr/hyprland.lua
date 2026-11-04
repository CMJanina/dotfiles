hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
    input = { kb_layout = "us", follow_mouse = 1 },
    general = {
        layout = "dwindle",
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = { active_border = "rgb(c7c7c7)", inactive_border = "rgb(444444)" },
    },
    dwindle = { preserve_split = true },
    decoration = { rounding = 4 },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})

hl.on("hyprland.start", function ()
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("uwsm app -- mako")
    hl.exec_cmd("uwsm app -- hypridle")
end)

hl.bind("SUPER + Return", hl.dsp.exec_cmd("uwsm app -- ghostty"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("uwsm app -- wofi --show drun"))
hl.bind("SUPER + CTRL + E", hl.dsp.exec_cmd("uwsm app -- dolphin"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("uwsm app -- helium"))
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + CTRL + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + CTRL + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd([[uwsm app -- sh -c 'choice=$(printf "Cancel\nLog out\n" | wofi --dmenu --prompt "Log out?" --lines 2 --cache-file /dev/null) && [ "$choice" = "Log out" ] && uwsm stop']]))
hl.bind("CTRL + left", hl.dsp.focus({ workspace = "m-1" }))
hl.bind("CTRL + right", hl.dsp.focus({ workspace = "m+1" }))

local function snapHalf(direction)
    local window = hl.get_active_window()
    local monitor = window and window.monitor
    if not monitor then return end

    local reserved = monitor.reserved
    -- Mode dimensions already account for scaling and rotation.
    local width = monitor.mode.width - reserved.left - reserved.right
    local height = monitor.mode.height - reserved.top - reserved.bottom
    local x = monitor.x + reserved.left
    local y = monitor.y + reserved.top
    if direction == "left" or direction == "right" then
        local half = math.floor(width / 2)
        if direction == "right" then
            x = x + half
            width = width - half
        else
            width = half
        end
    else
        local half = math.floor(height / 2)
        if direction == "down" then
            y = y + half
            height = height - half
        else
            height = half
        end
    end

    local border = hl.get_config("general:border_size")
    hl.dispatch(hl.dsp.window.fullscreen_state({ window = window, internal = 0, client = 0, layout_aware = false }))
    hl.dispatch(hl.dsp.window.float({ window = window, action = "enable" }))
    hl.dispatch(hl.dsp.window.resize({ window = window, x = width - 2 * border, y = height - 2 * border }))
    hl.dispatch(hl.dsp.window.move({ window = window, x = x + border, y = y + border }))
end

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    hl.bind("SUPER + CTRL + " .. direction, hl.dsp.focus({ direction = direction }))
    hl.bind("CTRL + ALT + " .. direction, function() snapHalf(direction) end)
end
hl.bind("CTRL + ALT + SUPER + left", hl.dsp.window.move({ monitor = "-1" }))
hl.bind("CTRL + ALT + SUPER + right", hl.dsp.window.move({ monitor = "+1" }))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind("SUPER + ALT + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind("SUPER + ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
local copyRegion = hl.dsp.exec_cmd([[uwsm app -- sh -c 'geometry=$(slurp) && grim -g "$geometry" - | wl-copy']])
hl.bind("Print", copyRegion)
hl.bind("SUPER + SHIFT + 4", copyRegion)
hl.bind("SUPER + SHIFT + 3", hl.dsp.exec_cmd([[uwsm app -- sh -c 'grim - | wl-copy']]))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })
