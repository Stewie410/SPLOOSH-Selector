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
    Gui, Parent: +LastFound                                     ; Place Parent GUI in coordinates previously known coordinates, or center of display
    Gui, Parent: +Resize                                        ; Allow Parent GUI to be resize
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
    Gui, TopBar: Font, s%fs_topbar%, %ff_topbar%                ; Set Font to Arial

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
    Gui, SideBar: Font, s%fs_sidebar%, %ff_sidebar%             ; Set Font to Arial

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
    Gui, SideBar: Add, Button, % "x" x_apply " y" y_apply " w" w_apply " h" h_apply " +gSubmitForm +AltSubmit", &APPLY
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

    ; Define local variables
    
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
}

; ##--------------------------------##
; #|        Functions: G-Labels     |#
; ##--------------------------------##
; TopBar --> Get PlayerForm GUI
GetPlayerForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    MsgBox,,, Player
}

; TopBar --> Get UIColorForm GUI
GetUIColorForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    MsgBox,,, UIColor
}

; TopBar --> Get ElementForm GUI
GetElementForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    MsgBox,,, Element
}

; SideBar --> Submit Form
SubmitForm() {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    MsgBox,,, APPLY
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

; ##------------------------------------##
; #|        Functions: UI Updates       |#
; ##------------------------------------##

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

; 

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
        c_<color> := new Cursor(name, dir, original)

        Definitions:
            name                            The Name or Color of the Cursor to be display in the GUI, eg "Cyan"
            dir                             The name of the directory this object's assets are located, such as "CYAN" for "Cyan"
            original                        An indicator of whether or not this is an original/default element
                                            To indicate a cursor is the original, use 1; otherwise use 0

        See defineGuiSections() for more information
    */
    c_cyan := new Cursor("Cyan", "CYAN", 0)
    c_eclipse := new Cursor("Eclipse", "ECLIPSE", 0)
    c_green := new Cursor("Green", "GREEN", 0)
    c_hotpink := new Cursor("Hot Pink", "HOT PINK", 0)
    c_orange := new Cursor("Orange", "ORANGE", 0)
    c_pink := new Cursor("Pink", "PINK", 0)
    c_purple := new Cursor("Purple", "PURPLE", 0)
    c_red := new Cursor("Red", "RED", 0)
    c_turquoise := new Cursor("Turquoise", "TURQUOISE", 0)
    c_yellow := new Cursor("Yellow", "YELLOW (ORIGINAL)", 1)

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

    ; Add Cursors to List of Cursor Objects
    l_cursors.push(c_cyan)
    l_cursors.push(c_eclipse)
    l_cursors.push(c_green)
    l_cursors.push(c_hotpink)
    l_cursors.push(c_orange)
    l_cursors.push(c_pink)
    l_cursors.push(c_purple)
    l_cursors.push(c_red)
    l_cursors.push(c_turquoise)
    l_cursors.push(c_yellow)
}

; Define Hitburst Objects
defineHitbursts() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Hitburst, follow the following pattern:
        h_<type> := new Hitburst(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    h_numbers := new Hitburst("Numbers", "NUMBERS", 0)
    h_smallbars := new Hitburst("Small Bars", "SMALLER BARS", 0)
    h_bars := new Hitburst("Bars", "BARS", 1)

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

    ; Add Hitbursts to list of Hitburst Objects
    l_hitbursts.push(h_numbers)
    l_hitbursts.push(h_smallbars)
    l_hitbursts.push(h_bars)
}

; Define ReverseArrow Objects
defineReverseArrows() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new ReverseArrow, follow the following pattern:
        r_<type> := new ReverseArrow(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    r_arrow := new ReverseArrow("Arrow", "ARROW", 0)
    r_half := new ReverseArrow("Half", "HALF", 0)
    r_bar := new ReverseArrow("Bar", "BAR", 1)

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

    ; Add ReverseArrows to list of ReverseArrow Objects
    l_reversearrows.push(r_arrow)
    l_reversearrows.push(r_half)
    l_reversearrows.push(r_bar)
}

