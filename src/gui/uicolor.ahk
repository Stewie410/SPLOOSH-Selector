; uicolor.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; UIColorForm GUI Definition

; Define
GuiUIColor() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: +ParentParent                                                             ; Define GUI as a child of Parent
    Gui, UIColorForm: +HWNDhUIColor                                                             ; Assign Window Handle to %hTopBar%
    Gui, UIColorForm: -Caption                                                                  ; Disable Titlebar
    Gui, UIColorForm: -Border                                                                   ; Disable Border
    Gui, UIColorForm: -DpiScale                                                                 ; Disable Windows Scaling
    Gui, UIColorForm: Margin, 0, 0                                                              ; Disable Margin
    Gui, UIColorForm: Color, %bg_form%                                                          ; Set Background Color
	Gui, UIColorForm: Font, s%fs_form% c%fg_form%, %ff_form%	                                ; Set font

    ; Define local variables
    local cx_items := 2                                                                         ; Number of items per row
    local cy_items := 11                                                                        ; Number of items per column
    local w_bg := w_form - (px_form * 2)                                                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                                                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)                                        ; Width of Text
    local w_ddl := w_text                                                                       ; Width of DropDownList
    local w_check := w_text                                                                     ; CheckBox width
    local w_tree := w_text                                                                      ; TreeView width
    local w_edit := w_text                                                                      ; Edit width
    local h_bg := h_form - (py_form * 2)                                                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                                                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)                                        ; Height of Text
    local h_check := h_text                                                                     ; CheckBox height
    local h_tree := h_text                                                                      ; TreeView height
    local h_edit := h_text                                                                      ; Edit height
    local r_edit := 1                                                                           ; Edit rows
    local lo_count := 1                                                                         ; Minimum Count Value
    local hi_count := 5                                                                         ; Maximum Count Value
    local x_bg := px_form * 0.75                                                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                                                       ; Inner-X of BG (offset)
    local a_x := buildPosArray(cy_items, cx_items, x_inner, w_inner, px_form, 5)                ; x positions
    local y_bg := py_form                                                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                                                     ; Inner-Y of BG (offset)
    local a_y := buildPosArray(cy_items, cy_items, y_inner, h_inner, py_form, 3)                ; y positions
    local o_color := getObjNamesAsString(l_uicolors, "|")                                       ; color options
    local def_color := getDefaultObject(l_uicolors)                                             ; default color selection
    local def_combo1 := var_combo_color_1                                                       ; default combo color 1
    local def_combo2 := var_combo_color_2                                                       ; default combo color 2
    local def_combo3 := var_combo_color_3                                                       ; default combo color 3
    local def_combo4 := var_combo_color_4                                                       ; default combo color 4
    local def_combo5 := var_combo_color_5                                                       ; default combo color 5
    local def_slborder := var_slider_border_color                                               ; default sliderborder color
    local def_sltrack := var_slider_track_color                                                 ; default slidertrack color
    local formBG := d_asset "\formBG.png"                                                       ; Form Background

    ; Sort Options Alphabetically
    Sort, o_color, CL D|

    ; Determine default choices
    def_color := getIndexOfSubstringInString(o_color, def_color, "|")

    ; Add Background to GUI
    Gui, UIColorForm: Add, Picture, % "x" x_bg " y" y_bg " w" w_bg " h" h_bg " +" SS_CENTERIMAGE, %formBG%

    ; Add labels to GUI
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", COLOR:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", INSTAFADE:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[3] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", COMBO COUNT:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[4] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", COMBO COLOR 1:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[5] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorComboColor2Text", COMBO COLOR 2:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[6] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorComboColor3Text", COMBO COLOR 3:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[7] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorComboColor4Text", COMBO COLOR 4:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[8] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorComboColor5Text", COMBO COLOR 5:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[9] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", Sliderborder:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[10] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", Slidertrack:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[11] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", Skin.ini:
    
    ; Hidden Checkboxes
    Gui, UIColorForm: Add, CheckBox, w15 h15 -Wrap +vUIColorOptionInstafade Checked0 +Disabled +Hidden1
    Gui, UIColorForm: Add, Text, % "x" a_x[2] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorOptionInstafadeDisabled +gToggleUIColorOptionInstafade", Disable
    Gui, UIColorForm: Add, Text, % "x" a_x[2] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorOptionInstafadeEnabled +gToggleUIColorOptionInstafade +Hidden1", Enable
    Gui, UIColorForm: Add, CheckBox, w15 h15 -Wrap +vUIColorOptionSaveIni Checked0 +Disabled +Hidden1
    Gui, UIColorForm: Add, Text, % "x" a_x[2] " y" a_y[11] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +gToggleUIColorOptionSaveIni +vUIColorOptionSaveIniOverwrite", Overwrite
    Gui, UIColorForm: Add, Text, % "x" a_x[2] " y" a_y[11] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +gToggleUIColorOptionSaveIni +vUIColorOptionSaveIniPreserve +Hidden1", Preserve

    ; Add controls to GUI
    Gui, UIColorForm: Font, s%fs_input% c%fg_input%, %ff_input% ; Font for Edit Box
    Gui, UIColorForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " +Choose" def_color " +vUIColorOptionColor +gGetUIColorComboSliderColors", %o_color%
    Gui, UIColorForm: Add, Edit, % "x" a_x[2] " y" a_y[3] " w" w_edit " h" h_edit " r" r_edit " +Number -Wrap +vUIColorComboColorCount +gToggleUIColorOptionComboCount +BackgroundFFFFFF"
    Gui, UIColorForm: Add, UpDown, % "+Range" lo_count "-" hi_count, 1
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[4] " w" w_tree " h" h_tree " +Background" def_combo1 " +" SS_CENTERIMAGE " +ReadOnly +vUIColorComboColor1 +gChangeComboColor1 +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[5] " w" w_tree " h" h_tree " +Background" def_combo2 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor2 +gChangeComboColor2 +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[6] " w" w_tree " h" h_tree " +Background" def_combo3 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor3 +gChangeComboColor3 +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[7] " w" w_tree " h" h_tree " +Background" def_combo4 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor4 +gChangeComboColor4 +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[8] " w" w_tree " h" h_tree " +Background" def_combo5 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor5 +gChangeComboColor5 +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[9] " w" w_tree " h" h_tree " +Background" def_slborder " +" SS_CENTERIMAGE " +ReadOnly +vUIColorSliderborderColor +gChangeSliderborderColor +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[10] " w" w_tree " h" h_tree " +Background" def_sltrack " +" SS_CENTERIMAGE " +ReadOnly +vUIColorSlidertrackColor +gChangeSlidertrackColor +AltSubmit"

    ; Initialize
    ToggleUIColorOptionSaveIni()
    ToggleUIColorOptionComboCount()
}

