; SPLOOSHSelector.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; Date:         2019-09-10
; Name:         SPLOOSH-Selector
; Description:  Sploosh Asset Selector for AutoHotKey

; ##----------------------------##
; #|        Script Options      |#
; ##----------------------------##
#SingleInstance, Force                                          ; Allow only one running instance of script
#Persistent                                                     ; Keep the script running until explicitly closed
#NoEnv                                                          ; Avoid checking empty variables for environment
#Warn ClassOverwrite                                            ; Enable warnings, Warn on class overwrite
SetWorkingDir, %A_ScriptDir%                                    ; Set the Working Directory to Script's current directory
FileEncoding UTF-8                                              ; Set Encoding to UTF-8
SetBatchLines, -1                                               ; Set speed of execution
SendMode, Input                                                 ; Send keystrokes/mouseclicks as "input"
DetectHiddenWindows, On                                         ; Allow script to see hidden windows
SetWinDelay, -1                                                 ; Delay after modifying a window
SetControlDelay, -1                                             ; Delay after modifying a control
OnExit("Cleanup")                                               ; Call Cleanup() On ExitApp Event

; ##-------------------------------------------------##
; #|        Global Variables -- Configuration        |#
; ##-------------------------------------------------##
; Width Definitions
w_app := 624                                                    ; Application/Parent
w_topbar := w_app                                               ; TopBar
w_sidebar := w_app / 5                                          ; SideBar
w_form := w_app - w_sidebar                                     ; Element, UIColor & Player

; Height Defintions
h_app := 685                                                    ; Application/Parent
h_topbar := h_app / 6                                           ; TopBar
h_sidebar := h_app - h_topbar                                   ; SideBar
h_form := h_app - h_topbar                                      ; Element, UIColor & Player

; X Positioning relative to Application
x_app := Round(A_ScreenWidth, 0)                                ; Application/Parent
x_topbar := 0                                                   ; TopBar
x_sidebar := 0                                                  ; SideBar
x_form := w_sidebar                                             ; Element, UIColor & Player

; Y Positioning relative to Application
y_app := Round(A_ScreenHeight, 0)                               ; Application/Parent
y_topbar := 0                                                   ; TopBar
y_sidebar := h_topbar                                           ; SideBar
y_form := h_topbar                                              ; Element, UIColor & Player

; Horizontal Padding
px_app := 0                                                     ; Application/Parent
px_topbar := 10                                                 ; TopBar
px_sidebar := 10                                                ; SideBar
px_form := 10                                                   ; Element, UIColor & Player

; Vertical Padding
py_app := 0                                                     ; Application/Parent
py_topbar := 15                                                 ; TopBar
py_sidebar := 10                                                ; SideBar
py_form := 10                                                   ; Element, UIColor & Player

; Background Colors
bg_app := "FFFFFF"                                              ; Application/Parent
bg_topbar := "FF8E77"                                           ; TopBar
bg_sidebar := "6DFF79"                                          ; SideBar
bg_form := "93D7FF"                                             ; Element, UIColor & Player
bg_app_og := "002D52"
bg_button_og := "004A7E"

; Foreground Colors
fg_app := "000000"                                              ; Application/Parent
fg_topbar := "FFFFFF"                                           ; TopBar
fg_sidebar := "FFFFFF"                                          ; SideBar
fg_form := "FFFFFF"                                             ; Element, UIColor & Player

; Font Faces
ff_app := "Arial"                                               ; Application/Parent
ff_topbar := "Arial"                                            ; TopBar
ff_sidebar := "Arial"                                           ; SideBar
ff_form := "Arial"                                              ; Element, UIColor & Player

; Font Sizes
fs_app := 10                                                    ; Application/Parent
fs_topbar := 10                                                 ; TopBar
fs_sidebar := 10                                                ; SideBar
fs_form := 10                                                   ; Element, UIColor & Player                                                ; A

; Directories
d_user := "C:\Users\" A_UserName                                ; User's Home Directory
d_game := d_user "\AppData\Local\osu!"                          ; Game Installation Path
d_asset := A_Temp "\SPLOOSH-Selector"                           ; Script's Assets Path (FileInstall)
d_conf := "ASSET PACKS"                                         ; Directory containing Skin Configuration Elements
d_reset_gameplay := "!RESET (ORIGINAL GAMEPLAY ASSETS)"         ; Directory containing Original Gameplay Elements
d_reset_uicolor := "!RESET (ORIGINAL UI COLOR)"                 ; Directory containing Original UI Color Elements
d_cursor_notrail := "!NO CURSOR TRAIL"                          ; Directory containing ELements to disable Cursor Trails
d_uicolor_instafade := "SKIN.INI FOR INSTAFADE HITCIRCLE"       ; Directory containing Elements to enable instant-fade circles

; Names
n_app := "SPLOOSH Selector"                                     ; Application Name
n_skin := "SPLOOSH"                                             ; Skin Name
n_ver := skinName " ( + )"                                      ; Expected Skin Name for customizations

; Object Lists
l_cursors := []                                                 ; List of Cursors
l_hitbursts := []                                               ; List of Hitbursts
l_reversearrows := []                                           ; List of ReverseArrows
l_sliderballs := []                                             ; List of Sliderballs
l_uicolors := []                                                ; List of UI Colors
l_players := []                                                 ; List of Players

; Variables
var_selected_form := "Element"                                  ; Selected Form

; ##----------------##
; #|        Run     |#
; ##----------------##
; Initial Environment, Objects and Variables
InitEnv()

; Display the GUI
Gui, TopBar: Show, % "x" x_topbar " y" y_topbar " w" w_topbar " h" h_topbar
Gui, SideBar: Show, % "x" x_sidebar " y" y_sidebar " w" w_sidebar " h" h_sidebar
Gui, ElementForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form 
Gui, UIColorForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, PlayerForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, Parent: Show, % "w" w_app " h" h_app, %n_app%

; Check GameDirectory now, if there's an issue finding the skin, notify the user
initCheckPath()

; ##--------------------------------##
; #|        Message Listeners       |#
; ##--------------------------------##

; ##----------------------------##
; #|        Event Listeners     |#
; ##----------------------------##
; Main Window Escape
ParentGuiEscape(GuiHwnd) {
    ExitApp
}

; Main Window Closed
ParentGuiClose(GuiHwnd) {
    ExitApp
}

; ##------------------------##
; #|        GUI: Parent     |#
; ##------------------------##
GuiParent() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI's Parameters
    Gui, Parent: +HWNDhParent                                   ; Define Parent GUI, Assign Window Handle to %hParent%
    ;Gui, Parent: +MinSize%w_app%x%h_app%                        ; Define Parent GUI's Minimum Size to %parentW% and %parentH%\
    Gui, Parent: +LastFound                                     ; Make Parent the LastFound window
    Gui, Parent: -Resize                                        ; Allow Parent GUI to be resize
    Gui, Parent: Margin, 0, 0                                   ; Disable Parent GUI's Margin
    Gui, Parent: Color, %bg_app%                                ; Set Parent GUI's Background Color
}