; Define Sliderball Objects
defineSliderballs() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Sliderball, follow the following pattern:
        h_<type> := new Sliderball(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    s_single := new Sliderball("Single", "SINGLE", 0)
    s_double := new Sliderball("Double", "DOUBLE", 0)
    s_default := new Sliderball("Default", "DEFAULT", 1)

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

    ; Add Sliderballs to list of Sliderball Objects
    l_sliderballs.push(s_single)
    l_sliderballs.push(s_double)
    l_sliderballs.push(s_default)
}

; Define UIColor Objects
defineUIColors() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new UIColor, follow the following pattern:
        h_<type> := new UIColor(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */
    u_cyan := new UIColor("Cyan", "CYAN", 0)
    u_darkgray := new UIColor("Dark Gray", "DARK GRAY", 0)
    u_evergreen := new UIColor("Evergreen", "EVERGREEN", 0)
    u_hotpink := new UIColor("Hot Pink", "HOT PINK", 0)
    u_lightgray := new UIColor("Light Gray", "LIGHT GRAY", 0)
    u_orange := new UIColor("Orange", "ORANGE", 0)
    u_red := new UIColor("Red", "RED", 0)
    u_yellow := new UIColor("Yellow", "YELLOW", 0)
    u_blue := new UIColor("Blue", "BLUE", 1)

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

    ; Ad UIColors to list of UIColor Objects
    l_uicolors.push(u_cyan)
    l_uicolors.push(u_darkgray)
    l_uicolors.push(u_evergreen)
    l_uicolors.push(u_hotpink)
    l_uicolors.push(u_lightgray)
    l_uicolors.push(u_orange)
    l_uicolors.push(u_red)
    l_uicolors.push(u_yellow)
    l_uicolors.push(u_blue)
}