; Toggle UICoplorOptionInstafade state
ToggleUIColorOptionInstafade() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    local state := UIColorOptionInstafade = 0 ? 1 : 0                                           ; Get New-State of Checkbox
    GuiControl, UIColorForm:, UIColorOptionInstafade, %state%                                   ; Update Checkbox Value
    GuiControl, % ((state) ? "Show" : "Hide"), UIColorOptionInstafadeEnabled                    ; Show/Hide the "Enabled" label
    GuiControl, % ((state) ? "Hide" : "Show"), UIColorOptionInstafadeDisabled                   ; Show/Hide the "Disabled" label
}

; Toggle UIColorOptionSaveIni state
ToggleUIColorOptionSaveIni() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    local state := UIColorOptionSaveIni = 0 ? 1 : 0                                             ; Get New-State of Checkbox
    GuiControl, UIColorForm:, UIColorOptionSaveIni, %state%                                     ; Update Checkbox Value
    GuiControl, % ((state) ? "Show" : "Hide"), UIColorOptionSaveIniOverwrite                    ; Show/Hide the "Overwrite" label
    GuiControl, % ((state) ? "Hide": "Show"), UIColorOptionSaveIniPreserve                      ; Show/Hide the "Preserve" label
    updateUIColorColors(!state)                                                                 ; Update UI Colors
    updateTreeViewBackground()                                                                  ; Update Color Previews
}

; Toggle ComboColor[x] & Labels based on selected combo count
ToggleUIColorOptionComboCount() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    updateComboColorVisibility(UIColorComboColorCount)                                          ; Update Visibility
}

; Get Combo/Slider Colors by UIColor Option
GetUIColorComboSliderColors() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    updateUIColorColors(!UIColorOptionSaveIni)                                                  ; Update selected UIColors
    updateTreeViewBackground()                                                                  ; Update Combo Colors
}

; Get ComboColor[0]
ChangeComboColor1() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_1)                                       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 1                                                                       ; Set flag for which TreeView to update
}

; Get ComboColor[1]
ChangeComboColor2() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_2)                                       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 2                                                                       ; Set flag for which TreeView to update
}

