; GuiFormPlayer.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; PlayerForm GUI Definition

; Define
GuiPlayer() {
    global                                                                                      ; Set global Scope inside Function
    Gui, PlayerForm: +ParentParent                                                              ; Define GUI as a child of Parent
    Gui, PlayerForm: +HWNDhPlayer                                                               ; Assign Window Handle to %hTopBar%
    Gui, PlayerForm: -Caption                                                                   ; Disable Titlebar
    Gui, PlayerForm: -Border                                                                    ; Disable Border
    Gui, PlayerForm: -DpiScale                                                                  ; Disable Windows Scaling
    Gui, PlayerForm: Margin, 0, 0                                                               ; Disable Margin
    Gui, PlayerForm: Color, %bg_form%                                                           ; Set Background Color
	Gui, PlayerForm: Font, s%fs_form% c%fg_form%, %ff_form%		                                ; Set font

    ; Define local variables
    local cx_items := 2                                                                         ; Number of items per row
    local cy_items := 2                                                                         ; Number of items per column
    local w_bg := w_form - (px_form * 2)                                                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                                                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)                                        ; Width of Text
    local w_ddl := w_text                                                                       ; Width of DropDownList
    local h_bg := h_form - (py_form * 2)                                                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                                                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)                                        ; Height of Text
    local x_bg := px_form * 0.75                                                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                                                       ; Inner-X of BG (offset)
    local a_x := buildPosArray(cy_items, cx_items, x_inner, w_inner, px_form, 5)                ; x positions
    local y_bg := py_form                                                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                                                     ; Inner-Y of BG (offset)
    local a_y := buildPosArray(cy_items, cy_items, y_inner, h_inner, py_form, 3)                ; y positions
    local o_player := getObjNamesAsString(l_players, "|")                                       ; player names
    local o_version := ""                                                                       ; player versions (ddl)
    local def_player := 1                                                                       ; default player selection
    local def_version := 1                                                                      ; default version selection
    local formBG := d_asset "\formBG.png"                                                       ; Form Background

    ; Sort Options Alphabetically
    Sort, o_player, CL D|
    Sort, o_version, CL D|

    ; Add Background to GUI
    Gui, PlayerForm: Add, Picture, % "x" x_bg " y" y_bg " w" w_bg " h" h_bg " +" SS_CENTERIMAGE, %formBG%
    ;Gui, PlayerForm: Add, Text, x%x_inner% y%y_inner% w%w_inner% h%h_inner% +BackgroundFFFFFF

    ; Add Labels to the GUI
    Gui, PlayerForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans", PLAYER:
    Gui, PlayerForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vPlayerOptionVersionText +Hidden1", VERSION:

    ; Add Controls to the GUI
    Gui, PlayerForm: Font, s%fs_input% c%fg_input%, %ff_input%  ; Font for Edit Box
    Gui, PlayerForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " +Choose" def_player " +gGetPlayerOptionVersion +vPlayerOptionName", %o_player%
    Gui, PlayerForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_version " +vPlayerOptionVersion +Hidden1", %o_version%

    ; Update UI for PlayerOptionVersion controls/labels
    GetPlayerOptionVersion()
}

; Get Player Versions/Options
GetPlayerOptionVersion() {
    global                                                                                      ; Set global Scope inside Function
    Gui, PlayerForm: Submit, NoHide                                                             ; Get +vVar values without hiding GUI
    togglePlayerForm(PlayerOptionName)                                                          ; Display Player, if any
}

; Hide all Player Options
hidePlayerOptions() {
    global                                                                                      ; Set global scope inside function
    GuiControl, Hide, PlayerOptionVersion                                                       ; Hide the Option Control
    GuiControl, Hide, PlayerOptionVersionText                                                   ; Hide the Option Label
}

; Toggle Visibility of Versions/Options
togglePlayerForm(name) {
    global                                                                                      ; Set global Scope inside Function

    ; Define local vars
    local optStr := ""                                                                          ; Set Options String
    
    hidePlayerOptions()                                                                         ; Hide all PlayerForm options

    ; Get sorted list of options from player
    for k, v in l_players {
        if (name = v.name) {                                                                    ; If the passed name matches an obj in list
            optStr := StrReplace(v.listNames, ",", "|")                                         ; Get list of Options, if any
            Sort, optStr, CL D|                                                                 ; Sort them based on the "|" delimiter
            break                                                                               ; Break out of the loop
        }
    }

    ; Break out of function if no options were retrieved
    if (!optStr)
        return

    ; Display the Player Option Controls & Label
    GuiControl, PlayerForm:, PlayerOptionVersion, |%optStr%                                     ; Set the contents of the PlayerOptionVersion DDL to the $optStr
    GuiControl, PlayerForm: Choose, PlayerOptionVersion, 1                                      ; Select the first element as the "default"
    GuiControl, Show, PlayerOptionVersionText                                                   ; Hide Version Text
    GuiControl, Show, PlayerOptionVersion                                                       ; Hide Version DDL
}