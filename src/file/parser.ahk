; parser.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Reading or Parsing skin.ini

; Get a color from the skin.ini
getSkinColorElement(str_type, path, cnt := 0) {
    global                                                                                      ; Declare global scope inside function

    ; Define local variables
    local dir_path := GamePath "\Skins\" getDirectoryName(n_skin, GamePath "\Skins")            ; Get path to skin
    local file_ini := dir_path "\" path "\skin.ini"                                             ; UIColor skin.ini
    local rgb_color := []                                                                       ; RGB Color Value
    local start                                                                                 ; Line number to read

    ; If $path === "none", then use current skin.ini
    if (InStr(path, "none"))
        file_ini := dir_path "\skin.ini"

    ; Get ColorType
    for k, v in ["Combo" cnt, "SliderBorder", "SliderTrackOverride"] {
        if (InStr(v, str_type)) {
            if ((v = "Combo" cnt) && (!cnt))
                break
            start := TF_Find(file_ini,,, v ":")
            if (start)
                rgb_color := StrSplit(RegExReplace(TF_ReadLines("!" file_ini, start, start, 1), ")^[^:]*:\s*(.*).*$", "$1"), ",") 
            break
        }
    }

    ; if $rgb_color is defined, return the hex color; else return empty string
    return (rgb_color.MaxIndex()) ? rgbToHex(rgb_color) : ""
}