; ##------------------------##
; #|        GUI: TopBar     |#
; ##------------------------##
GuiTopBar() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI's Parameters
    Gui, TopBar: +ParentParent                                  ; Define GUI as a child of Parent
    Gui, TopBar: +HWNDhTopBar                                   ; Assign Window Handle to %hTopBar%
    Gui, TopBar: -Caption                                       ; Disable Titlebar
    Gui, TopBar: -Border                                        ; Disable Border
    Gui, TopBar: -DpiScale                                      ; Disable Windows Scaling
    Gui, TopBar: Margin, 0, 0                                   ; Disable Margin
    Gui, TopBar: Color, %bg_topbar%                             ; Set Background Color
    Gui, TopBar: Font, s%fs_topbar%, %ff_topbar%                ; Set font

    ; Define Local Variables for sizing and placement
    local cx_items := 4                                         ; Number of Items per Row
    local cy_items := 2                                         ; Number of Items per Column
    local w_text := w_sidebar                                   ; Text Width
    local w_button := (w_topbar / cx_items) - (px_topbar * 2)   ; Button Width
    local w_edit := 0                                           ; Edit Width
    local h_text := (h_topbar / cy_items) - (py_topbar * 2)     ; Text Height
    local h_button := h_text                                    ; Button Height
    local h_edit := h_text                                      ; Edit Height
    local r_edit := 1                                           ; Rows of Edit
    local a_x := []                                             ; X Positions
    local a_y := []                                             ; Y Positions

    ; Add positions to x/y arrays
    for k, v in [1, 2, 3, 4] {
        if (k = 1) {
            a_x.push(px_topbar)
            a_y.push(py_topbar)
        } else {
            a_x.push(((w_topbar / cx_items) * v) - (w_topbar / cx_items) - (px_topbar * 1))
            a_y.push(((h_topbar / cy_items) * v) - (h_topbar / cy_items) + (py_topbar * 1))
        }
    }

    ; Update Vars based on a_x[] values
    w_edit := a_x[4] - a_x[3] + w_button

    ; Add Label(s) to the GUI
    Gui, TopBar: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, CATEGORY:     ; Row 1
    Gui, TopBar: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE, GAME PATH:    ; Row 2

    ; Add Controls to Row 1 of the GUI
    Gui, TopBar: Add, Button, % "x" a_x[2] " y" a_y[1] " w" w_button " h" h_button " +gGetPlayerForm +AltSubmit", &PLAYER         ; Row 1
    Gui, TopBar: Add, Button, % "x" a_x[3] " y" a_y[1] " w" w_button " h" h_button " +gGetUIColorForm +AltSubmit", &UI COLOR      ; Row 1
    Gui, TopBar: Add, Button, % "x" a_x[4] " y" a_y[1] " w" w_button " h" h_button " +gGetElementForm +AltSubmit", &ELEMENT       ; Row 1
    Gui, TopBar: Add, Edit, % "x" a_x[2] " y" a_y[2] " w" w_edit " h" h_edit " r" r_edit " +vGamePath", %d_game%                              ; Row 2
    Gui, TopBar: Add, Button, % "x" a_x[4] " y" a_y[2] " w" w_button " h" h_button " +gBrowseDirectory +AltSubmit", &BROWSE...    ; Row 2
}

