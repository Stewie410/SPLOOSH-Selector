; writer.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Writing or Modifying skin.ini

; Remove Combo Colors [2-5] from skin.ini
removeComboColors(cnt) {
    global                                                                                      ; Set scope to global

    ; Define local variables
    local file_ini := GamePath "\Skins\" getDirectoryName(n_skin, GamePath "\Skins") "\skin.ini"    ; Define the path to the current skin.ini
    
    ; Remove Combo Color from Skin.ini
    try {
        IniDelete, %file_ini%, Colours, % "Combo" cnt
    } catch e {
        OutputDebug, %A_Now%: Failed to remove Combo%cnt% from skin.ini`n%e%
    }
}

; Update ComboColor [1-5] in skin.ini
updateComboColor(cnt, hex_color) {
    global                                                                                      ; Set scope to global

    ; Define local variables
    local file_ini := GamePath "\Skins\" getDirectoryName(n_skin, GamePath "\Skins") "\skin.ini"    ; Define the path to the current skin.ini
    local rgb_color := hexToRGB(hex_color)                                                      ; RGB equivalent to hex_color
    local start := TF_Find(file_ini,,,"Combo" cnt)                                              ; Determine line number containing the ComboColor

    ; If a starting line wasn't determined
    if (!start) {
        start := TF_Find(file_ini,,,"Combo" (cnt - 1)) + 1                                      ; Get the previous color's line, and add 1

        ; Insert the ComboColor line
        TF_InsertLine("!" file_ini, start, start, "Combo" cnt ": " Format("{:d},{:d},{:d}", rgb_color*))

    ; If a starting line was determined
    } else {
        ; Replace that line with the updated color
        TF_ReplaceLine("!" file_ini, start, start, "Combo" cnt ": " Format("{:d},{:d},{:d}", rgb_color*))
    }
}

; Update Slider Border/Track Color in skin.ini
updateSliderColor(part, hex_color) {
    global                                                                                      ; Set scope to global

    ; Define local variables
    local file_ini := GamePath "\Skins\" getDirectoryName(n_skin, GamePath "\Skins") "\skin.ini"    ; Define the path to the current skin.ini
    local rgb_color := hexToRGB(hex_color)                                                      ; RGB equivalent to hex_color
    local start                                                                                 ; Line number to modify

    ; Update Slider Color values
    for k, v in ["SliderBorder", "SliderTrackOverride"] {
        if (InStr(v, part)) {                                                                     ; If $part is in element (case insensitive)
            start := TF_Find(file_ini,,, v ":")                                                 ; Get line number containing key
            if (start)                                                                          ; If key was found, replace the line
                TF_ReplaceLine("!" file_ini, start, start, v ": " Format("{:d},{:d},{:d}", rgb_color*))
            break
        }
    }
}

; Update Instant-Fade Hitircles in skin.ini
updateHitcircleOverlap(overlap := 3) {
    global                                                                                      ; Set scope to global

    ; Define local variables
    local file_ini := GamePath "\Skins\" getDirectoryName(n_skin, GamePath "\Skins") "\skin.ini"    ; Define the path to the current skin.ini
    local rgb_color := hexToRGB(hex_color)                                                      ; RGB equivalent to hex_color
    local start := TF_Find(file_ini,,, "HitCircleOverlap:")                                     ; Line number to modify

    ; If Line not found, abort
    if (!start) {
        OutputDebug, %A_Now%: Failed to locate HitCircleOverlap key in skin.ini
        return
    }

    ; Update Instafade Value
    TF_ReplaceLine("!" file_ini, start, start, "HitCircleOverlap: " overlap)
}