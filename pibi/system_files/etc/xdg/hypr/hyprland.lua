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
hl.bind("SUPER + E", hl.dsp.exec_cmd("uwsm app -- dolphin"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("uwsm app -- helium"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    hl.bind("SUPER + " .. direction, hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }))
end

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("Print", hl.dsp.exec_cmd([[uwsm app -- sh -c 'geometry=$(slurp) && grim -g "$geometry" - | wl-copy']]))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })
