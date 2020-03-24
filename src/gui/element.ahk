; GuiFormElement.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; ElementForm GUI Definition

; Define
GuiElement() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ElementForm: +ParentParent                                                             ; Define GUI as a child of Parent
    Gui, ElementForm: +HWNDhElement                                                             ; Assign Window Handle to %hTopBar%
    Gui, ElementForm: -Caption                                                                  ; Disable Titlebar
    Gui, ElementForm: -Border                                                                   ; Disable Border
    Gui, ElementForm: -DpiScale                                                                 ; Disable Windows Scaling
    Gui, ElementForm: Margin, 0, 0                                                              ; Disable Margin
    Gui, ElementForm: Color, %bg_form%                                                          ; Set Background Color
	Gui, ElementForm: Font, s%fs_form% c%fg_form%, %ff_form%	                                ; Set font

    ; Define local variables
    local cx_items := 2                                                                         ; Number of Items per Row
    local cy_items := 5                                                                         ; Number of Items per column
    local w_bg := w_form - (px_form * 2)                                                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                                                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)                                        ; Width of Text
    local w_ddl := w_text                                                                       ; Width of DropDownList
    local w_check := w_text
    local h_bg := h_form - (py_form * 2)                                                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                                                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)                                        ; Height of Text
    local h_check := h_text                                                                     ; CheckBox Height
    local x_bg := px_form * 0.75                                                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                                                       ; Inner-X of BG (offset)
    local a_x := []                                                                             ; x positions
    local y_bg := py_form                                                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                                                     ; Inner-Y of BG (offset)
    local a_y := []                                                                             ; y positions
    local o_element := menu_element_types                                                       ; Element Options
    local o_mania := menu_mania_types                                                           ; Mania Options
    local o_cursor := getObjNamesAsString(l_cursors, "|")                                       ; Cursor Options
    local o_ctrail := "None|" . o_cursor                                                        ; Cursor Trail Options
    local o_csmoke := o_cursor                                                                  ; Cusror Smoke Options
    local o_hitburst := getObjNamesAsString(l_hitbursts, "|")                                   ; Hitburst Options
    local o_revarrow := getObjNamesAsString(l_reversearrows, "|")                               ; ReverseArrow Options
    local o_sliderball := getObjNamesAsString(l_sliderballs, "|")                               ; Sliderball Options
    local o_scorebarbg := getObjNamesAsString(l_scorebarbgs, "|")                               ; ScorebarBG Options
    local o_circlenumbers := getObjNamesAsString(l_circlenumbers, "|")                          ; CircleNumber Options
    local o_hitsounds := getObjNamesAsString(l_hitsounds, "|")                                  ; Hitsound Pack Options
    local o_followpoints := getObjNamesAsString(l_followpoints, "|")                            ; FollowPoint Options
    local o_mania_arrow_color := getObjNamesAsString(l_maniaarrows, "|")                        ; ManiaArrow Color Options
    local o_mania_bar_color := getObjNamesAsString(l_maniabars, "|")                            ; ManiaBar Color Options
    local o_mania_dot_color := getObjNamesAsString(l_maniadots, "|")                            ; ManiaDot Color Options
    local def_cursor := getDefaultObject(l_cursors)                                             ; Default Cursor Selection
    local def_ctrail := def_cursor                                                              ; Default CursorTrail Color Selection
    local def_csmoke := def_cursor                                                              ; Default CusorSmoke Color Selection
    local def_hitburst := getDefaultObject(l_hitbursts)                                         ; Default Hitburst Selection
    local def_revarrow := getDefaultObject(l_reversearrows)                                     ; Default ReverseArrow Selection
    local def_sliderball := getDefaultObject(l_sliderballs)                                     ; Default Sliderball Selection
    local def_scorebarbg := getDefaultObject(l_scorebarbgs)                                     ; Default ScorebarBG Selection
    local def_circlenumber := getDefaultObject(l_circlenumbers)                                 ; Default CircleNumber Selection
    local def_hitsound := getDefaultObject(l_hitsounds)                                         ; Default Hitsound Pack Selection
    local def_followpoint := getDefaultObject(l_followpoints)                                   ; Default FollowPoint Selection
    local def_mania := 1                                                                        ; Default Mania
    local def_mania_color := 1                                                                  ; Default mania Color 
    local formBG := d_asset "\formBG.png"                                                       ; Form Background

    ; Add positions to x/y arrays
    a_x := buildPosArray(cy_items, cx_items, x_inner, w_inner, px_form, 5)
    a_y := buildPosArray(cy_items, cy_items, y_inner, h_inner, py_form, 4)
    
    ; Sort Options Alphabetically
    Sort, o_cursor, CL D|
    Sort, o_ctrail, CL D|
    Sort, o_csmoke, CL, D|
    Sort, o_hitburst, CL D|
    Sort, o_revarrow, CL D|
    Sort, o_sliderball, CL D|
    Sort, o_scorebarbg, CL D|
    Sort, o_circlenumbers, CL D|
    Sort, o_hitsounds, CL D|
    Sort, o_followpoints, CL D|
    Sort, o_mania_arrow_color, CL D|
    Sort, o_mania_bar_color, CL D|
    Sort, o_mania_dot_color, CL D|

    ; Determine default choices
    def_cursor := getIndexOfSubstringInString(o_cursor, def_cursor, "|")
    def_csmoke := getIndexOfSubstringInString(o_csmoke, def_csmoke, "|")
    def_ctrail := getIndexOfSubstringInString(o_ctrail, def_ctrail, "|")
    def_hitburst := getIndexOfSubstringInString(o_hitburst, def_hitburst, "|")
    def_revarrow := getIndexOfSubstringInString(o_revarrow, def_revarrow, "|")
    def_sliderball := getIndexOfSubstringInString(o_sliderball, def_sliderball, "|")
    def_scorebarbg := getIndexOfSubstringInString(o_scorebarbg, def_scorebarbg, "|")
    def_circlenumber := getIndexOfSubstringInString(o_circlenumbers, def_circlenumber, "|")
    def_hitsound := getIndexOfSubstringInString(o_hitsounds, def_hitsound, "|")
    def_followpoint := getIndexOfSubstringInString(o_followpoints, def_followpoint, "|")

    ; Add Background to GUI
    Gui, ElementForm: Add, Picture, % "x" x_bg " y" y_bg " w" w_bg " h" h_bg " +" SS_CENTERIMAGE, %formBG%

    ; Add Labels to GUI
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", ELEMENT:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionColorText", COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vOtherElementOptionTypeText +Hidden1", TYPE:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[3] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionTrailText", TRAIL COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[3] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vOtherElementOptionColorText +Hidden1", COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[4] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionSmokeText", SMOKE COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[5] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionTrailSolidText", SOLID TRAIL:

	; Hidden Checkboxes
    Gui, ElementForm: Add, CheckBox, w15 h15 -Wrap +vCursorElementOptionTrailSolid Checked +Disabled +Hidden1
    Gui, ElementForm: Add, Text, % "x" a_x[2] " y" a_y[5] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionTrailSolidEnabled +gToggleCursorElementOptionTrailSolid", Enable
    Gui, ElementForm: Add, Text, % "x" a_x[2] " y" a_y[5] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionTrailSolidDisabled +gToggleCursorElementOptionTrailSolid +Hidden1", Disable

    ; Add Controls to GUI
    Gui, ElementForm: Font, s%fs_input% c%fg_input%, %ff_input% ; Font for Edit Box
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " +gGetElementType +vElementType +Sort", %o_element%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_cursor " +vCursorElementOptionColor", %o_cursor%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_hitburst " +vHitburstElementOptionType +Hidden1", %o_hitburst%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_revarrow " +vReverseArrowElementOptionType +Hidden1", %o_revarrow%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_sliderball " +vSliderballElementOptionType +Hidden1", %o_sliderball%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_scorebarbg " +vScorebarBGElementOptionType +Hidden1", %o_scorebarbg%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_circlenumber " +vCircleNumbersElementOptionType +Hidden1", %o_circlenumbers%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_hitsound " +vHitsoundsElementOptionType +Hidden1", %o_hitsounds%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_followpoint " +vFollowPointElementOptionType +Hidden1", %o_followpoints%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_mania " +gGetElementManiaType +vManiaElementOptionType +Hidden1", %o_mania%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[3] " w" w_ddl " +Choose" def_ctrail " +vCursorElementOptionTrail +gCheckCursorTrailSolidState", %o_ctrail%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[3] " w" w_ddl " +Choose1 +vManiaElementArrowOptionColor +Hidden1", %o_mania_arrow_color%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[3] " w" w_ddl " +Choose1 +vManiaElementBarOptionColor +Hidden1", %o_mania_bar_color%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[3] " w" w_ddl " +Choose1 +vManiaElementDotOptionColor +Hidden1", %o_mania_dot_color%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[4] " w" w_ddl " +Choose" def_csmoke " +vCursorElementOptionSmoke", %o_csmoke%

    ; Update Element Form
    GetElementType()
}

