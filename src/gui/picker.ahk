; GuiColorPicker.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; ColorPicker GUI Definition

; Define
GuiColorPicker(w := 600, h := 600, hex := "FFFFFF") {
    global                                                                                      ; Set global Scope inside Function
    local w_picker := w                                                                         ; picker width
    local w_palette := w_picker                                                                 ; palette width
    local w_panel := w_picker                                                                   ; panel width
    local h_picker := h                                                                         ; picker height
    local h_palette := h_picker / 1.35                                                          ; palette height
    local h_panel := h_picker - h_palette                                                       ; panel height
    local x_palette := 0                                                                        ; X Position of Palette
    local x_panel := 0                                                                          ; X Position of Panel
    local y_palette := 0                                                                        ; Y Position of Palette
    local y_panel := h_palette                                                                  ; Y Position of Palette
    local px_panel := 10                                                                        ; horizontal padding on panel
    local py_panel := 10                                                                        ; vertical padding on panel
    local bg_picker := bg_form                                                                  ; Picker background color
    local fg_picker := fg_form                                                                  ; Picker foreground color
    local ff_picker := ff_input                                                                 ; Picker Font face
    local fs_picker := 15                                                                       ; Picker Font size
    local n_picker := n_app ": Color Picker"                                                    ; Picker Name
    local img_palette := d_asset "\hsbImg.png"                                                  ; Palette Image
    
    local cx_items := 5                                                                         ; Number of items per row
    local cy_items := 2                                                                         ; Number of items per column
    local w_text := (w_panel / cx_items) - (px_panel * 2)                                       ; text width
    local w_edit := w_text / 1.5                                                                ; edit width
    local w_button := w_text / 1                                                                ; button width
    local w_tree := w_text                                                                      ; TreeView width
    local h_text := (h_panel / cy_items) - (py_panel * 2)                                       ; text height
    local h_edit := h_text                                                                      ; edit height
    local h_button := h_text                                                                    ; button height
    local h_tree := h_text                                                                      ; TreeView height
    local r_edit := 1                                                                           ; edit rows
    local a_x := []                                                                             ; x positions on panel
    local a_y := []                                                                             ; y positions on panel
    local lo_rgb := 0                                                                           ; rgb floor
    local hi_rgb := 255                                                                         ; rgb ceiling
    local def_rgb := hexToRGB(hex)                                                              ; Array of RGB values
    local def_preview := var_picker_hover_color                                                 ; default preview color
    local def_selected := var_picker_selected_color                                             ; default selected color

    ; Add positions to x/y arrays
    Loop, %cx_items%
    {
        if (A_Index = 1) {
            a_x.push(px_panel)
            a_y.push(py_panel + h_palette)
        } else {
            a_x.push(((w_panel / cx_items) * A_Index) - (w_panel / cx_items) - (px_panel * 1))
            a_y.push(((h_panel / cy_items) * A_Index) - (h_panel / cy_items) + ((py_panel * 0) + h_palette))
        }
    }

    ; Define the GUI's Parameters
    Gui, ColorPicker: +HWNDhColorPicker -Resize +OwnerParent
    Gui, ColorPicker: Margin, 0, 0
    Gui, ColorPicker: Color, %bg_picker%
    Gui, ColorPicker: Font, s%fs_picker% c%fg_picker%, %ff_picker%

    ; Add Labels to the GUI
    Gui, ColorPicker: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, R
    Gui, ColorPicker: Add, Text, % "x" a_x[2] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, G
    Gui, ColorPicker: Add, Text, % "x" a_x[3] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, B
    Gui, ColorPicker: Add, Text, % "x" a_x[4] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, COLOR

    ; Add Controls to the GUI
    Gui, ColorPicker: Add, Picture, % "x" x_palette " y" y_palette " w" w_palette " h" h_palette " +" SS_CENTERIMAGE " +HWNDhColorPickerPalette +gColorPickerSelectColor +AltSubmit", %img_palette%
    Gui, ColorPicker: Add, TreeView, % "x" a_x[4] " y" a_y[2] " w" w_tree " h" h_tree " +Background" def_selected " +" SS_CENTERIMAGE " +ReadOnly +vColorPickerSelectedColor +Background" hex
    Gui, ColorPicker: Add, Button, % "x" a_x[5] " y" a_y[2] " w" w_button " h" h_button " +gColorPickerSubmitForm", &SELECT

    ; Add writable Edits to the GUI
    Gui, ColorPicker: Font, s%fs_picker% c000000, %ff_picker%
    Gui, ColorPicker: Add, Edit, % "x" a_x[1] " y" a_y[2] " w" w_edit " h" h_edit " r" r_edit " +Number -Wrap +vColorPickerRGBRed +BackgroundFFFFFF +gColorPickerModifyRed"
    Gui, ColorPicker: Add, UpDown, % "+Range" lo_rgb "-" hi_rgb " +gColorPickerModifyRed", % def_rgb[1]
    Gui, ColorPicker: Add, Edit, % "x" a_x[2] " y" a_y[2] " w" w_edit " h" h_edit " r" r_edit " +Number -Wrap +vColorPickerRGBGreen +BackgroundFFFFFF +gColorPickerModifyRed"
    Gui, ColorPicker: Add, UpDown, % "+Range" lo_rgb "-" hi_rgb " +gColorPickerModifyGreen", % def_rgb[2]
    Gui, ColorPicker: Add, Edit, % "x" a_x[3] " y" a_y[2] " w" w_edit " h" h_edit " r" r_edit " +Number -Wrap +vColorPickerRGBBlue +BackgroundFFFFFF +gColorPickerModifyRed"
    Gui, ColorPicker: Add, UpDown, % "+Range" lo_rgb "-" hi_rgb " +gColorPickerModifyBlue", % def_rgb[3]
}