; ##----------------------------##
; #|        GUI: SideBar        |#
; ##----------------------------##
GuiSideBar() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI's Parameters
    Gui, SideBar: +ParentParent                                 ; Define GUI as a child of Parent
    Gui, SideBar: +HWNDhSideBar                                 ; Assign Window Handle to %hTopBar%
    Gui, SideBar: -Caption                                      ; Disable Titlebar
    Gui, SideBar: -Border                                       ; Disable Border
    Gui, SideBar: -DpiScale                                     ; Disable Windows Scaling
    Gui, SideBar: Margin, 0, 0                                  ; Disable Margin
    Gui, SideBar: Color, %bg_sidebar%                           ; Set Background Color
    Gui, SideBar: Font, s%fs_sidebar%, %ff_sidebar%             ; Set font

    ; Define Local Variables for sizing and placement
    local cx_items := 1                                         ; number of items per row
    local cy_items := 5                                         ; number of items per column
    local w_apply := (w_sidebar / cx_items) - (px_sidebar * 2)  ; apply button width
    local w_group := w_apply                                    ; groupbox width
    local w_reset := w_group - (px_sidebar * 2)                 ; reset button width
    local h_apply := (h_sidebar / cy_items) - (py_sidebar * 2)  ; apply button height
    local h_group := h_apply * (cy_items - 0.5)                 ; groupbox height
    local h_reset := (h_group / 3) - (py_sidebar * 2)           ; reset button height
    local x_apply := px_sidebar                                 ; apply button x
    local x_group := px_sidebar                                 ; groupbox x
    local x_reset := px_sidebar * 2                             ; reset button x
    local y_apply := py_sidebar                                 ; apply button y
    local y_group := h_apply + (y_apply * 2)                    ; groupbox y

    ; Add Labels to GUI
    ; Add Controls to GUI (Standalone)
    Gui, SideBar: Add, Button, % "x" x_apply " y" y_apply " w" w_apply " h" h_apply " +gSubmitForm", &APPLY
    Gui, SideBar: Add, GroupBox, % "x" x_group " y" y_group " w" w_group " h" h_group " +Section", RESET
    Gui, SideBar: Add, Button, % "x" x_reset " ys+" (py_sidebar * 2) " w" w_reset " h" h_reset " +gResetAll +AltSubmit", ALL
    Gui, SideBar: Add, Button, % "x" x_reset " ys+" ((py_sidebar * 3) + h_reset) " w" w_reset " h" h_reset " +gResetGameplay +AltSubmit", GAMEPLAY
    Gui, SideBar: Add, Button, % "x" x_reset " ys+" ((py_sidebar * 4) + (h_reset * 2)) " w" w_reset " h" h_reset " +gResetUIColor +AltSubmit", UI`nCOLOR
}

; ##----------------------------##
; #|        GUI: UI Color       |#
; ##----------------------------##
GuiUIColor() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI
    Gui, UIColorForm: +ParentParent                             ; Define GUI as a child of Parent
    Gui, UIColorForm: +HWNDhUIColor                             ; Assign Window Handle to %hTopBar%
    Gui, UIColorForm: -Caption                                  ; Disable Titlebar
    Gui, UIColorForm: -Border                                   ; Disable Border
    Gui, UIColorForm: -DpiScale                                 ; Disable Windows Scaling
    Gui, UIColorForm: Margin, 0, 0                              ; Disable Margin
    Gui, UIColorForm: Color, %bg_form%                          ; Set Background Color
    Gui, UIColorForm: Font, s%fs_form%, %ff_form%               ; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of items per row
    local cy_items := 2                                         ; Number of items per column
    local w_text := (w_form / cx_items) - (px_form * 2)         ; Text width
    local w_ddl := w_text                                       ; DropDownList width
    local w_check := w_text                                     ; CheckBox width
    local h_text := (h_form / cy_items) - (py_form * 2)         ; Text height
    local h_ddl := h_text                                       ; DropDownList height
    local h_check := h_text                                     ; CheckBox height
    local a_x := []                                             ; x positions
    local a_y := []                                             ; y positions
    local o_color := ""                                         ; color options
    local def_color := ""                                       ; default color selection

    ; Add positions to x/y arrays
    for k, v in [1, 2] {
        if (k = 1) {
            a_x.push(px_form)
            a_y.push(py_form)
        } else {
            a_x.push(((w_form / cx_items) * v) - (w_form / cx_items) + (px_form * 1))
            a_y.push(((h_form / cy_items) * v) - (h_form / cy_items) + (py_form * 1))
        }
    }

    ; Get Options
    for k, v in l_uicolors {
        if (o_color = "") {
            o_color := v.name
        } else {
            o_color := o_color "|" v.name
        }
        if (v.original = 1) {
            def_color := v.name
        }
    }

    ; Sort Options Alphabetically
    Sort, o_color, CL D|

    ; Determine default choices
    for k, v in (StrSplit(o_color, "|")) {
        if (v = def_color) {
            def_color := k
        }
    }

    ; Add labels to GUI
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, COLOR:
    Gui, UIColorForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE, INSTAFADE CIRCLES:

    ; Add controls to GUI
    Gui, UIColorForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " h" h_ddl " +Choose" def_color " +vUIColorOptionColor", %o_color%
    Gui, UIColorForm: Add, CheckBox, % "x" a_x[2] " y" a_y[2] " w" w_check " +vUIColorOptionInstafade", Enabled
}

; ##-----------------------------##
; #|        GUI: ElementForm     |#
; ##-----------------------------##
GuiElement() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI
    Gui, ElementForm: +ParentParent                             ; Define GUI as a child of Parent
    Gui, ElementForm: +HWNDhElement                             ; Assign Window Handle to %hTopBar%
    Gui, ElementForm: -Caption                                  ; Disable Titlebar
    Gui, ElementForm: -Border                                   ; Disable Border
    Gui, ElementForm: -DpiScale                                 ; Disable Windows Scaling
    Gui, ElementForm: Margin, 0, 0                              ; Disable Margin
    Gui, ElementForm: Color, %bg_form%                          ; Set Background Color
    Gui, ElementForm: Font, s%fs_form%, %ff_form%               ; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of Items per Row
    local cy_items := 4                                         ; Number of Items per column
    local w_text := (w_form / cx_items) - (px_form * 2)         ; Text width
    local w_ddl := w_text                                       ; DropDownList width
    local h_text := (h_form / cy_items) - (py_form * 2)         ; Text height
    local h_ddl := h_text                                       ; DropDownList height
    local a_x := []                                             ; x positions
    local a_y := []                                             ; y positions
    local o_element := "Cursor|Hitburst|Reverse Arrow|Sliderball"   ; Element Options
    local o_cursor := ""                                        ; Cursor Options
    local o_ctrail := "None"                                    ; Cursor Trail Options
    local o_csmoke := ""                                        ; Cusror Smoke Options
    local o_hitburst := ""                                      ; Hitburst Options
    local o_revarrow := ""                                      ; ReverseArrow Options
    local o_sliderball := ""                                    ; Sliderball Options
    local def_cursor := ""                                      ; Default Cursor Selection
    local def_ctrail := ""                                      ; Default CursorTrail Color Selection
    local def_csmoke := ""                                      ; Default CusorSmoke Color Selection
    local def_hitburst := ""                                    ; Default Hitburst Selection
    local def_revarrow := ""                                    ; Default ReverseArrow Selection
    local def_sliderball := ""                                  ; Default Sliderball Selection

    ; Add positions to x/y arrays
    for k, v in [1, 2, 3, 4] {
        if (k = 1) {
            a_x.push(px_form)
            a_y.push(py_form)
        } else {
            a_x.push(((w_form / cx_items) * v) - (w_form / cx_items) + (px_form * 1))
            a_y.push(((h_form / cy_items) * v) - (h_form / cy_items) + (py_form * 1))
        }
    }

    ; Get Options
    for k, v in l_cursors {
        if (o_cursor = ""){
            o_cursor := v.name
        } else {
            o_cursor := o_cursor "|" v.name
            o_ctrail := o_ctrail "|" v.name
        }
        if (v.original = 1) {
            def_cursor := v.name
            def_ctrail := v.name
        }
    }
    o_csmoke := o_cursor
    for k, v in l_hitbursts {
        if (o_hitburst = "") {
            o_hitburst := v.name
        } else {
            o_hitburst := o_hitburst "|" v.name
        }
        if (v.original = 1) {
            def_hitburst := v.name
        }
    }
    for k, v in l_reversearrows {
        if (o_revarrow = ""){
            o_revarrow := v.name
        } else {
            o_revarrow := o_revarrow "|" v.name
        }
        if (v.original = 1) {
            def_revarrow := v.name
        }
    }
    for k, v in l_sliderballs {
        if (o_sliderball = ""){
            o_sliderball := v.name
        } else {
            o_sliderball := o_sliderball "|" v.name
        }
        if (v.original = 1) {
            def_sliderball := v.name
        }
    }

    ; Sort Options Alphabetically
    Sort, o_cursor, CL D|
    Sort, o_ctrail, CL D|
    Sort, o_csmoke, CL, D|
    Sort, o_hitburst, CL D|
    Sort, o_revarrow, CL D|
    Sort, o_sliderball, CL D|

    ; Determine default choices
    for k, v in (StrSplit(o_cursor, "|")) {
        if (v = def_cursor) {
            def_cursor := k
            def_csmoke := k
        }
    }
    for k, v in (StrSplit(o_ctrail, "|")) {
        if (v = def_ctrail) {
            def_ctrail := k
        }
    }
    for, k, v in (StrSplit(o_csmoke, "|")) {
        if (v = def_csmoke) {
            def_csmoke = k
        }
    }
    for k, v in (StrSplit(o_hitburst, "|")) {
        if (v = def_hitburst) {
            def_hitburst := k
        }
    }
    for k, v in (StrSplit(o_revarrow, "|")) {
        if (v = def_revarrow) {
            def_revarrow := k
        }
    }
    for k, v in (StrSplit(o_sliderball, "|")) {
        if (v = def_sliderball) {
            def_sliderball := k
        }
    }

    ; Add Labels to GUI
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, ELEMENT:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +vCursorElementOptionColorText", COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +vOtherElementOptionTypeText +Hidden1", TYPE:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[3] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +vCursorElementOptionTrailText", TRAIL COLOR:
    Gui, ElementForm: Add, Text, % "x" a_x[1] " y" a_y[4] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +vCursorElementOptionSmokeText", SMOKE COLOR:

    ; Add Controls to GUI
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " h" h_ddl " +Choose1 +gGetElementType +vElementType +Sort", %o_element%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " h" h_ddl " +Choose" def_cursor " +vCursorElementOptionColor", %o_cursor%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " h" h_ddl " +Choose" def_hitburst " +vHitburstElementOptionType +Hidden1", %o_hitburst%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " h" h_ddl " +Choose" def_revarrow " +vReverseArrowElementOptionType +Hidden1", %o_revarrow%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " h" h_ddl " +Choose" def_sliderball " +vSliderballElementOptionType +Hidden1", %o_sliderball%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[3] " w" w_ddl " h" h_ddl " +Choose" def_ctrail " +vCursorElementOptionTrail", %o_ctrail%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[4] " w" w_ddl " h" h_ddl " +Choose" def_csmoke " +vCursorElementOptionSmoke", %o_csmoke%

    ; Update Element Form
    GetElementType()
}

; ##----------------------------##
; #|        GUI: PlayerForm     |#
; ##----------------------------##
GuiPlayer() {
    global                                                      ; Set global Scope inside Function

    ; Define the GUI
    Gui, PlayerForm: +ParentParent                              ; Define GUI as a child of Parent
    Gui, PlayerForm: +HWNDhPlayer                               ; Assign Window Handle to %hTopBar%
    Gui, PlayerForm: -Caption                                   ; Disable Titlebar
    Gui, PlayerForm: -Border                                    ; Disable Border
    Gui, PlayerForm: -DpiScale                                  ; Disable Windows Scaling
    Gui, PlayerForm: Margin, 0, 0                               ; Disable Margin
    Gui, PlayerForm: Color, %bg_form%                           ; Set Background Color
    Gui, PlayerForm: Font, s%fs_form%, %ff_form%                ; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of items per row
    local cy_items := 2                                         ; Number of items per column
    local w_text := (w_form / cx_items) - (px_form * 2)         ; Text width
    local w_ddl := w_text                                       ; DropDownList width
    local h_text := (h_form / cy_items) - (py_form * 2)         ; Text height
    local h_ddl := h_text                                       ; DropDownList height
    local a_x := []                                             ; x positions
    local a_y := []                                             ; y positions
    local a_version := []                                       ; player versions
    local o_player := ""                                        ; player names
    local o_version := ""                                       ; player versions (ddl)
    local def_player := 1                                       ; default player selection
    local def_version := 1                                      ; default version selection

    ; Add positions to x/y arrays
    for k, v in [1, 2, 3] {
        if (k = 1) {
            a_x.push(px_form)
            a_y.push(py_form)
        } else {
            a_x.push(((w_form / cx_items) * v) - (w_form / cx_items) + (px_form * 1))
            a_y.push(((h_form / cy_items) * v) - (h_form / cy_items) + (py_form * 1))
        }
    }

    ; Get Options
    for k, v in l_players {
        if (o_player = "") {
            o_player := v.name
        } else {
            o_player := o_player "|" v.name
        }
    }

    ; Sort Options Alphabetically
    Sort, o_player, CL D|
    Sort, o_version, CL D|

    ; Add Labels to the GUI
    Gui, PlayerForm: Add, Text, % "x" a_x[1] " y" a_y[1] " w" w_text " h" h_text " +" SS_CENTERIMAGE, PLAYER:
    Gui, PlayerForm: Add, Text, % "x" a_x[1] " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +vPlayerOptionVersionText +Hidden1", VERSION:

    ; Add Controls to the GUI
    Gui, PlayerForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " h" h_ddl " +Choose" def_player " +gGetPlayerOptionVersion +vPlayerOptionName", %o_player%
    Gui, PlayerForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " h" h_ddl " +Choose" def_version " +vPlayerOptionVersion +Hidden1", %o_version%

    ; Update UI for PlayerOptionVersion controls/labels
    GetPlayerOptionVersion()
}

; ##--------------------------------##
; #|        Functions: G-Labels     |#
; ##--------------------------------##
; TopBar --> Get PlayerForm GUI
GetPlayerForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("Player", 1)                                     ; Show PlayerForm
    global var_selected_form := "Player"                        ; Update Selected Form
}

; TopBar --> Get UIColorForm GUI
GetUIColorForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("UIColor", 1)                                    ; Show UIColorForm
    global var_selected_form := "UIColor"                       ; Update Selected Form
}

; TopBar --> Get ElementForm GUI
GetElementForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("Element", 1)                                    ; Show ElementForm
    global var_selected_form := "Element"                       ; Update Selected Form
}

; SideBar --> Submit Form
SubmitForm() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    Gui, ElementForm: Submit, NoHide                            ; Get vVar values without hiding GUI
    Gui, UIColorForm: Submit, NoHide                            ; Get vVar values without hiding GUI
    Gui, PlayerForm: Submit, NoHide                             ; Get vVar values without hiding GUI
    applyForm()                                                 ; Apply Configuration, based on selected form
}

; SideBar --> Reset All Elements
ResetAll() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    if (resetSkin("gameplay") = 0) {                            ; Reset Gameplay, if successful
        resetSkin("uicolor")                                    ; Reset UIColor
    }
}

; SideBar --> Reset Gameplay Elements
ResetGameplay() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("gameplay")                                       ; Reset Gameplay
}

; SideBar --> Reset UI Color Elements
ResetUIColor() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("uicolor")                                        ; Reset UIColor
}

; ElementForm --> Get Element Type (options)
GetElementType() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    toggleElementForm("ALL")                                    ; Hide all ElementForm options
    toggleElementForm(ElementType, 1)                           ; Display ElementOptions, if any
}

; PlayerForm --> Get Player Versions (options)
GetPlayerOptionVersion() {
    global                                                      ; Set global Scope inside Function
    Gui, PlayerForm: Submit, NoHide                             ; Get +vVar values without hiding GUI
    togglePlayerForm("ALL")                                     ; Hide all PlayerForm options
    togglePlayerForm(PlayerOptionName, 1)                       ; Display PlayerOptions, if any
}

; ##------------------------------------##
; #|        Functions: UI Updates       |#
; ##------------------------------------##
; TopBar --> Toggle Visibility of a Form -- Args: $1: Name; $2: Visible (def: 0)
toggleForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

    ; If Name not passed, return
    if (name = "") {
        return
    }

    ; Handler for "ALL" name
    if (name = "ALL") {
        Gui, PlayerForm: Show, Hide                             ; Hide PlayerForm
        Gui, ElementForm: Show, Hide                            ; Hide ElementForm
        Gui, UIColorForm: Show, Hide                            ; Hide UIColorForm
    }

    ; Update visibility
    if (vis = 1) {                                              ; If visibility set to 1
        Gui, %name%Form: Show                                   ; Show window
    } else {                                                    ; Otherwise
        Gui, %name%Form: Show, Hide                             ; Hide Window
    }
}

; ElementForm --> Toggle Visibility of Element Options -- Args: $1: Name, $2: Visible (def: 0)
toggleElementForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

    ; If Name not passed, return
    if (name = "") {
        return
    }

    ; Define/update local vars
    StringLower, name, name                                     ; Set %name% to lowercase
    local visCmd := vis = 1 ? "Show" : "Hide"                   ; Set visibility command

    ; Handler for "ALL" name
    if (name = "all") {
        GuiControl, %visCmd%, CursorElementOptionColorText
        GuiControl, %visCmd%, CursorElementOptionTrailText
        GuiControl, %visCmd%, CursorElementOptionSmokeText
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, CursorElementOptionColor
        GuiControl, %visCmd%, CursorElementOptionTrail
        GuiControl, %visCmd%, CursorElementOptionSmoke
        GuiControl, %visCmd%, HitburstElementOptionType
        GuiControl, %visCmd%, ReverseArrowElementOptionType
        GuiControl, %visCmd%, SliderballElementOptionType
        return
    } else if (name = "cursor") {
        GuiControl, %visCmd%, CursorElementOptionColorText
        GuiControl, %visCmd%, CursorElementOptionTrailText
        GuiControl, %visCmd%, CursorElementOptionSmokeText
        GuiControl, %visCmd%, CursorElementOptionColor
        GuiControl, %visCmd%, CursorElementOptionTrail
        GuiControl, %visCmd%, CursorElementOptionSmoke
    } else if (name = "hitburst") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, HitburstElementOptionType
    } else if (name = "reverse arrow") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, ReverseArrowElementOptionType
    } else if (name = "sliderball") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, SliderballElementOptionType
    }
}

; PlayerForm --> Toggle Visibility of Version Options && update Version Options -- Args: $1: name; $2: visibility (def: 0)
togglePlayerForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

    ; Return if no index passed
    if (name = "") {
        return
    }

    ; Define local vars
    local visCmd := vis = 1 ? "Show" : "Hide"                   ; Set visibility command
    local optStr := ""                                          ; Set Options String
    local sortPlayers := ""                                     ; Sorted Players

    ; Handler for "ALL"
    if (name = "ALL") {
        GuiControl, %visCmd%, PlayerOptionVersionText           ; Hide Version Text
        GuiControl, %visCmd%, PlayerOptionVersion               ; Hide Version DDL
        return                                                  ; return
    }

    ; Get the list of players into a string
    for k, v in l_players {
        if (sortPlayers = "") {
            sortPlayers := v.name
        } else {
            sortPlayers := sortPlayers "|" v.name
        }
    }

    ; Sort the list of players alphabetically
    Sort, sortPlayers, CL D|

    ; Split string into array, and search for %name%
    for i, j in StrSplit(sortPlayers, "|") {
        if (j = name) {                                     ; When name is found, search for name in %l_players%, as position may have changed
            for k, l in l_players {
                if (name = l.name) {                        ; If name is found, set %optStr% to the listNames 
                    optStr := StrReplace(l.listNames, ",", "|")
                    Sort, optStr, CL D|                     ; Sort the options string
                    break
                }
            }
            break
        }
    }

    if (optStr = "") {
        return
    }

    GuiControl, PlayerForm:, PlayerOptionVersion, |%optStr%
    GuiControl, PlayerForm: Choose, PlayerOptionVersion, 1
    GuiControl, %visCmd%, PlayerOptionVersionText               ; Hide Version Text
    GuiControl, %visCmd%, PlayerOptionVersion                   ; Hide Version DDL
}

; ##---------------------------------------##
; #|        Functions: Event Handlers      |#
; ##---------------------------------------##

; ##--------------------------------##
; #|        Functions: Backend      |#
; ##--------------------------------##
; Initialize Environment
InitEnv() {
    global                                                      ; Set global Scope inside Function
    Menu, Tray, Tip, %n_app%                                    ; Define SysTray Icon with Application Name

    ; Install Assets
    ;FileInstall, Source, Dest, 1

    ; Add Fonts
    ;DllCall("Gdi32.dll\AddFontResourceEx", "Str", %pathToFont% "\MyFont.ttf", "UInt", 0x10, "UInt", 0)

    ; Instatiate Objects
    defineCursors()
    defineHitbursts()
    defineReverseArrows()
    defineSliderballs()
    defineUIColors()
    definePlayers()

    ; Define GUIs
    GuiParent()
    GuiTopBar()
    GuiSideBar()
    GuiElement()
    GuiUIColor()
    GuiPlayer()
}

; Check if default game directory exists
initCheckPath() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get vVar values without hiding GUI
    if (getDirectoryName(n_skin, GameDirectory "\Skins") = "") {
        MsgBox,, %n_app%, WARNING: Please update Game Path before continuing!
    }
}

; Cleanup Environment
Cleanup() {
    global                                                      ; Set global Scope inside Function

    ; Remove Fonts
    ;DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", %pathToFont% "\MyFont.ttf", "UInt", 0x10, "UInt", 0)
}

; Define Cursor Objects
defineCursors() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Cursor, follow the follow pattern:
        co_<color> := new Cursor(name, dir, original)

        Definitions:
            name                            The Name or Color of the Cursor to be display in the GUI, eg "Cyan"
            dir                             The name of the directory this object's assets are located, such as "CYAN" for "Cyan"
            original                        An indicator of whether or not this is an original/default element
                                            To indicate a cursor is the original, use 1; otherwise use 0

        See defineGuiSections() for more information
    */
    co_cyan := new Cursor("Cyan", "CYAN", 0)
    co_eclipse := new Cursor("Eclipse", "ECLIPSE", 0)
    co_green := new Cursor("Green", "GREEN", 0)
    co_hotpink := new Cursor("Hot Pink", "HOT PINK", 0)
    co_orange := new Cursor("Orange", "ORANGE", 0)
    co_pink := new Cursor("Pink", "PINK", 0)
    co_purple := new Cursor("Purple", "PURPLE", 0)
    co_red := new Cursor("Red", "RED", 0)
    co_turquoise := new Cursor("Turquoise", "TURQUOISE", 0)
    co_yellow := new Cursor("Yellow", "YELLOW (ORIGINAL)", 1)

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add Cursors to List of Cursor Objects
    l_cursors.push(co_cyan)
    l_cursors.push(co_eclipse)
    l_cursors.push(co_green)
    l_cursors.push(co_hotpink)
    l_cursors.push(co_orange)
    l_cursors.push(co_pink)
    l_cursors.push(co_purple)
    l_cursors.push(co_red)
    l_cursors.push(co_turquoise)
    l_cursors.push(co_yellow)
}

; Define Hitburst Objects
defineHitbursts() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Hitburst, follow the following pattern:
        ho_<type> := new Hitburst(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    ho_numbers := new Hitburst("Numbers", "NUMBERS", 0)
    ho_smallbars := new Hitburst("Small Bars", "SMALLER BARS", 0)
    ho_bars := new Hitburst("Bars", "BARS", 1)

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add Hitbursts to list of Hitburst Objects
    l_hitbursts.push(ho_numbers)
    l_hitbursts.push(ho_smallbars)
    l_hitbursts.push(ho_bars)
}

; Define ReverseArrow Objects
defineReverseArrows() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new ReverseArrow, follow the following pattern:
        ro_<type> := new ReverseArrow(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    ro_arrow := new ReverseArrow("Arrow", "ARROW", 0)
    ro_half := new ReverseArrow("Half", "HALF", 0)
    ro_bar := new ReverseArrow("Bar", "BAR", 1)

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add ReverseArrows to list of ReverseArrow Objects
    l_reversearrows.push(ro_arrow)
    l_reversearrows.push(ro_half)
    l_reversearrows.push(ro_bar)
}

; Define Sliderball Objects
defineSliderballs() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Sliderball, follow the following pattern:
        ho_<type> := new Sliderball(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    so_single := new Sliderball("Single", "SINGLE", 0)
    so_double := new Sliderball("Double", "DOUBLE", 0)
    so_default := new Sliderball("Default", "DEFAULT", 1)

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add Sliderballs to list of Sliderball Objects
    l_sliderballs.push(so_single)
    l_sliderballs.push(so_double)
    l_sliderballs.push(so_default)
}

; Define UIColor Objects
defineUIColors() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new UIColor, follow the following pattern:
        ho_<type> := new UIColor(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    uo_cyan := new UIColor("Cyan", "CYAN", 0)
    uo_darkgray := new UIColor("Dark Gray", "DARK GRAY", 0)
    uo_evergreen := new UIColor("Evergreen", "EVERGREEN", 0)
    uo_hotpink := new UIColor("Hot Pink", "HOT PINK", 0)
    uo_lightgray := new UIColor("Light Gray", "LIGHT GRAY", 0)
    uo_orange := new UIColor("Orange", "ORANGE", 0)
    uo_red := new UIColor("Red", "RED", 0)
    uo_yellow := new UIColor("Yellow", "YELLOW", 0)
    uo_blue := new UIColor("Blue", "BLUE", 1)

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Ad UIColors to list of UIColor Objects
    l_uicolors.push(uo_cyan)
    l_uicolors.push(uo_darkgray)
    l_uicolors.push(uo_evergreen)
    l_uicolors.push(uo_hotpink)
    l_uicolors.push(uo_lightgray)
    l_uicolors.push(uo_orange)
    l_uicolors.push(uo_red)
    l_uicolors.push(uo_yellow)
    l_uicolors.push(uo_blue)
}

; Define Player Objects
definePlayers() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new player with no additional options:
            po_<name> := new PlayerOptions(name, dir)

        To define a new player with additional options:
            po_<name> := new PlayerOptions(name, dir)

        See defineCursors() & defineGuiSections() for more information

        See below on how to add additional options to PlayerOptions objects
    */
    po_404aimnotfound := new PlayerOptions("404AimNotFound", "404ANF")
    po_abyssal := new PlayerOptions("Abyssal", "ABYSSAL")
    po_angelsim := new PlayerOptions("Angelsim", "ANGELSIM")
    po_axarious := new PlayerOptions("Axarious", "AXARIOUS")
    po_azer := new PlayerOptions("Azer", "AZER X2")
    po_azr8 := new PlayerOptions("azr8 + GayzMcGee", "AZR8 + MCGEE")
    po_badeu := new PlayerOptions("Badeu", "BADEU")
    po_breastrollmc := new PlayerOptions("BeastrollMC", "BEASTROLLMC X5")
    po_bikko := new PlayerOptions("Bikko", "BIKKO")
    po_bubbleman := new PlayerOptions("Bubbleman", "BUBBLEMAN")
    po_comfort := new PlayerOptions("Comfort", "COMFORT")
    po_cookiezi := new PlayerOptions("Cookiezi", "COOKIEZI X5")
    po_doomsday := new PlayerOptions("Doomsday", "DOOMSDAY")
    po_dustice := new PlayerOptions("Dustice", "DUSTICE")
    po_emilia := new PlayerOptions("Emilia", "EMILIA")
    po_flyingtuna := new PlayerOptions("FlyingTuna", "FLYINGTUNA")
    po_freddiebenson := new PlayerOptions("Freddie Benson", "FREDDIE BENSON")
    po_funorange := new PlayerOptions("FunOrange", "FUNORANGE")
    po_gn := new PlayerOptions("-GN", "GN")
    po_hvick225 := new PlayerOptions("Hvick225", "HVICK225")
    po_idke := new PlayerOptions("Idke", "IDKE")
    po_informous := new PlayerOptions("Informous", "INFORMOUS")
    po_karthy := new PlayerOptions("Karthy", "KARTHY")
    po_mathi := new PlayerOptions("Mathi", "MATHI")
    po_monko2k := new PlayerOptions("Monko2k", "MONKO2K")
    po_rafis := new PlayerOptions("Rafis", "RAFIS X2")
    po_rohulk := new PlayerOptions("Rohulk", "ROHULK")
    po_rrtyui := new PlayerOptions("rrtyui", "RRTYUI")
    po_rustbell := new PlayerOptions("Rustbell", "RUSTBELL")
    po_ryuk := new PlayerOptions("RyuK", "RYUK")
    po_seysant := new PlayerOptions("Seysant", "SEYSANT")
    po_sotarks := new PlayerOptions("Sotarks", "SOTARKS")
    po_sweden := new PlayerOptions("Sweden", "SWEDEN")
    po_talala := new PlayerOptions("Talala", "TALALA")
    po_toy := new PlayerOptions("Toy", "TOY")
    po_tranquility := new PlayerOptions("Tranquil-ity", "TRANQUIL-ITY")
    po_varvalian := new PlayerOptions("Varvalian", "VARVALIAN")
    po_vaxei := new PlayerOptions("Vaxei", "VAXEI")
    po_wubwoofwolf := new PlayerOptions("WubWoofWolf", "WWW")
    po_xilver := new PlayerOptions("Xilver X Recia", "XILVER X RECIA")

    /*
        To add additional options to a player:
            -Provide at least two variants of the option
            -Define whether or not an option is mandatory

        To add an option to a player:
            p_<name>.add(name, dir)
        To define whether the provided options are required:
            p_<name>.required := 1

        When adding an option:
            For non-required options
                -The first option MUST be the "Default"
                    -The Directory MUST be "."
                -The "require" property MUST be set to 0
                    -This occurs by default on object creation
            For required options
                -Define at least two options
                -The "require" property MUST be set to 1

        What makes optionds required?
            Required
                If the contents of a Player Directory ONLY contains additional directories
                with multiple versions of the skin; but doesn't actually contain any
                skin elements itself; then the option is "required" for application
            Optional
                If the contents of a Player Directory contain skin elements, as well as
                further directories with modifications; then the option is "Optional"
                for application
    */
    ; Add Mandatory Options to PlayerOptions Objects
    po_azer.add("2017", "2017")
    po_azer.add("2018", "2018")
    po_azer.require := 1

    po_beastrollmc.add("v1.3", "V1.3")
    po_beastrollmc.add("v3", "V3")
    po_beastrollmc.add("v4", "V4")
    po_beastrollmc.add("v5", "V5")
    po_beastrollmc.add("v6", "V6")
    po_beastrollmc.require := 1

    po_cookiezi.add("Burakku Shippu", "BURRAKU SHIPU")
    po_cookiezi.add("nathan on osu", "NATHAN ON OSU")
    po_cookiezi.add("Panimi", "PANIMI")
    po_cookiezi.add("Seoul", "SEOUL")
    po_cookiezi.add("Shigetora", "SHIGETORA")
    po_cookiezi.require := 1

    po_rafis.add("Blue", "BLUE")
    po_rafis.add("White", "WHITE")
    po_rafis.require := 1

    ; Add Optional Options to PlayerOptions Objects
    po_abyssal.add("Purple & Pink Combo", ".")
    po_abyssal.add("Blue & Red Combo", "BLUE+RED COMBO VER")

    po_axarious.add("Without Slider Ends", ".")
    po_axarious.add("With Slider Ends", "+SLIDERENDS")

    po_azr8.add("Red & Orange Slider Head", ".")
    po_azr8.add("Blue & Cyan Slider Head", "SPLOOSH SLIDER")

    po_bikko.add("Without Slider Ends", ".")
    po_bikko.add("With Slider Ends", "+SLIDERENDS")

    po_comfort.add("Standard", ".")
    po_comfort.add("Nautz Version", "NAUTZ VERSION")

    po_dustice.add("Outer Circle", ".")
    po_dustice.add("No Outer Circle", "NO OUTER CIRCLE")

    po_idke.add("Without Slider Ends", ".")
    po_idke.add("With Slider Ends", "+SLIDERENDS")

    po_mathi.add("Flat Hitcircle", ".")
    po_mathi.add("Shaded Hitcircle", "SHADERED HITCIRCLE")

    po_rohulk.add("Flat Approach Circle", ".")
    po_rohulk.add("Gamma Approach Circle", "GAMMA ACIRCLE")

    po_rustbell.add("Without 300 Explosions", ".")
    po_rustbell.add("With 300 Explosions", "HIT300 EXPLOSIONS")

    po_talala.add("White Numbers", ".")
    po_talala.add("Cyan Numbers", "CYAN NUMBERS")

    po_vaxei.add("Blue Slider Border", ".")
    po_vaxei.add("Red Slider Border", "RED SLIDERBORDER")

    po_xilver.add("Orange & Dots", ".")
    po_xilver.add("Blue & Plus", "XILVER X SPLOOSH")

    /*
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(c_<name>)
        Hitbursts       -->         l_hitbursts.push(h_<name>)
        ReverseArrows   -->         l_reversearrows.push(r_<name>)
        Sliderballs     -->         l_sliderballs.push(s_<name>)
        UIColors        -->         l_uicolors.push(u_<name>)
        Players         -->         l_players.push(p_<name>)
    */

    ; Add Players to list of Player Objects
    l_players.push(po_404aimnotfound)
    l_players.push(po_abyssal)
    l_players.push(po_angelsim)
    l_players.push(po_axarious)
    l_players.push(po_azer)
    l_players.push(po_azr8)
    l_players.push(po_badeu)
    l_players.push(po_breastrollmc)
    l_players.push(po_bikko)
    l_players.push(po_bubbleman)
    l_players.push(po_comfort)
    l_players.push(po_cookiezi)
    l_players.push(po_doomsday)
    l_players.push(po_dustice)
    l_players.push(po_emilia)
    l_players.push(po_flyingtuna)
    l_players.push(po_freddiebenson)
    l_players.push(po_funorange)
    l_players.push(po_gn)
    l_players.push(po_hvick225)
    l_players.push(po_idke)
    l_players.push(po_informous)
    l_players.push(po_karthy)
    l_players.push(po_mathi)
    l_players.push(po_monko2k)
    l_players.push(po_rafis)
    l_players.push(po_rohulk)
    l_players.push(po_rrtyui)
    l_players.push(po_rustbell)
    l_players.push(po_ryuk)
    l_players.push(po_seysant)
    l_players.push(po_sotarks)
    l_players.push(po_sweden)
    l_players.push(po_talala)
    l_players.push(po_toy)
    l_players.push(po_tranquility)
    l_players.push(po_varvalian)
    l_players.push(po_vaxei)
    l_players.push(po_wubwoofwolf)
    l_players.push(po_xilver)
}

; Browse for a Directory
BrowseDirectory(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI

    ; Provide a Directory/Tree Browser
    try {
        Gui, TopBar: +OwnDialogs                                ; Make Dialog Modal
        FileSelectFolder, d_select, %d_game%, 0, Select Game Folder
        Gui, TopBar: -OwnDialogs                                ; Disable Modal Dialogs
    } catch e {
        MsgBox,,, An Exception was thrown!`nSpecifically: %e%
        return
    }

    ; Return value, if selected
    if (d_select <> "") {
        GuiControl, TopBar:, GamePath, %d_select%
        d_game := d_select
    }               
}