; Get Element Options
GetElementType() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    toggleElementForm(ElementType)                                                              ; Display ElementOptions, if any
}

; Get Mania Options 
GetElementManiaType() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    toggleManiaForm(ManiaElementOptionType)                                                     ; Display ElementOptions, if any
}

; Toggle State of CursorTrailSolid based on CursorTrail DDL Choice
CheckCursorTrailSolidState() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    toggleCursorTrailSolidState(CursorElementOptionTrail)                                       ; Toggle state of CursorTrailSolid based on CursorTrail DDL Choice
}

; Toggle CursorElementOptionTrailSolid state (workaround for checkbox labels)
ToggleCursorElementOptionTrailSolid() {
    global                                                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    local state := (!InStr(CursorElementOptionTrail, "none")) ? (!CursorElementOptionTrailSolid) : 0    ; Get new state of checkbox -- if Trail == None then keep disabled
    GuiControl, ElementForm:, CursorElementOptionTrailSolid, %state%                            ; Update Checkbox Value
    GuiControl, % ((state) ? "Show" : "Hide"), CursorElementOptionTrailSolidEnabled             ; Show/Hide the "Enabled" label
    GuiControl, % ((!state) ? "Show" : "Hide"), CursorElementOptionTrailSolidDisabled           ; Show/Hide the "Disabled" label
}