; Select Color from Palette
ColorPickerSelectColor() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                                                            ; Get vVar values without hiding GUI
    var_picker_selected_color := var_picker_hover_color                                         ; Set selected color to current color
    updateColorPickerSelectedColor()                                                            ; Update Preview Color
    updateColorPickerRGB()                                                                      ; Update RGB values
}

; Modify $red value (RGB)
ColorPickerModifyRed() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                                                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                                                            ; Update Preview Color
}

; Modify $green value (RGB)
ColorPickerModifyGreen() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                                                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                                                            ; Update Preview Color
}

; Modify $blue value (RGB)
ColorPickerModifyBlue() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                                                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                                                            ; Update Preview Color
}

; Submit Form
ColorPickerSubmitForm() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Destroy                                                                   ; Close ColorPicker
    toggleParentWindow(1) 

    ; Update Selected Color Var
    if (var_picker_count = 7) {                                                                 ; If $PickerCount == 7
        var_slider_track_color := var_picker_selected_color                                     ; Update $SliderTrack color
    } else if (var_picker_count = 6) {                                                          ; If $PickerCount == 6
        var_slider_border_color := var_picker_selected_color                                    ; Update $SliderBorder color
    } else {                                                                                    ; Otherwise
        var_combo_color_%var_picker_count% := var_picker_selected_color                         ; Update $ComboColorN color
    }

    ; Update BG Colors
    updateTreeViewBackground()
}

; Update Preview Color
updateColorPickerSelectedColor() {
    global                                                                                      ; Set global Scope inside Function
    GuiControl, ColorPicker: +BackgroundDefault, ColorPickerSelectColor                         ; Remove Previous BG color to remove colored borders
    GuiControl, % "ColorPicker: +Background" var_picker_selected_color, ColorPickerSelectedColor
}

; Update RGB Values
updateColorPickerRGB() {
    global                                                                                      ; Set global Scope inside Function
    local a_rgb := hexToRGB(var_picker_selected_color)                                          ; Convert Selected HEX to RGB array
    try {
        for k, v in ["Red", "Green", "Blue"]
            GuiControl, ColorPicker:, ColorPickerRGB%v%, % a_rgb[k]                             ; Update Color Picker's RGB Values
    } catch e {
        OutputDebug, %A_Now%: Failed to update ColorPicker RGB Values`n%e% 
    }
}

; Get Color at mouse position
getCoordinateColor(x, y) {
    ; Get and format color
    PixelGetColor, out, x, y, RGB
    StringRight, out, out, 6
    SetFormat, IntegerFast, hex
    SetFormat, IntegerFast, D

    ; return out
    return out
}