; Get ComboColor[2]
ChangeComboColor3() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_3)                                       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 3                                                                       ; Set flag for which TreeView to update
}

; Get ComboColor[3]
ChangeComboColor4() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_4)                                       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 4                                                                       ; Set flag for which TreeView to update
}

; Get ComboColor[4]
ChangeComboColor5() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_5)                                       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 5                                                                       ; Set flag for which TreeView to update
}

; Get Sliderborder Color
ChangeSliderborderColor() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_slider_border_color)                                 ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 6                                                                       ; Set flag for which TreeView to update
}

; Get SliderTrack Color
ChangeSlidertrackColor() {
    global                                                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_slider_track_color)                                  ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker                                        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                                                       ; Disable all other controls
    var_picker_count := 7                                                                       ; Set flag for which TreeView to update
}


; Get selected UI Colors
updateUIColorColors(init) {
    global                                                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local ui_select := UIColorOptionColor                                                       ; Get the selected UI Color
    local colorPath := "none"                                                                   ; Get the path to the selected UI Color
    local a_combo := []                                                                         ; Combo Colors
    local a_slider := []                                                                        ; Slider Colors

    ; Update colorPath if not initial call
    if (!init) {
        for k, v in l_uicolors {
            if (v.name = ui_select) {
                colorPath := d_conf "\" v.uicolorDir "\" v.dir
                break
            }
        }
    }
    
    ; Get selected UI Color colors
    loop, 5
        a_combo.push(getSkinColorElement("combo", colorPath, A_Index))
    a_slider.push(getSkinColorElement("border", colorPath))
    a_slider.push(getSkinColorElement("track", colorPath))

    ; If Colors were pulled, update global vars -- otherwise, assume "Combo1" as default
    var_combo_color_1 := a_combo[1]
    var_combo_color_2 := (a_combo[2]) ? a_combo[2] : var_combo_color_1
    var_combo_color_3 := (a_combo[3]) ? a_combo[3] : var_combo_color_1
    var_combo_color_4 := (a_combo[4]) ? a_combo[4] : var_combo_color_1
    var_combo_color_5 := (a_combo[5]) ? a_combo[5] : var_combo_color_1

    ; Update Slider colors if pulled from file
    var_slider_border_color := a_slider[1]
    var_slider_track_color := a_slider[2]
}

; Update Bacground Colors of TreeView Elements
updateTreeViewBackground() {
    global                                                                                      ; Set global scope inside function

    ; Update Background Colors
    try {
        ; Update ComboColorN Background Colors
        for k, v in [var_combo_color_1, var_combo_color_2, var_combo_color_3, var_combo_color_4, var_combo_color_5] {
            GuiControl, UIColorForm: +BackgroundDefault, % "UIColorComboColor" . k
            GuiControl, % "UIColorForm: +Background" . v, % "UIColorComboColor" . k
        }

        ; Update Slider Border Background Color
        GuiControl, UIColorForm: +BackgroundDefault, UIColorSliderborderColor
        GuiControl, % "UIColorForm: +Background" var_slider_border_color, UIColorSliderborderColor

        ; Update Slider Track Background Color
        GuiControl, UIColorForm: +BackgroundDefault, UIColorSlidertrackColor
        GuiControl, % "UIColorForm: +Background" var_slider_track_color, UIColorSlidertrackColor
    } catch e {
        OutputDebug, %A_Now%: Failed to update TreeView Backgrounds in UIColorForm`n%e%
    }
}

; Hide ComboColor[2-5] Controls & Labels
hideComboColorOptions() {
    global                                                                                      ; Set global scope inside function
    for k, v in [2, 3, 4, 5] {
        GuiControl, Hide, % "UIColorComboColor" . v                                             ; Hide Control
        GuiControl, Hide, % "UIColorComboColor" . v . "Text"                                    ; Hide Label
    }
}

; Toggle Visibility of Combo Colors [2-5]
updateComboColorVisibility(cnt) {
    global                                                                                      ; Set global scope inside function
    
    hideComboColorOptions()                                                                     ; Hide ComboColor[2-5] Options
    if (cnt <= 1)
        return                                                                                  ; If no additional controls requested, break
    
    loop, %cnt% {
        if (A_Index = 1)
            continue                                                                            ; Skip the first run of this loop
        GuiControl, Show, % "UIColorComboColor" . A_Index                                       ; Display all Controls from 2 to $cnt
        GuiControl, Show, % "UIColorComboColor" . A_Index . "Text"                              ; Display all Labels from 2 to $cnt
    }
}