; Hide All Element Options
hideElementFormOptions() {
    global                                                                                      ; Set global scope inside function
    try {
        ; Hide grouped options & Labels
        for k, v in ["Color", "Trail", "Smoke"] {
            GuiControl, Hide, % "CursorElementOption" v
            GuiControl, Hide, % "CursorElementOption" v "Text"
        }
        for k, v in ["Text", "Enabled", "Disabled"]
            GuiControl, Hide, % "CursorElementOptionTrailSolid" v
        for k, v in ["Hitburst", "ReverseArrow", "Sliderball" "ScorebarBG", "CircleNumbers", "Hitsounds", "FollowPoint", "Mania"]

        ; Hide other options
        GuiControl, Hide, OtherElementOptionTypeText
        GuiControl, Hide, OtherElementOptionColorText

        ; Hide Mania Options
        hideManiaFormOptions()
    } catch e {
        OutputDebug, %A_Now%: Failed to hide Element option controls and labels`n%e%
    }
}

; Hide all Mania Element Options
hideManiaFormOptions() {
    global                                                                                      ; Set global scope inside function
    try {
        for k, v in ["Arrow", "Bar", "Dot"]
            GuiControl, Hide, % "ManiaElement" . v . "OptionColor"                              ; Hide all Mania color options
    } catch e {
        OutputDebug, %A_Now%: Failed to hide mania color options`n%e%
    }
}

; Toggle Visibility of Element Options
toggleElementForm(name) {
    global                                                                                      ; Set global Scope inside Function

    ; Define/update local vars
    local lc_name                                                                               ; Define $lc_name as the lowecase version of the passed name
    local gc_name := name                                                                       ; Define $gc_name as the GUI Control version of the passed name
    StringLower, lc_name, name                                                                  ; Set $lc_name to lowercase of $name
    gc_name := RegExReplace(name, "\s")                                                         ; Remove whitespace characters from $gc_name

    hideElementFormOptions()                                                                    ; Hide all ElementFormOptions Controls & Labels

    ; Cursor has its own labels to enable; handle these first
    if (name = "cursor") {
        try {
            ; Show the following elements for each of the types in this array
            for k, v in ["Color", "Trail", "Smoke"] {
                GuiControl, Show, % "CursorElementOption" v "Text"
                GuiControl, Show, % "CursorElementOption" v
            }

            ; Show cursor trail elements
            GuiControl, Show, CursorElementOptionTrailSolidText
            GuiControl, % ((CursorElementOptionTrailSolid) ? "Show" : "Hide"), CursorElementOptionTrailSolidEnabled
            GuiControl, % ((CursorElementOptionTrailSolid) ? "Hide": "Show"), CursorElementOptionTrailSolidDisabled
        } catch e {
            OutputDebug, %A_Now%: Failed to enable cusror option visibility`n%e%
        }

        ; Break out of the function now
        return
    }

    ; All other element types
    GuiControl, Show, OtherElementOptionTypeText
    try {
        GuiControl, Show, % gc_name . "ElementOptionType"
    } catch e {
        OutputDebug, %A_Now%: Failed to toggle visibility of Element Option controls`n%e%
    }
    
    ; For Mania Elements
    if (name = "mania") {
        GuiControl, Show, OtherElementOptionColorText
        toggleManiaForm(ManiaElementOptionType)
    }
}

; Toggle Visibility of Mania Options
toggleManiaForm(name) {
    global                                                                                      ; Set global Scope inside Function

    hideManiaFormOptions()                                                                      ; Hide all ManiaFormOptions Controls & Labels

    try {
        GuiControl, Show, % "ManiaElement" name "OptionColor"                                   ; Try to update visibility
    } catch e {
        OutputDebug, %A_Now%: Failed to update ManiaFormOption Visibiltiy`n%e%                  ; On Error, log to debug console
    }
}

; Toggle State of CursorElementOptionTrailSolid Checkbox
toggleCursorTrailSolidState(state) {
    global                                                                                     ; Set global Scope inside Function
    if (InStr(state, "none")) {
        GuiControl, ElementForm:, CursorElementOptionTrailSolid, 0
        GuiControl, Hide, CursorElementOptionTrailSolidEnabled
        GuiControl, Show, CursorElementOptionTrailSolidDisabled
    } else {
        local solid := CursorElementOptionTrailSolid
        GuiControl, % ((solid) ? "Show" : "Hide"), CursorElementOptionTrailSolidEnabled
        GuiControl, % ((solid) ? "Hide" : "Show"), CursorElementOptionTrailSolidDisabled
    }
}