; Get name of a directory based on string -- Args: $1: Name to search for, $2: Path to search
getDirectoryName(name := "", path := "") {
    if (name = "" || path = "") {                               ; If args not passed, return
        return
    } else if (FileExist(path) = "") {                          ; If path doesn't exist, return
        return
    }

    ; Define Local Variables
    dir := ""                                                   ; Define return val as passed name

    ; Loop through a given path
    Loop, Files, %path%\*, D                                    ; Return only directories
    {
        if (RegExMatch(A_LoopFileName, "i)"%name%) <> 0) {      ; If skin name is found
            dir := A_LoopFileName                               ; Set return val to name
            break                                               ; Break loop
        }
    }
    return dir                                                  ; Return value
}

; Reset Skin -- Args: $1: Type
resetSkin(type := "") {
    global                                                      ; Set global Scope inside Function

    ; If arg not passed, break
    if (type = "") {
        return
    }

    ; Define Local variables
    local src := GamePath "\Skins"                              ; Source directory
    local dst := GamePath "\Skins"                              ; Destination directory
    local skin := getDirectoryName(n_skin, src)                 ; Skin name

    ; Handle skin not found
    if (skin = "") {
        MsgBox,,RESET ERROR, Cannot locate skin in `"%src%`"    ; Notify user of error
        return 1                                                ; return
    }

    ; Update local vars
    src := src "\" skin "\" d_conf                              ; Update source directory
    dst := dst "\" skin                                         ; Update destination directory
    
    ; Reset Skin
    StringLower,type,type                                       ; Set all characters in type to lowercase
    if (type = "gameplay") {                                    ; If type is gameplay
        FileCopy, %src%\%d_reset_gameplay%\*.*, %dst%, 1        ; Copy reset-gameplay elements to dst
        FileDelete, %dst%\cursormiddle@2x.png                   ; Delete CursorMiddle
    } else if (type = "uicolor") {                              ; If type is uicolor
        FileCopy, %src%\%d_reset_uicolor%\*.*, %dst%, 1         ; Copy reset-uicolor elements to dst
    } else {
        MsgBox,,RESET ERROR, Unknown Reset Type: %type%         ; Notify Error
        return 1
    }
    return 0
}