; Define Player Objects
definePlayers() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new player with no additional options:
            p_<name> := new Player(name, dir)

        To define a new player with additional options:
            p_<name> := new PlayerOptions(name, dir)

        See defineCursors() & defineGuiSections() for more information

        See below on how to add additional options to PlayerOptions objects
    */
    p_404aimnotfound := new Player("404AimNotFound", "404ANF")
    p_abyssal := new PlayerOptions("Abyssal", "ABYSSAL")
    p_angelsim := new Player("Angelsim", "ANGELSIM")
    p_axarious := new PlayerOptions("Axarious", "AXARIOUS")
    p_azer := new PlayerOptions("Azer", "AZER X2")
    p_azr8 := new PlayerOptions("azr8 + GayzMcGee", "AZR8 + MCGEE")
    p_badeu := new Player("Badeu", "BADEU")
    p_breastrollmc := new PlayerOptions("BeastrollMC", "BEASTROLLMC X5")
    p_bikko := new PlayerOptions("Bikko", "BIKKO")
    p_bubbleman := new Player("Bubbleman", "BUBBLEMAN")
    p_comfort := new PlayerOptions("Comfort", "COMFORT")
    p_cookiezi := new PlayerOptions("Cookiezi", "COOKIEZI X5")
    p_doomsday := new Player("Doomsday", "DOOMSDAY")
    p_dustice := new PlayerOptions("Dustice", "DUSTICE")
    p_emilia := new Player("Emilia", "EMILIA")
    p_flyingtuna := new Player("FlyingTuna", "FLYINGTUNA")
    p_freddiebenson := new Player("Freddie Benson", "FREDDIE BENSON")
    p_funorange := new Player("FunOrange", "FUNORANGE")
    p_gn := new Player("-GN", "GN")
    p_hvick225 := new Player("Hvick225", "HVICK225")
    p_idke := new PlayerOptions("Idke", "IDKE")
    p_informous := new Player("Informous", "INFORMOUS")
    p_karthy := new Player("Karthy", "KARTHY")
    p_mathi := new PlayerOptions("Mathi", "MATHI")
    p_monko2k := new Player("Monko2k", "MONKO2K")
    p_rafis := new PlayerOptions("Rafis", "RAFIS X2")
    p_rohulk := new PlayerOptions("Rohulk", "ROHULK")
    p_rrtyui := new Player("rrtyui", "RRTYUI")
    p_rustbell := new PlayerOptions("Rustbell", "RUSTBELL")
    p_ryuk := new Player("RyuK", "RYUK")
    p_seysant := new Player("Seysant", "SEYSANT")
    p_sotarks := new Player("Sotarks", "SOTARKS")
    p_sweden := new Player("Sweden", "SWEDEN")
    p_talala := new PlayerOptions("Talala", "TALALA")
    p_toy := new Player("Toy", "TOY")
    p_tranquility := new Player("Tranquil-ity", "TRANQUIL-ITY")
    p_varvalian := new Player("Varvalian", "VARVALIAN")
    p_vaxei := new PlayerOptions("Vaxei", "VAXEI")
    p_wubwoofwolf := new Player("WubWoofWolf", "WWW")
    p_xilver := new PlayerOptions("Xilver X Recia", "XILVER X RECIA")

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
    p_azer.add("2017", "2017")
    p_azer.add("2018", "2018")
    p_azer.require := 1

    p_beastrollmc.add("v1.3", "V1.3")
    p_beastrollmc.add("v3", "V3")
    p_beastrollmc.add("v4", "V4")
    p_beastrollmc.add("v5", "V5")
    p_beastrollmc.add("v6", "V6")
    p_beastrollmc.require := 1

    p_cookiezi.add("Burakku Shippu", "BURRAKU SHIPU")
    p_cookiezi.add("nathan on osu", "NATHAN ON OSU")
    p_cookiezi.add("Panimi", "PANIMI")
    p_cookiezi.add("Seoul", "SEOUL")
    p_cookiezi.add("Shigetora", "SHIGETORA")
    p_cookiezi.require := 1

    p_rafis.add("Blue", "BLUE")
    p_rafis.add("White", "WHITE")
    p_rafis.require := 1

    ; Add Optional Options to PlayerOptions Objects
    p_abyssal.add("Purple & Pink Combo", ".")
    p_abyssal.add("Blue & Red Combo", "BLUE+RED COMBO VER")

    p_axarious.add("Without Slider Ends", ".")
    p_axarious.add("With Slider Ends", "+SLIDERENDS")

    p_azr8.add("Red & Orange Slider Head", ".")
    p_azr8.add("Blue & Cyan Slider Head", "SPLOOSH SLIDER")

    p_bikko.add("Without Slider Ends", ".")
    p_bikko.add("With Slider Ends", "+SLIDERENDS")

    p_comfort.add("Standard", ".")
    p_comfort.add("Nautz Version", "NAUTZ VERSION")

    p_dustice.add("Outer Circle", ".")
    p_dustice.add("No Outer Circle", "NO OUTER CIRCLE")

    p_idke.add("Without Slider Ends", ".")
    p_idke.add("With Slider Ends", "+SLIDERENDS")

    p_mathi.add("Flat Hitcircle", ".")
    p_mathi.add("Shaded Hitcircle", "SHADERED HITCIRCLE")

    p_rohulk.add("Flat Approach Circle", ".")
    p_rohulk.add("Gamma Approach Circle", "GAMMA ACIRCLE")

    p_rustbell.add("Without 300 Explosions", ".")
    p_rustbell.add("With 300 Explosions", "HIT300 EXPLOSIONS")

    p_talala.add("White Numbers", ".")
    p_talala.add("Cyan Numbers", "CYAN NUMBERS")

    p_vaxei.add("Blue Slider Border", ".")
    p_vaxei.add("Red Slider Border", "RED SLIDERBORDER")

    p_xilver.add("Orange & Dots", ".")
    p_xilver.add("Blue & Plus", "XILVER X SPLOOSH")

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
    l_players.push(p_404aimnotfound)
    l_players.push(p_abyssal)
    l_players.push(p_angelsim)
    l_players.push(p_axarious)
    l_players.push(p_azer)
    l_players.push(p_azr8)
    l_players.push(p_badeu)
    l_players.push(p_breastrollmc)
    l_players.push(p_bikko)
    l_players.push(p_bubbleman)
    l_players.push(p_comfort)
    l_players.push(p_cookiezi)
    l_players.push(p_doomsday)
    l_players.push(p_dustice)
    l_players.push(p_emilia)
    l_players.push(p_flyingtuna)
    l_players.push(p_freddiebenson)
    l_players.push(p_funorange)
    l_players.push(p_gn)
    l_players.push(p_hvick225)
    l_players.push(p_idke)
    l_players.push(p_informous)
    l_players.push(p_karthy)
    l_players.push(p_mathi)
    l_players.push(p_monko2k)
    l_players.push(p_rafis)
    l_players.push(p_rohulk)
    l_players.push(p_rrtyui)
    l_players.push(p_rustbell)
    l_players.push(p_ryuk)
    l_players.push(p_seysant)
    l_players.push(p_sotarks)
    l_players.push(p_sweden)
    l_players.push(p_talala)
    l_players.push(p_toy)
    l_players.push(p_tranquility)
    l_players.push(p_varvalian)
    l_players.push(p_vaxei)
    l_players.push(p_wubwoofwolf)
    l_players.push(p_xilver)
}

; Browse for a Directory
BrowseDirectory(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI

    ; Provide a Directory/Tree Browser
    try {
        FileSelectFolder, d_select, %d_game%, 0, Select Game Folder
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
        MsgBox,,RESET ERROR, Cannot locate skin in `"%src%`"      ; Notify user of error
        return 1                                                ; return
    }

    ; Update local vars
    src += skin                                                 ; Update source directory
    dst += skin                                                 ; Update destination directory
    
    ; Reset Skin
    if ((StringLower,,type) = "gameplay") {                     ; If type is gameplay
        FileCopy, %src%\%d_reset_gameplay%\*.*, %dst%, 1        ; Copy reset-gameplay elements to dst
    } else if ((StringLower,,type) = "uicolor") {               ; If type is uicolor
        FileCopy, %src%\%d_reset_uicolor%\*.*, %dst%, 1         ; Copy reset-uicolor elements to dst
    } else {
        MsgBox,,RESET ERROR, Unknown Reset Type: %type%         ; Notify Error
        return 1
    }
    return 0
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
                this.original := 0
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
; #|        Class: ElementForm: Cursor      |#
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
; #|        Class: ElementForm: Hitburst      |#
; ##--------------------------------------##
Class Hitburst Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Hitburst Name (type)
    dir :=                                                      ; String: Name of the Hitburst's Directory

    ; Static Variables
    Static hitburstsDir := "HITBURSTS"                          ; Name of the Hitburst Directory

    ; Constructor
    __new(nanme, d, o) {
        base.__new("hitburst", hitburstsDir, o)
        this.name := n
        this.dir := d
    }
}

; ##-------------------------------------------##
; #|        Class: ElementForm: Reverse Arrow      |#
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
; #|        Class: ElementForm: Sliderball      |#
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
; #|        Class: PlayerForm: Options      |#
; ##------------------------------------##
Class PlayerOptions Extends Player {
    ; Instance Variables
    listNames :=                                                ; Array of Strings: Name of Options
    listDirs :=                                                 ; Array of Strings: Directory Names of Options
    require :=                                                  ; Integer: 1/0 (T/F) are options required to select skin?

    ; Constructor
    __new(n, d, ln, ld, r) {
        base.__new(n, d)
        this.listNames := []
        this.listDirs := []
        this.require := 0

        ; Check contents of ln & ld
        if (ln <> "") {
            if (ln.length <> 0) {
                this.listNames := ln
            }
        }
        if (ld <> "") {
            if (ld.length <> 0) {
                this.listDirs := ld
            }
        }

        ; Check contents of r
        if (r is integer) {
            if (r >= 0 && r <= 1) {
                this.require := r
            }
        }
    }

    ; Methods
    ; Return if Option is Required (True/False)
    isRequired() {
        return this.require = 1 ? True : False
    }

    ; Add an option to lists
    add(name, dir, index) {
        if (name <> "" && dir <> "") {
            for key, value in lsitNames {
                if (value = name && listDirs[index] = dir) {
                    return
                }
            }
            if (index <> "") {
                listNames.InsertAt(index, name)
                listDirs.InsertAt(index, dir)
                return
            }
            listNames.Push(name)
            listDirs.Push(dir)
        }
    }

    ; Remove Option from lists
    rem(name, dir, index) {
        if (index <> "") {
            listNames.RemoveAt(index)
            listDirs.RemoveAt(index)
            return
        }
        num := ""
        for key, value in listNames {
            if (value = name && listDirs[key] = dir) {
                num := key
                break
            }
        }
        if (num <> "") {
            listNames.RemoveAt(num)
            listDirs.RemoveAt(num)
        }
    }
}