; Apply Form Configuration --> Args: $1: Form Name
applyForm() {
    global                                                      ; Set global Scope inside Function

    ; Define local variables
    local src := GamePath "\Skins"                              ; Source Directory
    local dst := GamePath "\Skins"                              ; Destination Directory
    local skin := getDirectoryName(n_skin, src)                 ; Skin Name
    local form := var_selected_form
    StringLower, form, form                                     ; Convert %form% to all lowercase

    ; Handle skin not found
    if (skin = "") {
        Gui, SideBar: +OwnDialogs                               ; Make Dialogs Modal
        MsgBox,,APPLY ERROR, Cannot locate skin in `"%src%`"    ; Notify user of error
        Gui, SideBar: +OwnDialogs                               ; Disable Modal Dialogs
        return 1                                                ; Return
    }

    ; Update local vars
    src := src "\" skin "\" d_conf                              ; Update source
    dst := dst "\" skin                                         ; Update destination

    if (form = "element") {
        local etype := ElementType                              ; Define %etype% as current ElementType
        StringLower, etype, etype                               ; Convert %etype% to all lowercase
        if (etype = "cursor") {
            local d_opt1 := ""                                  ; Directory of Option1
            local d_opt2 := ""                                  ; Directory of Option2
            local d_opt3 := ""                                  ; Directory of Option3
            
            ; Get Directories for Options
            for i, j in l_cursors {
                if (j.name = CursorElementOptionColor) {
                    d_opt1 := j.elementsDir "\" j.cursorsDir "\" j.dir
                }
                if (j.name = CursorElementOptionTrail) {
                    d_opt2 := j.elementsDir "\" j.cursorsDir "\" j.dir
                }
                if (j.name = CursorElementOptionSmoke) {
                    d_opt3 := j.elementsDir "\" j.cursorsDir "\" j.dir
                }
            }
            
            ; If %d_opt2% is still blank
            if (d_opt2 = "") {
                if (CursorElementOptionTrail = "None") {        ; If "None" is selected
                    d_opt2 := d_opt1 "\..\" d_cursor_notrail    ; Set path to one directory higher than opt1, followed by d_cursor_notrail
                }
            }

            ; Verify Paths Exist
            if (FileExist(src "\" d_opt1) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }
            if (FileExist(src "\" d_opt2) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt2%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }
            if (FileExist(src "\" d_opt3) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt3%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }
            
            ; Copy Base Cursor Files to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1

            ; If ColorDir & TrailDir differ
            if (d_opt1 <> d_opt2) {
                ; Copy Trail to Destination
                FileCopy, %src%\%d_opt2%\cursortrail@2x.png, %dst%, 1
            }

            ; If ColorDir & SmokeDir differ
            if (d_opt1 <> d_opt2) {
                ; Copy Smoke to Destination
                FileCopy, %src%\%d_opt3%\cursor-smoke@2x.png, %dst%, 1
            }
        } else if (etype = "hitburst") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_hitbursts {
                if (j.name = HitburstElementOptionType) {
                    d_opt1 := j.elementsDir "\" j.hitburstsDir "\" j.dir
                }
            }

            ; Verify Paths Exist
            if (FileExist(src "\" d_opt1) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "reverse arrow") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_reversearrows {
                if (j.name = ReverseArrowElementOptionType) {
                    d_opt1 := j.elementsDir "\" j.reverseArrowDir "\" j.dir
                }
            }

            ; Verify Paths Exist
            if (FileExist(src "\" d_opt1) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "sliderball") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_sliderballs {
                if (j.name = SliderballElementOptionType) {
                    d_opt1 := j.elementsDir "\" j.sliderballDir "\" j.dir
                }
            }

            ; Verify Paths Exist
            if (FileExist(src "\" d_opt1) = "") {
                Gui, SideBar: +OwnDialogs                       ; Make Dialogs Modal
                MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
                Gui, SideBar: +OwnDialogs                       ; Disable Modal Dialogs
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        }
    } else if (form = "uicolor") {
        local d_opt1 := ""                                      ; Directory of Option 1
        local d_opt2 := d_uicolor_instafade                     ; Directory of Option 2

        ; Get Directories for Options
        for i, j in l_uicolors {
            if (j.name = UIColorOptionColor) {
                d_opt1 := j.uiColorDir "\" j.dir
            }
        }

        ; Verify Paths Exist
        if (FileExist(src "\" d_opt1) = "") {
            Gui, SideBar: +OwnDialogs                           ; Make Dialogs Modal
            MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
            Gui, SideBar: +OwnDialogs                           ; Disable Modal Dialogs
            return
        }

        ; Copy Base UIColor to Destination
        FileCopy, %src%\%d_opt1%\*.*, %dst%, 1

        ; If Instafade Enabled
        if (vUIColorOptionInstafade = 1) {
            FileCopy, %src%\%d_opt1%\%d_opt2%\skin.ini, %dst%, 1
            }
    } else if (form = "player") {
        local d_opt1 := ""                                      ; Directory of Option 1
        local d_opt2 := ""                                      ; Directory of Option 2
        local b_opt2 := ""                                      ; Boolean of Option 2 (required)

        ; Get Directories for Options
        for i, j in l_players {
            if (j.name = PlayerOptionName) {
                d_opt1 := j.playersDir "\" j.dir
                if (j.listNames <> "") {
                    for k, l in j.getArray("listNames") {
                        if (l = PlayerOptionVersion) {
                            local arr := j.getArray("listDirs")
                            if (arr[k] = ".") {
                                d_opt2 := d_opt1
                            } else {
                                d_opt2 := d_opt1 "\" arr[k]
                            }
                        }
                    }
                    b_opt2 := j.require
                }
            }
        }

        ; Verify Paths Exist
        if (FileExist(src "\" d_opt1) = "") {
            Gui, SideBar: +OwnDialogs                           ; Make Dialogs Modal
            MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt1%
            Gui, SideBar: +OwnDialogs                           ; Disable Modal Dialogs
            return
        }
        if (d_opt2 <> "" && FileExist(src "\" d_opt2) = "") {
            Gui, SideBar: +OwnDialogs                           ; Make Dialogs Modal
            MsgBox,,APPLY ERROR, Cannot locate path:`t%src%\%d_opt2%
            Gui, SideBar: +OwnDialogs                           ; Disable Modal Dialogs
            return
        }

        ; Reset Gameplay Elements, to prevent unintended mixing
        resetSkin("gameplay")

        ; If option is defined && required
        if (d_opt2 <> "") {
            if (b_opt2 = 0) {
                FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
            }
            FileCopy, %src%\%d_opt2%\*.*, %dst%, 1
        } else {
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        }

        ; Remove Files if necessary
        if (PlayerOptionName = "Bikko") {
            FileDelete, %dst%\cursormiddle@2x.png
        } else if (PlayerOptionName = "Cookiezi") {
            if (PlayerOptionVersion = "Shigetora") {
                FileDelete, %dst%\cursormiddle@2x.png
            }
        }
    }
}

; ##----------------------------##
; #|        Class: Element      |#
; ##----------------------------##
Class Element {
    ; Instance Variables
    type :=                                                     ; String: Element Type (Cursor, Hitburst, Reverse Arrow, Sliderball, etc)
    rootDir :=                                                  ; String: Name of Element Type's Directory
    original :=                                                 ; Integer: 1/0 (T/F) is the original element

    ; Static Variables
    Static elementsDir := "ELEMENT PACKS"                       ; Name of the ELement Packs Directory

    ; Constructor
    __new(t, r, o) {
        this.type := t
        this.rootDir := r
        this.original := 0

        ; Check contents of o, and apply where applicable
        if (o is integer) {
            if (o >= 0 && o <= 1) {
                this.original := o
            }
        }
    }

    ; Methods
    ; Append String to RootPath
    addToRootPath(val) {
        if (val <> "" && this.rootDir <> val) {
            this.rootDir += val
        } 
    }

    ; Return if Element is Original (True/False)
    isOriginal() {
        return this.original = 1 ? True : False
    }
}

; ##------------------------------------##
; #|        Class: Element: Cursor      |#
; ##------------------------------------##
Class Cursor Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Cursor Name (color)
    dir :=                                                      ; String: Name of the Cursor's Directory

    ; Static Variables
    Static cursorsDir := "CURSORS"                              ; Name of the Cursors Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("cursor", cursorDir, o)
        this.name := n
        this.dir := d
    }
}

; ##--------------------------------------##
; #|        Class: Element: Hitburst      |#
; ##--------------------------------------##
Class Hitburst Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Hitburst Name (type)
    dir :=                                                      ; String: Name of the Hitburst's Directory

    ; Static Variables
    Static hitburstsDir := "HITBURSTS"                          ; Name of the Hitburst Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitburst", hitburstsDir, o)
        this.name := n
        this.dir := d
    }
}

; ##-------------------------------------------##
; #|        Class: Element: Reverse Arrow      |#
; ##-------------------------------------------##
Class ReverseArrow Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Reverse Arrow Name (type)
    dir :=                                                      ; String: Name of the Reverse Arrow's Directory

    ; Static Variables
    Static reverseArrowDir := "REVERSEARROWS"                   ; Name of the Reverse Arrow Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitburst", reverseArrowDir, o)
        this.name := n
        this.dir := d
    }
}

; ##----------------------------------------##
; #|        Class: Element: Sliderball      |#
; ##----------------------------------------##
Class Sliderball Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Sliderball Name (type)
    dir :=                                                      ; String: Name of the Sliderball's Directory

    ; Static Variables
    Static sliderballDir := "SLIDERBALLS"                       ; Name of the Sliderball Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitburst", sliderballDir, o)
        this.name := n
        this.dir := d
    }
}

; ##----------------------------##
; #|        Class: UIColor      |#
; ##----------------------------##
Class UIColor {
    ; Instance Variables
    name :=                                                     ; String: Name (color) of the UI Color
    dir :=                                                      ; String: Name of the UI Color's Directory
    original :=                                                 ; Integer: 1/0 (T/F) is the original cursor 

    ; Static Variables
    Static uiColorDir := "UI COLORS"                            ; Name of the UI Colors Directory

    ; Constructor
    __new(n, d, o) {
        this.name := n
        this.dir := d
        this.original := 0

        ; Check contents of o
        if (o is integer) {
            if (o >= 0 && o <= 1) {
                this.original := o
            }
        }
    }

    ; Methods
    ; Return if Element is Original (True/False)
    isOriginal() {
        return this.original = 1 ? True : False
    }
}

; ##----------------------------##
; #|        Class: Player       |#
; ##----------------------------##
Class Player {
    ; Instance Variables
    name :=                                                     ; String: Name of the Player
    dir :=                                                      ; String: Name of the Player's Directory

    ; Static Variables
    Static playersDir := "PLAYER PACKS"                         ; Name of the Player Packs Directory

    ; Constructor
    __new(n, d) {
        this.name := n
        this.dir := d
    }
}

; ##------------------------------------##
; #|        Class: Player: Options      |#
; ##------------------------------------##
Class PlayerOptions Extends Player {
    ; Instance Variables
    listNames :=                                                ; Name of Options
    listDirs :=                                                 ; Directory Names of Options
    require :=                                                  ; Integer: 1/0 (T/F) are options required to select skin?

    ; Constructor
    __new(n, d) {
        base.__new(n, d)
        this.listNames := ""
        this.listDirs := ""
        this.require := 0
    }

    ; Methods
    ; Return if Option is Required (True/False)
    isRequired() {
        return this.require = 1 ? True : False
    }

    ; Add an option to lists
    add(n, d) {
        if (n = "" || d = "") {
            return
        }
        if (this.listNames = "" && this.listDirs = "") {
            this.listNames := n
            this.listDirs := d
        } else {
            this.listNames := this.listNames "," n
            this.listDirs := this.listDirs "," d
        }
    }

    ; Get array of listX
    getArray(v) {
        if (v = "listNames") {
            if (this.listNames <> "") {
                return StrSplit(this.listNames, ",")
            }
            return []
        } else if (v = "listDirs") {
            if (this.listDirs <> "") {
                return StrSplit(this.listDirs, ",")
            }
            return []
        }
    }
}

; ##----------------------------------##
; #|        Included Libraries        |#
; ##----------------------------------##
#Include %A_ScriptDir%\assets\lib\tf.ahk