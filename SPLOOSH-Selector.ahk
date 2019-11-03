; SPLOOSHSelector.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; Date:         2019-10-21
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
; Background Colors
bg_app := "002D52"                                              ; Application/Parent
bg_topbar := "002D52"                                           ; TopBar
bg_sidebar := "002D52"                                          ; SideBar
bg_preview := "002D52"                                          ; Preview
bg_form := "002D52"                                             ; Element, UIColor & Player

; Foreground Colors
fg_app := "000000"                                              ; Application/Parent
fg_topbar := "FFFFFF"                                           ; TopBar
fg_sidebar := "FFFFFF"                                          ; SideBar
fg_preview := "FFFFFF"                                          ; Preview
fg_form := "FFFFFF"                                             ; Element, UIColor & Player
fg_input := "000000"                                            ; Inputs

; Font Faces
ff_app := "Debussy"                                             ; Application/Parent
ff_topbar := "Debussy"                                          ; TopBar
ff_sidebar := "Debussy"                                         ; SideBar
ff_preview := "Debussy"                                         ; Preview
ff_form := "Debussy"                                            ; Element, UIColor & Player
ff_input := "Roboto"                                            ; Inputs

; Font Sizes
fs_app := 10                                                    ; Application/Parent
fs_topbar := 14                                                 ; TopBar
fs_sidebar := 10                                                ; SideBar
fs_preview := 10                                                ; Preview
fs_form := 14                                                   ; Element, UIColor & Player
fs_input := 10                                                  ; Inputs

; ##----------------##
; #|        Run     |#
; ##----------------##
; Initial Environment, Objects and Variables
InitEnv()

; Display the GUI
Gui, TopBar: Show, % "x" x_topbar " y" y_topbar " w" w_topbar " h" h_topbar
Gui, SideBar: Show, % "x" x_sidebar " y" y_sidebar " w" w_sidebar " h" h_sidebar
Gui, ElementForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide" 
Gui, UIColorForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, PlayerForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, PreviewPane: Show, % "x" x_preview " y" y_preview " w" w_preview " h" h_preview
Gui, Parent: Show, % "w" w_app " h" h_app, %n_app%

; Show Default Selected Form
toggleForm("ALL")
toggleForm(var_selected_form, 1)

; Check GameDirectory now, if there's an issue finding the skin, notify the user
initCheckPath()

; ##--------------------------------##
; #|        Message Listeners       |#
; ##--------------------------------##
; On Mouse Movement, run "WM_MOUSEMOVE()" func
OnMessage(0x0200, "WM_MOUSEMOVE")

; On Left Mouse-Button Up, run "OnWM_LBUTTONUP()" func
OnMessage(0x202, "OnWM_LBUTTONUP")

; ##----------------------------##
; #|        Event Listeners     |#
; ##----------------------------##
; Main Window Escape
ParentGuiEscape(GuiHwnd) {
    ExitApp
}

; ColorPicker Window Escape
ColorPickerGuiEscape(GuiHwnd) {
    Gui, ColorPicker: Destroy
    toggleParentWindow(1)
}

; Main Window Closed
ParentGuiClose(GuiHwnd) {
    ExitApp
}

; ColorPicker Window Closed
ColorPickerGuiClose(GuiHwnd) {
    Gui, ColorPicker: Destroy
    toggleParentWindow(1)
}

; ##------------------------##
; #|        GUI: Parent     |#
; ##------------------------##
GuiParent() {
    global                                                      ; Set global Scope inside Function
    Gui, Parent: +HWNDhParent                                   ; Define Parent GUI, Assign Window Handle to %hParent%
    Gui, Parent: +LastFound                                     ; Make Parent the LastFound window
    Gui, Parent: -Resize                                        ; Disallow Parent GUI to be resize
    Gui, Parent: Margin, 0, 0                                   ; Disable Parent GUI's Margin
    Gui, Parent: Color, %bg_app%                                ; Set Parent GUI's Background Color
}

; ##------------------------##
; #|        GUI: TopBar     |#
; ##------------------------##
GuiTopBar() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: +ParentParent                                  ; Define GUI as a child of Parent
    Gui, TopBar: +HWNDhTopBar                                   ; Assign Window Handle to %hTopBar%
    Gui, TopBar: -Caption                                       ; Disable Titlebar
    Gui, TopBar: -Border                                        ; Disable Border
    Gui, TopBar: -DpiScale                                      ; Disable Windows Scaling
    Gui, TopBar: Margin, 0, 0                                   ; Disable Margin
    Gui, TopBar: Color, %bg_topbar%                             ; Set Background Color
    Gui, TopBar: Font, s%fs_topbar% c%fg_topbar%, %ff_topbar%   ; Font for Text

    ; Define Local Variables for sizing and placement
    local cx_items := 4                                         ; Number of Items per Row
    local cy_items := 2                                         ; Number of Items per Column
    local w_text := w_sidebar                                   ; Text Width
    local w_button := (w_topbar / cx_items) - (px_topbar * 2)   ; Button Width
    local w_edit := 0                                           ; Edit Width
	local w_pic := 127											; Picture Width
    local h_text := (h_topbar / cy_items) - (py_topbar * 2)     ; Text Height
    local h_button := h_text                                    ; Button Height
    local h_edit := h_text                                      ; Edit Height
    local r_edit := 1                                           ; Rows of Edit
    local a_x := buildPosArray(cx_items, cx_items, 0, w_topbar, px_topbar, 1, 1)    ; X Positions
    local a_y := buildPosArray(cx_items, cy_items, 0, h_topbar, py_topbar, 1)       ; Y Positions
    local playerNormal := d_asset "\categoryPlayersNormal.png"		; PlayerNormal image
    local uicolorNormal := d_asset "\categoryUIColorsNormal.png"	; UIColorNormal image
    local elementNormal := d_asset "\categoryElementsNormal.png"	; ElementNormal image
    local browseNormal := d_asset "\browseGameDirectoryNormal.png"	; BrowseNormal image
    local playerHover := d_asset "\categoryPlayersHover.png"		; PlayerHover image
    local uicolorHover := d_asset "\categoryUIColorsHover.png"		; UIColorHover image
    local elementHover := d_asset "\categoryElementsHover.png"		; ElementHover image
    local browseHover := d_asset "\browseGameDirectoryHover.png"	; BrowseHover image
    local playerActive := d_asset "\categoryPlayersActive.png"		; PlayerActive image
    local uicolorActive := d_asset "\categoryUIColorsActive.png"	; UIColorActive image
    local elementActive := d_asset "\categoryElementsActive.png"	; ElementActive image

    ; Update Vars based on a_x[] values
    w_edit := a_x[4] - a_x[3] + w_button

    ; Add Label(s) to the GUI
    Gui, TopBar: Add, Text, % "x" a_x[1] " y" (a_y[1] + (py_topbar * 1.5)) " w" w_text " h" h_text " +" SS_CENTERIMAGE, CATEGORY:
    Gui, TopBar: Add, Text, % "x" a_x[1] " y" (a_y[2] + (py_topbar * 1.5)) " w" w_text " h" h_text " +" SS_CENTERIMAGE, GAME PATH:

    ; Add Images to the GUI
    Gui, TopBar: Add, Picture, % "x" a_x[2] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +gGetPlayerForm +HWNDhCategoryPlayerNormal +AltSubmit", %playerNormal%
    Gui, TopBar: Add, Picture, % "x" a_x[2] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryPlayerHover +Hidden1", %playerHover%
    Gui, TopBar: Add, Picture, % "x" a_x[2] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryPlayerActive +Hidden1", %playerActive%
    Gui, TopBar: Add, Picture, % "x" a_x[3] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +gGetUIColorForm +HWNDhCategoryUIColorNormal", %uicolorNormal%
    Gui, TopBar: Add, Picture, % "x" a_x[3] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryUIColorHover +Hidden1", %uicolorHover%
    Gui, TopBar: Add, Picture, % "x" a_x[3] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryUIColorActive +Hidden1", %uicolorActive%
    Gui, TopBar: Add, Picture, % "x" a_x[4] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +gGetElementForm +HWNDhCategoryElementNormal", %elementNormal%
    Gui, TopBar: Add, Picture, % "x" a_x[4] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryElementHover +Hidden1", %elementHover%
    Gui, TopBar: Add, Picture, % "x" a_x[4] " y" a_y[1] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhCategoryElementActive +Hidden1", %elementActive%
    Gui, TopBar: Add, Picture, % "x" a_x[4] " y" a_y[2] " w" w_pic " +" SS_CENTERIMAGE " +gBrowseDirectory +HWNDhBrowseGameDirectoryNormal", %browseNormal%
    Gui, TopBar: Add, Picture, % "x" a_x[4] " y" a_y[2] " w" w_pic " +" SS_CENTERIMAGE " +HWNDhBrowseGameDirectoryHover +Hidden1", %browseHover%

    ; Add Input Controls to the GUI
    Gui, TopBar: Font, s%fs_input% c%fg_input%, %ff_input%
    Gui, TopBar: Add, Edit, % "x" a_x[2] " y" (a_y[2] + (py_topbar * 1.5)) " w" w_edit " h" h_edit " r" r_edit " +vGamePath", %d_game%
}

; ##----------------------------##
; #|        GUI: SideBar        |#
; ##----------------------------##
GuiSideBar() {
    global                                                      ; Set global Scope inside Function
    Gui, SideBar: +ParentParent                                 ; Define GUI as a child of Parent
    Gui, SideBar: +HWNDhSideBar                                 ; Assign Window Handle to %hTopBar%
    Gui, SideBar: -Caption                                      ; Disable Titlebar
    Gui, SideBar: -Border                                       ; Disable Border
    Gui, SideBar: -DpiScale                                     ; Disable Windows Scaling
    Gui, SideBar: Margin, 0, 0                                  ; Disable Margin
    Gui, SideBar: Color, %bg_sidebar%                           ; Set Background Color
    Gui, SideBar: Font, s%fs_sidebar%, %ff_sidebar%             ; Set font

    ; Define Local Variables for sizing and placement
	local cx_items := 1											; Number of items per row
	local cy_items := 4										    ; Number of items per column
	local gx_items := 1											; Number of items per row in "group"
	local gy_items := 5											; Number of items per column in "group"
	local w_outline := 140										; reset outline width
	local w_button := 110										; button width
    local w_sbutton := w_button - (px_sidebar * 1)              ; button width of submit button
	local w_gbutton := w_button - (px_sidebar * 3)				; button width inside "group"
	local h_outline := 400										; reset outline height
	local h_button := 110										; button height
    local h_sbutton := h_button - (py_sidebar * 1)              ; button height of submit button
	local h_gbutton := h_button - (py_sidebar * 3)				; button height inside "group"
	local a_x := buildPosArray(cy_items, cx_items, 0, w_sidebar, px_sidebar, 1)     ; x positions
	local a_y := buildPosArray(cy_items, cy_items, 0, h_sidebar, py_sidebar, 1, 1)  ; y positions
	local g_x := []												; x positions inside "group"
	local g_y := []												; y positions inside "group"
    local x_sbutton := (w_sidebar - w_outline) + (px_sidebar * 1.5) ; x position of submit button
	local resetOutline := d_asset "\sidebarResetOutline.png"		; ResetOutline image
	local applyNormal := d_asset "\applyNormal.png"					; ApplyNormal image
	local resetAllNormal := d_asset "\resetAllNormal.png"			; ResetAllNormal image
	local resetGameplayNormal := d_asset "\resetGameplayNormal.png"	; ResetGameplayNormal image
	local resetUIColorNormal := d_asset "\resetUIColorNormal.png"	; ResetUIColorNormal image
	local applyHover := d_asset "\applyHover.png"					; ApplyHover image
	local resetAllHover := d_asset "\resetAllHover.png"				; ResetAllHover image
	local resetGameplayHover := d_asset "\resetGameplayHover.png"	; ResetGameplayHover image
	local resetUIColorHover := d_asset "\resetUIColorHover.png"		; ResetUIColorHover image

	; Get g[xy] positions
	Loop, %gy_items%
	{
		g_x.push(((w_sidebar - w_outline) * A_Index) + (px_sidebar * 2.5))
		;g_y.push(((h_outline / gy_items) * A_Index) + (py_sidebar * ((6.5 - A_Index) - A_Index)))
        g_y.push((((h_outline + (py_sidebar * 2)) / gy_items) * A_Index) + (py_sidebar * 1))
	}

    ; Add Images to the GUI
	Gui, SideBar: Add, Picture, % "x" x_sbutton " y" a_y[1] " w" w_sbutton " h" h_sbutton " +" SS_CENTERIMAGE " +gSubmitForm +HWNDhSidebarApplyNormal", %applyNormal%
	Gui, SideBar: Add, Picture, % "x" x_sbutton " y" a_y[1] " w" w_sbutton " h" h_sbutton " +" SS_CENTERIMAGE " +HWNDhSidebarApplyHover +Hidden1", %applyHover%
	Gui, Sidebar: Add, Picture, % "x" a_x[1] " y" a_y[2] " w" w_outline " h" h_outline " +" SS_CENTERIMAGE, %resetOutline%
	Gui, Sidebar: Add, Picture, % "x" g_x[1] " y" g_y[2] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +gResetAll +HWNDhSidebarResetAllNormal", %resetAllNormal%
	Gui, Sidebar: Add, Picture, % "x" g_x[1] " y" g_y[2] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +gResetAll +HWNDhSidebarResetAllHover +Hidden1", %resetAllHover%
	Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[3] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +gResetGameplay +HWNDhSidebarResetGameplayNormal", %resetGameplayNormal%
	Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[3] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +HWNDhSidebarResetGameplayHover +Hidden1", %resetGameplayHover%
	Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[4] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +gResetUIColor +HWNDhSidebarResetUIColorNormal", %resetUIColorNormal%
	Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[4] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +HWNDhSidebarResetUIColorHover +Hidden1", %resetUIColorHover%
    Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[5] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE, %resetUIColorNormal%
}

; ##----------------------------##
; #|        GUI: UI Color       |#
; ##----------------------------##
GuiUIColor() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: +ParentParent                             ; Define GUI as a child of Parent
    Gui, UIColorForm: +HWNDhUIColor                             ; Assign Window Handle to %hTopBar%
    Gui, UIColorForm: -Caption                                  ; Disable Titlebar
    Gui, UIColorForm: -Border                                   ; Disable Border
    Gui, UIColorForm: -DpiScale                                 ; Disable Windows Scaling
    Gui, UIColorForm: Margin, 0, 0                              ; Disable Margin
    Gui, UIColorForm: Color, %bg_form%                          ; Set Background Color
	Gui, UIColorForm: Font, s%fs_form% c%fg_form%, %ff_form%	; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of items per row
    local cy_items := 11                                        ; Number of items per column
    local w_bg := w_form - (px_form * 2)                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)        ; Width of Text
    local w_ddl := w_text                                       ; Width of DropDownList
    local w_check := w_text                                     ; CheckBox width
    local w_tree := w_text                                      ; TreeView width
    local w_edit := w_text                                      ; Edit width
    local h_bg := h_form - (py_form * 2)                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)        ; Height of Text
    local h_check := h_text                                     ; CheckBox height
    local h_tree := h_text                                      ; TreeView height
    local h_edit := h_text                                      ; Edit height
    local r_edit := 1                                           ; Edit rows
    local lo_count := 1                                         ; Minimum Count Value
    local hi_count := 5                                         ; Maximum Count Value
    local x_bg := px_form * 0.75                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                       ; Inner-X of BG (offset)
    local a_x := buildPosArray(cy_items, cx_items, x_inner, w_inner, px_form, 5)    ; x positions
    local y_bg := py_form                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                     ; Inner-Y of BG (offset)
    local a_y := buildPosArray(cy_items, cy_items, y_inner, h_inner, py_form, 3)    ; y positions
    local o_color := getObjNamesAsString(l_uicolors, "|")       ; color options
    local def_color := getDefaultObject(l_uicolors)             ; default color selection
    local def_combo1 := var_combo_color_1                       ; default combo color 1
    local def_combo2 := var_combo_color_2                       ; default combo color 2
    local def_combo3 := var_combo_color_3                       ; default combo color 3
    local def_combo4 := var_combo_color_4                       ; default combo color 4
    local def_combo5 := var_combo_color_5                       ; default combo color 5
    local def_slborder := var_slider_border_color               ; default sliderborder color
    local def_sltrack := var_slider_track_color                 ; default slidertrack color
    local formBG := d_asset "\formBG.png"                       ; Form Background

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

	; Add CheckBox to GUI
    Gui, UIColorForm: Add, CheckBox, % "x" a_x[2] " y" (a_y[2] + 3) " w15 h15 -Wrap +vUIColorOptionInstafade +gToggleUIColorOptionInstafade"
    Gui, UIColorForm: Add, Text, % "x" (a_x[2] + 20) " y" a_y[2] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorOptionInstafadeText +gToggleUIColorOptionInstafade", Enable

    Gui, UIColorForm: Add, CheckBox, % "x" a_x[2] " y" (a_y[11] + 3) " w15 h15 -Wrap +vUIColorOptionSaveIni +gToggleUIColorOptionSaveIniCheckbox"
    Gui, UIColorForm: Add, Text, % "x" (a_x[2] + 20) " y" a_y[11] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vUIColorOptionSaveIniText +gToggleUIColorOptionSaveIni", Overwrite

    ; Add controls to GUI
    Gui, UIColorForm: Font, s%fs_input% c%fg_input%, %ff_input% ; Font for Edit Box
    Gui, UIColorForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " +Choose" def_color " +vUIColorOptionColor +gGetUIColorComboSliderColors", %o_color%
    Gui, UIColorForm: Add, Edit, % "x" a_x[2] " y" a_y[3] " w" w_edit " h" h_edit " r" r_edit " +Number -Wrap +vUIColorComboColorCount +gToggleUIColorOptionComboCount +BackgroundFFFFFF"
    Gui, UIColorForm: Add, UpDown, % "+Range" lo_count "-" hi_count, 1
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[4] " w" w_tree " h" h_tree " +Background" def_combo1 " +" SS_CENTERIMAGE " +ReadOnly +vUIColorComboColor1 +gChangeComboColorFirst +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[5] " w" w_tree " h" h_tree " +Background" def_combo2 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor2 +gChangeComboColorSecond +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[6] " w" w_tree " h" h_tree " +Background" def_combo3 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor3 +gChangeComboColorThird +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[7] " w" w_tree " h" h_tree " +Background" def_combo4 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor4 +gChangeComboColorFourth +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[8] " w" w_tree " h" h_tree " +Background" def_combo5 " +" SS_CENTERIMAGE " +ReadOnly +Hidden1 +vUIColorComboColor5 +gChangeComboColorFifth +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[9] " w" w_tree " h" h_tree " +Background" def_slborder " +" SS_CENTERIMAGE " +ReadOnly +vUIColorSliderborderColor +gChangeSliderborderColor +AltSubmit"
    Gui, UIColorForm: Add, TreeView, % "x" a_x[2] " y" a_y[10] " w" w_tree " h" h_tree " +Background" def_sltrack " +" SS_CENTERIMAGE " +ReadOnly +vUIColorSlidertrackColor +gChangeSlidertrackColor +AltSubmit"

    ; Check UIColor Skin.ini Overwrite checkbox
    ToggleUIColorOptionSaveIni()
    ToggleUIColorOptionComboCount()
}

; ##-----------------------------##
; #|        GUI: ElementForm     |#
; ##-----------------------------##
GuiElement() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: +ParentParent                             ; Define GUI as a child of Parent
    Gui, ElementForm: +HWNDhElement                             ; Assign Window Handle to %hTopBar%
    Gui, ElementForm: -Caption                                  ; Disable Titlebar
    Gui, ElementForm: -Border                                   ; Disable Border
    Gui, ElementForm: -DpiScale                                 ; Disable Windows Scaling
    Gui, ElementForm: Margin, 0, 0                              ; Disable Margin
    Gui, ElementForm: Color, %bg_form%                          ; Set Background Color
	Gui, ElementForm: Font, s%fs_form% c%fg_form%, %ff_form%	; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of Items per Row
    local cy_items := 5                                         ; Number of Items per column
    local w_bg := w_form - (px_form * 2)                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)        ; Width of Text
    local w_ddl := w_text                                       ; Width of DropDownList
    local w_check := w_text
    local h_bg := h_form - (py_form * 2)                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)        ; Height of Text
    local h_check := h_text                                     ; CheckBox Height
    local x_bg := px_form * 0.75                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                       ; Inner-X of BG (offset)
    local a_x := []                                             ; x positions
    local y_bg := py_form                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                     ; Inner-Y of BG (offset)
    local a_y := []                                             ; y positions
    local o_element := menu_element_types                       ; Element Options
    local o_mania := menu_mania_types                           ; Mania Options
    local o_cursor := getObjNamesAsString(l_cursors, "|")       ; Cursor Options
    local o_ctrail := "None|" . o_cursor                        ; Cursor Trail Options
    local o_csmoke := o_cursor                                  ; Cusror Smoke Options
    local o_hitburst := getObjNamesAsString(l_hitbursts, "|")   ; Hitburst Options
    local o_revarrow := getObjNamesAsString(l_reversearrows, "|")           ; ReverseArrow Options
    local o_sliderball := getObjNamesAsString(l_sliderballs, "|")           ; Sliderball Options
    local o_scorebarbg := getObjNamesAsString(l_scorebarbgs, "|")           ; ScorebarBG Options
    local o_circlenumbers := getObjNamesAsString(l_circlenumbers, "|")      ; CircleNumber Options
    local o_hitsounds := getObjNamesAsString(l_hitsounds, "|")              ; Hitsound Pack Options
    local o_followpoints := getObjNamesAsString(l_followpoints, "|")        ; FollowPoint Options
    local o_mania_arrow_color := getObjNamesAsString(l_maniaarrows, "|")    ; ManiaArrow Color Options
    local o_mania_bar_color := getObjNamesAsString(l_maniabars, "|")        ; ManiaBar Color Options
    local o_mania_dot_color := getObjNamesAsString(l_maniadots, "|")        ; ManiaDot Color Options
    local def_cursor := getDefaultObject(l_cursors)             ; Default Cursor Selection
    local def_ctrail := def_cursor                              ; Default CursorTrail Color Selection
    local def_csolid := 1                                       ; Default CursorTrail Solid State
    local def_csmoke := def_cursor                              ; Default CusorSmoke Color Selection
    local def_hitburst := getDefaultObject(l_hitbursts)         ; Default Hitburst Selection
    local def_revarrow := getDefaultObject(l_reversearrows)     ; Default ReverseArrow Selection
    local def_sliderball := getDefaultObject(l_sliderballs)     ; Default Sliderball Selection
    local def_scorebarbg := getDefaultObject(l_scorebarbgs)     ; Default ScorebarBG Selection
    local def_circlenumber := getDefaultObject(l_circlenumbers) ; Default CircleNumber Selection
    local def_hitsound := getDefaultObject(l_hitsounds)         ; Default Hitsound Pack Selection
    local def_followpoint := getDefaultObject(l_followpoints)   ; Default FollowPoint Selection
    local def_mania := 1                                        ; Default Mania
    local def_mania_color := 1                                  ; Default mania Color 
    local formBG := d_asset "\formBG.png"                       ; Form Background

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

	; Add CheckBox to GUI
    Gui, ElementForm: Add, CheckBox, % "x" a_x[2] " y" (a_y[5] + 3) " w15 h15 +Checked" def_csolid " -Wrap +vCursorElementOptionTrailSolid"
    Gui, ElementForm: Add, Text, % "x" (a_x[2] + 20) " y" a_y[5] " w" w_text " h" h_text " +" SS_CENTERIMAGE " +BackgroundTrans +vCursorElementOptionTrailSolidEnableText +gToggleCursorElementOptionTrailSolid", Enable

    ; Add Controls to GUI
    Gui, ElementForm: Font, s%fs_input% c%fg_input%, %ff_input% ; Font for Edit Box
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[1] " w" w_ddl " +gGetElementType +vElementType +Sort", %o_element%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_cursor " +vCursorElementOptionColor", %o_cursor%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_hitburst " +vHitburstElementOptionType +Hidden1", %o_hitburst%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_revarrow " +vReverseArrowElementOptionType +Hidden1", %o_revarrow%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_sliderball " +vSliderballElementOptionType +Hidden1", %o_sliderball%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_scorebarbg " +vScorebarBGElementOptionType +Hidden1", %o_scorebarbg%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_circlenumber " +vCircleNumberElementOptionType +Hidden1", %o_circlenumbers%
    Gui, ElementForm: Add, DropDownList, % "x" a_x[2] " y" a_y[2] " w" w_ddl " +Choose" def_hitsound " +vHitsoundElementOptionType +Hidden1", %o_hitsounds%
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

; ##----------------------------##
; #|        GUI: PlayerForm     |#
; ##----------------------------##
GuiPlayer() {
    global                                                      ; Set global Scope inside Function
    Gui, PlayerForm: +ParentParent                              ; Define GUI as a child of Parent
    Gui, PlayerForm: +HWNDhPlayer                               ; Assign Window Handle to %hTopBar%
    Gui, PlayerForm: -Caption                                   ; Disable Titlebar
    Gui, PlayerForm: -Border                                    ; Disable Border
    Gui, PlayerForm: -DpiScale                                  ; Disable Windows Scaling
    Gui, PlayerForm: Margin, 0, 0                               ; Disable Margin
    Gui, PlayerForm: Color, %bg_form%                           ; Set Background Color
	Gui, PlayerForm: Font, s%fs_form% c%fg_form%, %ff_form%		; Set font

    ; Define local variables
    local cx_items := 2                                         ; Number of items per row
    local cy_items := 2                                         ; Number of items per column
    local w_bg := w_form - (px_form * 2)                        ; Width of BG
    local w_inner := w_bg - (px_form * 6)                       ; Inner-Width of BG
    local w_text := (w_inner / cx_items) - (px_form * 2)        ; Width of Text
    local w_ddl := w_text                                       ; Width of DropDownList
    local h_bg := h_form - (py_form * 2)                        ; Height of BG
    local h_inner := h_bg - (py_form * 3)                       ; Inner-Height of BG
    local h_text := (h_inner / cy_items) - (py_form * 2)        ; Height of Text
    local x_bg := px_form * 0.75                                ; X position of BG
    local x_inner := x_bg + (px_form * 3)                       ; Inner-X of BG (offset)
    local a_x := buildPosArray(cy_items, cx_items, x_inner, w_inner, px_form, 5)    ; x positions
    local y_bg := py_form                                       ; Y Position of BG
    local y_inner := y_bg + (py_form * 1.5)                     ; Inner-Y of BG (offset)
    local a_y := buildPosArray(cy_items, cy_items, y_inner, h_inner, py_form, 3)    ; y positions
    local o_player := getObjNamesAsString(l_players, "|")       ; player names
    local o_version := ""                                       ; player versions (ddl)
    local def_player := 1                                       ; default player selection
    local def_version := 1                                      ; default version selection
    local formBG := d_asset "\formBG.png"                       ; Form Background

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

; ##--------------------------------##
; #|        GUI: PreviewPane        |#
; ##--------------------------------##
GuiPreview() {
    global                                                      ; Set global Scope inside Function
    Gui, PreviewPane: +ParentParent                             ; Define GUI as a child of Parent
    Gui, PreviewPane: +HWNDhPlayer                              ; Assign Window Handle to %hTopBar%
    Gui, PreviewPane: -Caption                                  ; Disable Titlebar
    Gui, PreviewPane: -Border                                   ; Disable Border
    Gui, PreviewPane: -DpiScale                                 ; Disable Windows Scaling
    Gui, PreviewPane: Margin, 0, 0                              ; Disable Margin
    Gui, PreviewPane: Color, %bg_preview%                       ; Set Background Color
    Gui, PreviewPane: Font, s%fs_preview%, %ff_preview%         ; Set font

    ; Define local variables
    local cx_items := 3                                         ; Number of items per row
    local cy_items := 1                                         ; Number of items per column
    local w_pic := w_preview / cx_items                         ; picture width
    local h_pic := h_preview / cy_items                         ; picture height
    local a_x := buildPosArray(cy_items, cx_items, 0, w_preview, px_preview, 1) ; x positions
    local a_y := buildPosArray(cy_items, cy_items, 0, h_preview, py_preview, 1) ; y positions

    ; Add Controls to GUI
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[1] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageOne +Hidden1",
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[2] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageTwo +Hidden1",
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[3] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageThree +Hidden1",
}

; ##--------------------------------##
; #|        GUI: ColorPicker        |#
; ##--------------------------------##
GuiColorPicker(w := 600, h := 600, hex := "FFFFFF") {
    global                                                      ; Set global Scope inside Function
    local w_picker := w                                         ; picker width
    local w_palette := w_picker                                 ; palette width
    local w_panel := w_picker                                   ; panel width
    local h_picker := h                                         ; picker height
    local h_palette := h_picker / 1.35                           ; palette height
    local h_panel := h_picker - h_palette                       ; panel height
    local x_palette := 0                                        ; X Position of Palette
    local x_panel := 0                                          ; X Position of Panel
    local y_palette := 0                                        ; Y Position of Palette
    local y_panel := h_palette                                  ; Y Position of Palette
    local px_panel := 10                                        ; horizontal padding on panel
    local py_panel := 10                                        ; vertical padding on panel
    local bg_picker := bg_form                                  ; Picker background color
    local fg_picker := fg_form                                  ; Picker foreground color
    local ff_picker := ff_input                                 ; Picker Font face
    local fs_picker := 15                                       ; Picker Font size
    local n_picker := n_app ": Color Picker"                    ; Picker Name
    local img_palette := d_asset "\hsbImg.png"                  ; Palette Image
    
    local cx_items := 5                                         ; Number of items per row
    local cy_items := 2                                         ; Number of items per column
    local w_text := (w_panel / cx_items) - (px_panel * 2)       ; text width
    local w_edit := w_text / 1.5                                ; edit width
    local w_button := w_text / 1                                ; button width
    local w_tree := w_text                                      ; TreeView width
    local h_text := (h_panel / cy_items) - (py_panel * 2)       ; text height
    local h_edit := h_text                                      ; edit height
    local h_button := h_text                                    ; button height
    local h_tree := h_text                                      ; TreeView height
    local r_edit := 1                                           ; edit rows
    local a_x := []                                             ; x positions on panel
    local a_y := []                                             ; y positions on panel
    local lo_rgb := 0                                           ; rgb floor
    local hi_rgb := 255                                         ; rgb ceiling
    local def_rgb := hexToRGB(hex)                              ; Array of RGB values
    local def_preview := var_picker_hover_color               ; default preview color
    local def_selected := var_picker_selected_color             ; default selected color

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

; ##--------------------------------##
; #|        Functions: G-Labels     |#
; ##--------------------------------##
; TopBar --> Get PlayerForm GUI
GetPlayerForm() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("Player", 1)                                     ; Show PlayerForm
    var_selected_form := "Player"                               ; Update Selected Form
}

; TopBar --> Get UIColorForm GUI
GetUIColorForm() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("UIColor", 1)                                    ; Show UIColorForm
    updateUIColorColors(!UIColorOptionSaveIni)                   ; Update selected UIColors
    updateTreeViewBackground()                                  ; Update Combo Colors
    var_selected_form := "UIColor"                              ; Update Selected Form
}

; TopBar --> Get ElementForm GUI
GetElementForm() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    toggleForm("ALL")                                           ; Hide all forms
    toggleForm("Element", 1)                                    ; Show ElementForm
    var_selected_form := "Element"                              ; Update Selected Form
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
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("gameplay")                                       ; Reset Gameplay elements
    resetSkin("uicolor")                                        ; Reset UI Color elements
    resetSkin("hitsounds")                                      ; Reset Hitsounds
}

; SideBar --> Reset Gameplay Elements
ResetGameplay() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("gameplay")                                       ; Reset Gameplay
}

; SideBar --> Reset UI Color Elements
ResetUIColor() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("uicolor")                                        ; Reset UIColor
}

; SideBar --> Reset Hitsounds
ResetHitsounds() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                ; Get vVar values without hiding GUI
    resetSkin("hitsounds")                                      ; Reset Hitsounds
}

; ElementForm --> Get Element Type (options)
GetElementType() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    toggleElementForm("ALL")                                    ; Hide all ElementForm options
    toggleElementForm(ElementType, 1)                           ; Display ElementOptions, if any
}

; ElementForm --> Get ELement Mania Type (options)
GetElementManiaType() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    toggleManiaForm("ALL")                                      ; Hide all ElementForm options
    toggleManiaForm(ManiaElementOptionType, 1)                  ; Display ElementOptions, if any
}

; ElementForm --> Check state of CursorTrailSolid checkbox (en/dis)
CheckCursorTrailSolidState() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    toggleCursorTrailSolidState(CursorElementOptionTrail)       ; Toggle state of CursorTrailSolid based on CursorTrail DDL Choice
}

; ElemntForm --> Toggle CursorElementOptionTrailSolid state (workaround)
ToggleCursorElementOptionTrailSolid() {
    global                                                      ; Set global Scope inside Function
    Gui, ElementForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    local ctrl_enabled                                          ; Placeholder for "is control enabled"
    GuiControlGet, ctrl_enabled, Enabled, CursorElementOptionTrailSolid     ; Get whether control is enabled or disabled
    if (ctrl_enabled)                                           ; If Control is enabled
        GuiControl, ElementForm:, CursorElementOptionTrailSolid, % (!CursorElementOptionTrailSolid)
}

; UIColorForm --> Toggle UIColorOptionInstafade state (workaround)
ToggleUIColorOptionInstafade() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    local ctrl_state := UIColorOptionInstafade                  ; Placeholder for "is control checked"
    GuiControl, UIColorForm:, UIColorOptionInstafade, % (ctrl_state = 1 ? 0 : 1)
}

; UIColorFomr --> Toggle ComboColor[x] & Labels based on requested combo count
ToggleUIColorOptionComboCount() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    updateComboColorVisibility(UIColorComboColorCount - 1)      ; Update Visibility
}

; UIColorForm --> Toggle UIColorOptionSaveIni state (workaround)
ToggleUIColorOptionSaveIni() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiControl, UIColorForm:, UIColorOptionSaveIni, % (!UIColorOptionSaveIni)
    updateUIColorColors(UIColorOptionSaveIni)
    updateTreeViewBackground()
}

; UIColorForm --> Toggle UIColorOptionSaveIni state for Checkbox
ToggleUIColorOptionSaveIniCheckbox() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    updateUIColorColors(!UIColorOptionSaveIni)                  ; Get Current/Overwrite Colors
    updateTreeViewBackground()                                  ; Update Treeview Colors
}

; UIColorForm --> Get Combo/Slider Colors by UIColor Option
GetUIColorComboSliderColors() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVar values without hiding GUI
    updateUIColorColors(!UIColorOptionSaveIni)                  ; Update selected UIColors
    updateTreeViewBackground()                                  ; Update Combo Colors
}

; UIColorForm --> Get Combo Color 1
ChangeComboColorFirst() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_1)       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 1                                       ; Set flag for which TreeView to update
}

; UIColorForm --> Get Combo Color 2
ChangeComboColorSecond() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_2)       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 2                                       ; Set flag for which TreeView to update
}

; UIColorForm --> Get Combo Color 3
ChangeComboColorThird() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_3)       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 3                                       ; Set flag for which TreeView to update
}

; UIColorForm --> Get Combo Color 4
ChangeComboColorFourth() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_4)       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 4                                       ; Set flag for which TreeView to update
}

; UIColorForm --> Get Combo Color 5
ChangeComboColorFifth() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_combo_color_5)       ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 5                                       ; Set flag for which TreeView to update
}

; UIColorForm -- Get Sliderborder Color
ChangeSliderborderColor() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_slider_border_color) ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 6                                       ; Set flag for which TreeView to update
}

; UIColorForm -- Get SliderTrack Color
ChangeSlidertrackColor() {
    global                                                      ; Set global Scope inside Function
    Gui, UIColorForm: Submit, NoHide                            ; Get +vVare values without hiding GUI
    GuiColorPicker(w_picker, h_picker, var_slider_track_color)  ; Instantiate the ColorPicker GUI
    Gui, ColorPicker: Show, % "w" w_picker " h" h_picker        ; Display the ColorPicker GUI
    toggleParentWindow(0)                                       ; Disable all other controls
    var_picker_count := 7                                       ; Set flag for which TreeView to update
}

; PlayerForm --> Get Player Versions (options)
GetPlayerOptionVersion() {
    global                                                      ; Set global Scope inside Function
    Gui, PlayerForm: Submit, NoHide                             ; Get +vVar values without hiding GUI
    togglePlayerForm("ALL")                                     ; Hide all PlayerForm options
    togglePlayerForm(PlayerOptionName, 1)                       ; Display Player, if any
}

; ColorPicker --> Select Color from Palette
ColorPickerSelectColor() {
    global                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                            ; Get vVar values without hiding GUI
    var_picker_selected_color := var_picker_hover_color         ; Set selected color to current color
    updateColorPickerSelectedColor()                            ; Update Preview Color
    updateColorPickerRGB()                                      ; Update RGB values
}

; ColorPicker --> Modify RED RGB Value
ColorPickerModifyRed() {
    global                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                             ; Update Preview Color
}

; ColorPicker --> Modify GREEN RGB Value
ColorPickerModifyGreen() {
    global                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                             ; Update Preview Color
}

; ColorPicker --> Modify BLUE RGB Value
ColorPickerModifyBlue() {
    global                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Submit, NoHide                            ; Get vVar values without hiding GUI
    var_picker_selected_color := rgbToHex([ColorPickerRGBRed, ColorPickerRGBGreen, ColorPickerRGBBlue]) ; Set selected to hex(rgb)
    updateColorPickerSelectedColor()                             ; Update Preview Color
}

; ColorPicker --> Submit Color FOrm
ColorPickerSubmitForm() {
    global                                                      ; Set global Scope inside Function
    Gui, ColorPicker: Destroy                                   ; Close ColorPicker
    toggleParentWindow(1) 

    ; Update Selected Color Var
    var_combo_color_%var_picker_count% := var_picker_selected_color
    if (var_picker_count <= 5)
        var_combo_color_%var_picker_count% := var_picker_selected_color
    else if (var_picker_count = 6)
        var_slider_border_color := var_picker_selected_color
    else if (var_picker_count = 7)
        var_slider_track_color := var_picker_selected_color

    ; Update BG Colors
    updateTreeViewBackground()
}

; PreviewPane --> Open Hyperlink based on which form is selected
OpenPreviewLink() {
    global                                                      ; Set global Scope inside Function
    if (var_selected_form = "Element")
        Run, % hl_preview_element
    else if (var_selected_form = "Player")
        Run, % hl_preview_player
    else if (var_selected_form = "UIColor")
        Run, % hl_preview_uicolor
}

; PreviewPane --> Open Hyperlink to Source Code
OpenSourceLink() {
    Run, % hl_source_code
}

; PreviewPane --> Open Hyperlink to Download correct Skin version
OpenDownloadLink() {
    Run, % hl_skin_download
}

; ##------------------------------------##
; #|        Functions: UI Updates       |#
; ##------------------------------------##
; Global Modal Message Box
modalMsgBox(title := "", message := "", guiname := "") {
    global                                                      ; Set global Scope inside Function
    
    ; Enable Modal Dialogs for provided GUI
    Gui, %guiname%: +OwnDialogs

    ; Display Message
    MsgBox,, %title%, %message%

    ; Disable Modal Dialogs for provided GUI
    Gui, %guiname%: -OwnDialogs
}

; TopBar --> Toggle Visibility of a Form -- Args: $1: Name; $2: Visible (def: 0)
toggleForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

	; Define Local Variables
	local hwndCtrl := ""

	; Determine Control to Modify
	if (name = "Element")
		hwndCtrl := hCategoryElementActive
	else if (name = "Player")
		hwndCtrl := hCategoryPlayerActive
	else if (name = "UIColor")
		hwndCtrl := hCategoryUIColorActive

    ; Handler for "ALL" name
    if (name = "ALL") {
		; Hide Windows
        Gui, PlayerForm: Show, Hide                             ; Hide PlayerForm
        Gui, ElementForm: Show, Hide                            ; Hide ElementForm
        Gui, UIColorForm: Show, Hide                            ; Hide UIColorForm

		; Hide Controls
        GuiControl, TopBar: Hide, % hCategoryElementActive		; Hide ElementActive
        GuiControl, TopBar: Hide, % hCategoryPlayerActive		; Hide PlayerActive
        GuiControl, TopBar: Hide, % hCategoryUIColorActive		; Hide UIColorActive
    }

    ; Update visibility
    if (vis) {                                                  ; If visibility set to 1
        Gui, %name%Form: Show                                   ; Show window
		GuiControl, TopBar: Show, % hwndCtrl					; Show Control
    } else {                                                    ; Otherwise
        Gui, %name%Form: Show, Hide                             ; Hide Window
		GuiControl, TopBar: Hide, % hwndCtrl					; Hide Control
    }
}

; ElementForm --> Toggle Visibility of Element Options -- Args: $1: Name, $2: Visible (def: 0)
toggleElementForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

    ; Define/update local vars
    local visCmd := vis = 1 ? "Show" : "Hide"                   ; Set visibility command
    StringLower, name, name                                     ; Set %name% to lowercase

    ; Handler for "ALL" name
    if (name = "all") {
        GuiControl, %visCmd%, CursorElementOptionColorText
        GuiControl, %visCmd%, CursorElementOptionTrailText
        GuiControl, %visCmd%, CursorElementOptionSmokeText
        GuiControl, %visCmd%, CursorElementOptionTrailSolidText
        GuiControl, %visCmd%, CursorElementOptionTrailSolidEnableText
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, OtherElementOptionColorText
        GuiControl, %visCmd%, CursorElementOptionColor
        GuiControl, %visCmd%, CursorElementOptionTrail
        GuiControl, %visCmd%, CursorElementOptionSmoke
        GuiControl, %visCmd%, CursorElementOptionTrailSolid
        GuiControl, %visCmd%, HitburstElementOptionType
        GuiControl, %visCmd%, ReverseArrowElementOptionType
        GuiControl, %visCmd%, SliderballElementOptionType
        GuiControl, %visCmd%, ScorebarBGElementOptionType
        GuiControl, %visCmd%, CircleNumberElementOptionType
        GuiControl, %visCmd%, HitsoundElementOptionType
        GuiControl, %visCmd%, FollowPointElementOptionType
        GuiControl, %visCmd%, ManiaElementOptionType
        GuiControl, %visCmd%, ManiaElementArrowOptionColor
        GuiControl, %visCmd%, ManiaELementBarOptionColor
        GuiControl, %visCmd%, ManiaElementDotOptionColor
        return
    } else if (name = "cursor") {
        GuiControl, %visCmd%, CursorElementOptionColorText
        GuiControl, %visCmd%, CursorElementOptionTrailText
        GuiControl, %visCmd%, CursorElementOptionSmokeText
        GuiControl, %visCmd%, CursorElementOptionTrailSolidText
        GuiControl, %visCmd%, CursorElementOptionTrailSolidEnableText
        GuiControl, %visCmd%, CursorElementOptionColor
        GuiControl, %visCmd%, CursorElementOptionTrail
        GuiControl, %visCmd%, CursorElementOptionSmoke
        GuiControl, %visCmd%, CursorElementOptionTrailSolid
    } else if (name = "hitburst") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, HitburstElementOptionType
    } else if (name = "reverse arrow") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, ReverseArrowElementOptionType
    } else if (name = "sliderball") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, SliderballElementOptionType
    } else if (name = "scorebar bg") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, ScorebarBGElementOptionType
    } else if (name = "circle numbers") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, CircleNumberElementOptionType
    } else if (name = "hitsounds") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, HitsoundElementOptionType
    } else if (name = "follow points") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, FollowPointElementOptionType
    } else if (name = "mania") {
        GuiControl, %visCmd%, OtherElementOptionTypeText
        GuiControl, %visCmd%, OtherElementOptionColorText
        GuiControl, %visCmd%, ManiaElementOptionType
        toggleManiaForm("ALL")
        toggleManiaForm(ManiaElementOptionType, 1)
    }
}

; ElementForm --> Toggle Visibility of Mania Options -- Args: $1: Name, $2: Visible (def: 0)
toggleManiaForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

    ; Define/update local vars
    local visCmd := vis = 1 ? "Show" : "Hide"                   ; Set visibility command
    StringLower, name, name                                     ; Set %name% to lowercase

    ; Handler for "ALL" name
    if (name = "all") {
        GuiControl, %visCmd%, ManiaElementArrowOptionColor
        GuiControl, %visCmd%, ManiaElementBarOptionColor
        GuiControl, %visCmd%, ManiaElementDotOptionColor
    } else if (name = "arrow")
        GuiControl, %visCmd%, ManiaElementArrowOptionColor
    else if (name = "bar")
        GuiControl, %visCmd%, ManiaElementBarOptionColor
    else if (name = "dot")
        GuiControl, %visCmd%, ManiaElementDotOptionColor
}

; ElementForm --> Toggle state of CursorElementOptionTrailSolid checkbox
toggleCursorTrailSolidState(state) {
    global                                                      ; Set global Scope inside Function

    if (state = "None") {
        GuiControl, ElementForm:, CursorElementOptionTrailSolid, 0
        GuiControl, ElementForm: Disable, CursorElementOptionTrailSolid
        return
    }
    GuiControl, ElementForm: Enable, CursorElementOptionTrailSolid
}

; UIColorForm --> Get Colors of selected UIColor -- Args: $1: Initialize? (0/1;F/T; def=0)
updateUIColorColors(init := 0) {
    global                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local ui_select := UIColorOptionColor                       ; Get the selected UI Color
    local colorPath := ""                                       ; Get the path to the selected UI Color
    local a_combo := []                                         ; Combo Colors
    local a_slider := []                                        ; Slider Colors

    ; Update colorPath
    if (init) {
        colorPath := "none"
    } else {
        for k, v in l_uicolors {
            if (v.name = ui_select) {
                colorPath := d_conf "\" v.uicolorDir "\" v.dir
                break
            }
        }
    }

    ; Check to make sure the colorPath was updated
    if (!colorPath)
        return
    
    ; Get selected UI Color colors
    a_combo.push(getComboColor(1, colorPath))
    a_combo.push(getComboColor(2, colorPath))
    a_combo.push(getComboColor(3, colorPath))
    a_combo.push(getComboColor(4, colorPath))
    a_combo.push(getComboColor(5, colorPath))
    a_slider.push(getSliderborderColor(colorPath))
    a_slider.push(getSlidertrackColor(colorPath))

    ; If Colors were pulled, update global vars -- otherwise, assume "Combo1" as default
    if (a_combo[1]) {
        var_combo_color_1 := a_combo[1]
        var_combo_color_2 := var_combo_color_1
        var_combo_color_3 := var_combo_color_1
        var_combo_color_4 := var_combo_color_1
        var_combo_color_5 := var_combo_color_1
        if (a_combo[2])
            var_combo_color_2 := a_combo[2]
        if (a_combo[3])
            var_combo_color_3 := a_combo[3]
        if (a_combo[4])
            var_combo_color_4 := a_combo[4]
        if (a_combo[5])
            var_combo_color_5 := a_combo[5]
    }
    if (a_slider[1])
        var_slider_border_color := a_slider[1]
    if (a_slider[2])
        var_slider_track_color := a_slider[2]
    return
}

; UIColorForm --> Update the background colors of the TreeView elements
updateTreeViewBackground() {
    global                                                      ; Set global scope inside function

    ; Update Background Colors
    GuiControl, % "UIColorForm: +Background" var_combo_color_1, UIColorComboColor1
    GuiControl, % "UIColorForm: +Background" var_combo_color_2, UIColorComboColor2
    GuiControl, % "UIColorForm: +Background" var_combo_color_3, UIColorComboColor3
    GuiControl, % "UIColorForm: +Background" var_combo_color_4, UIColorComboColor4
    GuiControl, % "UIColorForm: +Background" var_combo_color_5, UIColorComboColor5
    GuiControl, % "UIColorForm: +Background" var_slider_border_color, UIColorSliderborderColor
    GuiControl, % "UIColorForm: +Background" var_slider_track_color, UIColorSlidertrackColor
}

; UIColorForm --> Show/Hide the ComboColor 2-5 based on UIColorComboColorCount value -- Args: $1: Number of colors to show (0-4)
updateComboColorVisibility(cnt := 0) {
    global                                                      ; Set global scope inside function

    ; Show requested controls
    if (!cnt) {
        GuiControl, Hide, UIColorComboColor2                    ; Hide ComboColor2
        GuiControl, Hide, UIColorComboColor3                    ; Hide ComboColor3
        GuiControl, Hide, UIColorComboColor4                    ; Hide ComboColor4
        GuiControl, Hide, UIColorComboColor5                    ; Hide ComboColor5
        GuiControl, Hide, UIColorComboColor2Text                ; Hide ComboColor2Text
        GuiControl, Hide, UIColorComboColor3Text                ; Hide ComboColor3Text
        GuiControl, Hide, UIColorComboColor4Text                ; Hide ComboColor4Text
        GuiControl, Hide, UIColorComboColor5Text                ; Hide ComboColor5Text
    } else if (cnt = 1) {
        GuiControl, Show, UIColorComboColor2                    ; Show ComboColor2
        GuiControl, Hide, UIColorComboColor3                    ; Hide ComboColor3
        GuiControl, Hide, UIColorComboColor4                    ; Hide ComboColor4
        GuiControl, Hide, UIColorComboColor5                    ; Hide ComboColor5
        GuiControl, Show, UIColorComboColor2Text                ; Show ComboColor2Text
        GuiControl, Hide, UIColorComboColor3Text                ; Hide ComboColor3Text
        GuiControl, Hide, UIColorComboColor4Text                ; Hide ComboColor4Text
        GuiControl, Hide, UIColorComboColor5Text                ; Hide ComboColor5Text
    } else if (cnt = 2) {
        GuiControl, Show, UIColorComboColor2                    ; Show ComboColor2
        GuiControl, Show, UIColorComboColor3                    ; Show ComboColor3
        GuiControl, Hide, UIColorComboColor4                    ; Hide ComboColor4
        GuiControl, Hide, UIColorComboColor5                    ; Hide ComboColor5
        GuiControl, Show, UIColorComboColor2Text                ; Show ComboColor2Text
        GuiControl, Show, UIColorComboColor3Text                ; Show ComboColor3Text
        GuiControl, Hide, UIColorComboColor4Text                ; Hide ComboColor4Text
        GuiControl, Hide, UIColorComboColor5Text                ; Hide ComboColor5Text
    } else if (cnt = 3) {
        GuiControl, Show, UIColorComboColor2                    ; Show ComboColor2
        GuiControl, Show, UIColorComboColor3                    ; Show ComboColor3
        GuiControl, Show, UIColorComboColor4                    ; Show ComboColor4
        GuiControl, Hide, UIColorComboColor5                    ; Hide ComboColor5
        GuiControl, Show, UIColorComboColor2Text                ; Show ComboColor2Text
        GuiControl, Show, UIColorComboColor3Text                ; Show ComboColor3Text
        GuiControl, Show, UIColorComboColor4Text                ; Show ComboColor4Text
        GuiControl, Hide, UIColorComboColor5Text                ; Hide ComboColor5Text
    } else if (cnt = 4) {
        GuiControl, Show, UIColorComboColor2                    ; Show ComboColor2
        GuiControl, Show, UIColorComboColor3                    ; Show ComboColor3
        GuiControl, Show, UIColorComboColor4                    ; Show ComboColor4
        GuiControl, Show, UIColorComboColor5                    ; Show ComboColor5
        GuiControl, Show, UIColorComboColor2Text                ; Show ComboColor2Text
        GuiControl, Show, UIColorComboColor3Text                ; Show ComboColor3Text
        GuiControl, Show, UIColorComboColor4Text                ; Show ComboColor4Text
        GuiControl, Show, UIColorComboColor5Text                ; Show ComboColor5Text
    }
}

; PlayerForm --> Toggle Visibility of Version Options && update Version Options -- Args: $1: name; $2: visibility (def: 0)
togglePlayerForm(name, vis := 0) {
    global                                                      ; Set global Scope inside Function

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
        if (!sortPlayers)
            sortPlayers := v.name
        else
            sortPlayers .= "|" v.name
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

    if (!optStr)
        return

    GuiControl, PlayerForm:, PlayerOptionVersion, |%optStr%
    GuiControl, PlayerForm: Choose, PlayerOptionVersion, 1
    GuiControl, %visCmd%, PlayerOptionVersionText               ; Hide Version Text
    GuiControl, %visCmd%, PlayerOptionVersion                   ; Hide Version DDL
}

; ColorPicker --> Update Preview Color
updateColorPickerSelectedColor() {
    global                                                      ; Set global Scope inside Function
    GuiControl, % "ColorPicker: +Background" var_picker_selected_color, ColorPickerSelectedColor
}

; ColorPicker --> Update RGB Values
updateColorPickerRGB() {
    global                                                      ; Set global Scope inside Function
    local a_rgb := hexToRGB(var_picker_selected_color)          ; Convert Selected HEX to RGB array
    GuiControl, ColorPicker:, ColorPickerRGBRed, % a_rgb[1]
    GuiControl, ColorPicker:, ColorPickerRGBGreen, % a_rgb[2]
    GuiControl, ColorPicker:, ColorPickerRGBBlue, % a_rgb[3]
}

; ColorPicker --> Toggle Enabled/Disabled state of all non-Color-Picker windows
toggleParentWindow(vis := 0) {
    global                                                      ; Set global Scope inside Function
    if (vis) {
        Gui, TopBar: -Disabled
        Gui, SideBar: -Disabled
        Gui, ElementForm: -Disabled
        Gui, UIColorForm: -Disabled
        Gui, PlayerForm: -Disabled
        Gui, PreviewPane: -Disabled
    } else {
        Gui, TopBar: +Disabled
        Gui, SideBar: +Disabled
        Gui, ElementForm: +Disabled
        Gui, UIColorForm: +Disabled
        Gui, PlayerForm: +Disabled
        Gui, PreviewPane: +Disabled
    }
}

; ##---------------------------------------##
; #|        Functions: Event Handlers      |#
; ##---------------------------------------##
; On Mouse-Movement
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
    global                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local activeForm := var_selected_form                       ; Currently Visible Form
    local x_mouse := ""                                         ; Mouse's X Position
    local y_mouse := ""                                         ; Mouse's Y Position
    local ctrl_mouse := ""                                      ; Control under the Mouse
    local win_mouse := ""                                       ; Window under the Mouse
    local list_buttons := []                                    ; Buton window handles
    local is_button := 0                                        ; Flag for handlers

    list_buttons.push({key: hCategoryElementNormal, hwnd: hCategoryElementHover, ui: "Top"})
    list_buttons.push({key: hCategoryPlayerNormal, hwnd: hCategoryPlayerHover, ui: "Top"})
    list_buttons.push({key: hCategoryUIColorNormal, hwnd: hCategoryUIColorHover, ui: "Top"})
    list_buttons.push({key: hBrowseGameDirectoryNormal, hwnd: hBrowseGameDirectoryHover, ui: "Top"})
    list_buttons.push({key: hSidebarApplyNormal, hwnd: hSidebarApplyHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetAllNormal, hwnd: hSidebarResetAllHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetGameplayNormal, hwnd: hSidebarResetGameplayHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetUIColorNormal, hwnd: hSidebarResetUIColorHover, ui: "Side"})

    ; Get Mouse info
    MouseGetPos, x_mouse, y_mouse, win_mouse, ctrl_mouse, 3
    GuiControlGet, ctrl_mouse, Pos, % ctrl_mouse

    ; Iterate over button list -- if the mouse control is one of thse, update && quit
    for i in list_buttons {
        if (ctrl_mouse = list_buttons[i].key) {
            GuiControl, % list_buttons[i].ui "Bar: Show", % list_buttons[i].hwnd
            is_button := 1
        } else
            GuiControl, % list_buttons[i].ui "Bar: Hide", % list_buttons[i].hwnd
    }
    if (is_button)
        return

    ; If the mouse is over the color palette, set the below pixel's color to 'hover_color'
    if (ctrl_mouse = hColorPickerPalette)
        var_picker_hover_color := getCoordinateColor(x_mouse, y_mouse)
}

; Left Mouse-Button UP
OnWM_LBUTTONUP(wParam, lParam, msg, hwnd) {
    global                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local activeForm := var_selected_form                       ; Currently Visible Form
    local x_mouse := ""                                         ; Mouse's X Position
    local y_mouse := ""                                         ; Mouse's Y Position
    local ctrl_mouse := ""                                      ; Control under the Mouse
    local win_mouse := ""                                       ; Window under the Mouse

    ; Get Mouse info
    MouseGetPos, x_mouse, y_mouse, win_mouse, ctrl_mouse, 3
    GuiControlGet, ctrl_mouse, Pos, % ctrl_mouse
}

; ##--------------------------------##
; #|        Functions: Backend      |#
; ##--------------------------------##
; Initialize Environment
InitEnv() {
    global                                                      ; Set global Scope inside Function

    ; Define Initial Backend Variables (global)
    defineGlobals()

    Menu, Tray, Tip, %n_app%                                    ; Define SysTray Icon with Application Name
    
    ; Define Local Variables
    local file_list := {}                                       ; Define assets to be extracted
    file_list.push({name: "categoryElementsNormal", type: "png"})   ; To add an assets, define its 'name' and file 'type'
    file_list.push({name: "categoryElementsHover", type: "png"})
    file_list.push({name: "categoryElementsActive", type: "png"})
    file_list.push({name: "categoryPlayersNormal", type: "png"})
    file_list.push({name: "categoryPlayersHover", type: "png"})
    file_list.push({name: "categoryPlayersActive", type: "png"})
    file_list.push({name: "categoryUIColorsNormal", type: "png"})
    file_list.push({name: "categoryUIColorsHover", type: "png"})
    file_list.push({name: "categoryUIColorsActive", type: "png"})
    file_list.push({name: "browseGameDirectoryNormal", type: "png"})
    file_list.push({name: "browseGameDirectoryHover", type: "png"})
    file_list.push({name: "applyNormal", type: "png"})
    file_list.push({name: "applyHover", type: "png"})
    file_list.push({name: "resetAllNormal", type: "png"})
    file_list.push({name: "resetAllHover", type: "png"})
    file_list.push({name: "resetGameplayNormal", type: "png"})
    file_list.push({name: "resetGameplayHover", type: "png"})
    file_list.push({name: "resetUIColorNormal", type: "png"})
    file_list.push({name: "resetUIColorHover", type: "png"})
    file_list.push({name: "sidebarResetOutline", type: "png"})
    file_list.push({name: "formBG", type: "png"})
    file_list.push({name: "hsbImg", type: "png"})
    file_list.push({name: "debussy", type: "ttf"})
    file_list.push({name: "Roboto-Regular", type: "ttf"})

    ; Create asset directory if it doesn't exist
    if (!FileExist(d_asset))
        FileCreateDir, %d_asset%

    ; Extract any missing assets
    for i in file_list {
        if (!FileExist(d_asset "\" file_list[i].name "." file_list[i].type)) {
            local funcname := file_list[i].name
            Extract_%funcname%(d_asset "\" file_list[i].name "." file_list[i].type)
        }
    }

    ; Add Fonts
    DllCall("Gdi32.dll\AddFontResourceEx", "Str", d_asset "\debussy.ttf", "UInt", 0x10, "UInt", 0)
    DllCall("Gdi32.dll\AddFontResourceEx", "Str", d_asset "\Roboto-Regular.ttf", "UInt", 0x10, "UInt", 0)

    ; Instatiate Objects
    defineCursors()
    defineHitbursts()
    defineReverseArrows()
    defineSliderballs()
    defineScorebarBGs()
    defineCircleNumbers()
    defineHitsounds()
    defineFollowPoints()
    defineManiaArrows()
    defineManiaBars()
    defineManiaDots()
    defineUIColors()
    definePlayers()

    ; Define GUIs
    GuiParent()
    GuiTopBar()
    GuiSideBar()
    GuiElement()
    GuiUIColor()
    GuiPlayer()
    GuiPreview()
}

; Check if default game directory exists
initCheckPath() {
    global                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                 ; Get vVar values without hiding GUI
    if (!getDirectoryName(n_skin, GameDirectory "\Skins"))
        modalMsgBox(n_app ": Game Directory", "WARNING: Please update Game Path before continuing!", "Parent")
}

; Cleanup Environment
Cleanup() {
    global                                                      ; Set global Scope inside Function

    ; Hide Parent GUI
    Gui, Parent: Hide

    ; Remove Fonts
    DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", d_asset "\debussy.ttf", "UInt", 0x10, "UInt", 0)
    DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", d_asset "\Roboto-Regular.ttf", "UInt", 0x10, "UInt", 0)
}

; Define Additional Global Variables
defineGlobals() {
    global                                                      ; Set global Scope inside Function

    ; Width Definitions
    w_app := 624                                                ; Application/Parent -- Default: 624
    w_picker := 600                                             ; ColorPicker
    w_topbar := w_app                                           ; TopBar
    w_sidebar := w_app / 4                                      ; SideBar
    w_preview := w_app - w_sidebar                              ; Preview
    w_form := w_app - w_sidebar                                 ; Element, UIColor & Player

    ; Height Defintions
    h_app := 685                                                ; Application/Parent -- Default: 685
    h_picker := 600                                             ; ColorPicker
    h_topbar := h_app / 5                                       ; TopBar
    h_sidebar := h_app - h_topbar                               ; SideBar
    h_preview := h_app / 8                                      ; Preview
    h_form := h_app - h_topbar - h_preview                      ; Element, UIColor & Player

    ; X Positioning relative to Application
    x_app := Round(A_ScreenWidth, 0)                            ; Application/Parent
    x_topbar := 0                                               ; TopBar
    x_sidebar := 0                                              ; SideBar
    x_preview := w_sidebar                                      ; Preview
    x_form := w_sidebar                                         ; Element, UIColor & Player

    ; Y Positioning relative to Application
    y_app := Round(A_ScreenHeight, 0)                           ; Application/Parent
    y_topbar := 0                                               ; TopBar
    y_sidebar := h_topbar                                       ; SideBar
    y_preview := h_topbar + h_form                              ; Preview
    y_form := h_topbar                                          ; Element, UIColor & Player

    ; Horizontal Padding
    px_app := 0                                                 ; Application/Parent
    px_topbar := 10                                             ; TopBar
    px_sidebar := 10                                            ; SideBar
    px_preview := 10                                            ; Preview
    px_form := 10                                               ; Element, UIColor & Player

    ; Vertical Padding
    py_app := 0                                                 ; Application/Parent
    py_topbar := 10                                             ; TopBar
    py_sidebar := 10                                            ; SideBar
    py_preview := 10                                            ; Preview
    py_form := 10                                               ; Element, UIColor & Player

    ; Names
    n_app := "SPLOOSH Selector"                                 ; Application Name
    n_skin := "SPLOOSH"                                         ; Skin Name
    n_ver := "(S+)"												; Skin Version required

    ; Runtime Vars
    var_selected_form := "Player"								; Selected Form (Element|Player|UIColor) -- Determines Default Form too
    var_cursor_changed := 0                                     ; Flag to indicate if the cursor has been changed
    var_picker_selected_color := "FFFFFF"                       ; ColorPicker Selected Color
    var_picker_hover_color := "FFFFFF"                          ; ColorPicker Preview Color
    var_picker_cursor_changed := 0                              ; ColorPicker SystemCursor Changed
    var_picker_cursor_current := ""                             ; ColorPicker Current Cursor
    var_combo_color_1 := "1978FF"                               ; Combo Color 1
    var_combo_color_2 := "1978FF"                               ; Combo Color 2
    var_combo_color_3 := "1978FF"                               ; Combo Color 3
    var_combo_color_4 := "1978FF"                               ; Combo Color 4
    var_combo_color_5 := "1978FF"                               ; Combo Color 5
    var_slider_border_color := "DEDEDE"                         ; Slider Border Color
    var_slider_track_color := "212121"                          ; Slider Track Color
    var_picker_count := 0                                       ; Flag to indicate which TreeView to update

    ; Hyperlinks
    hl_preview_element := ""									; Elements Preview
    hl_preview_uicolor := ""									; UI Color Preview
    hl_preview_player := ""										; Player/Packs Preview
    hl_source_code := "https://github.com/Stewie410/SPLOOSH-Selector"	; Source Code
    hl_skin_download := ""

    ; Directories
    d_user := "C:\Users\" A_UserName                            ; User's Home Directory
    d_game := d_user "\AppData\Local\osu!"                      ; Game Installation Path
    d_asset := A_Temp "\SPLOOSH-Selector"                       ; Script's Assets Path (FileInstall)
    d_conf := "ASSET PACKS"                                     ; Directory containing Skin Configuration Elements
    d_default := "DEFAULT ASSETS"								; Directory containing Default/Reset Assets
    d_default_gameplay := d_default "\GP"         				; Directory containing Original Gameplay Elements
    d_default_uicolor := d_default "\UI"				        ; Directory containing Original UI Color Elements
    d_default_hitsounds := d_default "\HS"                      ; Directory containing Original Hitsounds
    d_cursor_notrail := "Z NO CT"                          		; Directory containing ELements to disable Cursor Trails
    d_cursor_solidtrail := "Z CM"                     			; Directory containing Elements to enable a solid cursor trail
    d_uicolor_instafade := "SKIN.INI FOR INSTAFADE HITCIRCLE"   ; Directory containing Elements to enable instant-fade circles
    d_mania_current := "CURRENT MANIA"

    ; Object Lists
    l_cursors := []                                             ; List of Cursors
    l_hitbursts := []                                           ; List of Hitbursts
    l_reversearrows := []                                       ; List of ReverseArrows
    l_sliderballs := []                                         ; List of Sliderballs
    l_scorebarbgs := []                                         ; List of ScorebarBGs
    l_circlenumbers := []                                       ; List of CircleNumbers
    l_followpoints := []                                        ; List of FollowPoints
    l_maniaarrows := []                                         ; list of ManiaArrows
    l_maniabars := []                                           ; List of ManiaBars
    l_maniadots := []                                           ; List of ManiaDots
    l_hitsounds := []                                           ; List of Hitsounds
    l_uicolors := []                                            ; List of UI Colors
    l_players := []                                             ; List of Players

    ; Debug Background Colors
    bg_debug_topbar := "FF8E77"                                 ; Distinct BG color for Topbar
    bg_debug_sidebar := "6DFF79"                                ; Distinct BG color for Sidebar
    bg_debug_preview := "002D52"                                ; Distinct BG color for PreviewPane
    bg_debug_form := "93D7FF"                                   ; Distinct BG Color for Forms

    ; Non-Object-Based Menu Options
    menu_element_types := "Cursors||Hitbursts|Hitsounds|Reverse Arrows|Sliderballs|Scorebar BGs|Circle Numbers|Mania|Follow Points"
    menu_mania_types := "Arrow|Bar|Dot"
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
    
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        ScorebarBGs     -->         l_scorebarbgs.psuh(bo_<name>)
        CircleNumbers   -->         l_circlenumbers.push(no_<name>)
        Mania Arrows    -->         l_maniaarrows.push(mao_<name>)
        Mania Bars      -->         l_maniabars.push(mbo_<name>)
        Mania Dots      -->         l_maniadots.push(mdo_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add Cursors to List of Cursor Objects
    l_cursors.push(new Cursor("Cyan", "CYAN", 0))
    l_cursors.push(new Cursor("Eclipse", "ECLIPSE", 0))
    l_cursors.push(new Cursor("Green", "GREEN", 0))
    l_cursors.push(new Cursor("Hot Pink", "HOT PINK", 0))
    l_cursors.push(new Cursor("Orange", "ORANGE", 0))
    l_cursors.push(new Cursor("Pink", "PINK", 0))
    l_cursors.push(new Cursor("Purple", "PURPLE", 0))
    l_cursors.push(new Cursor("Red", "RED", 0))
    l_cursors.push(new Cursor("Turquoise", "TURQUOISE", 0))
    l_cursors.push(new Cursor("Yellow", "YELLOW", 1))
}

; Define Hitburst Objects
defineHitbursts() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Hitburst, follow the following pattern:
        ho_<type> := new Hitburst(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Hitbursts to list of Hitburst Objects
    l_hitbursts.push(new Hitburst("Numbers", "NUMBERS", 0))
    l_hitbursts.push(new Hitburst("Small Bars", "SMALLER BARS", 0))
    l_hitbursts.push(new Hitburst("Default", "DEFAULT", 1))
}

; Define ReverseArrow Objects
defineReverseArrows() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new ReverseArrow, follow the following pattern:
        ro_<type> := new ReverseArrow(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ReverseArrows to list of ReverseArrow Objects
    l_reversearrows.push(new ReverseArrow("Arrow", "ARROW", 0))
    l_reversearrows.push(new ReverseArrow("Half Circle", "HALF CIRCLE", 0))
    l_reversearrows.push(new ReverseArrow("Full Circle", "FULL CIRCLE", 0))
    l_reversearrows.push(new ReverseArrow("Default", "DEFAULT", 1))
}

; Define Sliderball Objects
defineSliderballs() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Sliderball, follow the following pattern:
        ho_<type> := new Sliderball(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Sliderballs to list of Sliderball Objects
    l_sliderballs.push(new Sliderball("Single", "SINGLE", 0))
    l_sliderballs.push(new Sliderball("Double", "DOUBLE", 0))
    l_sliderballs.push(new Sliderball("Default", "DEFAULT", 1))
}

; Define ScorebarBG Objects
defineScorebarBGs() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new ScorebarBG, follow the following pattern:
        ho_<type> := new ScorebarBG(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ScorebarBGs to list of ScorebarBG Objects
    l_scorebarbgs.push(new ScorebarBG("Sidebars", "SIDEBARS", 0))
    l_scorebarbgs.push(new ScorebarBG("Black Box", "BLACK BOX", 0))
    l_scorebarbgs.push(new ScorebarBG("Default", "DEFAULT", 1))
}

; Define CircleNumber Objects
defineCircleNumbers() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Circle Number, follow the following pattern:
        ho_<type> := new Circle Number(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add CircleNumbers to list of CircleNumber Objects
    l_circlenumbers.push(new CircleNumber("Default", "DEFAULT", 1))
    l_circlenumbers.push(new CircleNumber("Squared", "SQUARED", 0))
    l_circlenumbers.push(new CircleNumber("Dots", "DOTS", 0))
}

; Define FollowPoint Objects
defineFollowPoints() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new FollowPoint, follow the following pattern:
        ho_<type> := new FollowPoint(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add FollowPoint to list of FollowPoint Objects
    l_followpoints.push(new FollowPoint("Blue", "BLUE", 0))
    l_followpoints.push(new FollowPoint("Default", "DEFAULT", 1))
    l_followpoints.push(new FollowPoint("Green", "GREEN", 0))
    l_followpoints.push(new FollowPoint("None", "NONE", 0))
    l_followpoints.push(new FollowPoint("Pink", "PINK", 0))
    l_followpoints.push(new FollowPoint("Red", "RED", 0))
    l_followpoints.push(new FollowPoint("Turquoise", "TURQUOISE", 0))
    l_followpoints.push(new FollowPoint("Yellow", "YELLOW", 0))
}

; Define Hitsound Pack Objects
defineHitsounds() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Hitsound Pack, follow the following pattern:
        ho_<type> := new Hitsound Pack(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Hitsound Pack to list of Hitsound Pack Objects
    l_hitsounds.push(new Hitsound("Clacks 1", "CLACKS 1", 0))
    l_hitsounds.push(new Hitsound("Clacks 2", "CLACKS 2", 0))
    l_hitsounds.push(new Hitsound("Default", "DEFAULT", 1))
    l_hitsounds.push(new Hitsound("Hats", "HATS", 0))
    l_hitsounds.push(new Hitsound("Kicks", "KICKS", 0))
    l_hitsounds.push(new Hitsound("osu!", "OSU", 0))
    l_hitsounds.push(new Hitsound("Pong", "PONG", 0))
    l_hitsounds.push(new Hitsound("Pops", "POPS", 0))
    l_hitsounds.push(new Hitsound("SDVX 1", "SDVX 1", 0))
    l_hitsounds.push(new Hitsound("SDVX 2", "SDVX 2", 0))
    l_hitsounds.push(new Hitsound("Slim", "SLIM", 0))
    l_hitsounds.push(new Hitsound("Ticks", "TICKS", 0))
    l_hitsounds.push(new Hitsound("Tofu", "TOFU", 0))
    l_hitsounds.push(new Hitsound("Wood", "WOOD", 0))
}

; Define ManiaArrow Objects
defineManiaArrows() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mao_<type := new ManiaArrow(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Arrow Objects
    l_maniaarrows.push(new ManiaArrow("Blue", "BLUE"))
    l_maniaarrows.push(new ManiaArrow("Cyan", "CYAN"))
    l_maniaarrows.push(new ManiaArrow("Dark Gray", "DARK GRAY"))
    l_maniaarrows.push(new ManiaArrow("Evergreen", "EVERGREEN"))
    l_maniaarrows.push(new ManiaArrow("Hot Pink", "HOT PINK"))
    l_maniaarrows.push(new ManiaArrow("Light Gray", "LIGHT GRAY"))
    l_maniaarrows.push(new ManiaArrow("Orange", "ORANGE"))
    l_maniaarrows.push(new ManiaArrow("Purple", "PURPLE"))
    l_maniaarrows.push(new ManiaArrow("Red", "RED"))
    l_maniaarrows.push(new ManiaArrow("Yellow", "YELLOW"))
}

; Define ManiaBar Objects
defineManiaBars() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mbo_<type := new ManiaBar(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Bars Objects
    l_maniabars.push(new ManiaBar("Blue", "BLUE"))
    l_maniabars.push(new ManiaBar("Cyan", "CYAN"))
    l_maniabars.push(new ManiaBar("Dark Gray", "DARK GRAY"))
    l_maniabars.push(new ManiaBar("Evergreen", "EVERGREEN"))
    l_maniabars.push(new ManiaBar("Hot Pink", "HOT PINK"))
    l_maniabars.push(new ManiaBar("Light Gray", "LIGHT GRAY"))
    l_maniabars.push(new ManiaBar("Orange", "ORANGE"))
    l_maniabars.push(new ManiaBar("Purple", "PURPLE"))
    l_maniabars.push(new ManiaBar("Red", "RED"))
    l_maniabars.push(new ManiaBar("Yellow", "YELLOW"))
}

; Define ManiaDot Objects
defineManiaDots() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mdo_<type := new ManiaDot(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Dots Objects
    l_maniadots.push(new ManiaDot("Blue", "BLUE"))
    l_maniadots.push(new ManiaDot("Cyan", "CYAN"))
    l_maniadots.push(new ManiaDot("Dark Gray", "DARK GRAY"))
    l_maniadots.push(new ManiaDot("Evergreen", "EVERGREEN"))
    l_maniadots.push(new ManiaDot("Hot Pink", "HOT PINK"))
    l_maniadots.push(new ManiaDot("Light Gray", "LIGHT GRAY"))
    l_maniadots.push(new ManiaDot("Orange", "ORANGE"))
    l_maniadots.push(new ManiaDot("Purple", "PURPLE"))
    l_maniadots.push(new ManiaDot("Red", "RED"))
    l_maniadots.push(new ManiaDot("Yellow", "YELLOW"))
}

; Define UIColor Objects
defineUIColors() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new UIColor, follow the following pattern:
        ho_<type> := new UIColor(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Ad UIColors to list of UIColor Objects
    l_uicolors.push(new UIColor("Cyan", "CYAN", 0))
    l_uicolors.push(new UIColor("Dark Gray", "DARK GRAY", 0))
    l_uicolors.push(new UIColor("Evergreen", "EVERGREEN", 0))
    l_uicolors.push(new UIColor("Hot Pink", "HOT PINK", 0))
    l_uicolors.push(new UIColor("Light Gray", "LIGHT GRAY", 0))
    l_uicolors.push(new UIColor("Orange", "ORANGE", 0))
    l_uicolors.push(new UIColor("Purple", "PURPLE", 0))
    l_uicolors.push(new UIColor("Red", "RED", 0))
    l_uicolors.push(new UIColor("Yellow", "YELLOW", 0))
    l_uicolors.push(new UIColor("Blue", "BLUE", 1))
}

; Define Player Objects
definePlayers() {
    global                                                      ; Set global Scope inside Function
    /*
        To define a new player with additional options, follow this pattern:
            local po_<name> := new Player("<Player Name>", "<Player Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.add("<Option1 Name>", "<Option1 Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.add("<Option2 Name>", "<Option2 Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.require := 1

        For Players without additional skin options, please see below
    */

    ; Add Mandatory Options to Player Objects
    ; Abyssal
    local po_abyssal := new Player("Abyssal", "ABYSSAL", 0)
    po_abyssal.add("Purple & Pink Combo", "PINK+PURPLE", 0)
    po_abyssal.add("Blue & Red Combo", "BLUE+RED COMBO VER", 0)
	po_abyssal.require := 1

    ; Axarious
    local po_axarious := new Player("Axarious", "AXARIOUS", 0)
    po_axarious.add("Without Slider Ends", "-SLIDERENDS", 0)
    po_axarious.add("With Slider Ends", "+SLIDERENDS", 0)
	po_axarious.require := 1

    ; Azer
    local po_azer := new Player("Azer", "AZER", 0)
    po_azer.add("2017", "2017", 0)
    po_azer.add("2018", "2018", 0)
    po_azer.require := 1

    ; azr8 & GayzMcGee
    local po_azr8 := new Player("azr8 + GayzMcGee", "GAYZR8", 0)
    po_azr8.add("Fire", "FIRE", 0)
    po_azr8.add("ICE", "ICE", 0)
	po_azr8.require := 1

    ; BeastrollMC (YungLing)
    local po_beasttrollmc := new Player("BeasttrollMC", "BEASTTROLLMC", 0)
    po_beasttrollmc.add("v1.3", "V1.3", 0)
    po_beasttrollmc.add("v3", "V3", 0)
    po_beasttrollmc.add("v4", "V4", 0)
    po_beasttrollmc.add("v5", "V5", 0)
    po_beasttrollmc.add("v6", "V6", 0)
    po_beasttrollmc.require := 1

    ; bikko
    local po_bikko := new Player("Bikko", "BIKKO", 1)
    po_bikko.add("Without Slider Ends", "-SLIDERENDS", 1)
    po_bikko.add("With Slider Ends", "+SLIDERENDS", 1)
	po_bikko.require := 1

    ; Comfort
    local po_comfort := new Player("Comfort", "COMFORT", 0)
    po_comfort.add("Standard", "STANDARD", 0)
    po_comfort.add("Nautz", "NAUTZ", 0)
	po_comfort.require := 1

    ; Cookiezi (chocomint)
    local po_cookiezi := new Player("Cookiezi", "COOKIEZI", 0)
    po_cookiezi.add("Burakku Shippu", "BURAKKU SHIPU", 0)
    po_cookiezi.add("Chocomint", "CHOCOMINT", 0)
    po_cookiezi.add("nathan on osu", "NATHAN", 0)
    po_cookiezi.add("Panimi", "PANIMI", 0)
    po_cookiezi.add("Seoulless", "SEOULLESS", 0)
    po_cookiezi.add("Shigetora", "SHIGETORA", 1)
    po_cookiezi.require := 1

    ; Dustice
    local po_dustice := new Player("Dustice", "DUSTICE", 0)
    po_dustice.add("Outer Slider Circle", "+SLIDERCIRCLE", 0)
    po_dustice.add("No Outer Slider Circle", "-SLIDERCIRCLE", 0)
	po_dustice.require := 1

    ; Emilia
    local po_emilia := new Player("Emilia", "EMILIA", 0)
    po_emilia.add("New", "NEW", 0)
    po_emilia.add("Old", "OLD", 0)
    po_emilia.require := 1

    ; FlyingTuna
    local po_flyingtuna := new Player("FlyingTuna", "FLYINGTUNA", 0)
    po_flyingtuna.add("MathiTuna", "MATHITUNA", 0)
    po_flyingtuna.add("Selyu", "SELYU", 0)
    po_flyingtuna.require := 1

    ; idke
    local po_idke := new Player("idke", "IDKE", 0)
    po_idke.add("Old without Slider Ends", "OLD\-SLIDERENDS", 1)
    po_idke.add("Old with Slider Ends", "OLD\+SLIDERENDS", 1)
    po_idke.add("New without Slider Ends", "NEW\-SLIDERENDS", 0)
    po_idke.add("New with Slider Ends", "NEW\+SLIDERENDS", 0)
	po_idke.require := 1

    ; Karhy
    local po_karthy := new Player("Karthy", "KARTHY", 0)
    po_karthy.add("azr8", "KARTHY AZR8", 0)
    po_karthy.add("v5", "KARTHY V5", 0)
    po_karthy.require := 1

    ; Mathi
    local po_mathi := new Player("Mathi", "MATHI", 0)
    po_mathi.add("Flat Hitcircle", "-SHADER", 0)
    po_mathi.add("Shaded Hitcircle", "+SHADER", 0)
	po_mathi.require := 1

    ; Rafis
    local po_rafis := new Player("Rafis", "RAFIS", 0)
    po_rafis.add("Blue", "BLUE", 0)
    po_rafis.add("White", "WHITE", 0)
    po_rafis.add("Yellow", "YELLOW", 0)
    po_rafis.require := 1

    ; Rohulk
    local po_rohulk := new Player("Rohulk", "ROHULK", 0)
    po_rohulk.add("Flat Approach Circle", "-GAMMA", 0)
    po_rohulk.add("Gamma Approach Circle", "+GAMMA", 0)
	po_rohulk.require := 1


    ; rustbell
    local po_rustbell := new Player("Rustbell", "RUSTBELL", 0)
    po_rustbell.add("Without Hit-300 Explosions", "-EXPLOSIONS", 0)
    po_rustbell.add("With Hit-300 Explosions", "+EXPLOSIONS", 0)
	po_rustbell.require := 1

    ; talala
    local po_talala := new Player("talala", "TALALA", 0)
    po_talala.add("White Numbers", "WHITE NUMBERS", 0)
    po_talala.add("Cyan Numbers", "CYAN NUMBERS", 0)
	po_talala.require := 1

    ; Vaxei
    local po_vaxei := new Player("Vaxei", "VAXEI", 0)
    po_vaxei.add("Blue Slider Border", "BLUE SLIDER", 0)
    po_vaxei.add("Red Slider Border", "RED SLIDER", 0)
	po_vaxei.require := 1

    ; WhiteCat
    local po_whitecat := new Player("WhiteCat", "WHITECAT", 0)
    po_whitecat.add("DT", "DT", 0)
    po_whitecat.add("No Mod", "NOMOD", 0)
    po_whitecat.add("Coffee", "COFFEE", 0)
    po_whitecat.require := 1

    ; Xilver & Recia
    local po_xilver := new Player("Xilver X Recia", "XILVER X RECIA", 0)
    po_xilver.add("Orange & Dots", "ORANGE DOT", 0)
    po_xilver.add("Blue & Plus", "BLUE CROSS", 0)
	po_xilver.require := 1

    /*
        Now that all options have been defined, we'll need to add each of our player objects
        to the approrpriate list.  While things are currently pushed to the list in
        alphabetical order, it is essentially irrelevant as the list will be sorted prior to
        being added the GUI...but, it does make it a bit easier to track stuff, especially when
        adding a new player to the list.

        To Add players without any additional options, simply follow the pattern:
            l_players.push(new Player("<Player Name>", "<Player Directory Name>"))

        To Add players WITH options, simply follow the pattern:
            l_players.push(po_<name>)
    */

    ; Add Players to list of Player Objects
    l_players.push(new Player("404AimNotFound", "404ANF", 0))
    l_players.push(po_abyssal)
    l_players.push(new Player("Andros", "ANDROS", 0))
    l_players.push(new Player("Angelsim", "ANGELSIM", 0))
    l_players.push(po_axarious)
    l_players.push(po_azer)
    l_players.push(po_azr8)
    l_players.push(new Player("badeu", "BADEU", 0))
    l_players.push(po_beasttrollmc)
    l_players.push(po_bikko)
    l_players.push(new Player("Bubbleman", "BUBBLEMAN", 0))
    l_players.push(po_comfort)
    l_players.push(po_cookiezi)
    l_players.push(new Player("Doomsday", "DOOMSDAY", 0))
    l_players.push(po_dustice)
    l_players.push(po_emilia)
    l_players.push(po_flyingtuna)
    l_players.push(new Player("Freddie Benson", "FREDDIE BENSON", 0))
    l_players.push(new Player("FunOrange", "FUNORANGE", 0))
    l_players.push(new Player("-GN", "GN", 0))
    l_players.push(new Player("hvick225", "HVICK225", 0))
    l_players.push(po_idke)
    l_players.push(new Player("Informous", "INFORMOUS", 0))
    l_players.push(po_karthy)
    l_players.push(new Player("Koi Fish", "KOI FISH", 0))
    l_players.push(po_mathi)
    l_players.push(new Player("Monko2k", "MONKO2K", 0))
    l_players.push(po_rafis)
    l_players.push(po_rohulk)
    l_players.push(new Player("rrtyui", "RRTYUI", 0))
    l_players.push(po_rustbell)
    l_players.push(new Player("RyuK", "RYUK", 0))
    l_players.push(new Player("Seysant", "SEYSANT", 0))
    l_players.push(new Player("Sotarks", "SOTARKS", 0))
    l_players.push(po_talala)
    l_players.push(new Player("Toy", "TOY", 0))
    l_players.push(new Player("Tranquil-ity", "TRANQUIL-ITY", 0))
    l_players.push(new Player("Varvalian", "VARVALIAN", 0))
    l_players.push(po_vaxei)
    l_players.push(po_whitecat)
    l_players.push(new Player("WubWoofWolf", "WWW", 0))
    l_players.push(po_xilver)
    l_players.push(new Player("Yaong", "YAONG", 0))
}


; Browse for a Directory
BrowseDirectory(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    Gui, TopBar: Submit, NoHide                                 ; Get +vVar values without hiding GUI

    ; Provide a Directory/Tree Browser
    try {
		; Provide modal dialog
        Gui, TopBar: +OwnDialogs                                ; Make Dialog Modal
        FileSelectFolder, d_select, %d_game%, 0, Select Game Folder
        Gui, TopBar: -OwnDialogs                                ; Disable Modal Dialogs

		; return value, if selected
		if (d_select) {
			GuiControl, TopBar:, GamePath, %d_select%
			d_game := d_select
            updateUIColorColors(1)                              ; Update selected UIColors
            updateTreeViewBackground()                          ; Update Combo Colors
		} 
    } catch e
        MsgBox,,%n_app%, An Exception was thrown!`nSpecifically: %e%
}

; Get name of a directory based on string -- Args: $1: Name to search for, $2: Path to search
getDirectoryName(name, path) {
    ; Handle invalid input
    if (!FileExist(path))                                       ; If path doesn't exist, return
        return

    ; Define Local Variables
    dir := ""                                                   ; Define return val as passed name

    ; Loop through a given path
    Loop, Files, %path%\*, D                                    ; return only directories
    {
        if (RegExMatch(A_LoopFileName, "i)"name)) {             ; If skin name is found
			if (RegExMatch(A_LoopFileName, "i)"name " " n_ver)) {
                dir := A_LoopFileName                           ; Set return val to name
                break                                           ; Break loop
			}
            if (FileExist(path "\" A_LoopFileName "\" d_conf)) {
                dir := A_LoopFileName                           ; Set return val to name
                break                                           ; Break loop
            }
        }
    }
    return dir                                                  ; return value
}

; Reset Skin -- Args: $1: Type
resetSkin(type) {
    global                                                      ; Set global Scope inside Function

    ; Define Local variables
    local src := GamePath "\Skins"                              ; Source directory
    local dst := GamePath "\Skins"                              ; Destination directory
    local skin := getDirectoryName(n_skin, src)                 ; Skin name

    ; Handle skin not found
    if (!skin) {
        MsgBox,,RESET ERROR, Cannot locate skin in `"%src%`"    ; Notify user of error
        return 1                                                ; return
    }

    ; Update local vars
    src := src "\" skin "\" d_conf                              ; Update source directory
    dst := dst "\" skin                                         ; Update destination directory
    
    ; Reset Skin
    StringLower,type,type                                       ; Set all characters in type to lowercase
    if (type = "gameplay") {                                    ; If type is gameplay
        FileCopy, %src%\%d_default_gameplay%\*.*, %dst%, 1      ; Copy reset-gameplay elements to dst
        FileDelete, %dst%\cursormiddle@2x.png                   ; Delete CursorMiddle
        if (!UIColorOptionSaveIni) && (var_selected_form = "UIColor") {     ; If Overwrite Skin.ini is unchecked
            updateUIColorColors(UIColorOptionSaveIni)                       ; Update UIColor Combo/Slider Colors
            updateTreeViewBackground()                                      ; Update TreeView BG Colors
        }
    } else if (type = "uicolor") {                              ; If type is uicolor
        FileCopy, %src%\%d_default_uicolor%\*.*, %dst%, 1       ; Copy reset-uicolor elements to dst
    } else if (type = "hitsounds") {                            ; If type is hitsounds
        FileCopy, %src%\%d_default_hitsounds%\*.*, %dst%, 1     ; Copy reset-hitsounds elements to dst
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
    local form := var_selected_form								; Selected Form
    StringLower, form, form                                     ; Convert %form% to all lowercase

    ; Handle skin not found
    if (!skin) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate skin in " src, "SideBar")
        return 1                                                ; return
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
            local d_opt4 := ""                                  ; Directory of Option4
            
            ; Get Directories for Options
            for i, j in l_cursors {
                if (j.name = CursorElementOptionColor)
                    d_opt1 := j.elementsDir "\" j.cursorsDir "\" j.cursorColorDir "\" j.dir
                if (j.name = CursorElementOptionTrail)
                    d_opt2 := j.elementsDir "\" j.cursorsDir "\" j.cursorTrailDir "\" j.dir
                if (j.name = CursorElementOptionSmoke)
                    d_opt3 := j.elementsDir "\" j.cursorsDir "\" j.cursorSmokeDir "\" j.dir
            }
            
            ; Handle Cursor Trail == None && Solid Cursor Trail
            if (CursorElementOptionTrail = "None") {            ; If "None" is selected
				d_opt2 := d_opt1 "\..\..\" d_cursor_notrail	    ; Set path to one directory higher than opt1, followed by d_cursor_notrail
            } else if (CursorElementOptionTrailSolid)
                d_opt4 := d_opt1 "\..\..\" d_cursor_solidtrail

            ; Verify Paths Exist
            if !(FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }
            if !(FileExist(src "\" d_opt2)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt2, "ElementForm")
                return
            }
            if !(FileExist(src "\" d_opt3)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt3, "ElementForm")
                return
            }
			if !(FileExist(src "\" d_opt4)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt4, "ElementForm")
                return
			}

			; Delete Solid-Trail Image
            FileDelete, %dst%\cursormiddle@2x.png

			; Copy Cursor Color, Trail and Smoke to Destination
			FileCopy, %src%\%d_opt3%\*.*, %dst%, 1
			FileCopy, %src%\%d_opt2%\*.*, %dst%, 1
			FileCopy, %src%\%d_opt1%\*.*, %dst%, 1

			; If SolidTrail enabled, Copy to Destination
			if (d_opt4)
				FileCopy, %src%\%d_opt4%\*.*, %dst%, 1
        } else if (etype = "hitburst") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_hitbursts {
                if (j.name = HitburstElementOptionType)
                    d_opt1 := j.elementsDir "\" j.hitburstsDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "reverse arrow") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_reversearrows {
                if (j.name = ReverseArrowElementOptionType)
                    d_opt1 := j.elementsDir "\" j.reverseArrowDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "sliderball") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_sliderballs {
                if (j.name = SliderballElementOptionType)
                    d_opt1 := j.elementsDir "\" j.sliderballDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Base Hitburst to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "scorebar bg") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_scorebarbgs {
                if (j.name = ScorebarBGElementOptionType)
                    d_opt1 := j.elementsDir "\" j.scorebarbgDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy ScorebarBG to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1
        } else if (etype = "circle numbers") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_circlenumbers {
                if (j.name = CircleNumberElementOptionType)
                    d_opt1 := j.elementsDir "\" j.circleNumberDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy CircleNumbers to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1

            ; Update Hitcircle Overlap -- Dots must be 48; otherwise default
            if (RegExMatch(CircleNumberElementOptionType, "i).*dot.*"))
                updateHitcircleOverlap(48)
            else
                updateHitcircleOverlap()
        } else if (etype = "hitsounds") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_hitsounds {
                if (j.name = HitsoundElementOptionType)
                    d_opt1 := j.elementsDir "\" j.hitsoundDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Hitsound Pack Files to Destination
            resetSkin("hitsounds")                              ; Reset Hitsound elements, to avoid bad-mixes
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1              ; Update Hitsounds
        } else if (etype = "follow points") {
            local d_opt1 := ""                                  ; Directory of Option 1

            ; Get Directories for Options
            for i, j in l_followpoints {
                if (j.name = FollowPointElementOptionType)
                    d_opt1 := j.elementsDir "\" j.followpointDir "\" j.dir
            }

            ; Verify Paths Exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Hitsound Pack Files to Destination
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1              ; Update FollowPoints
        } else if (etype = "mania") {
            local mtype := ManiaElementOptionType               ; Get Mania Type
            local d_opt1                                        ; Directory of Selected Mania Pack

            ; Get Directories for Options
            StringLower, mtype, mtype                           ; Set mtype to lowercase
            if (mtype = "arrow") {
                for i, j in l_maniaarrows {
                    if (j.name = ManiaElementArrowOptionColor) {
                        d_opt1 := j.maniaDir "\" j.arrowDir "\" j.dir
                    }
                }
            } else if (mtype = "bar") {
                for i, j in l_maniabars {
                    if (j.name = ManiaElementBarOptionColor) {
                        d_opt1 := j.maniaDir "\" j.barDir "\" j.dir
                    }
                }
            } else if (mtype = "dot") {
                for i, j in l_maniadots {
                    if (j.name = ManiaElementDotOptionColor) {
                        d_opt1 := j.maniaDir "\" j.dotDir "\" j.dir
                    }
                }
            } else {
                modalMsgBox(n_app ":`tApply Error", "Unrecognized Mania Type:`t" mtype)
                return
            }

            ; Verify Paths exist
            if (!FileExist(src "\" d_opt1)) {
                modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "ElementForm")
                return
            }

            ; Copy Mania<Type> to Current Mania
            FileCopyDir, %src%\%d_opt1%, %src%\%d_mania_current%, 1
        }
    } else if (form = "uicolor") {
        local d_opt1 := ""                                      ; Directory of Option 1

        ; Get Directories for Options
        for i, j in l_uicolors {
            if (j.name = UIColorOptionColor)
                d_opt1 := j.uiColorDir "\" j.dir
        }

        ; Verify Paths Exist
        if (!FileExist(src "\" d_opt1)) {
            modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "UIColorForm")
            return
        }

        ; Copy Base UIColor to Destination
        FileCopy, %src%\%d_opt1%\*.png, %dst%, 1
        FileCopy, %src%\%d_opt1%\*.jpg, %dst%, 1

        ; If Preserve INI changes not requested, replace skin.ini file
        if (UIColorOptionSaveIni)
            FileCopy, %src%\%d_opt1%\skin.ini, %dst%, 1

        ; If Instafade Enabled
        updateInstafadeCircles(UIColorOptionInstafade)
        
        ; Update Requested Combo Colors
        removeComboColors()
        updateComboColor(1, var_combo_color_1)
        if (UIColorComboColorCount >= 2)
            updateComboColor(2, var_combo_color_2)
        if (UIColorComboColorCount >= 3)
            updateComboColor(3, var_combo_color_3)
        if (UIColorComboColorCount >= 4)
            updateComboColor(4, var_combo_color_4)
        if (UIColorComboColorCount >= 5)
            updateComboColor(5, var_combo_color_5)
        

        ; Update SliderBorder
        updateSliderborderColor(var_slider_border_color)
        updateSlidertrackColor(var_slider_track_color)
    } else if (form = "player") {
        local d_opt1 := ""                                      ; Directory of Option 1
        local d_opt2 := ""                                      ; Directory of Option 2
        local cmiddle := 0                                      ; Check to determine if cursormiddle should remain

        ; Get Directories for Options
        for i, j in l_players {
            if (j.name = PlayerOptionName) {
                d_opt1 := j.playersDir "\" j.dir
                if (j.listNames) {
                    for k, l in j.getArray("listNames") {
                        if (l = PlayerOptionVersion) {
                            local dirs := j.getArray("listDirs")
                            local mids := j.getArray("listMiddle")
                            d_opt2 := d_opt1 "\" dirs[k]
                            cmiddle := mids[k]
                            dirs :=
                        }
                    }
                } else
                    cmiddle := j.mids
            }
        }

        ; Verify Paths Exist
        if (!FileExist(src "\" d_opt1)) {
            modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt1, "PlayerForm")
            return
        }
        if (d_opt2) && (!FileExist(src "\" d_opt2)) {
            modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" src "\" d_opt2, "PlayerForm")
            return
        }

        ; Reset Gameplay Elements, to prevent unintended mixing
        resetSkin("gameplay")

        ; If option is defined && required
        if (d_opt2)
            FileCopy, %src%\%d_opt2%\*.*, %dst%, 1
        else
            FileCopy, %src%\%d_opt1%\*.*, %dst%, 1

        ; Remove Files if necessary
        if (cmiddle)
            return
        FileDelete, %dst%\cusormiddle@2x.png
    }
}

; Hex to RGB -- Args: $1: Color ([0-9A-F]{6})
hexToRGB(color) {    
    ; Define local variables
    a_dec := []                                                 ; array of decimal values

    ; split color into each hex value
    Loop, 6
    {
        a_dec.push(hexToDec(SubStr(color, A_Index, 1)))         ; Convert character to decimal
    }

    ; return RGB as an array
    return [(a_dec[1] * 16 + a_dec[2]), (a_dec[3] * 16 + a_dec[4]), (a_dec[5] * 16 + a_dec[6])]
}

; RGB To Hex -- Args: $1: RGB Array
rgbToHex(arr) {
    ; handle invalid input
    if (arr.MaxIndex() != 3)
        return

    ; Define local variables
    rx := decToHex(Floor(arr[1] / 16))
    gx := decToHex(Floor(arr[2] / 16))
    bx := decToHex(Floor(arr[3] / 16))
    ry := decToHex(Mod(arr[1], 16))
    gy := decToHex(Mod(arr[2], 16))
    by := decToHex(Mod(arr[3], 16))

    ; return Hex as String
    return "" . rx . ry . gx . gy . bx . by
}

; Convert decimal value (0-15) to a hex character -- Args: $1: value
decToHex(val) {
    ; handle invlaid input
    if (val < 0) || (val > 15)
        return

    ; Find and return value
    for i, j in ["A", "B", "C", "D", "E", "F"] {
        if ((i + 9) = val)
            return j
    }
    return val
}

; Convert Hex to Decimal (0-F) -- Args: $1: Value
hexToDec(val) {
    ; Handle non-hex input
    if (RegExMatch(val, "i)[^0-9A-F]"))
        return

    ; Find and return value
    for i, j in ["A", "B", "C", "D", "E", "F"] {
        if (val = j)
            return (i + 9)
    }
    return val
}

; Get color of pixel color at coordinates -- Args: $1: X Position; $2: Y Position
getCoordinateColor(x, y) {
    ; Get and format color
    PixelGetColor, out, x, y, RGB
    StringRight, out, out, 6
    SetFormat, IntegerFast, hex
    SetFormat, IntegerFast, D

    ; return out
    return out
}

; Get ComboColor from Selected UI Color -- Args: $1: Combo Count (1-5); $2: Path to UI Color (relative to Skin path)
getComboColor(cnt, path) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\" path "\skin.ini"  ; Skin.ini file to pull colors from
    local str_color := ""                                       ; String of RGB values

    ; Handle path = "none" --> get current Skin.ini
    local lpath
    StringLower, lpath, path
    if (lpath = "none")
        ini_og := src_path "\" skin_dir "\skin.ini"             ; Get current skin path

    ; Read through file, searching for correct combo color
    Loop, Read, %ini_og%
    {
        if (RegExMatch(A_LoopReadLine, ")^Combo" cnt ":\s*")) {
            str_color := RegExReplace(A_LoopReadLine, "i)^.*:\s*(.*).*$", "$1")
            break
        }
    }

    ; Handle if str_color is not set
    if (!str_color)
        return ""

    ; return Hex color of extracted color
    return rgbToHex(StrSplit(str_color, ","))
}

; Get SliderBorderColor from selected UI Color -- Args: $1: Path to UI Color (relative to Skin path) 
getSliderborderColor(path) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\" path "\skin.ini"  ; Skin.ini file to pull colors from
    local str_color := ""                                       ; String of RGB values

    ; Handle path = "none" --> get current Skin.ini
    local lpath
    StringLower, lpath, path
    if (lpath = "none")
        ini_og := src_path "\" skin_dir "\skin.ini"             ; Get current skin path

    ; Read through file, searching for correct combo color
    Loop, Read, %ini_og%
    {
        if (RegExMatch(A_LoopReadLine, ")^SliderBorder:\s*")) {
            str_color := RegExReplace(A_LoopReadLine, "i)^.*:\s*(.*).*$", "$1")
            break
        }
    }

    ; Handle if str_color is not set
    if (!str_color)
        return ""
    
    ; return Hex color of extracted color
    return rgbToHex(StrSplit(str_color, ","))
}

; Get SliderTrackOverrideColor from selected UI Color -- Args: $1: Path to UI Color (relative to Skin path) 
getSlidertrackColor(path) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\" path "\skin.ini"  ; Skin.ini file to pull colors from
    local str_color := ""                                       ; String of RGB values

    ; Handle path = "none" --> get current Skin.ini
    local lpath
    StringLower, lpath, path
    if (lpath = "none")
        ini_og := src_path "\" skin_dir "\skin.ini"             ; Get current skin path

    ; Read through file, searching for correct combo color
    Loop, Read, %ini_og%
    {
        if (RegExMatch(A_LoopReadLine, ")^SliderTrackOverride:\s*")) {
            str_color := RegExReplace(A_LoopReadLine, "i)^.*:\s*(.*).*$", "$1")
            break
        }
    }

    ; Handle if str_color is not set
    if (!str_color)
        return ""
    
    ; return Hex color of extracted color
    return rgbToHex(StrSplit(str_color, ","))
}

; Remove Combo Colors 2-5 in Skin INI file
removeComboColors() {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file

    ; Build temporary skin file, modifying the specified line(s)
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, "i)^Combo[2-5]:\s*"))
            continue
        FileAppend, %A_LoopReadLine%`n
    }

    ; Update Skin.ini
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete temporary
}

; Update Combo Colors in Skin INI file -- Args: $1: Combo1-5; $2: Color (hex)
updateComboColor(cnt, col) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file
    local hex_rgb := hexToRGB(col)                              ; Get RGB Values of the passed hex color
    local col_found := 0                                        ; Flag to denote if the color was found
    
    ; Build temporary skin file, modifying the specified line
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, "i)^Combo" cnt ":\s*")) {
            FileAppend, % "Combo" cnt ": " hex_rgb[1] "," hex_rgb[2] "," hex_rgb[3] "`n"
            col_found := 1
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }

    ; If color was found and updated, update skin.ini and return
    if (col_found) {
        FileCopy, %ini_tmp%, %ini_og%, 1                        ; Replace original with temporary
        FileDelete, %ini_tmp%                                   ; Delete temporary
        return
    }
    
    ; If color was not found, add to skin
    FileDelete, %ini_tmp%                                       ; Delete previous temporary
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, "i)^Combo" (cnt - 1) ":\s*")) {
            FileAppend, %A_LoopReadLine%`n
            FileAppend, % "Combo" cnt ": " hex_rgb[1] "," hex_rgb[2] "," hex_rgb[3] "`n"
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }
    
    ; Update skin.ini & return
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete temporary
}

; Update Slider Border Color -- Args: $1: Color (hex)
updateSliderborderColor(col) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file
    local hex_rgb := hexToRGB(col)                              ; Get RGB Values of the passed hex color

    ; Build Temporary skin file, modifying the specified line
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, ")^SliderBorder:\s*")) {
            FileAppend, % "SliderBorder: " hex_rgb[1] "," hex_rgb[2] "," hex_rgb[3] "`n"
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }

    ; Update Skin.ini file
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete temporary 
}

; Update Slidertrack Override Color -- Args: $1: Color (hex)
updateSlidertrackColor(col) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file
    local hex_rgb := hexToRGB(col)                              ; Get RGB Values of the passed hex color

    ; Build Temporary skin file, modifying the specified line
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, ")^SliderTrackOverride:\s*")) {
            FileAppend, % "SliderTrackOverride: " hex_rgb[1] "," hex_rgb[2] "," hex_rgb[3] "`n"
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }

    ; Update Skin.ini file
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete temporary 
}

; Update Instafade Circles -- Args: $1: Enable/Disable (def: 0)
updateInstafadeCircles(insta) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file
    local fade_isnt := 160                                      ; Instant-fade value
    local fade_norm := 3                                        ; Normal-fade value

    ; Build Temporary skin file, modifying the specified lines
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, ")^HitCircleOverlap:\s*[0-9]+")) {
            FileAppend, % "HitCircleOverlap: " (insta = 1 ? fade_inst : fade_norm) "`n"
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }

    ; Update Skin.ini file
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete temporary 
}

; Update Hitcircle Overlap value -- Args: $1: Overlap Value (integer)
updateHitcircleOverlap(val := 3) {
    global                                                      ; Set scope to global

    ; Define local variables
    local src_path := GamePath "\Skins"                         ; Define the path to the skins directory
    local skin_dir := getDirectoryName(n_skin, src_path)        ; Get the directory of the skin
    local ini_og := src_path "\" skin_dir "\skin.ini"           ; Skin.ini file to pull colors from
    local ini_tmp := d_asset "\new_skin.ini"                    ; Temporary skin.ini file

    ; Build Temporary Skin file, modifying the specified line
    Loop, Read, %ini_og%, %ini_tmp%
    {
        if (RegExMatch(A_LoopReadLine, "i)^HitCircleOverlap:")) {
            FileAppend, % "HitCircleOverlap: " val "`n"
            continue
        }
        FileAppend, %A_LoopReadLine%`n
    }
    
    ; Update SKin.ini file
    FileCopy, %ini_tmp%, %ini_og%, 1                            ; Replace original with temporary
    FileDelete, %ini_tmp%                                       ; Delete Temporary
}

; Build Positioning Array -- Args: $1: Number of Iterations; $2: Number of elements; $3: Offset; $4: Max Height/Width; $5: Padding Amount; $6: Padding Multiplier; $7: Subtract Padding? (def: 0)
buildPosArray(iterations, elements, offset := 0, max := 0, padding := 0, multiplier := 0, subtract := 0) {
    ; Define local variables
    positions := []

    ; Build Array
    Loop, %iterations%
    {
        if (A_Index = 1)
            positions.push(offset + padding)
        else {
            if (subtract)
                positions.push(((max / elements) * A_Index) - (max / elements) - (padding * multiplier))
            else
                positions.push(((max / elements) * A_Index) - (max / elements) + (padding * multiplier))
        }
    }

    ; return Posititions array
    return positions
}

; Convert Object Array as a string (name) -- Args: $1: Array; $2: Delimiter (def: ',')
getObjNamesAsString(arr, delim := ",") {
    ; Define local variables
    str := ""

    ; Builds String
    for k, v in arr {
        if (!str)
            str := v.name
        else
            str .= delim . v.name
    }

    ; return String
    return str
}

; Get Default/Standard Option from Array -- Args: $1: Array
getDefaultObject(arr) {
    ; Determine Default Option
    for k, v in arr {
        if (v.original)
            return v.name
    }

    ; return empty string
    return ""
}

; Get Index of substring in ObjNamesAsString -- Args: $1: Haystack; $2: Needle, $3: Delimiter (def: ',')
getIndexOfSubstringInString(haystack, needle, delim := ",") {
    ; Determine index
    for k, v in (StrSplit(haystack, delim)) {
        if (v = needle)
            return k
    }

    ; return Null
    return
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
        if (o is integer)
            this.original := o ? 1 : 0
    }

    ; Methods
    ; Append String to RootPath
    addToRootPath(val) {
        if (this.rootDir != val)
            this.rootDir += val
    }

    ; return if Element is Original (True/False)
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
	Static cursorColorDir := "COLOR"							; Name of the Cursor Colors Directory
	Static cursorSmokeDir := "SMOKE"							; Name of the Cursor Smoke Directory
	Static cursorTrailDir := "TRAIL"							; Name of the Cursor Trail Directory

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

; ##----------------------------------------##
; #|        Class: Element: Scorebar BG     |#
; ##----------------------------------------##
Class ScorebarBG Extends Element {
    ; Instance Variables
    name :=                                                     ; String: ScorebarBG Name (type)
    dir :=                                                      ; String: Name of the ScorebarBG's Directory

    ; Static Variables
    Static scorebarbgDir := "SCOREBAR BGS"                      ; Name of the ScorebarBG Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("scorebarbg", scorebarbgDir, o)
        this.name := n
        this.dir := d
    }
}

; ##----------------------------------------##
; #|        Class: Element: Numbers         |#
; ##----------------------------------------##
Class CircleNumber Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Circle Number's Name (type)
    dir :=                                                      ; String: Name of the Circle Number's Directory

    ; Static Variables
    Static circleNumberDir := "NUMBERS"                         ; Name of the Circle Numbers Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("numbers", circleNumberDir, o)
        this.name := n
        this.dir := d
    }
}

; ##--------------------------------------------##
; #|        Class: Element: Hitsound Pack       |#
; ##--------------------------------------------##
Class Hitsound Extends Element {
    ; Instance Variables
    name :=                                                     ; String: Hitsound Pack Name (type)
    dir :=                                                      ; String: Name of the Hitsound Pack's Directory

    ; Static Variables
    Static hitsoundDir := "HITSOUNDS"                           ; Name of the Hitsound Packs Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitsound", hitsoundDir, o)
        this.name := n
        this.dir := d
    }
}

; ##--------------------------------------------##
; #|        Class: Element: Follow Point        |#
; ##--------------------------------------------##
Class FollowPoint Extends Element {
    ; Instance Variables
    name :=                                                     ; String: FollowPoint Name (type)
    dir :=                                                      ; String: Name of the FollowPoint's Directory

    ; Static Variables
    Static followpointDir := "FOLLOWPOINTS"                     ; Name of the FollowPoint Pack's Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("followpoint", followpointDir, o)
        this.name := n
        this.dir := d
    }
}

; ##---------------------------##
; #|        Class: Mania       |#
; ##---------------------------##
Class Mania {
    ; Instance Variables
    type :=                                                     ; String: Mania Type (Arrow/Bar/Dot)
    rootDir :=                                                  ; String: Name of the Type's directory

    ; Static Variables
    Static maniaDir := "MANIA PACKS"                            ; Name of the mania packs directory

    ; Constructor
    __new(t, r) {
        this.type := t
        this.rootDir := r
    }

    ; Methods
    ; Append String to RootPath
    addToRootPath(val) {
        if (val = this.rootDir)
            return
        this.rootDir += val
    }
}

; ##-----------------------------------------##
; #|        Class: Mania: ManiaArrow         |#
; ##-----------------------------------------##
Class ManiaArrow Extends Mania {
    ; Instance Variables
    name :=                                                     ; String: Name of the Color of Arrow
    dir :=                                                      ; String: Name of the color's directory

    ; Static Variables
    Static arrowDir := "ARROWS"                                 ; Name of the Arrows directory

    ; Constructor
    __new(n, d) {
        base.__new("arrow", arrowDir)
        this.name := n
        this.dir := d
    }
}

; ##-----------------------------------------##
; #|        Class: Mania: ManiaBar           |#
; ##-----------------------------------------##
Class ManiaBar Extends Mania {
    ; Instance Variables
    name :=                                                     ; String: Name of the Color of Bar
    dir :=                                                      ; String: Name of the color's directory

    ; Static Variables
    Static barDir := "BARS"                                     ; Name of the Bars directory

    ; Constructor
    __new(n, d) {
        base.__new("bar", barDir)
        this.name := n
        this.dir := d
    }
}

; ##-----------------------------------------##
; #|        Class: Mania: ManiaDot           |#
; ##-----------------------------------------##
Class ManiaDot Extends Mania {
    ; Instance Variables
    name :=                                                     ; String: Name of the Color of Dot
    dir :=                                                      ; String: Name of the color's directory

    ; Static Variables
    Static dotDir := "DOTS"                                     ; Name of the Dots directory

    ; Constructor
    __new(n, d) {
        base.__new("dot", dotDir)
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
            this.original := o ? 1 : 0
        }
    }

    ; Methods
    ; return if Element is Original (True/False)
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
    listNames :=                                                ; Name of Options
    listDirs :=                                                 ; Directory Names of Options
    listMiddle :=                                               ; Names of Verions to contain cursormiddle.png & cursormiddle@2x.png
    require :=                                                  ; Integer: 1/0 (T/F) are options required to select skin?

    ; Static Variables
    Static playersDir := "PLAYER PACKS"                         ; Name of the Player Packs Directory

    ; Constructor
    __new(n, d, m) {
        this.name := n
        this.dir := d
        this.listNames :=
        this.listDirs :=
        this.listMiddle := m
        this.require := 0
    }

    ; Methods
    ; return if Option is Required (True/False)
    isRequired() {
        return this.require = 1 ? True : False
    }

    ; Add an option to lists
    add(n, d, m) {
        if (!this.listNames) && (!this.listDirs) {
            this.listNames := n
            this.listDirs := d
            this.listMiddle := m
            return
        }
        this.listNames .= "," n
        this.listDirs .= "," d
        this.listMiddle .= "," m
    }

    ; Get array of listX
    getArray(v) {
        if (v = "listNames") {
            if (this.listNames)
                return StrSplit(this.listNames, ",")
        } else if (v = "listDirs") {
            if (this.listDirs)
                return StrSplit(this.listDirs, ",")
        } else if (v = "listMiddle") {
            if (this.listMiddle)
                return StrSplit(this.listMiddle, ",")
        }
        return []
    }
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Players: Normal           |#
; ##--------------------------------------------------------------------##
Extract_categoryPlayersNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3937 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2873, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2873, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2873, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Players: Hover            |#
; ##--------------------------------------------------------------------##
Extract_categoryPlayersHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3904 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2849, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2849, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2849, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Players: Active           |#
; ##--------------------------------------------------------------------##
Extract_categoryPlayersActive(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3750 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2737, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2737, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2737, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Elements: Normal          |#
; ##--------------------------------------------------------------------##
Extract_categoryElementsNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3695 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2697, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2697, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2697, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Elements: Hover           |#
; ##--------------------------------------------------------------------##
Extract_categoryElementsHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3652 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2665, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2665, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2665, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: Elements: Active          |#
; ##--------------------------------------------------------------------##
Extract_categoryElementsActive(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAAH8AAAA0CAYAAACjIue8AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAAn2SURBVHhe7Z1/jBVXFcfPvNUCWxbsYpHCggWq29ZWiYWGtkZoLbY1kPiLpNGKJrYxpk2s0X8a09hEmxITI9EYNdbYooYmtKYJRCDW1jRiG9AE4qJCfwpYkXZLKxQWpG88n3lzt3fm3Ts/9s0KbzOf5OS9Nztz5977vffcc+/82EBkcUPkHSIyX+1NtRlqTTU4R+1JtTfUzs34PK7Gvm9TO6HWIx/6/oOT++YtWBT09FwhQTAYBHKRSPBu/eNUtQG1cSNoaJG6j4Nqx9ReVHtWba/an9R2bb4pGNHPylHxq2PlllAFlk+r3aC2VG2yWk1nIPzTatvUHtaGQMOohI7FV8ER+AtqX1RbzDaLV9QmqfVFv2rKcFTtpNo7o19vgTf4mdoDnXqEMYuvojNW3Kl2u5rJ4Ck1MjQt+lVTJf9Ro6MxvgId64dq67QRvBZtKUlp8VV0BnZE/4YaDQBopXXv/v9h1zfC36tGIzgdbSlIKfFVeNz6T9UWRRtarbHu5WcOu/53qd2mDYBhoRCFw2IV/h79eEoN4QnvoRb+zGLqHz3Q5alYp0Lk9nxNjKnZL9Q+Hm1onai39bXmLMLW5VG1z6kXYOroJVN8FX6WfjyhdrEagVw9dTv7MTr9Xe1abQCH2OjC6/ZTwrOaUwvfHaATeqHbE7GOTpw9P3b1O9VIANfB75ruwuiGB1jiGgLaer4Kz1Rug5rp8bXw3Qm6GQ+wIdY1gcvtf11tpRqrSyzc13Qv6IeO6ImuCRJuX1sH0wXcfVsrqelquFKH4f5ZD4hI93wWcBA+c4pQ03VwqRVd0XeUUfG119+iH6zgsWM9zk8scP/oujjWOSJy+3Ew8Bc1goOaiQ3R/+Xq/k8b8QkINqk5V+8m94gsnRlKb0Yk8MqIyI6XWyEE+6+aF8rCaaE8/lIwut1H2fQN550TyvVzJDrPsf+KbDnYkOdY7U5h58e331jKePPCpsyaIrllnN0bykcHQpmqaZtzFzmfDecY4V4bC9JdNENkQZ+m/XYdq7Vszx8NZNewyEvHnfkx+q5S8TdHe6j4G/WDmzCc3LekKZfN8K4HjfKjPaH85kDQtv/6vaFsfMFfOWXTBwr+kw+3p3nXDpGhV+MfCpX8zQ+2p/+tP4cJwcrkASG+t7QpA335ZaSBrr8uuf3OP4qsnt+Uay7IP5/N6t9K1AAo+5r3hJnHb/9XU9YNNdoaTAw3haxuqPCsCNHznSycJoUqBVq9q33/NYPtlWIom77hkxe+9d3m9kvMLWgtrpsdOtO/+4ogahhQNg9zdAS1hQfKeOX57Xm66l3xF4ubBsoLD5yXvNLo847n77cOJuvCYqXqPpUUrlejARxmayfsORJ/GSfs9G+Y5y48otAzDHaDSUNlliWrjDQoxMkDFz0WTpwOZd3V8Y8CeMqHzui9nBpcxhalowj/4NGm/PpFfw/vFDt902N9MA4CLjfdQ23mnutvGC6KlBFx7Mbng2GnDAwrA57Giot3sff1+EsSo/OyQLs/gV6m23e1tlVb4y8pxnt/8B1jGBpuyl07G7L8glC+9gG/WGacrirPBhrJV59ujbcfmxvKl9+XzANird2dbJSbboy/WBAb2IGpLy0ztpsA8P39oR4XyKb97UGixWZyMKbpHRkxRiXn9cayZKWf12MZv9mfaDoLov8ssvKQBd6GILPqOnHB2L5xRStgvUbji/1vBFHDolFnCA8XI773kl8WtEBj9C4yUGVhs9I/v8DFZYQvEhRlkZWHPGiATAWrBGF9cD6CzvuubHkRGmwOsyh9Zat5eT2tU0z6eT0WXO4ed5yGuKAMZcr4qQWNqOFUBVNY3/iehvPiDTKIov3K2OcOMCrDpO/qscy/s9i2vyn/cFyx6J9cTpysMhJDjDeM70XPgzfI8gDUYiUXcah8z6pSJZj0fW6XhZcsho4E0QpYmsHpxQXLKyPjLI1sPGEc5zws+DBjeOT57PNlTHWPIb73Hq8siIRtMytvVeFL3zV3xZ1TKUT5PnYPt5Y+08yc4hffl4cs7t/byMxHpxDRX9avHmtSa4XygX2NKG9fejJ0NryMqe4h/jKmZ7/sSBhzrW7ZpPfPi57T+5v0XT3VuPNtB93iIMaRU4EcdzzSwNq8D18esqARfmd3tR3BwBST1T2COj4J7O64tBnljSmer2N4eLbnvbfcww0c3llr/ySRG+fGPyyWzAwStmx2IK+fDGX4ZFBo/6tnBTKntyl/fa3Y/iZ9euql5yUrd+fLoewa1r+fEvnE/PaKf+QFkWd03tvTaD/XvL5Ath6opowb4m408mYgOw6704QDx0L5w7+T+fwMj7imIF9HuA8n5rM6e7hoevI4fpv8zextL/uvNE+U3cGj9Pztre/R0x8dUTayzZtqpSF9V089fKJ1Xnq3q6VzlQtYHu2UomVkcabsKt544IiFjM7bqf3H1LjX2znl+ye3ABaEaUiZ/aFs+oe4JSEFl1oN6cLSGEyQ5gvWyubh1ZF2UV3jPGOyKyBj9a0I6cvOZZbPKTdxgGOhB52pscca8S29GjI4b+aMDiaRjLEjgkpZ/0xrVYnLqnn7Az2jbPoPPZcMqKhc+9IsS5p2Wj/fl6ywdG8cSx7wMHY6HPeDPW5hCMjsQIw0yGMalnJtXF6Dxrvm8TCa6vnyynZmJSwvexo7Om9F9+ivK7eEXMvnmn7XPIrF4swJHVsdLTsKJAl+6KEI5YKoOWvaVpSi6ZCnKT3+/BgI6tI9PgvqwaxV4MFc9WFh9F2t4j8cHaXicz/J39QcYUfNBIOw9BIV/3Tk6vmiHzzjDbSOmomH0fXeWO/EOP9LtSE13ELdACYWxt2jLzpHjIoft4bbWr/qhzInGEZPXt4wutSViPD1D7z1aa0a260JVE0Xg47ouTbWd5SE+DF3qzH3p7Xw7pea7gX90BE90TWBc96h0T8vWuIVLNzlw8RDJyA1XYbRjYc0rtJe3/bGLlfPx/2z47VqHEgC9bN73QV6GeF5O4fzVW1O8UEP4FLvKjUSYEnQsbBacxZinrVEN57M8V6yz12a4uZ+/eAO3+VqrDnmHlNzxjD6/F4N4TM9trfnG+IEVqh9W80sKNfDwNmF0QN90GlFnvBQqherF6D384y3WQbmjrbpra81ZwC7/lm2ZR5Pry9Ebs+3iRO+XI1pA/NHc+ISlyJqKsDUN/WPDujBY9eFhYcxj9/qBbjf/ytqd6iZewEINlhBqt/DWz3M2bkAZ25nwa3/WO27KvqY7sPsOHiLA8Jb1T6vZt7JC4w/PCxdv3J9bCA2N3H1q9kemnfqPKh2f5FxPYtKI3dtCCwK3az2ETVe8VJfI+gc3DovU/6d2kMqOFO4SqhUfJvYI+AJaASDagSJF6rRIMb136x0KfybFYR2/ZuVcZhdifwP/1EFlv9yiQEAAAAASUVORK5CYII="
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3641 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2657, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2657, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2657, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: UI Colors: Normal         |#
; ##--------------------------------------------------------------------##
Extract_categoryUIColorsNormal(_Filename, _DumpData = 0) {
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAAH8AAAA0CAYAAACjIue8AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAAphSURBVHhe7Z0PkFVVHcfPSgriLgqLwhKKFLSMhVpAGIgLmcU8XNMBGQkaUqP8g9k4UabDC2kgkpwpA0Ox0IQoBTX5I0YGa0DyR8J/BbtaDC3CKCC6oMYQ9Puce89797137nv3vvf2z9u5n5nfu3/2nXvuO9/z93fPPVum1JBTlDpTKdVX7H9ilWInxOA0sRfEjoqdkWX7gdiprn0o1kGp4cM6qfLyi1VZ2SCxajnZT6yPWLlYb7HmpUx+WmnRKHZEbLfYG2K7xLaJ7VCrZ34k26JT3BSKxRF4nNhXxC4R6yQWURgI/6LYc2LLJCOQMYpC4eLH4gj8DbEbxQZzysMBsY5iFfooIgxNYv8V666PklAb/FrskUJrhPzFj8XPks/vit0qZm7wmBg31EUfRRST98UoaLTFQMGaL/ZzyQSH9ZmQhBc/Fv+YfCL63WJkACCXRqW75fCmN8LPEiMTHNdnAhJO/Fican2h2MX62MmNUSlvPbzpv0NsimQAmoVASLc8ILH4DPl8VKyXmOne055HtB4m/dHjXLEbVP+aDqqhbr0+m4PcJT8WZ2j2mNjV+tiJqLOzG9GG8OrytNjXpRZg6OhLdvFj8Z7yuU5sgBgduWjo1vYxOu0UGyUZYD8nbZzibjNJFR5vTiR8aYBO6IVu61wdrdhLvlPVbxXjAlQdHEeUFkY3aoAhtiYgs+Q7Q7mlYqbER8KXJuhmaoClrq4p2Kr974ldKYZ3Ccd9ROmCfuiInuiaQmq1H4szfqe6z8glESUNT+owqn/8AZr0ko8DB+GzDhEiSg4etaIr+iZIih+LT5JPPHh8MWrn2xdU/+g62NVZ41T7TmfgVTE6BxHtG3r/A6X6P+64d/vXxOTzO2LGbZtB/16Vqm+Ps9S+Q9lbBL/vcb6yorM61EQGzA9z7V7dKlR5p46BrlXe6TQ18PxzdBis6YNj6thxJq34U8i95hOfDa4TJlzPruWqundlrjjRt0psq2qoqzcl/wn5ZBKGlYduq1VTRjuP6pdvfF2Nm/243k/np9dfob4/7lK9/8Kru9WYGUvUkY+OpZzPFt7GoH5VavyIzyTCe9nV+I66ad5KtV7iSodwPxw/Qo0d/mn3TJKFa7apB5/dpl56Y597Jkm+95pvfISZPflL7lEm/Mb7n9msfvv8yzotvZBBbrtqqDU86f+zpzapFZuZEJQBk0KuLRPh8Qi9K2b14PGjtv3iJvfI4aqZv8u4KKWlfiGVR5JJc5ervQffV+vmXO+ecbCFt5ErYQyj7lyUkgG8Ambjrkf/rH7y+F/do+C/NZ1847OlmR/ewgRBw976wEr1wCoGcCngAj6bDh+pi/Bvi2UwtDpzut253TOf4nbpbOYYJDnzjI7qgvPOdo+S2MKnQ4IGER6m1n7e3QsuBHB9vm8I+lu9FBLfFZ/9hLuXm8sGnq+mT6jR+5T4oJnmixcxNzMFdEbvkYjvXFGu6W5bndqh1YETFP7y8r/1duLIC0OFA74/UhI2H1o6PhPXVy8J3i9/cx+VegpG5xrEN1dqM49p596QLB0G2s2qSXNV2Zgf6S1NCtUoW1OtLZ42Vm+93Ltsg6oYOysRjuuks2AqDrDwNEd8VNOE5Rq09+lQ3V/Yt4d7lITmyZs29FdInx8vrXO/kcDoPMArfpuAUlHdO7Wp4Id865cr1P53nREE2yXrX9HtJ1uwlSbC/WDR2kQ7STiuQ/vphfhI1DC0dHxeDh/NnLf5TPxr6uSqe9S8mxm4SVP4q9U6fdI7iR60+L6P/FoDWx9h3oot7p4/YcI9tOYldy9JmPYXmiu++bdcqUVsWn53RiGAhrcOqj9t95+9zWiDGmnf4mm6f0H/wIeeiN/mvXlNH/JsIjx+4XZaqtNi0NzxUZ0DQ0aal1zQR1g1Y6JfBihH/Ky8dzS/hC8mFafnN1WwV6W9pz7AUqKK8TubMz76AqaJA5oX2vn0JiUdRgl+HUTEz+qys+XaPueYGdtJvvw5XtYpnLV//5e7l8Q7lPPjH3sy73Py5Re5e0koBdMnXOYeJdlSv9fdC0ZzxWfr5IEtPvwPNXcu0p1DfB108GzhrxlmFf8I4vvO8YK9B5kingrVCcMcA0Mz25h88y5ePwsHbVr6D6AdW3bXeN3JwhFD3HgdaRvZksA4eWzh+DuuT2D7yB1XZ7SlhCNeG2R04jRmrtVc8eHNo+OYDo4yc11+L+mx88GpOj5K9s7GA7qDN+03a/V3ArAfD9+zsjPaObZDRDa3ZTb4gQO+PU/dMmaI7sR48fE6JUDkdK9gNmj/qAbDhjMMvn2Bbkdt92rD3H9zxMe1n9z0T91hS4cqnpIexrEE9BW8TYbLGkr+a86+PwwbwjLR7ZzkA6WKKiwoXcsdzzThgnSEvBCP8bkHbYeNYIXG5wdDRNrzdGi/GSJ+sqqreyYYf3yRB3kZvIb4G519/faHFW7mU1Pud49yQ/tjfqCtDf/PAd+oElCFUQqCMHf5JnfP6QgFzThc3+trD9vuQyHx2dLGtO205zYHESOKIENfA7qljfVN4m/soPrX0DDfIXa6mO88fh5v3vfkJn1z3bt0Vn16pHb6qJLuXb5BXTfnCVXvac8I17njqWr4BefpY0rK/JXBbn5rw1v6adiJEycT4b1wrXGz/6D2vPOee8Zhw+t71Motu7QzJFu4da+k9pS51+1v7lMTaga6Z+xQKuv3Jn9jIfGlp83Dz23X+8D3L5W/mbQm83Bu99uHdXwsQTCoHy9QZcK1Rk9/TBfcNHhkTxV3s3mk+5R8mjdyAkPHo6pbhW/nxYvprFhuJhTEmcVrZYW4P15ZoTuvhcYfhLDx5UobqnpKfLZr8R0eru1qPBgkfZ5Wq2deY8TnWT7P9KNXsdo3Rt9rRfxlxsnDu134DCPh2zfoi87o7U7gdN7r5h1vIHdEtD+MrrNcvVOmbi8WY9hH7ogyQPvCVPfoi86apPhObpjiHEQvZbYzjJ4s3pBYvSN1cYaGukYZ+vHFEWI8NI7e3Cl90JHh3RwRnsU1EnirfcN0MbwWZIJMx35EKYF+6Iie6JqC3anjrLT1NzEeB0Xr7pQmRjd8u1+QUp+xYpet5NP+88VRYgTkAs3vGYkoJuhlhGd1DutSbXbxwVnOo1aMC+CCyv9Vm4iWBJ3QC91qXR2t+PryEzirdKwQGyl2Uix3mIjWwujDalwIn7XGzr0UW0PdMRkBLJE9agkeIrPlor4zAyNaHKMH7+DPFrtRhM+c4ptGuFIci1P6ecfbzNnicRpLdke0Dt70x23LOD7QGnwQfBFGaKjbLbUA4vNIcJiY8zjK6VlGCzK2HCa9GcZRwu8RY929UCty599+O0t83S42VcxkAjobeJCidXiLD2N2nG7MuwCq+gVi92Xr1GWj8M6b0yH8pthkMbMmL9D+HBIjh0aZITyITQ3bTcw7Ktshhqfu4VwdulwUt+cei+MUuk7scjFe6Dc+5Yj8oVpnPtfzYr8XwRnCFYXiiu/FqRGoCcgE5t+s8IIbGaL5/81K6cF0OoRmrhdtt/ffrBRUwu0o9X8F9jROS7xc0gAAAABJRU5ErkJggg=="
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3787 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2764, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2764, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2764, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: UI Colors: Hover          |#
; ##--------------------------------------------------------------------##
Extract_categoryUIColorsHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3701 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2701, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2701, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2701, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------------------##
; #|        Embedded Assets: Category Button: UI Colors: Active         |#
; ##--------------------------------------------------------------------##
Extract_categoryUIColorsActive(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 3563 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 2600, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2600, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 2600, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------##
; #|        Embedded Assets: Browse Button: Normal          |#
; ##--------------------------------------------------------##
Extract_browseGameDirectoryNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 4293 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 3133, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 3133, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 3133, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------##
; #|        Embedded Assets: Browse Button: Hover           |#
; ##--------------------------------------------------------##
Extract_browseGameDirectoryHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 4212 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 3074, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 3074, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 3074, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##----------------------------------------------------##
; #|		Embedded Assets: Apply Button: Normal		|#
; ##----------------------------------------------------##
Extract_applyNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 6004 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 4382, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 4382, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 4382, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##----------------------------------------------------##
; #|		Embedded Assets: Apply Button: Hover		|#
; ##----------------------------------------------------##
Extract_applyHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 5939 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 4335, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 4335, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 4335, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------##
; #|		Embedded Assets: Reset All Button: Normal		|#
; ##--------------------------------------------------------##
Extract_resetAllNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 5179 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 3780, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 3780, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 3780, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------##
; #|		Embedded Assets: Reset All Button: Hover		|#
; ##--------------------------------------------------------##
Extract_resetAllHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 5119 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 3736, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 3736, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 3736, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------------------##
; #|		Embedded Assets: Reset Gameplay Button: Normal		|#
; ##------------------------------------------------------------##
Extract_resetGameplayNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 9233 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 6739, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 6739, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 6739, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------------------##
; #|		Embedded Assets: Reset Gameplay Button: Hover		|#
; ##------------------------------------------------------------##
Extract_resetGameplayHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 9081 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 6628, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 6628, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 6628, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------------------##
; #|		Embedded Assets: Reset UI Color Button: Normal		|#
; ##------------------------------------------------------------##
Extract_resetUIColorNormal(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 7500 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 5474, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 5474, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 5474, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------------------##
; #|		Embedded Assets: Reset UI Color Button: Hover		|#
; ##------------------------------------------------------------##
Extract_resetUIColorHover(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 7463 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 5447, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 5447, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 5447, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------------------##
; #|		Embedded Assets: Sidebar Outline: With Text			|#
; ##------------------------------------------------------------##
Extract_sidebarResetOutline(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 4228 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 3086, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 3086, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 3086, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##----------------------------------------##
; #|        Embedded Assets: Form BG        |#
; ##----------------------------------------##
Extract_formBG(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 7152 * (A_IsUnicode ? 2 : 1))
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 5220, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 5220, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 5220, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##----------------------------------------##
; #|        Embedded Asset: HSB Image       |#
; ##----------------------------------------##
Extract_hsbImg(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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/GMzLdsAADoVaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1LjUtYzAxNCA3OS4xNTE0ODEsIDIwMTMvMDMvMTMtMTI6MDk6MTUgICAgICAgICI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgICAgICAgICAgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFBob3Rvc2hvcCBDQyAoV2luZG93cyk8L3htcDpDcmVhdG9yVG9vbD4KICAgICAgICAgPHhtcDpDcmVhdGVEYXRlPjIwMTQtMDUtMTVUMTM6MDk6MjUrMDE6MDA8L3htcDpDcmVhdGVEYXRlPgogICAgICAgICA8eG1wOk1ldGFkYXRhRGF0ZT4yMDE0LTA1LTE1VDEzOjE2OjEzKzAxOjAwPC94bXA6TWV0YWRhdGFEYXRlPgogICAgICAgICA8eG1wOk1vZGlmeURhdGU+MjAxNC0wNS0xNVQxMzoxNjoxMyswMTowMDwveG1wOk1vZGlmeURhdGU+CiAgICAgICAgIDx4bXBNTTpJbnN0YW5jZUlEPnhtcC5paWQ6ZWNkNjhhMmYtNjNhYy04MjRhLWIwYWUtMDllNDgxMzNhODJmPC94bXBNTTpJbnN0YW5jZUlEPgogICAgICAgICA8eG1wTU06RG9jdW1lbnRJRD54bXAuZGlkOjIwYTlhYzA3LTVmYjUtMTc0Yy1hOTRhLTg5YTdlZjc1NWJiMzwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOjIwYTlhYzA3LTVmYjUtMTc0Yy1hOTRhLTg5YTdlZjc1NWJiMzwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8eG1wTU06SGlzdG9yeT4KICAgICAgICAgICAgPHJkZjpTZXE+CiAgICAgICAgICAgICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6YWN0aW9uPmNyZWF0ZWQ8L3N0RXZ0OmFjdGlvbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0Omluc3RhbmNlSUQ+eG1wLmlpZDoyMGE5YWMwNy01ZmI1LTE3NGMtYTk0YS04OWE3ZWY3NTViYjM8L3N0RXZ0Omluc3RhbmNlSUQ+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDp3aGVuPjIwMTQtMDUtMTVUMTM6MDk6MjUrMDE6MDA8L3N0RXZ0OndoZW4+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDpzb2Z0d2FyZUFnZW50PkFkb2JlIFBob3Rvc2hvcCBDQyAoV2luZG93cyk8L3N0RXZ0OnNvZnR3YXJlQWdlbnQ+CiAgICAgICAgICAgICAgIDwvcmRmOmxpPgogICAgICAgICAgICAgICA8cmRmOmxpIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OmFjdGlvbj5zYXZlZDwvc3RFdnQ6YWN0aW9uPgogICAgICAgICAgICAgICAgICA8c3RFdnQ6aW5zdGFuY2VJRD54bXAuaWlkOmVjZDY4YTJmLTYzYWMtODI0YS1iMGFlLTA5ZTQ4MTMzYTgyZjwvc3RFdnQ6aW5zdGFuY2VJRD4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OndoZW4+MjAxNC0wNS0xNVQxMzoxNjoxMyswMTowMDwvc3RFdnQ6d2hlbj4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OnNvZnR3YXJlQWdlbnQ+QWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKTwvc3RFdnQ6c29mdHdhcmVBZ2VudD4KICAgICAgICAgICAgICAgICAgPHN0RXZ0OmNoYW5nZWQ+Lzwvc3RFdnQ6Y2hhbmdlZD4KICAgICAgICAgICAgICAgPC9yZGY6bGk+CiAgICAgICAgICAgIDwvcmRmOlNlcT4KICAgICAgICAgPC94bXBNTTpIaXN0b3J5PgogICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3BuZzwvZGM6Zm9ybWF0PgogICAgICAgICA8cGhvdG9zaG9wOkNvbG9yTW9kZT4zPC9waG90b3Nob3A6Q29sb3JNb2RlPgogICAgICAgICA8cGhvdG9zaG9wOklDQ1Byb2ZpbGU+c1JHQiBJRUM2MTk2Ni0yLjE8L3Bob3Rvc2hvcDpJQ0NQcm9maWxlPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8dGlmZjpYUmVzb2x1dGlvbj43MjAwMDAvMTAwMDA8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOllSZXNvbHV0aW9uPjcyMDAwMC8xMDAwMDwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPGV4aWY6Q29sb3JTcGFjZT4xPC9leGlmOkNvbG9yU3BhY2U+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj42MDA8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NDAwPC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg"
	Static 2 = "ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg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"
	Static 3 = "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"
	Static 4 = "sOybMCFnsEFUDdxN02EJVKX83kjQlQ2fZv0iUdOubU7NtNtqG/sge5gb5AD12g+2tD8FAcvqsz4NwtgwmYnBihRDVL8FK5W+4I/NZIRsJyujMr6GFb9AMG0RQ+d2EHEtrEFYqU6QnsPqup2nLXAf0fNJqjncBKtslDOWqjo4hOpcwaj5nnvKH4tFGoGsEeELAy6Phfjh1H8NvEUrU2Z3s+9O0fwWTG/wWHKIH6CYKMftOUFig9et11EHkFnkrrxkZRJo3BSQ1T1fAtLOXYQzF6mGpjXBXsO4+85ozwh7VWBAlANxPEn2/OWcqzLMls1mc5a000hT1fupBorZvtlN1mA1ZckZrAFeYDIPLJjFgXqCWz4Ei9UELHeESOcN6VoMRa5klUS5mJVNtt5groahjgWDzjA5givplMm6Ewi6ty5T7L07QsfhHZ4YrCgKbgGj1RF3Dj5C8ov4sQ9B8mbqiVhAhzCpSRVvZFIQjTBagF8sbymdN3hDlpvhOkdhr6jML3QqFJ3cQ/bez4IlRNaTVUDCZLJGKHQTMVjza1EH4JwHyaSsFYs1D3S7Ai/zAd2QyxK7F3gpYvZ+JzAa5jGt4kiYSnuHVnR3OwEckMj4m0qBr+oaHILgrYzIiZiwOoMVLQcWjs6Dz6LXugidFTPFsMZcs8V0di8j9LgC3KUYsfWGWketfa4scVyDi8krSsTOuFwYx7qjcBXQ6OD9U26aNK22ybQyGp4l3qJ8QbZc5wpZhzRWBWjN2NiaeVORmH6FuFXK7vKczvyOUfgylUGMMC/YKFqK420qES7LCijLVmKsjlV+/V3RTnwF/47ScaqMUYXAjRA0jGSZ6YGsm5rN8mDLuRpUVQYgLE3HZUkal3VHkt5wGkwrukFqLKYz63RFcwjIe2UiDBKY8MRgZRzchXhAc6Q6ggCztCDgmeuzIvaqkeNgbGBq01WhuCo2USM5n01IjWxSSu2dUNsOGeFs31WBPcVKucM8qkCDAQz3/TTQmotJHifSqkbba3o+GoUz38wPgRnY/I+oo7ByI5lq40BcM+akD9S2UsMhhuVUoPMQ3qICE1xVOaZvxfhWd0ROJzC7mxaVQXRuMWqq1BxkIciXIIHA89K/CLkbmdjc0JuNDGWslaPFq8BqJEfneBhmWhaDVU15KIfUxD5SwQMV8hfiHJ8i7fJpOKFP+HPYazVYbL5GhBUchZEWYACVs1BYJdtYlaqJ4mcusjIzvasmzud5jwYuvF1NJ1YGpDsM7xCECGOTnI0nqu6oyp+syqXQfq5ot6+aCcjNZebkKhxDMF3DWHidLHEmIlrOUyQm3lZ2+8rxakh0ZTxO5Xs14/NWe19Zwbzip5UldhNSdXoNsjmA81gcFgKzdqgR5EmYx2giBQgj2FKxhtMInPV+ZD3pCrMwhu/Igw1/b+BF8BXtbrf8OUtTtOT1Sku6Cv7gMwlBDVZLoGYLNqoLfotTE0FZxFCxOole2BizWi0n0RUdfxU3+WaBfUcwwxn3UNliGQ/o6qx1A5Or2iggTnFXmatVod7QXcxLNmKrZjPJugZHYDLRsa1oDg7GgTC3DyNjlon/zIFXtile0APirJ1d7cZsp3cuoMMld8PCKoyU81pWyeh0CmbHfAqWy1GVz5XcowHPGemrFNgZpP8M2LA///8xMWaPn/lhgjJAS899mJ6lkfxI1o3YBMyHCLgo+q6Kcyq07c4jcgt73clNWd0VAnarUoPlOBTSqZjoYLElEg0bgIDe8xIEdCE6xNKucjHN3KAdslYxV0Cseu+5EUemZAhQEU2AhGFfI3FVjbgTxzdXmCaH+XJ6r1YZrqfr0oMgQknwV4Ih5qebmfutTrNvYpNsRcJmrtWKFuq6XJwItsaCTTNGS61qdXHU884QasdC3KGRK5a0MiTzOR0WzRicd39GHLAOQkfj9rGQ3d0bqiZzEabJredmdVRqaHQZqzija1rB7ucv18Xeo9SPKgxBhy5j7OBijCzoqjgUX2g0Stg0klBR8wEz9Y9BmK+sqth10Sw96YbgiqtcI2Or6TsHp2cdttURNSuYXdkDEoaoohzkfHd3ELszCHpkabQrSQ9GpnEJ8gTQI27Ul6v4UlZBfJmpx8sM6BxhHqs6tzKSZZjeBGbip5sBFNvrIKg9Rw4B8FVinWHRLswA4irfXPAkKuRGYBIZQxN5COcKsAJ5wJvC4gZV2ec1Yx9lQ6vZjIImVvrxdGAvmItTwljprnKDwCrb5mr0wnAsZtA1pQgvxFovkURDC0LWi6QIP4Ol3QmnkgmJOkXuUQa9gWv3qu0hSpVGy3+WvGjLeLshF79z7GIsrM0Ov8YJBgbuyJV43KEfc92hGgDd4ZXrSjasJfx8lkWPRuNE8zvaww/6EMs8+3820yPDOCyjPpPMTQRyzUgPOh2ClbxHmACJ2GmmCV6twWIrHOBSDRnEBbzR5e6wqE/DKhy1RFXQrkbmjHDJR1c3M595xxyIVRmzDHsL/r4SJqwLvLHiX53ACvDKDlXupVxvtTrEluUsZwFEJugII2WwqqTu1ox04UQcTV5HIyhOEc5LsAXkbiMpPjfXMZuEEy4C+TierMg9Q5iXyU1msN3BMM3gW/N1nyEhRxHIYcKyKpXH13qC6aupwOgOOWxUN4EG049TJA/Ap76lzEo2zyMjZlvCaKkvOpK8gJq3wbSoKsQL4M31mKt2IxYrUzWpyD/IH5IJh0Fwrw6X2YKV43IrFXlsZW1ul4PDNatCAWdy6d9/t8S+MtnqrFYo6rTr0GO8soL5Bm92eUQmZ3vTRxIwOWUe2aQOgAv/RGZ6wewodAfIwwBXXdCDo7DvgOxdHV7ulpmhYhoqkbM7vLeHDBbj9yOMkVXoAnwQAZKUYSvA+AqnqAhXVgDPwgmFP549kqN4AyNIALxSGxhsLRsBwbC5wreqYb0ySEThbve58sD0JgKLjMHKIGc2vHl+zDB7pgWu5LXsZmZj9SqL0JF+agK+lypyVVDlBBYgLFZWiuDyvkCe9FbsVqXK1uV8sypfh/ud20ochu35tw88SyBEBe4Z0TsXvD/q8348/JpIj/cTwK/E60Qe6YI/Hx3gNa8NOtM/ksAo6v/IyCM1/BlGajFF6kNEdaozSqVA/Di9PmnKnaOmBEjVMU7X1eQoHxisblzJlgQlSPiHj4DtcrlBlvVWyV13pMScCo2KTJwKXSb200JfkskysNRgK6Slsxotx5+6tUndSNRW8L07vmaFYYYIEBXTRTeaKKcB6HnCDhSHwTABsSoKCrECqxS2dm2RF6mwVH8dVxk80pOL7fK91X2EVT26RQAj4Yy78FguU+W2ggDP3YkK2uW0RSdZ5sgbzP9GQgb3KVD6COC/gw9YKA3wzkAYe6ebJqz0orvQ4mJBF0sTNiMNkNFwwwCSzrJV5ZbdcDSALj+EcD5qUhVrqp3OG9RgZQ21Ecz+xPPQ50g09AOxVq4aiVNhsrI70sRzXaQqo1V1wWu70AwTApIBpvFmpH4WCDGG9LFKTrGl5toKU3AZWHHrqty0efY6wMfWfvn+j6RttJSicTgjYJyiVNmj6bASw6y+KmrmdfQ0LniljZm3U5HyBd6D7sRNTXmEJhK6lcL2AS1sxnZjJ1TvSbCkgqKsctG1GFaZ2A1LcWq6vqYIW8AQXYiFgCITusCHO2fVvp8PnoZ5h9m7ZccCuoxRpRSdfEgzsZvD6R4pdmfa3xA5VgedVwp8nfJFmKkNRuqqtIczXDqZLJUIjULE7pV+8ZWcxBAsmZMw7n+Qxgg8QOQRslWTTcGNpmrV1vEQSKeLoGuYVwTG8VHw4aAzh5nqJODKki6K6Oni7g/BYlusV1QdG2ljRVA8mhzVEbdMZcFQM6g8V98CyGuhkBC7LNZgi6xBt3m3KkumxHuccegZ4wTCmGcwPUo7Motxxo5nXLbKzbqKdYDfg54xWs4ifF5yLSFZHVEfJ7hpScqO1UlVTUuR2kA+wXbAHwfO6qqWVE8qk5yYqWXkrcrMO9+HfTc1+qSyHzKmoRv4q5vJNh5gRe49063KlEmiDHaDFgFVgZ1Ck9dCSBDNHbyI51nTzR3C1zhrITPuRrbD6nge1bWoZvcpm3MDLsbwZkyZqrFSLiV0Y7OXuEhKkEWZStmQKcK70NjJibQkL6MyYQAXD1W7vZsu3ILijkWo1xVv3EkAlLFizQzyIktSn6H4ZsVfO9BE8dAjVUnPJtxmAZXqGQG8MoHo/LMZtmKaj3lBd/Vkvjn7LpdgqwZhCMOosoF3TFVmmyqM4aTx1EVrRcSt0D4Iblkp1iVB3h8B1px3UCI+I1lqXVyNTDpuTtd9mF4C0AKAqooJSS5DoVYHird0nSvNyiaARTPXpFqvLrhRAVUmShrZXjPdQ8UlOJsu4OtsPQmNXoJCbEmg1JEPMVC+UZlWlEaMdmtVZevOJHY6ARkSaKeCqGZEj+q4TL6FRajZxQWx5ur0ThiruouQAgacUFaQFdjn/2XD0Ri/GC1dVcNVrctk6uku6+2MIKs+3xIP00xPpUzpySs5XyTDAS25kY4qfFu4QK4Qouo6dMUaK9OoCiKOf9RgzVciUh6JNK5aEHBFqiQXeEY7owFUXRaS76DcttM1WAk7lFRc7AKqmtSVztgOX+xiZcYf4IEKpTvVCYBgnYCsooSl3ZWizxcXFtVQsfLEaKf7QNw5GJU6ZjVWc3XvZZhGI0SxcyMbtNzDIHDaVX0us1OVHm8YOQtXvoBVGqpcAqAlpd0dXRWKOD20n8hH5TAVu0+SauzhTHQkniHyNm0ymbnKNxqnE3kZIFZijHIzTGdQzU53fbaLPR4B6UcC+2HmVWggtVKlz7qvFMHaUVN6Xp0gxYQN3Zlq7rQrc2TOHwxWVFl7JYHTR4CkmrHsuiCLV/W4s7QdC5SaSOYiIWCbuZxjDNKI/+pB8NUSql3ZjpOezICJImkyG+yG63N6oJSNO+Chg5XieoKCQ+1kLJgYiSmphthMzC/DBMpEukjjZZtrC1guBaWHgOBzcYkrWZ0yR1neowt4rBLys/ZFBy99GNBDUjqhAnvBKlR/rNtOVZ3hNExrzNmZQUxnFNOATiYIIpfh/KKrQPBmg9GUijtQk6a6BJ5bJoadPc3NgKviYoC3dDvpmNW5aAyrOSrUKoh8ShH2rN0JAZs1t0xliu0feG6TipRHVPdgJAZ0JVeGaW9VEk8ui6VEknyYripEQBBWFji0iZ0BdIcfBAZXIrqq9knJi3Q8N3h8QjdxAL5mVqT6k9pHFldfCXN1JSbTwIcbRH79c1oIlyByr0WaUWGqD+S1ZNHOr/LPTBGRqiWquiVntkZlOmVLrMKpTOyF76L0qRz5aoArwItWJ9pVyN7zXIMVzbF41LW6Au/yeLZHzzECk/jAc7dzpNr+ETx3gQ87APyySQSg+ANcloIFTSP5t+tRlucSukEXTARflZRjaZNedDJMWu7x/5/whBadxl1hqlORO2sWVRlsIB7qjOLGBrIsFV3gihGqCicWSmdIlOGNfNkzFmvnEQVbTk2XmsE1Y3K1crJS2+zOq/Nk/aKMMVbBZeqCG3KZaNWv4RSSZG1REJQ9S+fBoOPdDbEZmCN7H2u2XU4PKlpxbHoUJ6WoFoCzyhWVyV47UWGoIHpk6Y48cHwFM9PphPyIYDgMpgtBENWMu+IIOWfEDWOznDGfqplWEb0NuqfENitWv+KYJAyTgBlsweBFAF3qGJHRKOZ6F/PEU4A1BzV9gufKyOf+D6YxxTakPyUWXBnI6ujiJjZqRvg6Y8b1eByWXB2H1rOTbutJwFRRk4/0aCoDlcfCfyvnBoqscZaFjlJ3Hc+D1NzpUixIu4wL0c18hrsxsN3dDaycLsHMvCz56ShxnkETBVmaYWWDQBeVDHJTf1Fo4qokrgRe2We6Ug46wBqIx95ceC43ZOLLWXNMhxboyIaoVSerXIZpuPu1w05lcgzOPt0q7JIKuNwf6UozjOJzjoNTzbXzhKrPxIlljJZC/MnemqQIHwc7R3HxJ54rcz+nZdED6PqYR/kkpC1Iqg/EW1Wm4w3oiVDDWHWZCeTVz2wziEbYqanuIAmN2eAiN6WkVl2VHXd0LaDrB1lKUD3nzOV0GOineR9McHQ2xmjKbKaXO9+IEbzHzaSPoj9km2E0FC7KZczZf9ZnwjBLCXKzQc6V9kgEltOTaPNTwBR1kVWKD9DjySv/d1OBmdDoJ3iPe54ijArO56L2yExms1Lh8oW44CQaz7OST2GY5gNelbEjHsRyRlXmK5VpUL1YTHKhUijrskMgySuVUR+EJVAZ9E/o2W1VFevk+00MFsgtBvL55koXKusT79BD0hRn6JLHVUiuJGojYaB2BNG0JODKvmEmVNECoj+jvedtuTpQZLZPNnmhF2zWueuqfLcbx4GlCOelfgXLbYbhcD6gyEw5ARIjJn4JOlNF5xC5DNZZWSlVlKNyGvEMrbgfKbYsC66yoc1ZoMTgeA/+3whLNockrMqyQyfMnZkljjwvZ43YTu8sdSf7xI7PmnTVPueokAB5C5Qqe7jMXIstx6CcUGXoc4W1YpJxw7ywjNtg8jM9WVRDOJyqZEOHLpAHDbDUxCgYy3um7C/4NHWGEZw7m2X7m+nS1Wtusq6F32GlCqTaD+k0mzObiOqxHVHfzGVkLq0TO+wGM9vhzzvMvp9i6OTYmktEfTMOqXYgouBp3MjXbY2CMPUosmcaw1lNFxUfzdKCjswuq+qDsSe4gikZIG3w4UlLLIJZWkclXeel/VZnGeZK7khMpQl/yoYbsOZcd44IUM/cw9xv1ByBbC+/BNURrbSWehthxw218kKX8WLgjJHGijB2otxu7IfOOA+nKTdrUwdlsJTmrmpb6tBleQqzAPEAOAe+M7XF1aBpZyLUV2xTxczO8YwmdmZltiKKU+yww/5GgACEeasyza74bic2ONhNydgrJ+Jjvszp4R5JgIfkuSil59RVOD0fGWXqKCVGU2+f2C7XXplX6OSDq2nI6nuwkJiKtLIAL0EPwwO4dVruQKl4cXTEjaWKjZ6hdQWPuEHVhViOwTkfTBPPAjlnFV3ENFigJlksF+ErwFZxkUO45uz7rSxZxVahsCczfSvl2L4wWP3RFHqwSz56lDmt9xlcnbn2KpsemRWpRFl1txBlDt468Yor1XlZWtApfm+WSk/U9TcjFiUbwkBBhGfnc3b4I2ayTSdLaWdJh8fUeCTN8Pgaq7X6RN73xOq+gGQeY1a0hmQJz6WLn4IibOT52ZQ6CXxY50GkdtKMG9mMaNxtt3LSj2FuZBg7P8hNAvhgs+qX7Um064T6rpdQvK0SHnHleR8tD9A96jwQvBJ4nAUKTAwoKn2M7iyTvI7kFh5lHFabaZyMGUjQqOKOsYiHZq/dWKDVzeBJ/WjW3YQEJwA15ZHV/z6hZ5yrOemf8AdJB+b4B4OVqXAoVfaIwIURIq4MQKgkqZy+dZeDcYZNN2PZxxkUJXvIUl7NdBUw/Vo0kLQLRncYrii7ug1ftaHnz6v2QjkdwQqwfPlb3aQonv+YNp4LXm+FS3xEFIFitkBueBXtuY21DI5nLJeUlmuoC/ioGskGPbfQ4V2qcAeC62DMk5O3cMeeV4RLuPVEZYgN+RyNhlzx0KkKGyKBGklno7CPZWZelXSIlvsQqcFsn74I2dzMFS+FFxshf52qGlZCkKF9hZlW6qWYAkol+w3UmIaH7/2g5H4ZQUhWjaaKT1QQU/3/KHqMSvyvgqcoOTeIt4jXJyMHIlfShF1U1cGqYalKaVbcTRdJDRgxRrWSpBds5K/zPy7hC17RRTSQjQ1yBrTSYRRE/TJ9Oos4GVE7Eq+QjcVRplaJi1qWzmO6GZU0oFOFyPaTCCY5e5xKxa2ASYicCgh1AORzEdXnxgt4BHE1kI/ogiBfL+QTcBEEPxnobAXPlMUGVwIiP0wC6NGcnSHTTF0x6iuhAZVTf9WKdsyCGMfhRO3yQyScdkbuAH6OuVqWmChzP9RgRUUmj6wVq4WCCL6YWXzAy4ADufQ0S7aNgkdRxO+AHlgwbyN/m4PLtjgBO6DHWDtp9EhT5tN0DRV8zn5jT1KGaiwuS4sPwqB1eB29dC55tU5KySrM5lC98E4EWmHMEFABDfkMdCeDd5HrFzJX7s6YRWnZqHGVDmRsWIdudWL7wSh4nx0Yz9KSfTEdmeV2/vPerO+8Ov7SKXyPWKCsjHE2rcqccyAv0n9szHUA5yXM5DKIJpa9SL1SS5giJxhzkS7EMq9OvGam3YUjUYX0VQFRJ4hDYHb4UoP1GExBcIWPV2auw3ocZvC4a35C12NdxCtlKiMQG8kFr3+ErQzV8t3E6mkWaGeT1SoDyYd5/EhQHgq4Owpc2AiaDq0CNKclozR4dOxchzWPtwX8uqzxuGt94msRSVQ8EplOJuU26/CqssSsSliVMM6pRDbPsBrLOBJxIHmLVkw30jYQZzd3+9O7kVKbLz6D3VkFYmXuxye0SE9mdR253lVkFZ1YCVNh7F+c/IVnHapIuX1WQgTxDkBcg5WZ1EjYL2YG0WtZmvOXYaYKA2VTdLOg08nFMNAtAyCmyevUsSAhVRmqVuomSq+KqYrM881VKWNW2JvVZDFdrvFUg+USuIyZitirJgKdSjEIW7Igy7eisMhmm8BY7nn23WnmzpIRqhpsmC6HJUZcZZzMtSj21Uk0qDQiw+fOgCYYri3sIowy6ZlPZc9nWe5HmN2gBYMgFlM22EwJiM6eBmYOhHUaemWKxLxYEXvGfURfwknjKSYKE9f7+NmfJPLsgotR0MdZ4V1AIRBeFwSSdyNXEpclXsRTRJ6EzQBkDbjz+5gqSWZSs3y2kmpq8CZcZSRwdF5ViqgKUsL3R/oOlcL2ikOZzcFtys1k3ZTEv1IyqUi4MfzTzbTkw8IMitwbSeNVvxUEBd3EVWpGKjDLyUTvZbxRVnSi5pf7ieoq5gb4EGfAD6hAttvVSWkOzT7Eb3FDZRYwOcPPGVuVXoOBuNiiQVe/RsubPfchCFvmLRgRy0R+1KJsRgpxGNm3KKgcTlDVoPWsHMZqJLbP3h/VWXXBF3waoNTNz0bBlQK/EIybq5bILJtDG3WL3VkajLhdKa1h+8dVDLVnYrhC6mTLntWOKdbKgfxpkOIEWKz6Rl2sJlD9EBEtEHddQ7Blqoy86+AoNa0OrWidM1jRbt0TD/BBUnkOScowxZzlVlA5ak34MBNr2SbupBQc0dHn5a+6B6O7krG3FSlWdxJCklIu8Yrd2P5hrG13/Vdqux03E47mvJCXAjIc4RAVrHeECXmyH+8oKDJNmktsWBn+GCSeARZU3zMo2wj8AHQ5cZaIYYkbVf3oWKLTJ8d4Zcd6Zu8DaAkJB+rno3IeU3RXkMOAgNOsdFHVOVVAICutxAILpr5XFJBlsF11iM/BoXUOx61VI0QVqDH32ZGPAMnMACTd0EjgA+R6PGoEp2KtGCb5WwcrIxbn7HdLKO+GXPY6g+eXkXbMgreLkMtXwWRUqO40DTcj59HSNac6Bdk42YyT68mnu4ESjISAqyOd6WspCZJIjiRKr6upap+Iq1GQML89ShFe4IUkLSFN58IQJvH2+L5PPHcJMm2rYZqS8kCqCL8ayT9euwE9ZifFIxWhrQavPDhinjL5aJgMEVCTvMyKTABdOAI8zw2MVn5WqZgVn2QFJypX0p/i7bk0MTOdz2lHvpKljoBMdsZ6wvQwarqt62FUCO/QBSCeqIHrXaUaWk4n4eOH9cR5rGAYN/mVCSYy+TlWwhiN1wS4lhVzTrMpiQG8E4MFArfZeMtsxCYKG01GwEYZclenqqK5xULwRnCCYxrewxGkUPbiJg+c9J2L+9Wo2w4uzKtYrm6wTspVsfem14Jly0Fi/JYQvRAoMpt1XmkcuxDXLsDEFM6mOQiLpUwo8gRUprrBL/Jy7VnBdVW35HQQNsEiAfkcV6dlqZPvy7oKFcRntVsdamRPpKgYDTCLAhY1s495HrWfAbxFwpW1iViwbG+EwXO6sAEmNrE8TzNSaGwogionzNIwyjENYYJVfSqA12apEKFC4Cb4KtHBYiWJILmMLGHEMMOHmSPJlnSWDWccj1pZkWQeRAoh8ypfP7fBZ2fVMezbQWzdTNnHbWGOBEOr71VBVHZHO7zRUUo6go6d6og7Ay/wNqVBgiUIWDyMH+/2Z2QBF0yzdZtmGWx3KnXT7Fy0Q6siEnahG7h66jwvIfMyWXXREBbWC16iCQ+hAirWYuXWhqmilefvMATgc9J7M/HLilUyjNGESbKuQYZbmBmoOe9O9mHGLFGfiqPaSAM79UPYe5oBxKLXe8JUZ/1gzgAWGDSio8fj4hE1hTxA9ZMOFqCLSkCSpStlz8zjRDtyJtMwzNXhrK55YEF0HjbnXL3upQdB0oUqjMwK4pvB8yk2TQEENT2yJ7b1CT49pS57qLWyGIYPSYgLtezPCFJ6H0a6b96UHMzD/g/DdFQthYpPXHgepVa3Hm5RGgRTzzyJE+Uq0AaRbxnCG2Q3LiuEr0B7Z3aJbg9R+wjr2AN4E24jKTclfZ0dr8xBlUQ+BnRZ1a+qHL6ENxoJy8fOIQcidOIe3bSJo1Ol8qYsnm/kfO6SZvtU1O1YGZpp1Mv8EWA14soy6eYoj8EGoA3jSmbScJlcW4QQXSpAjQ+N7v4V3JkmrpXWwMoSHqzEVYWPUe1WVkdYYc568vd8vOp0zDppgVzKpNIZNMT7upFytDpiWL2TIg0car2SQ3AXCJPtZ0zT3HOSYRFnUTETaYyjHcJrZAOfGvQMD5Bw3hk1rAK2jliw9BNee6eroRUFaz3gf9n37agHZl7XnKvpyKTfnL2AkSkXauUTai+LTMPBLABvtYpqryJsYjXlVlMkzt5U7aRyhRYjiQe3Q1BJ0mXZ8GGkS9h40TxFmFXzzN8gq+Z15nBk+RRA93qwMPcj+NuF4dH3rnoJh6xt8ozK11E/hFqbcS9meZSN9eQqd+iErxswqSYSZisd/uipL+5nDhzmcZwOWeD4p2YGUMB68XqUP2GxgpKVqtSWcyK3aGdNRIitaLtsdau5QIMARCYmom6uAw4dHlZ5MakEJ7zT189lqh6R3q2SOUJwvPImqkL4MgI9V59fTX9RvOhKsFQJnEqzCIE1CYfZNLuB/Ct6PhAJpuowAxhplWr9FZDWYgU1WNlYTBQQFevWU3VWlbERlVHJzt/DfJ+zWvG0fWSYtBUo7+hTo5x8JxvCY6+U2jy6QXHPxwG5ck6W+GjgI24hEhVOOjBzNWmaXvmoZvgkJccA6Ez8ZWwQasnO+QunoC9aqMwMG6ESGqHrh5MuVCOxmtjZK1ItKqDJbiCrPGpkFSMAsY/9cd2wGJXDQMEbdZPf+bqgs8KO2RNkEL4hzqg30yvM3f7NSNMplXUkVEJL9m8W3Ci9wez4qwjxZe6kwZeVU4Ohs/3RAY3uLKSViLiLC+/Wk3QjLZN1VSFNEc5wfT7TB/KWKiYX56qFVFXW1QbA7mojacHHlXjBr8EYaegzCq7DcS3RNjrbQCPBE8jdq4ykasE67GaQgyC5k6XwlDIBC/DccT1/PdcT9OUoszoslpvJrirED+Q9ICyL5GjqRgOo5yDtItfL1r1SgCULtGbFOHeAJLO0RoIgB3argpCRBFNsxE4nC5PxyWriZyfeg0f2mRe5yH7VgjunIHtU61Qhkp1xey1I/UWerVK25IqGKiaqMhRhKxXosFbZ0lclhw4J63Aw1VFfUZbekfrHZJIqXfiXTMMXHazHIOJjCrI+p6USaWT1BIG1h3O0AGdU1UkeTU21bsFwvxcJH5RHaYYJ/D3s2XUdSj5RsU8O69TIdupUeQCxfEiWBkTiNtiktQzrZ5pan+Cp9pG8P2SwWoD25lt7JT8SQX4CiDWwLuQD1txgyikDAqEOWNZ/HsA2e6JGTKWBq5xEBSZfzMlJ+fUCuxVBkEjRMIIMLQlslAhPZA0dfqsSy1NkswodBTgm9pNZDA/25lEvF1nq0bJvSQj7OPn2QixJdyWeJ+sfYRNwWeI3m4XujOmqaPk3EQR+VPEJY7R64Ja7cDadXADAr4sCuNhjhDmyi/s5ORalazWbDHMS7nO5DlbUHxFB8y7gfKbmfsGrEM5qsFS9A0Q+w+WEGnIRoei3sI6ji5oAK3FR0w4HCfkgDLciZNGIfSl7AvK5nEo/awgsDQFCOmGpss3y6fk58Ggi1ZfRbQDvLrxMKpGZiyJ1h4hRfi3Qq7NJZO9tJFWRHuPoXikrcihCxe9CuEsl5Qv4kyyUNL8z40PBcaWr5XYgfv0+WeVaVrrYkXcGZmwXCHx2SwIijwTT5LK9NBIccrIWbP9VXYXRv2l6cKXBP8tBZjjFSe4M8aMZmVrJEDAMlplBVj9jzh6cf+cUYKlptl38wkjN/RfiYQlZrZcaZgBjE3M2xFHYQEEYKsadfl1BzfRVzUhmKISzym7BzF5lNVYw3IjzXSrpRTaUHfBESFMuJFqGlyAXWuKHPsyL6lx0d/k6Q9uGIHuzQsHHDfbDMAkWaIUexQlcFFDqIgjLfngDHxTVjJXJ3HHlhg9jf8rmfHTBgAFaEluFKv95zyMbFLFYmf5t5nXUTPJsnFi1pMcBiUggdzTMjWn7tiRAYv3xyvtdigSO0LwihpvhTDI2OvsRrIsh+ncTxzpybiO5aSxhpQhjmCnC5yL3JrCDqurNlmkzIb9SQUJxU1MkbzZWvCWBkgqmIM/jhIoKPLC0YcU4kay5zPU4uvmqthDE3UQY3QE10W+puIcUmDQTPWUX4sMgeWcxoFHwsQ7ecOMQCJjOLrgqCnG/75O5OOxzI+zWAJeddjxK1uNWbUMZ8CaJjuJeF130ikpiRfl+UG/TkJfyueRtRhBnnYeP57gI+GomNlHHVEswEZjYh2m6mbRuM3CL3TOi1FLVkOXMHKIv2wVf0cE1fbuxlzn1WjBwhluGIYDtVOTO6PIP48wzUzVjGUc0KBsN6kJ9kERYS9zxFWyEaoCaCmMyvKZ9jkoBZv4rSxV2EgoOcxOBsQZbsL2rVB9jYYG4kgXwGsuzqpEoWAsDNzY4oFKgns3UYDchKk1k3uOCV8ULAv1/FYIzCJyidEWYJ/jr35lU7kiCCrXzNuIVVJTaDTikOONmsk8NtbHn85C0YYQIKmhik0Fjr8SCpYJPCgMqJejDMvJuzoXNcmehvau3y/ZsFiSpTsIVCYcSLnDsH6ZjYjRhI6xSV2iYMEsKGziplUog9uBMJgZLDQfKBAUyCWr2HOsedFDbEMgzSkF2EmKPBDuwcB/Ii08uVNukWBKjgUshNLGtd8P3OoaqMjzuaCdAj+lx6ylUXKFKdKnKvNtjPmOKrGikJSaFJChr4B2EbOFkCiyjuCGqcaBzrqLCnpWGqFUfzYQ0zgQ6kFXr0HIDvK4LZh6EBWXOxE9HsqHaj/f38Vm9FWOxopnnbkAGsbQBrk3VhJ9t5I6qeSaMl1T7txOgse8ZBmXV9IkKjliresW8Ii3cLPgC/LyvioAVBnHGd4pgLmCwmuE9ohYklu7r4EI7jbwvwhQfYompECGi/f9cLb/Ae/pUbiQKVf7uInRG0jIuTCVQHeK/CUDxZ51fF+tIbSoduthzxt7R50WKQM5/vZAcCYvhWyGfmO1y2XKd+yTmMToVnDEPm77AB5xVuhyc+EENR2Bo4lKeRAmKNuSDoVxewUkVukkl1irVDHfboadzO4sx4nIdRXgIKMLUGT3JVTUOJ8qXPKYBo6sR9Zl/BMHbB4HhwzS5OS8Dg4xhRA9rtGvQRShNEMdldM8CkiaCMhVQDeHYGFAEeMm36qzqpik4QZdyREgZLHcwM+NKmkkGZzkUNsCZ9XkqD9VIWpBlvavQOpZtaCb+dVKFyhaaSBZ0w28q9NUFRm7GnVcT1YB8VBRIQKbAhlKRHyzPUQH2ICSuqtOqQPhss6qQwRDviwrakaQHHeithrClszdg7A3Z+5xOPgXvFe+hztNYWI9cPoJxxL24UFhw5aYFv/72luze2TJ3y/ijHT7Lk6g9U2Xd2Tk6wSgqsBoi4JrP0Yh3ckio5joVJI4DRvyvTKeTcw3EtVcZ4mekbbY8qyKhPWEIqvVXD/+eGCyl4q6K11mzreNu1S6vYH0jK4FB9CHC+ErJOEfPTmlLtubntV+ZKRj5wC5YJYXQGLfQAwZKMc1Vl+Cuoi4Y5c4CLCTsjKKOu5HeGwYqdEbjZDcP5sX5AO/faEneYQhk+/ieJkheRJCdDU90Ez1uIRiz3QavHRNkb8xSgGyFN3jFfl3kLWDkNpTnANSQtmEkUlV9ZzP3gMdcA0sbZnP92Oz0QchZJDyjAqTNNBMs+IeIFG6K6nIcjhOgNeLqmZNQjLnTl6ZqqVoSMLVC8OQUIfcc7U8yDS3IV/z57g/kGfNsaTIVQ0CrjcDwYjNWUj0sGdmbmUKUW1Gr1q+9ypKVLVjrnQRMEOk4VRQe2WJH3qiu6g6zonSXoVUCp4p9inTkqtPXrGauiI1iknGNUN2Rjm5Uh5U9r6LurDwx+k3NCOayjFYmbsSMwE7hqdVeyVMy4BSt8CagiZMfGeZ3UIFVT/ZYxZ71wveMFBSRejYWmMw5EgbpXX1d1noVmeGFr7IKUd2XWnkKjjMtsGas3Cg4vUwLkDINTsSWkb+N7C9twWSzTb4FAVHkeIZpQh3xUNyOPKfrYg41snP8de+cXuthhKfsCqvm0mbcyeg80b+zTbYyCNYJklaH3OjRCtGVbqaLcdZ6KzJgVb/Ygv9YBmmQALP6u3Z+42AndVNrTQQbLgnKFOTZ7rwjm5BREE1E42pxtMJiGu4XA/nb0Y5i520JhRcJg0VubjmiNC/ESqXNMKBZdg30/sZCyCjtpZaK6x0UcHX2p6oHq965VljRqgqwiVUffgen0mUsLkVnduEo7jurNF4WqTq/waEiK26+/cVgAbly+0ymZv0as8wcCDsVxfURq3QZTBRLXWa/i1XxdYIZ5gKULBhsFic7xJpUY5uY9GlbsJWsfoldeSSAgNHu2etNYGiYLFdVzTll0mYmCfBqmbMMkdsqBRPqR9XBVxKhw7gRSNDcL9Rz20zwB8nFfzIbJyBQvbdDhNvuYBIgHuTi9M2CsFBqR3AmbzIrAfzx5zNX7tR1PRe5zym4x73swnNNVjQ0LfrVFyF9sysYMVaV8XbZ3qdKJxp5XwOfA0A7AY3VshyCN/gq10506Ax8BHg2HQmJDPiq9IzEjRwOAvrVYbaC5x8CrKzYPKvCzYres81JudOOvLyPtRZ8FPgQwBsKnf2Wy0gF5JChcnQnjK1DhnTDKLth/I5sU3ZnWIF59Nmf8PW1epKoiFxKN9xc6g6jYg2Vv2ABlCvePRd8qNE4bFlnOCabq96htW0gTOcyGEAkJt9WPIDDqDMoo8LvjMFi3EFLAhb3s1fk/bsBP7IJpABvk4K0GDVSRplPNDOkIRcMdaUfsuWvVkfWbjWrNQJx/0oUjGXnjEwoEwFS8EEGRW4fBnMmMNzhIO/v0HWog7AATkli9JpC1mwQroNxnmuwGmJVkawQI1q6EYvVDLYpcvsXuBhP1vacwfyowzBDvy3ZzJVo6ex9n71FM9iqjBJWckVDuA31rZXsoquzr7StskSOKnJXAzwiV8HcC2D0SDWCExQlpo5VpYgN+fxDFuW6fSOtsEk6PTAwKAG1sMJROQoqVOutKgUjLGnjCno6dU6MrVItVg5XmxW6dHjzDWvVwJnwDwQmmYu01a9r4KWMDqulQlmnmzoinNkqvMRerPhbtkLTDEZD3iiv9gFV3ucGWkhcrUL08zJtBCUrpK9IZsV8RcW9yNMqQZF7BpdVaSGQJ1uzIc7DON5VblfmUJkklVUDq7npUdVUs7f+rKaww5dQcKvBsj4pkPXK8G2D7juqiPKtrIIhgqaOfMxQ+FlzbsKF4T3wl1nMzzoEM4+hAjbX16vyJBXYNejZICAU4wWvXsxye87Ea+B5/oaiArMV3BIoztxvds5PI2irzvWA"
	Static 5 = "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"
	Static 6 = "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"
	Static 7 = "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"
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 113398 * (A_IsUnicode ? 2 : 1))
		Loop, 7
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 82772, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 82772, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 82772, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##------------------------------------------------##
; #|        Embedded Assets: Fonts: Debussy         |#
; ##------------------------------------------------##
Extract_fontDebussy(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "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BwQHBAMHBAQHAwMFAQEBAQECAQYEBwIDAwIBAQIDAggEAQACADH/+AJyAtgAbwDjAAABBxcWFhcWFhcWFhcWFhUUBgcGBgcGBgcGBiMiIiMmIiMiIiciJiMmJicmJjU0Njc2Njc2Njc2Njc2Njc2Njc2Njc2Njc2NjcwMDMwMDEwMjMyFhcWFhcWFhcWFhcWFhcWFhUUBgcGBgcGBgcHBwcxBxQUFTAUMxQwMRYWFxYWFxYWMxYyMxYyMzIyMzI2MzY2NzY2NzY2NzY2NzY2NTQmNSYmJyYmJyYmJyYmIyIiIyIiMQYiIyIiIwYiIyIGMQYiIwYGBwYGBwYGFRQUFRQUMTAwMRQwMTAwMRQwMRQUMTAwMTUBlBAWCQ4GBQkEJj0XFxgDAgMIBRAxIiJQLwMHAwQGAwMGAwQGAzpaICEgBgYGEw0CBAICBAIECQQLFgoKEggeLxIRIQ8BAQEFCwYFDAYHDAYFCwQGCgMDBAICAQQDBhELBB4GgQECBgQFDQcCAwECAwEBAwECAwECBQMCBQICBQMCBQIFCAMCAwEBAgECBgUECwUGCwUBAwIBAQEBAQEBAQEBAQEBAQEBCA0FAwQBAgIB6RICAgIBAQEBByUdHUQmDRkMDRkNJjwVFhMBAQEFKCIhVTQVLRgYMhoECAQDCAQIDwcUIQ0OFwkgLw0ODgEBAgEFAgMHBQQKBggQCAgPCAULBQYLBQoYDAMfB/cCAQEBAQYMBQUIAwEBAQEBAQEBAQIBAQMCBAkFBQoGAgUDAgUCBQgEBAYBAgIBAQEBAwkGAwYDBAYDAQEBAQEBAQEBAQABACD//AKEAtAAawAAEzY2NzY2MyUWFhcWFhcWFhcWFhUUFBUGFBUUFDEUFBUGBhUGBgcGBgcBBgYHBgYjIiYnJiYnJiYnJiY1NDQ1MDQ1NDQ3MDQ1NjY3NjY3EyMGJicmJicmJicmJjU0NDU0NDUwNDU2Njc2Njc1PggQCgkUCgGQCxMJCRAHCQ8EBQUBAQEBAQEBAwL+2QgXDw8eEAcNBwcNBg8WCAcIAQEDAgIFA+zrChUJChAIBwsEBAMBBAQECgcCswYKBAQEAQEDAwMJBQgSCgoTCwECAQECAQECAQIBAgQCAgQCBAcD/foQFggIBwECAQMECBUNDhsPAQIBAgEBAgECAQULBQULBQFoAQQEBAsHBxAJCRMKAQIBAQEBAQEIEQgIDgYBAAADACj/+wJ8AtgArAEOAVUAADcmJicmJicmJic0JjU0NDU0Njc2NjciJjUiJicmJjUiJjUmJicmJjc0NDU0NDU0NDc0NDU2Njc2Njc2Njc2Njc2Njc2NjMyMjcyMjMyFhcWFhcWFhcWFhcWFhcUFBcUFBUUFBcUFBUUBgcGBgcGBjEGBgcGBgcWFhcWFhUUFAcUBgcGBgcGBgcGBgcGBgcGBgcGBgcGBgciIgciIiMiIiMmIiMmJicmJicmJic1NxQUMTAwMRQWFxYWFxYWMxYyMzIyMzIyNzAyMzI2MzY2NzY2NzY2NzY2NTQmNSYmJyYmJyYmJyYmJyYmJyImIyIiIyIiIwYiMSIiIwYiIwYGIwYGBwYGBxQUMQYU"
	Static 2 = "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"
	Static 3 = "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"
	Static 4 = "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AwECAgIGDQgIFQwBIQ4XCQgOBQEBAQECAQICAQEBCgoKFQsECAQEBwMBEyAMDAwBAQECBgMCAwICBAMFDQcIEgsBDBIIBw0FBQgDAwYCAQEBDAwMIBMBAQMHBAQHBAwVCgoJAQEBAgIBAgEBAQEFDggJFw8BAAACAAoAAAIbAoUABQATAAAhITUhFTEBMzUzFTMVIxUjNSM1MQIb/e8CEf3v7Tft7TftNzcBmO3tN+3tNwACAB0AAAIOAn8ABQAOAAAzNSEVITERNSUVBQUVJTEdAfH+DwHx/k8Bsf4PNzcBWz7mPsfHPuYAAAIAHQAAAg4CfwAFAA4AACUVITUhMREVBTUlJTUFMQIO/g8B8f4PAbH+TwHxNzc3AWI+5j7Hxz7mAAABABf/9wKpAtcA8QAAEzY2NzY2MxYWFxYWFxc3NjY3NjY3NjY3MjI3MjIzMhYXFhYXFhYXFhYXFhYXFhYXFBYXFhYXFBYXFBYXFBQXFBQVFAYHBgYHBzMWFhcWFhUUBgcGBiMjBxc3FhYXFhYVFBQxMDAxFBQxMDAxFDAxBgYHBgYjJwcUBgcGBgcGBgcGBiMiJicmJicmJicmJicmJicmJjUwMDUwMDEwNDU3IwYmJyYmJyYmJyYmNSI0NTQ0NTQ2NzY2NzY2NzY2MzcnJyMGJicmJicmJicmJjU0Njc2Njc2Njc2Njc2NjM3JyYmJyYmNTQ2NzY2NzY2NzY2NzVGCBAJCBIJDRoNDRgMcXIIEgkJEgoDBwQCBAIBBAIFCAUECQQIEQgFCAQEBwMBAgECAQEBAQEBAQEBAwMDCAVuWAcMBQUFBQUFDAebDgOnBwwFBQUBBgUFCwaoAgEBAQQCBxUPDyARBQsGBgsFBgoFBAkECAwFBAQCpQQHAwQGAwMDAgEDAQIBAgMDAwcEBAgEpAIMlgQIBAQGAwMDAgECAgEBAgEBAwECBgQECARWcwUJAwMDAgICBgQDBwQECQQCvwUJAwMEAQcHBxUOiYoJEAcHCQMCAQEBAQEBAgIDCQYEBwUECwUCBAECBAICBAECAwIECAQCBAECAwIKEQgIDgZyAQYFBQ4ICQ4FBgUOGgEBBgUFDQgBAQEBAQcNBQQFAYEHDAUGCwURGwkJCQEBAQQCAQUDAwkECBIKCxULAQEBgQEBAQIDAwIFAwMGAwIBAQEBBAcDAwYDAwUBAgIBGQ4BAgECBAMCBgQEBwQEBwMCAwIBBAECBQECAQJzBA4ICBIKBw8HCA8HBQsEBQcEAQAAAQAh/yICNwH0ARcAABMzERQWFxYWFxYWFxYWMzIyMzI2NzY2NzY2NzY2NzY2NzY2NzY2NxEzERQUMRQUFRQUMRQWFRQWFxYWFxYWFxYWMzI2NzY2NzY2NzY2NzY2NTQ2NzQ2NzQ0NzA2NTcGBhUGBgcGBgcGBgcGBgcGBgcGBiMiJicmJicwIjEmMDEwMDEmMDEiJicmJicmJicmJic0NDUmNDUmJjUGBgcGBgcGBgcGBiMiIiMiIiMmJicmJicmJicmJicmJicVFBYXFhYXFBYXFhYXFhYXFBYXFhYXFBYXFhYVFBQVFBQVFAYHBgYHIiIjIiIxIiIj"
	Static 5 = "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"
	Static 6 = "JyYmJyYmJyYmIyIGBwYGBwYGBwYGBzAUMQYUMRQUMRQUFRQUFRQUMTAwMRQUMTAwMRQwMRYWFxQUFxQUFRQUFRQUMQYUMRQUMRUHBwcxJzY2NzQ2NzcUMDUwMDEwMDUwMDE0JjUiJicmJiMiBgcGBgcwFDEGMDEUMDEGFDEUFDEUFBcWFhcWFhcWFjMwMDEwMjMwMDMwMDEwMDMwMDEyMjcyNjcwNjcHBxQUFRQUFRQUFRQUMRQUFRYyMzIyMzAyMzIyNzI2NzY2NzY2NTQ0NTQ0NSY0NQYGBwYGIwYGBwYGIwcHMTcGBgcGBgcGBhUUFDEUFhUUFBUUFDEUFBUwFDMUFDEWFhcWFjMwMDMwMDEwMjcwMDEwMjMyNjc2NjcWFhcWFjcyMjMyMjMwNjMwMjMwMDcwMDE2Njc2Njc0NDUwMDcwNDUwNDU0NDUwNDU0NDUiNDU0NDUnFBQVMBQzFDAxMBQzFBQxFBQxFBQVBhQVFAYHBgYHBgYHIgYxBiIjIiIjIiYnJiYnJjQ1NDQ1MDQ1NDQ1NDQ3MDY1NjY3NjY3IiYxJiIjIiYnIiIjMCI1IjAxIiIjIiIxIgYHBgYHFBQxMDAxFBQxMDAxFDAxFBQVMBQxBjAxMBQxBhQxFBQxBgYHBgYHJiYnJjQ1NDQ3NjY3MDQzNDAxMDY3MDA3MDAxMDA3MDAxNeYBAQEBAQECBwUGBQUKBgIDAQEBAQEBAQIDAQEBAQEBAQECAQIBAQIBAgEBAQEBAQMBAgQDAgQCAgUCBAcDAwYCAQEBAQEBAQICAQIBAQICAQMBBQwGBgwHDR8TEjAcAgYEBRgTAwYDAwUDAgUDAgUCAQEBAQEBBQ0HCA8HAgQDAgQCAgQDAgQCAgEBBAQCAQEBAQIDAgYDAQEBAQEBAQECAwEBAQEBAQMBAQEEBAEBAQIBCQcBAQEBAQEDAgEGBQYUDwEDAgEDAgEBAQEBAQcLAwMDARQBEwIFAwEEAQIDAgEDAgEDAgECAQIBAQMBAgMBAQIBAwMDBwQBAQEBAQEEBgICAgEBAQMCAQEBAQIBAgEBAQEBAgEBAQEEBgICAgEBAQEDAwMGBAIFAgIFAgQHBAQIBRcEAREBAwECAgIDBQIBAwECAgIDBQIBAQEBAwMDBgQBAQQHAwMCAQICAgUCAQMCAQMCAQEEBgMDAwEBAwMCCQYCAwECAwIBAgEBAQEBAQICAQEBAQEFAgIGBAQIBQULBgcNBwcNBgoUCQkQBgIDAQECAQIEAgECAQIBBAgEBAgDDBMIBwwEAQIBAQEBAQEBAQEBBwoFBAUBBQYFDAcBAQEBARYFDAcGDwkIEAoKFgwbCwMGAwICAgEDAQkNBAMGAwEBAQEBAQEDAgIGAwMHBAMFAgIFAgMGAgIEAgEBAQEBAQICA5UBAQEBAQYBAQEBAQYDBwsFBAgCAQEBAQIBAQIBAgMBAQEBAQIFAQECAQIBAQECAwEBAQEBAQIFAwIFAggOBAUEAQIFAgMEAgMFAgIFAgkIwwcLBQQIAgEBAQEBBAMDBgQBAQEBAQIFAgIFAQIFBAQJBAECAQEBAQEBAQEBBwwGBggBAQEIAQEBAQEBAQIBAwIBAQEBAQECAQMFAgMDAQEBAQEDAQIDAgEBAQEBAQIBAQEBAQEBAQEBAQMFAgIFAgEBAQUCAwUCAQMBAQEBAgEBAQEBAQEqAQEBAQIDAQIDARAcDAwTBwIDAQEBAQEBAQEBAQEBAQEBAQECAQIBAQIBAgEBAQEDBgMDBQICAQEBAQICAgYEAQIBAgEBAgECAQEBAQEBAQEBAQEBAQEBAQEBAQECBAECAQYFBhELAQEBAQQDAQEBAQEBAQEBAQUEBQ4KAwYDAwcEBAgFBAoFAQIBAQQDAQMDAggGAQIBAgMBAQEBAQEICgQEBQEBAQEBAQECASYFCQYGDgkBAgEBAwIEEw8DBgUEDwsBBQQEEg4BBAIDBAMGEg0EDAYGEAsBAgEBAgEBAQEBBAcCAgMCOAIqBgoFAgUCAgQCAQMDAQIDAgIFAgQIAwMCAQEEAwMGBAEBAwYCAgQCAQEBAQECBAQECgYCBQICBQMFCQQFBwQDBAECAQMDAwgGHQYBFgMDAgECAQECAQEBAQIEAwEBAQEBBAYDAwIDAwMHBAEBAQMFAgIEAgEBAQIDAwgEAQEBAQEBAQEGCwUFCwUBAgECAwEBAQEBAQECAQIDAgEBAQEEBgECAgECAgIGBAQIAgICBQYFEQoCBgMDBgMBAQEBAQEBBQQFDAgCBQMCBQMBAwEBAQEBAQEBAgEBAQEBBQYGEQsBAQEBAQEJDwYGBQEKAwMCAQEBAQEDAwG8BAIBAQEBAQUJBgYUDQIDAQIEAgECAgEDAQICAQICAQUIBAMGAwMFAQIBAQEB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AfQAAAH0AAAB9AAAAfQAAAETABoBsf/8AZH//gGS//8BuAABANsABwExABgB9AAAAfQAAAH0AAABs//+AfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAH0AAABIgAAASIAAAH0AAABIgAAAZAAMQEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAAAEAAAAAAAAAAAAAXw889QAJA+gAAAAAAAAAAAAAAAAAAAAA/8P/AwQoA5UAAAAFAAEAAQAAAAAAAQAAAyr/AwCWBDz/w//TBBQAAQAAAAAAAAAAAAAAAAAAAY8BIgAAAAAAAAEiAAABIgAAAUAAJQH0AAACWAAkAmoADANUACEC9gAXAfQAAAE/ACYBPwARAZcAIQH0AAABNf/kAfoAGAExABQBwwAHAqUAFAKlAGMCpwA0AqUANQKkAAYCpgAtAqQAMQKkACACpQAoAqQAMQFEACYBWP/zAfQAAAH0AAAB9AAAAiUABwH0AAACs//yAoUAHQKeABQC4gAdAhMAHQH4AB0DIgAUAu0AHQEhAB0B6f/8AqkAHQIAAB0DowAKAvQAHQMmABQCfgAdA0QAFAKFAB0CagANAj3/+AMBAB0Cmv/1A/YAAgKA//8Cgf/5ArwADQH0AAAB9AAAAfQAAAH0AAACMv/5ATj/+QJ8ABQCfAAdAiYAFAJ+ABQCbQATAWr/4gJ7ABMCaAAdAR4AGgEdABoCNAAdARgAHQOWAB0CaAAdAngAEwJ8AB0CegATAaQAHQIBAAkBgf/qAmUAHQIc//kDYv/0Akv//QIR//gCQAAKAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAnwAFAH0AAACfAAUAfQAAAJ8ABQB9AAAAm0AEwJtABMB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAngAEwH0AAAB9AAAAfQAAAH0AAACZQAdAfQAAAExABgCJgAUAs4ADgJ/ABIB9AAAAfQAAAJ9AB0DFgAxAxYAMwN6ABIBQQAAAVb/5QIlAA8Dcv/zAfQAAALJABkCJQAKAiUAHQIlAB0CwQAXAkAAIQHuABoCyQAOAzcAGQIlAAoBEgACAfQAAAH0AAADAAAiA9gAFAKBAA8CQgAQAUAAJQLJAA8CJQAKAcX/wwIlAA4CZAAGAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAABDwAFAPQABUB9AAAAjL/+QH0AAAB9AAAAU7//QFO//0CJQAKAe4AEgH0AAAB9AAAAfQAAAH0AAABVQAYAVUAFwH0AAAB9AAAAfQAAAEzAB8BNf/kAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAOAACQB9AAAAfQAAAH0AAAB9AAAARMAGgGx//wBkf/+AZL//wG4AAEA2wAHATEAGAH0AAAB9AAAAfQAAAGz//4B9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAAB9AAAAfQAAAH0AAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAAfQAAAEiAAABIgAAAfQAAAEiAAABkAAxASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAASIAAAEiAAABIgAAAAAAAQAABg4AAQEAAwAABwMAAAMAAwAAAAMAAwAAAAMAAwAAAAMAAwAAAAMAAwBJAAMAAwAVAAMAAwAAAAMAAwAsAAMAA//gAAMAA/7tAAMAAwAQAAMAAwENAAMAA/+gAAMAAwDBAAMAA/+gAAMAA/+gAAMAMAAAAAMASgAAAAMAvwAAAAMA2AAKAAMA2AAAAAMA2AAAAAMA4QAAAAUAA/7sAAgAA//RAAgAA/+aAAkAAwB5AA8AA/7YABQAA/9vABgAA/+mABgAA/+gABoAA//RABsAAwAnAB8AA/8nACAAAwCsACIAA/7rACMAA/+gACUAA/7sACcAA/8EACcASAAAACcASAAA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AACSdgAAknYAAJJ2AACUmgAAlJoAAJW6AACYdgAAm3IAAJ/oAACf6AAAn+gAAKLSAAClZgAAp54AAKj2AACpwAAAq2AAAKuoAACszgAArM4AALAyAACwbgAAsKYAALDgAACzcgAAtl4AALnOAAC7JgAAu/AAAL6MAADBggAAwYIAAMGCAADEGgAAyLoAAMvaAADOhAAAz4IAAM+kAADP1AAA0egAANPyAADUJAAA1CQAANQkAADUJAAA1CQAANQkAADUJAAA1pIAANm6AADZugAA2dgAANnYAADZ2AAA2rgAANuYAADcQgAA3IAAANyAAADcgAAA3IAAANyAAADdtgAA3soAAN7KAADeygAA3soAAN9CAADgJAAA4CQAAOAkAADgJAAA4CQAAOAkAADgJAAA4CQAAOAkAADgJAAA4CQAAOAkAADgJAAA4CQAAOuQAADrkAAA65AAAOuQAADrkAAA6+wAAOzuAADtYgAA7dYAAO98AADv8gAA8RIAAPESAADxEgAA8RIAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyJgAA8iYAAPImAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAADyxAAA8sQAAPLEAAEAAAGPBRwABQUcAAUAAQAAAAIAAgABFHAAAAABAAEAAAAQAMYAAQAAAAAAAAAAAAAAAQAAAAAAAQAHAAAAAQAAAAAAAgAHAAcAAQAAAAAAAwAPAA4AAQAAAAAABAAHAB0AAQAAAAAABQAA"
	Static 7 = "ACQAAQAAAAAABgAHACQAAQAAAAAABwAZACsAAwABBAkAAAAAAEQAAwABBAkAAQAOAEQAAwABBAkAAgAOAFIAAwABBAkAAwAeAGAAAwABBAkABAAOAH4AAwABBAkABQAAAIwAAwABBAkABgAOAIwAAwABBAkABwAyAJpEZWJ1c3N5UmVndWxhckRlYnVzc3kgUmVndWxhckRlYnVzc3lEZWJ1c3N5RmFudGF6aWEgRm9udHMgYW5kIFNvdW5kcwBEAGUAYgB1AHMAcwB5AFIAZQBnAHUAbABhAHIARABlAGIAdQBzAHMAeQAgAFIAZQBnAHUAbABhAHIARABlAGIAdQBzAHMAeQBEAGUAYgB1AHMAcwB5AEYAYQBuAHQAYQB6AGkAYQAgAEYAbwBuAHQAcwAgAGEAbgBkACAAUwBvAHUAbgBkAHMAAAACAAAAAAAA/7AAMgAAAAAAAAAAAAAAAAAAAAAAAAAAAY8AAAAAAAABAgEDAQQBBQEGAQcBCAEJAQoBCwEMAQ0BDgEPARABEQESARMBFAEVARYBFwEYARkBGgEbARwBHQEeAR8BIAEhASIBIwEkASUBJgEnASgBKQEqASsBLAEtAS4BLwEwATEBMgEzATQBNQE2ATcBOAE5AToBOwE8AT0BPgE/AUABQQFCAUMBRAFFAUYBRwFIAUkBSgFLAUwBTQFOAU8BUAFRAVIBUwFUAVUBVgFXAVgBWQFaAVsBXAFdAV4BXwFgAWEBYgFjAWQBZQFmAWcBaAFpAWoBawFsAW0BbgFvAXABcQFyAXMBdAF1AXYBdwF4AXkBegF7AXwBfQF+AX8BgAGBAYIBgwGEAYUBhgGHAYgBiQGKAYsBjAGNAY4BjwGQAZEBkgGTAZQBlQGWAZcBmAGZAZoBmwGcAZ0BngGfAaABoQGiAaMBpAGlAaYBpwGoAakBqgGrAawBrQGuAa8BsAGxAbIBswG0AbUBtgG3AbgBuQG6AbsBvAG9Ab4BvwHAAcEBwgHDAcQBxQHGAccByAHJAcoBywHMAc0BzgHPAdAB0QHSAdMB1AHVAdYB1wHYAdkB2gHbAdwB3QHeAd8B4AHhAeIB4wHkAeUB5gHnAegB6QHqAesB7AHtAe4B7wHwAfEB8gHzAfQB9QH2AfcB+AH5AfoB+wH8Af0B/gH/AgACAQICAgMCBAIFAgYCBwIIAgkCCgILAgwCDQIOAg8CEAIRAhICEwIUAhUCFgIXAhgCGQIaAhsCHAIdAh4CHwIgAiECIgIjAiQCJQImAicCKAIpAioCKwIsAi0CLgIvAjACMQIyAjMCNAI1AjYCNwI4AjkCOgI7AjwCPQI+Aj8CQAJBAkICQwJEAkUCRgJHAkgCSQJKAksCTAJNAk4CTwJQAlECUgJTAlQCVQJWAlcCWAJZAloCWwJcAl0CXgJfAmACYQJiAmMCZAJlAmYCZwJoAmkCagJrAmwCbQJuAm8CcAJxAnICcwJ0AnUCdgJ3AngCeQJ6AnsCfAJ9An4CfwKAAoECggKDAoQChQKGAocCiAKJAooCiwKMAo0Fc3BhY2UGZXhjbGFtCHF1b3RlZGJsCm51bWJlcnNpZ24GZG9sbGFyB3BlcmNlbnQJYW1wZXJzYW5kC3F1b3Rlc2luZ2xlCXBhcmVubGVmdApwYXJlbnJpZ2h0CGFzdGVyaXNrBHBsdXMFY29tbWEGaHlwaGVuBnBlcmlvZAVzbGFzaAR6ZXJvA29uZQN0d28FdGhyZWUEZm91cgRmaXZlA3NpeAVzZXZlbgVlaWdodARuaW5lBWNvbG9uCXNlbWljb2xvbgRsZXNzBWVxdWFsB2dyZWF0ZXIIcXVlc3Rpb24CYXQBQQFCAUMBRAFFAUYBRwFIAUkBSgFLAUwBTQFOAU8BUAFRAVIBUwFUAVUBVgFXAVgBWQFaC2JyYWNrZXRsZWZ0CWJhY2tzbGFzaAxicmFja2V0cmlnaHQLYXNjaWljaXJjdW0KdW5kZXJzY29yZQVncmF2ZQFhAWIBYwFkAWUBZgFnAWgBaQFqAWsBbAFtAW4BbwFwAXEBcgFzAXQBdQF2AXcBeAF5AXoJYnJhY2VsZWZ0A2JhcgpicmFjZXJpZ2h0CmFzY2lpdGlsZGUJQWRpZXJlc2lzBUFyaW5nCENjZWRpbGxhBkVhY3V0ZQZOdGlsZGUJT2RpZXJlc2lzCVVkaWVyZXNpcwZhYWN1dGUGYWdyYXZlC2FjaXJjdW1mbGV4CWFkaWVyZXNpcwZhdGlsZGUFYXJpbmcIY2NlZGlsbGEGZWFjdXRlBmVncmF2ZQtlY2lyY3VtZmxleAllZGllcmVzaXMGaWFjdXRlBmlncmF2ZQtpY2lyY3VtZmxleAlpZGllcmVzaXMGbnRpbGRlBm9hY3V0ZQZvZ3JhdmULb2NpcmN1bWZsZXgJb2RpZXJlc2lzBm90aWxkZQZ1YWN1dGUGdWdyYXZlC3VjaXJjdW1mbGV4CXVkaWVyZXNpcwZkYWdnZXIGZGVncmVlBGNlbnQIc3RlcmxpbmcHc2VjdGlvbgZidWxsZXQJcGFyYWdyYXBoCmdlcm1hbmRibHMKcmVnaXN0ZXJlZAljb3B5cmlnaHQJdHJhZGVtYXJrBWFjdXRlCGRpZXJlc2lzCG5vdGVxdWFsAkFFBk9zbGFzaAhpbmZpbml0eQlwbHVzbWludXMJbGVzc2VxdWFsDGdyZWF0ZXJlcXVhbAN5ZW4CbXULcGFydGlhbGRpZmYJc3VtbWF0aW9uB3Byb2R1Y3QCcGkIaW50ZWdyYWwLb3JkZmVtaW5pbmUMb3JkbWFzY3VsaW5lBU9tZWdhAmFlBm9zbGFzaAxxdWVzdGlvbmRvd24KZXhjbGFtZG93bgpsb2dpY2Fsbm90B3JhZGljYWwGZmxvcmluC2FwcHJveGVxdWFsBURlbHRhDWd1aWxsZW1vdGxlZnQOZ3VpbGxlbW90cmlnaHQIZWxsaXBzaXMGQWdyYXZlBkF0aWxkZQZPdGlsZGUCT0UCb2UGZW5kYXNoBmVtZGFzaAxxdW90ZWRibGxlZnQNcXVvdGVkYmxyaWdodAlxdW90ZWxlZnQKcXVvdGVyaWdodAZkaXZpZGUHbG96ZW5nZQl5ZGllcmVzaXMJWWRpZXJlc2lzCGZyYWN0aW9uCGN1cnJlbmN5DWd1aWxzaW5nbGxlZnQOZ3VpbHNpbmdscmlnaHQCZmkCZmwJZGFnZ2VyZGJsDnBlcmlvZGNlbnRlcmVkDnF1b3Rlc2luZ2xiYXNlDHF1b3RlZGJsYmFzZQtwZXJ0aG91c2FuZAtBY2lyY3VtZmxleAtFY2lyY3VtZmxleAZBYWN1dGUJRWRpZXJlc2lzBkVncmF2ZQZJYWN1dGULSWNpcmN1bWZsZXgJSWRpZXJlc2lzBklncmF2ZQZPYWN1dGULT2NpcmN1bWZsZXgFYXBwbGUGT2dyYXZlBlVhY3V0ZQtVY2lyY3VtZmxleAZVZ3JhdmUIZG90bGVzc2kKY2lyY3VtZmxleAV0aWxkZQZtYWNyb24FYnJldmUJZG90YWNjZW50BHJpbmcHY2VkaWxsYQxodW5nYXJ1bWxhdXQGb2dvbmVrBWNhcm9uBkxzbGFzaAZsc2xhc2gGU2Nhcm9uBnNjYXJvbgZaY2Fyb24GemNhcm9uCWJyb2tlbmJhcgNFdGgDZXRoBllhY3V0ZQZ5YWN1dGUFVGhvcm4FdGhvcm4FbWludXMIbXVsdGlwbHkLb25lc3VwZXJpb3ILdHdvc3VwZXJpb3INdGhyZWVzdXBlcmlvcgdvbmVoYWxmCm9uZXF1YXJ0ZXINdGhyZWVxdWFydGVycwVmcmFuYwZHYnJldmUGZ2JyZXZlBElkb3QIU2NlZGlsbGEIc2NlZGlsbGEGQ2FjdXRlBmNhY3V0ZQZDY2Fyb24GY2Nhcm9uBmRzbGFzaAphcnJvd3JpZ2h0BWhvdXNlBmVuZGFzaAlzZnRoeXBoZW4JZmlsbGVkYm94BmJ1bGxldAlvdmVyc3RvcmUGZGVncmVlBm1pZGRvdA11bmRlcnNjb3JlZGJsCWV4Y2xhbWRibAluc3VwZXJpb3IGcGVzZXRhBUdhbW1hBVRoZXRhA1BoaQVhbHBoYQVkZWx0YQdlcHNpbG9uBXNpZ21hA3RhdQNwaGkJYXJyb3dsZWZ0B2Fycm93dXAJYXJyb3dkb3duCWFycm93Ym90aAlhcnJvd3VwZG4NYXJyb3d1cGRuYmFzZQpvcnRob2dvbmFsDGludGVyc2VjdGlvbgtlcXVpdmFsZW5jZQ1yZXZsb2dpY2Fsbm90CmludGVncmFsdHAKaW50ZWdyYWxidApmaWxsZWRyZWN0BmNpcmNsZQd0cmlhZ3VwB3RyaWFncnQHdHJpYWdkbgd0cmlhZ2xmCWludmJ1bGxldAlpbnZjaXJjbGUGUmNhcm9uB3VwYmxvY2sHZG5ibG9jawVibG9jawdsZmJsb2NrB3J0YmxvY2sHbHRzaGFkZQVzaGFkZQdka3NoYWRlCXNtaWxlZmFjZQxpbnZzbWlsZWZhY2UDc3VuBmZlbWFsZQRtYWxlBXNwYWRlBGNsdWIFaGVhcnQHZGlhbW9uZAttdXNpY2Fsbm90ZQ5tdXNpY2Fsbm90ZWRibAZBYnJldmUGYWJyZXZlB0FvZ29uZWsHYW9nb25lawZEY2Fyb24GZGNhcm9uBkRzbGFzaAdFb2dvbmVrB2VvZ29uZWsGRWNhcm9uBmVjYXJvbgZMYWN1dGUGbGFjdXRlBkxjYXJvbgZsY2Fyb24GTmFjdXRlBm5hY3V0ZQZOY2Fyb24GbmNhcm9uCU9kYmxhY3V0ZQlvZGJsYWN1dGUGUmFjdXRlBnJhY3V0ZQZyY2Fyb24GU2FjdXRlBnNhY3V0ZQhUY2VkaWxsYQh0Y2VkaWxsYQZUY2Fyb24GdGNhcm9uBVVyaW5nBXVyaW5nCVVkYmxhY3V0ZQl1ZGJsYWN1dGUGWmFjdXRlBnphY3V0ZQRaZG90BHpkb3QETGRvdARsZG90BDI1MDAEMjUwMgQyNTBjBDI1MTAEMjUxNAQyNTE4BDI1MWMEMjUyNAQyNTJjBDI1MzQEMjUzYwQyNTUwBDI1NTEEMjU1MgQyNTUzBDI1NTQEMjU1NQQyNTU2BDI1NTcEMjU1OAQyNTU5BDI1NWEEMjU1YgQyNTVjBDI1NWQEMjU1ZQQyNTVmBDI1NjAEMjU2MQQyNTYyBDI1NjMEMjU2NAQyNTY1BDI1NjYEMjU2NwQyNTY4BDI1NjkEMjU2YQQyNTZiBDI1NmMAALgB/4UAAAH1AAUABQAAAu4="
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 104110 * (A_IsUnicode ? 2 : 1))
		Loop, 7
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 75992, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 75992, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 75992, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}

; ##--------------------------------------------------------##
; #|        Embedded Assets: Fonts: Roboto-Regular          |#
; ##--------------------------------------------------------##
Extract_fontRobotoRegular(_Filename, _DumpData = 0) {
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "AAEAAAASAQAABAAgR0RFRrRCsIIAAijcAAACYkdQT1P/GhLXAAIrQAAAXcxHU1VC64LkWQACiQwAABWQT1MvMpeCsagAAAGoAAAAYGNtYXABd1geAAAbWAAAEkZjdnQgK6gHnQAAMKgAAABUZnBnbXf4YKsAAC2gAAABvGdhc3AACAATAAIo0AAAAAxnbHlmJroL9AAAOxwAAelsaGRteFV6YHoAABZAAAAFGGhlYWT8atJ6AAABLAAAADZoaGVhCroKrgAAAWQAAAAkaG10eK5yj5cAAAIIAAAUOGxvY2GAd/+7AAAw/AAACh5tYXhwBz4DCQAAAYgAAAAgbmFtZeakFYkAAiSIAAAEJnBvc3T/bQBkAAIosAAAACBwcmVwomb6yQAAL1wAAAFJAAEAAAACIxKKf3BIXw889QAZCAAAAAAAxPARLgAAAADVAVL0+hv91QkwCHMAAAAJAAIAAAAAAAAAAQAAB2z+DAAACUn6G/5KCTAAAQAAAAAAAAAAAAAAAAAABQ4AAQAABQ4AjwAWAFQABQABAAAAAAAOAAACAAIkAAYAAQADBIYBkAAFAAAFmgUzAAABHwWaBTMAAAPRAGYCAAAAAgAAAAAAAAAAAOAAAv9QACBbAAAAIAAAAABHT09HAEAAAP/9BgD+AABmB5oCACAAAZ8AAAAABDoFsAAgACAAAwOMAGQAAAAAAAAAAAH7AAAB+wAAAg8AoAKPAIgE7QB3BH4AbgXcAGkE+QBlAWUAZwK8AIUCyAAmA3IAHASJAE4BkgAdAjUAJQIbAJADTAASBH4AcwR+AKoEfgBdBH4AXgR+ADUEfgCaBH4AhAR+AE0EfgBwBH4AZAHwAIYBsQApBBEASARkAJgELgCGA8cASwcvAGoFOAAcBPsAqQU1AHcFPwCpBIwAqQRsAKkFcwB6BbQAqQItALcEagA1BQQAqQROAKkG/ACpBbQAqQWAAHYFDACpBYAAbQTtAKgEvwBQBMYAMQUwAIwFFwAcBxkAPQUEADkEzgAPBMoAVgIfAJIDSAAoAh8ACQNYAEADnAAEAnkAOQRaAG0EfQCMBDAAXASDAF8EPQBdAscAPAR9AGAEaACMAfEAjQHp/78EDgCNAfEAnAcDAIsEagCMBJAAWwR9AIwEjABfArUAjAQgAF8CnQAJBGkAiAPgACEGAwArA/cAKQPJABYD9wBYArUAQAHzAK8CtQATBXEAgwHzAIsEYABpBKYAWwW0AGkEMwAPAesAkwToAFoDWABlBkkAWwOTAJMDwQBmBG4AfwZKAFoDqgCOAv0AggRGAGEC7wBCAu8APgKCAHsEiACaA+kAQwIWAJMB+wB0Au8AegOjAHoDwABmBdwAVQY1AFAGOQBvA8kARAd6//IERABZBYAAdgS6AKYEwgCLBsEATgSwAH4EkQBHBIgAWwScAJUExwBfBZoAHQH6AJsEcwCaBE8AIgIpACIFiwCiBIgAkQehAGgHRABhAfwAoAWHAF0Cuf/kBX4AZQSSAFsFkACMBPMAiAID/7QENwBiA8QAqQONAI0DqwCOA2oAgQHxAI0CrQB5AioAMgPGAHsC/ABeAloAfgAA/KcAAP1vAAD8iwAA/V4AAPwnAAD9OAINALcECwBxAhcAkwRzALEFpAAfBXEAZwU+ADIEkQB4BbUAsgSRAEUFuwBNBYkAWgVSAHEEhQBkBL0AoAQCAC4EiABgBFAAYwQlAG0EiACRBI4AegKXAMMEbgAlA+wAZQTEACkEiACRBE0AZQSIAGAELABRBF0AjwWjAFcFmgBfBpcAegShAHkEQv/aBkgASgX/ACoFZAB7CJEAMQikALEGggA+BbQAsAULAKIGBAAyB0MAGwS/AFAFtACxBakALwUHAE0GLABTBdkArwV6AJYHhwCwB8AAsAYSABAG6wCyBQUAowVkAJMHJwC3BRgAWQRsAGEEkgCdA1sAmgTUAC4GIAAVBBAAWASeAJwEUgCcBKAALAXvAJ0EnQCcBJ4AnAPYACgFzQBkBL0AnARZAGcGeACcBp4AkQT3AB4GNgCdBFgAnQRNAGQGhwCdBGQALwRo/+gETQBnBskAJwbkAJwEif/9BJ4AnAcIAJwGKwCBBFb/3AcrALcF+ACZBNIAKARGAA8HCwDJBgsAvAbRAJMF4QCWCQQAtgfRAJsEIwBQA9sATAVxAGcEiwBbBQoAFgQDAC4FcQBnBIgAWwcBAJwGJAB+BwgAnAYrAIEFMgB1BEcAZAT9AHQAAPxnAAD8cQAA/WYAAP2kAAD6GwAA+iwGCQCxBO0AnARW/9wFGwCoBIkAjARjAKIDkACRBNsAsQQFAJEHogAbBmEAFQWaALIEuACcBQkAowR+AJoGjABEBYMAPgX/AKkE2QCcB88AqAW0AJEIMQCwBvQAkQXuAHEE0wBtBRgAOQQqACkHLAA0BVwAHwW8AJYElgBnBW8AlgRqAIMFbwCJBi8APwS9/94FCQCjBFoAmgX+AC8E7wAsBbIAsQSIAJEGEgCpBOwAnAdPAKkGPgCdBYcAXQSoAGgEqABpBLcAOgOrADsFLgA5BEAAKQT2AFcGlABZBuQAZAZWADYFKwAxBEkAUgQHAHkHwQBEBnUAPwf7AKkGoQCQBPYAdgQdAGUFrQAjBSAARgVkAJYGAgAvBPIALAMgAG8EFAAACCkAAAQUAAAIKQAAArkAAAIKAAABXAAABH8AAAIwAAABogAAAQAAAADRAAAAAAAAAjQAJQI0ACUFQACiBj8AkAOlAA0BmQBgAZkAMAGXACQBmQBPAtQAaALbADwCwQAkBGkARgSPAFcCsgCKA8QAlAVaAJQBfgBSB6oARAJmAGwCZgBZA6MAOwLvADYDYAB6BKYAWwZVAB8GkACnCHYAqAXrAB8GKwCMBH4AXwXaAB8EIgAqBHQAIAVIAF0FTwAfBecAegPOAGgIOgCiBQEAZwUXAJgGJgBUBtcAZAbPAGMGagBZBI8AagWOAKkErwBFBJIAqATFAD8IOgBiAgz/sASCAGUEZACYBBEAPgQvAIUECAArAkwAtQKPAG4CAwBcBPMAPARuAB8EiwA8BtQAPAbUADwE7gA8BpsAXwAAAAAIMwBbCDUAXALvAEIC7wB6Au8AUAQPAFUEDwBgBA8AQgQOAHIEDwCABA8AMAQPAE4EDwBOBA8AmAQPAGMEIwBHBCsADQRUACYGFQAxBGcAFAR8AHQEJgAoBCAAQwRKAIoEuwBZBFwAigS7AGAE4wCKBgIAigO0AIoEVACKA88AKwHoAJcE4wCKBKwAYwPLAIoEIABDBDMAMAOhAA0DrwCKBGcAFAS7AGAEZwAUA4kAPgTOAIoD7wA/BWcAYAUXAGAE8gB1BXIAJgR8AGAHQQAnB08AigV0ACgEzQCKBFkAigUkAC4GCwAfBD8ARwTsAIoETgCLBMEAJwQfACIFKACKBGoAPQZRAIoGrACKBR0ACAXxAIoETgCKBHsASwZ2AIoEhwBQBBEACwZHAB8EeQCLBQkAiwU3ACMFwgBgBF8ADQSoACYGYQAmBGoAPQRqAIoFwwACBMoAXgQ/AEcEuwBgBDMAMAPjAEIIIgCKBKsAKALvAD4C7wA2Au8AWwLvAFYC7wA6Au8ATwLvAEkDlgCPArUAngPmAIoEOgAeBMMAZAVMALEFJACyBBMAkgU9ALIEDwCSBIAAigR8AGAEUACKBIUAEwH9AJ8DpACBAAD8pAPvAG4D8/9eBA4AaQP0AGkDrwCKA58AgQOeAIEC7wBQAu8ANgLvAFsC7wBWAu8AOgLvAE8C7wBJBYEAfgWuAH4FkwCyBeAAfgXjAH4D1QCgBIIAgwRYAA8EzwA+BGsAZQQuAEoDpACDAZEAZwakAGAEuQCCAfz/tgR/ADsEfwBzBH8AIwR/AHcEfwB2BH8ANwR/AH4EfwBfBH8AcAR/APQCBv+0AgT/tAH7AJsB+//6AfsAmwRQAIoFAAB4BCAAOwR9AIwEMgBcBJMAWwSMAFsEngBaBI0AjAScAFsEPQBdBH0AYAN5AFcE1gBnA7QAAAY5AAkD+ACKBLsAYATjADAE4wCKAfsAAAI1ACUFXQAHBV0ABwSG/+IExgAxAp3/9AU4ABwFOAAcBTgAHAU4ABwFOAAcBTgAHAU4ABwFNQB3BIwAqQSMAKkEjACpBIwAqQIt/+ACLQCwAi3/6QIt/9UFtACpBYAAdgWAAHYFgAB2BYAAdgWAAHYFMACMBTAAjAUwAIwFMACMBM4ADwRaAG0EWgBtBFoAbQRaAG0EWgBtBFoAbQRaAG0EMABcBD0AXQQ9AF0EPQBdBD0AXQH6/8YB+gCWAfr/zwH6/7sEagCMBJAAWwSQAFsEkABbBJAAWwSQAFsEaQCIBGkAiARpAIgEaQCIA8kAFgPJABYFOAAcBFoAbQU4ABwEWgBtBTgAHARaAG0FNQB3BDAAXAU1AHcEMABcBTUAdwQwAFwFNQB3BDAAXAU/AKkFGQBfBIwAqQQ9AF0EjACpBD0AXQSMAKkEPQBdBIwAqQQ9AF0EjACpBD0AXQVzAHoEfQBgBXMAegR9AGAFcwB6BH0AYAVzAHoEfQBgBbQAqQRoAIwCLf+3Afr/nQIt/8wB+v+yAi3/7AH6/9ICLQAYAfH/+wItAKkGlwC3A9oAjQRqADUCA/+0BQQAqQQOAI0ETgChAfEAkwROAKkB8QBXBE4AqQKHAJwETgCpAs0AnAW0AKkEagCMBbQAqQRqAIwFtACpBGoAjARq/7wFgAB2BJAAWwWAAHYEkABbBYAAdgSQAFsE7QCoArUAjATtAKgCtQBTBO0AqAK1AGMEvwBQBCAAXwS/AFAEIABfBL8AUAQgAF8EvwBQBCAAXwS/AFAEIABfBMYAMQKdAAkExgAxAp0ACQTGADECxQAJBTAAjARpAIgFMACMBGkAiAUwAIwEaQCIBTAAjARpAIgFMACMBGkAiAUwAIwEaQCIBxkAPQYDACsEzgAPA8kAFgTOAA8EygBWA/cAWATKAFYD9wBYBMoAVgP3AFgHev/yBsEATgWAAHYEiABbBID/vgSA/74EJgAoBIUAEwSFABMEhQATBIUAEwSFABMEhQATBIUAEwR8AGAD5gCKA+YAigPmAIoD5gCKAej/vgHoAI4B6P/HAej/swTjAIoEuwBgBLsAYAS7AGAEuwBgBLsAYAR8AHQEfAB0BHwAdAR8AHQEKwANBIUAEwSFABMEhQATBHwAYAR8AGAEfABgBHwAYASAAIoD5gCKA+YAigPmAIoD5gCKA+YAigSsAGMErABjBKwAYwSsAGME4wCKAej/lQHo/6oB6P/KAegABgHoAIgDzwArBFQAigO0AIIDtACKA7QAigO0AIoE4wCKBOMAigTjAIoEuwBgBLsAYAS7AGAESgCKBEoAigRKAIoEIABDBCAAQwQgAEMEIABDBCYAKAQmACgEJgAoBHwAdAR8AHQEfAB0BHwAdAR8AHQEfAB0BhUAMQQrAA0EKwANBCMARwQjAEcEIwBHBTgAHASM/ykFtP83Ai3/PQWU/+YFMv8UBWb/6QKX/5sFOAAcBPsAqQSMAKkEygBWBbQAqQItALcFBACpBvwAqQW0AKkFgAB2BQwAqQTGADEEzgAPBQQAOQIt/9UEzgAPBIUAZARQAGMEiACRApcAwwRdAI8EcwCaBJAAWwSIAJoD4AAhA/cAKQKX/+UEXQCPBJAAWwRdAI8GlwB6BIwAqQRzALEEvwBQAi0AtwIt/9UEagA1BSQAsgUEAKkFBwBNBTgAHAT7AKkEcwCxBIwAqQW0ALEG/ACpBbQAqQWAAHYFtQCyBQwAqQU1AHcExgAxBQQAOQRaAG0EPQBdBJ4AnASQAFsEfQCMBDAAXAPJABYD9wApBD0AXQNbAJoEIABfAfEAjQH6/7sB6f+/BFIAnAPJABYHGQA9BgMAKwcZAD0GAwArBxkAPQYDACsEzgAPA8kAFgFlAGcCjwCIBB4AoAID/7QBmQAwBvwAqQcDAIsFOAAcBFoAbQSMAKkFtACxBD0AXQSeAJwFiQBaBZoAXwUKABYEA//7CFkAWwlJAHYEvwBQBBAAWAU1AHcEMABcBM4ADwQCAC4CLQC3B0MAGwYgABUCLQC3BTgAHARaAG0FOAAcBFoAbQd6//IGwQBOBIwAqQQ9AF0FhwBdBDcAYgQ3AGIHQwAbBiAAFQS/AFAEEABYBbQAsQSeAJwFtACxBJ4AnAWAAHYEkABbBXEAZwSLAFsFcQBnBIsAWwVkAJMETQBkBQcATQPJABYFBwBNA8kAFgUHAE0DyQAWBXoAlgRZAGcG6wCyBjYAnQSDAF8FOAAcBFoAbQU4ABwEWgBtBTgAHARaAG0FOAAcBFr/ygU4ABwEWgBtBTgAHARaAG0FOAAcBFoAbQU4ABwEWgBtBTgAHARaAG0FOAAcBFoAbQU4ABwEWgBtBTgAHARaAG0EjACpBD0AXQSMAKkEPQBdBIwAqQQ9AF0EjACpBD0AXQSM//AEPf+6BIwAqQQ9AF0EjACpBD0AXQSMAKkEPQBdAi0AtwH6AJsCLQCjAfEAhQWAAHYEkABbBYAAdgSQAFsFgAB2BJAAWwWAAEcEkP/EBYAAdgSQAFsFgAB2BJAAWwWAAHYEkABbBX4AZQSSAFsFfgBlBJIAWwV+AGUEkgBbBX4AZQSSAFsFfgBlBJIAWwUwAIwEaQCIBTAAjARpAIgFkACMBPMAiAWQAIwE8wCIBZAAjATzAIgFkACMBPMAiAWQAIwE8wCIBM4ADwPJABYEzgAPA8kAFgTOAA8DyQAWBKEAXwTGADED2AAoBXoAlgRZAGcEcwCxA1sAmgYvAD8Evf/eBGgAjAUF/9QFBf/UBHMAAwNb//wFOP/3BCf/vwTOAA8EAgAuBQQAOQP3ACkEUABjBGwAEgY/AJAEfgBdBH4AXgR+ADUEfgCaBJIAmASmAIQEkgBkBKYAhwVzAHoEfQBgBbQAqQRqAIwFOAAcBFoAOQSMAF8EPQApAi3/CgH6/vAFgAB2BJAAMwTtAFUCtf+LBTAAjARpACsEpv7WBPsAqQR9AIwFPwCpBIMAXwU/AKkEgwBfBbQAqQRoAIwFBACpBA4AjQUEAKkEDgCNBE4AqQHxAIYG/ACpBwMAiwW0AKkEagCMBYAAdgUMAKkEfQCMBO0AqAK1AIIEvwBQBCAAXwTGADECnQAJBTAAjAUXABwD4AAhBRcAHAPgACEHGQA9BgMAKwTKAFYD9wBYBcb+MgSFABMEIv9jBR//gAIk/4QExf/VBGf/GwT8/+4EhQATBFAAigPmAIoEIwBHBOMAigHoAJcEVACKBgIAigTjAIoEuwBgBFwAigQmACgEKwANBFQAJgHo/7MEKwANA+YAigOvAIoEIABDAegAlwHo/7MDzwArBFQAigQfACIEhQATBFAAigOvAIoD5gCKBOwAigYCAIoE4wCKBLsAYATOAIoEXACKBHwAYAQmACgEVAAmBD8ARwTjAIoEfABgBCsADQXDAAIE7ACKBB8AIgVnAGAFtwCXBjkACQS7AGAEIABDBhUAMQYVADEGFQAxBCsADQU4ABwEWgBtBIwAqQQ9AF0EhQATA+YAigH6AIUAAAABAAAFEAkKBAAAAgICAwYFBwYCAwMEBQICAgQFBQUFBQUFBQUFAgIFBQUECAYGBgYFBQYGAgUGBQgGBgYGBgUFBgYIBgUFAgQCBAQDBQUFBQUDBQUCAgUCCAUFBQUDBQMFBAcEBAQDAgMGAgUFBgUCBgQHBAQFBwQDBQMDAwUEAgIDBAQHBwcECAUGBQUIBQUFBQUGAgUFAgYFCQgCBgMGBQYGAgUEBAQEAgMCBAMDAAAAAAAAAgUCBQYGBgUGBQYGBgUFBQUFBQUFAwUEBQUFBQUFBgYHBQUHBwYKCgcGBgcIBQYGBgcHBggJBwgGBggGBQUEBQcFBQUFBwUFBAcFBQcHBgcFBQcFBQUICAUFCAcFCAcFBQgHCAcKCQUEBgUGBQYFCAcIBwYFBgAAAAAAAAcGBQYFBQQFBQkHBgUGBQcGBwUJBgkIBwUGBQgGBgUGBQYHBQYFBwYGBQcGCAcGBQUFBAYFBgcIBwYFBQkHCQcGBQYGBgcGBAUJBQkDAgIFAgIBAQACAgYHBAICAgIDAwMFBQMEBgIJAwMEAwQFBwcKBwcFBwUFBgYHBAkGBgcICAcFBgUFBQkCBQUFBQUDAwIGBQUICAYHAAkJAwMDBQUFBQUFBQUFBQUFBQcFBQUFBQUFBQYHBAUEAgYFBAUFBAQFBQUEBQQGBgYGBQgIBgUFBgcFBgUFBQYFBwgGBwUFBwUFBwUGBgYFBQcFBQYFBQUFBAkFAwMDAwMDAwQDBAUFBgYFBgUFBQUFAgQABAQFBAQEBAMDAwMDAwMGBgYHBwQFBQUFBQQCBwUCBQUFBQUFBQUFBQICAgICBQYFBQUFBQUFBQUFBAUEBwQFBgYCAgYGBQUDBgYGBgYGBgYFBQUFAgICAgYGBgYGBgYGBgYFBQUFBQUFBQUFBQUFAgICAgUFBQUFBQUFBQUEBAYFBgUGBQYFBgUGBQYFBgYFBQUFBQUFBQUFBgUGBQYFBgUGBQICAgICAgICAgcEBQIGBQUCBQIFAwUDBgUGBQYFBQYFBgUGBQYDBgMGAwUFBQUFBQUFBQUFAwUDBQMGBQYFBgUGBQYFBgUIBwUEBQUEBQQFBAgIBgUFBQUFBQUFBQUFBQQEBAQCAgICBgUFBQUFBQUFBQUFBQUFBQUFBQQEBAQEBQUFBQYCAgICAgQFBAQEBAYGBgUFBQUFBQUFBQUFBQUFBQUFBQUHBQUFBQUGBQYCBgYGAwYGBQUGAgYIBgYGBQUGAgUFBQUDBQUFBQQEAwUFBQcFBQUCAgUGBgYGBgUFBggGBgYGBgUGBQUFBQUFBAQFBAUCAgIFBAgHCAcIBwUEAgMFAgIICAYFBQYFBQYGBgUJCgUFBgUFBQIIBwIGBQYFCAgFBQYFBQgHBQUGBQYFBgUGBQYFBgUGBAYEBgQGBQgHBQYFBgUGBQYFBgUGBQYFBgUGBQYFBgUGBQUFBQUFBQUFBQUFBQUFBQUCAgICBgUGBQYFBgUGBQYFBgUGBQYFBgUGBQYFBgUGBQYGBgYGBgYGBgYFBAUEBQQFBQQGBQUEBwUFBgYFBAYFBQUGBAUFBwUFBQUFBQUFBgUGBQYFBQUCAgYFBgMGBQUGBQYFBgUGBQYFBgUFAggIBgUGBgUGAwUFBQMGBgQGBAgHBQQHBQUGAgUFBgUFBAUGAgUHBgUFBQUFAgUEBAUCAgQFBQUFBAQGBwYFBQUFBQUFBgUFBgYFBgYHBQUHBwcFBgUFBQUEAgAAAAMAAAADAAAAHAADAAEAAAAcAAMACgAABooABAZuAAAA9ACAAAYAdAAAAAIADQB+AKAArACtAL8AxgDPAOYA7wD+AQ8BEQElAScBMAFTAV8BZwF+AX8BjwGSAaEBsAHwAf8CGwI3AlkCvALHAskC3QLzAwEDAwMJAw8DIwOKA4wDkgOhA7ADuQPJA84D0gPWBCUELwRFBE8EYgRvBHkEhgSfBKkEsQS6BM4E1wThBPUFAQUQBRMeAR4/HoUe8R7zHvkfTSAJ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"
	Static 2 = "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"
	Static 3 = "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"
	Static 4 = "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"
	Static 5 = "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"
	Static 6 = "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"
	Static 7 = "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"
	Static 8 = "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"
	Static 9 = "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"
	Static 10 = "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"
	Static 11 = "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MQERFAYHBwYVFDMyNxcGIyImNTQ3IiYnETMRFBYzMjY1EQQKeG8ybE4wNA1GWllnWs35BLePhYOPBI3883q6MChbUkgaeSxoVmhWzrgDF/z0eYF/ewMMAP//ADEAAAXxBh4CJgHVAAABBwCeATsAHgAUALAARViwAy8bsQMcPlmxFwT0MDH//wANAAAEHAYeAiYB0wAAAQYAnj0eABQAsABFWLAILxuxCBw+WbENBPQwMf//AA0AAAQcBeMCJgHTAAABBgBqbR4AFwCwAEVYsAgvG7EIHD5ZsRAC9LAZ0DAxAP//AEcAAAPgBh4CJgHSAAABBwB1ATMAHgAUALAARViwCC8bsQgcPlmxDAb0MDH//wBHAAAD4AXgAiYB0gAAAQcAogEaAB4AFACwAEVYsAcvG7EHHD5ZsREC9DAx//8ARwAAA+AGHgImAdIAAAEGAJ9SHwAUALAARViwBy8bsQccPlmxDwb0MDH//wAcAAAFHQY/AiYAJQAAAAYArgQA////KQAABEYGPwImACkAAAAHAK7+cgAA////NwAABQgGQQImACwAAAAHAK7+gAAC////PQAAAXcGQAImAC0AAAAHAK7+hgAB////5v/sBR0GPwAmADMUAAAHAK7/LwAA////FAAABR8GPwAmAD1kAAAHAK7+XQAA////6QAABN8GPwAmALoUAAAHAK7/MgAA////m//0Aq0GdAImAMMAAAEHAK//Kv/sAB0AsABFWLAMLxuxDBo+WbEYAfSwD9CwGBCwIdAwMQD//wAcAAAFHQWwAgYAJQAA//8AqQAABIgFsAIGACYAAP//AKkAAARGBbACBgApAAD//wBWAAAEegWwAgYAPgAA//8AqQAABQgFsAIGACwAAP//ALcAAAF3BbACBgAtAAD//wCpAAAFBQWwAgYALwAA//8AqQAABlIFsAIGADEAAP//AKkAAAUIBbACBgAyAAD//wB2/+wFCQXEAgYAMwAA//8AqQAABMAFsAIGADQAAP//ADEAAASXBbACBgA4AAD//wAPAAAEuwWwAgYAPQAA//8AOQAABM4FsAIGADwAAP///9UAAAJeBwcCJgAtAAABBwBq/3ABQgAXALAARViwAi8bsQIePlmxCwT0sBTQMDEA//8ADwAABLsG+wImAD0AAAEHAGoAwgE2ABcAsABFWLAILxuxCB4+WbEQ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"
	Static 12 = "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OBg5zDhEDAIM0DiKOVg5lDTeNoQ5sg1GN1w4ZjWMDYw4Og7CODo4OjeIOGY4fA/EOXYQJjU8OXYQQDhmOcwQhjXGNv45zDb+EQgSBhMIE+oUjDl2FJIUnDg6F4YZeBpqG3AbhhuMG5IejB6SHswfAh+MNaA1oCG+OBgiYCNeNN4lwDgYOBg1QjgYOBg4GCaWNaA4GDWgKEApBimYKfoq4DWWK241PDNGK5gtcjhmMQAxOjMkMyQ4ZjJwMvozJDMkMyQ2/jeIOVg5djNGOGY1xjWWNN41PDe4N7g3uDgYNN41PDgYOBg5zDWWNN41PDTGM3A0xjTGNMY6CDQSNGA6AjS8Oeo58DoCOfA56jnqOeo56jSuOfA0zDnMOcw5zDnMOIo2/jb+Nv42/jb+Nv42/jTMN3o3ejd6N3o4GDgYOBg4GDgYOcw5zDnMOcw5zDaEN1w3XDdcN1w3XDdcN1w1jDWMNYw1jDg6N4g3iDeIN4g3iDl2OXY2/jdcNv43XDb+N1w0zDTMNMw0zDnMN3o1jDd6NYw3ejWMN3o1jDd6NYw4GDg6OBg4GDgYOBg4GDe4OAI4AjgCOAI4GDg6OBg4OjgYODo4OjnMN4g5zDeIOcw3iDh8OHw4fDiKOIo4ijmUNoQ5djaEObI5sjmyOgI6AjoIOfA58DnwOfA58DnwOfA6AjoCOgI6AjoCOfA58DnwOgI56jS8NLw0vDS8OgI6AjoCOgg2/jd6OBg4GDnMNoQ2/jeuN3o5sjgYOBg3uDgYOBg5zDhEOIo2hDTeOBg2hDg6N4g5djeIN3o1xjgYOBg3uDe4NUI2/jeuNcY3ejgYOBg5zDhENMw4ijTeN1w1jDeIOGY5djU8NYw1ljl2OZQ5lDmUNoQ5djTGNMY0xjgYODo2/jdcN3o1jDlYOXY0zDaEOXY4GDTeNTw4GDb+N1w2/jdcN3o1jDWMNYw03jU8Ocw3iDeIOGY1Qjl2NUI5djVCOXY2/jdcNv43XDb+N1w2/jdcNv43XDb+N1w2/jdcNv43XDb+N1w2/jdcNv43XDb+N1w3ejWMN3o1jDd6NYw3ejWMN3o1jDd6NYw3ejWMN3o1jDgYOBg5zDeIOcw3iDnMN4g5zDeIOcw3iDnMN4g5zDeIN4g2hDl2NoQ5djaEOXY4ijXGNZY4OjWgNcY3uDaEOBg4Ojb+N1w3ejgYOcw3iDh8N644ZjnMOcw4GDg6N7g3uDgCOBg4OjgYODo5zDhEOGY4fDiKOVg5djlYOXY5lDmyOcw58DoCOfA56joIOeo58DoCOggAAgCkAAQABAAAAAYABgABAAsADAACABMAEwAEACUAKgAFACwALQALAC8ANgANADgAOAAVADoAPwAWAEUARgAcAEkASgAeAEwATAAgAE8ATwAhAFEAVAAiAFYAVgAmAFgAWAAnAFoAXQAoAF8AXwAsAIoAigAtAJYAlgAuAJ0AnQAvALEAtQAwALcAuQA1ALsAuwA4AL0AvgA5AMAAwQA7AMMAxQA9AMcAzgBAANIA0gBIANQA3gBJAOAA7wBUAPEA8QBkAPYA+ABlAPsA/ABoAP4BAABqAQMBBQBtAQoBCgBwAQ0BDQBx"
	Static 13 = "ARgBGgByASIBIgB1AS4BMAB2ATMBNQB5ATcBNwB8ATkBOQB9ATsBOwB+AUMBRAB/AVQBVACBAVYBVgCCAVgBWACDAVwBXgCEAYQBhQCHAYcBiQCJAdgB2ACMAdoB2wCNAd0B3QCPAeAB4QCQAesB7QCSAf8B/wCVAg4CEACWAjACMACZAjMCMwCaAkUCRQCbAkcCSACcAnoCewCeAn0CfQCgAn8ClAChApkCoAC3AqICpQC/AqoCrwDDArQCvADJAr4CvgDSAsACwADTAsICwgDUAsQCxADVAsYCzwDWAtgC2gDgAtwC3ADjAt4C3gDkAuAC4ADlAuIC4gDmAucC5wDnAukC6QDoAusC6wDpAu0C7QDqAu8C7wDrAvEC/QDsAv8C/wD5AwEDAQD6AwMDAwD7Aw4DDgD8AxADEAD9AxIDEgD+AyADIAD/AyIDJQEAAycDJwEEAykDKQEFAy8DOAEGA0MDRwEQA00DTwEVA1QDVAEYA2UDaQEZA20DbwEeA3gDeAEhA4YDiwEiA44DnQEoA6ADoAE4A6QDpAE5A6YDpgE6A6oDqgE7A60DrgE8A7ADsQE+A7MDuQFAA7sDvQFHA78DxAFKA8YDxwFQA8kDzAFSA9ID0wFWA9UD1QFYA9cD1wFZA9kD3AFaA98D5AFeA+YD5gFkA+oD6wFlA/AD8AFnA/ID+wFoA/4D/wFyBAEEBAF0BAsEDAF4BBAEEAF6BBIEGAF7BB4ERgGCBEgESAGrBEoEVwGsBF8EXwG6BHAEdQG7BHcEdwHBBHsEfAHCBH8EfwHEBIEEggHFBIQEhAHHBIYEhgHIBJcEmwHJBJ0EnQHOBJ8EoAHPBKIEogHRBKYEqAHSBKoEqgHVBKwErgHWBLAEsAHZBLIEsgHaBLQEugHbBLwEvAHiBL8EvwHjBMIExgHkBMgEyAHpBMoEywHqBM8EzwHsBNIE0gHtBNgE2AHuBN0E3QHvBOgE6AHwBOoE6gHxBPEE8QHyBPUE9QHzAAsAOP/YANL/2ADW/9gBOf/YAUX/2AMO/9gDEP/YAxL/2APB/9gEd//YBL//2AAYADoAFAA7ABIAPQAWARkAFAKZABYDIAASAyIAFgMkABYDiwAWA5oAFgOdABYD0wASA9UAEgPXABID2QAWA+oAFAPyABYEcAAWBHIAFgR0ABYEhgAWBMIAFATEABQExgASAAEAE/8gAOcAEP8WABL/FgAl/1YALv74ADgAFABF/94AR//rAEj/6wBJ/+sAS//rAFP/6wBV/+sAVv/mAFn/6gBa/+gAXf/oAJT/6wCZ/+sAm//qALL/VgC0/1YAu//rAL3/6ADI/+sAyf/rAMv/6gDSABQA1gAUAPf/6wED/+sBDf9WARj/6wEa/+gBHv/rASL/6wE5ABQBQv/rAUUAFAFg/+sBYf/rAWv/6wGG/xYBiv8WAY7/FgGP/xYB6//AAe3/wAIz/8ACf/9WAoD/VgKB/1YCgv9WAoP/VgKE/1YChf9WApr/3gKb/94CnP/eAp3/3gKe/94Cn//eAqD/3gKh/+sCov/rAqP/6wKk/+sCpf/rAqv/6wKs/+sCrf/rAq7/6wKv/+sCsP/qArH/6gKy/+oCs//qArT/6AK1/+gCtv9WArf/3gK4/1YCuf/eArr/VgK7/94Cvf/rAr//6wLB/+sCw//rAsX/6wLH/+sCyf/rAsv/6wLN/+sCz//rAtH/6wLT/+sC1f/rAtf/6wLl/vgC+f/rAvv/6wL9/+sDDgAUAxAAFAMSABQDFf/qAxf/6gMZ/+oDG//qAx3/6gMf/+oDI//oAzL/wAMz/8ADNP/AAzX/wAM2/8ADN//AAzj/wANN/8ADTv/AA0//wAOG/1YDjv9WA57/6wOi/+oDpP/rA6b/6AOp/+oDqv/rA6v/6gOy/vgDtv9WA8EAFAPD/94DxP/rA8b/6wPI/+sDyf/oA8v/6wPS/+gD2v/oA+L/VgPj/94D5v/rA+v/6APs/+sD8f/rA/P/6AP4/1YD+f/eA/r/VgP7/94D///rBAH/6wQC/+sEDP/rBA7/6wQQ/+sEFP/oBBb/6AQY/+gEHf/rBB7/VgQf/94EIP9WBCH/3gQi/1YEI//eBCT/VgQl/94EJv9WBCf/3gQo/1YEKf/eBCr/VgQr/94ELP9WBC3/3gQu/1YEL//eBDD/VgQx/94EMv9WBDP/3gQ0/1YENf/eBDf/6wQ5/+sEO//rBD3/6wQ//+sEQf/rBEP/6wRF/+sES//rBE3/6wRP/+sEUf/rBFP/6wRV/+sEV//rBFn/6wRb/+sEXf/rBF//6wRh/+sEY//qBGX/6gRn/+oEaf/qBGv/6gRt/+oEb//qBHH/6ARz/+gEdf/oBHcAFASZ/1YEmv/eBJz/6wSg/+sEpP/qBKn/6wSr/+sEvwAUBMP/6ATF/+gEy//ABNL/wATq/8AAMwA4/9UAOv/kADv/7AA9/90A0v/VANb/1QEZ/+QBOf/VAUX/1QHrAA4B7QAOAjMADgKZ/90DDv/VAxD/1QMS/9UDIP/sAyL/3QMk/90DMgAOAzMADgM0AA4DNQAOAzYADgM3AA4DOAAOA00ADgNOAA4DTwAOA4v/3QOa/90Dnf/dA8H/1QPT/+wD1f/sA9f/7APZ/90D6v/kA/L/3QRw/90Ecv/dBHT/3QR3/9UEhv/dBL//1QTC/+QExP/kBMb/7ATLAA4E0gAOBOoADgAdADj/sAA6/+0APf/QANL/sADW/7ABGf/tATn/sAFF/7ACmf/QAw7/sAMQ/7ADEv+wAyL/0AMk/9ADi//QA5r/0AOd/9ADwf+wA9n/0APq/+0D8v/QBHD/0ARy/9AEdP/QBHf/sASG/9AEv/+wBML/7QTE/+0AEQAu/+4AOf/uApX/7gKW/+4Cl//uApj/7gLl/+4DFP/uAxb/7gMY/+4DGv/uAxz/7gMe/+4Dsv/uBGL/7gRk/+4Ewf/uAE0ABgAQAAsAEAANABQAQQASAEf/6ABI/+gASf/oAEv/6ABV/+gAYQATAJT/6ACZ/+gAu//oAMj/6ADJ/+gA9//oAQP/6AEe/+gBIv/oAUL/6AFg/+gBYf/oAWv/6AGEABABhQAQAYcAEAGIABABiQAQAqH/6AKi/+gCo//oAqT/6AKl/+gCvf/oAr//6ALB/+gCw//oAsX/6ALH/+gCyf/oAsv/6ALN/+gCz//oAtH/6ALT/+gC1f/oAtf/6AOe/+gDxP/oA8j/6APL/+gD2wAQA9wAEAPfABAD5v/oA+z/6APx/+gD///oBAH/6AQC/+gEDv/oBB3/6AQ3/+gEOf/oBDv/6AQ9/+gEP//oBEH/6ARD/+gERf/oBFn/6ARb/+gEXf/oBGH/6ASc/+gEqf/oBKv/6ABAAEf/7ABI/+wASf/sAEv/7ABV/+wAlP/sAJn/7AC7/+wAyP/sAMn/7AD3/+wBA//sAR7/7AEi/+wBQv/sAWD/7AFh/+wBa//sAqH/7AKi/+wCo//sAqT/7AKl/+wCvf/sAr//7ALB/+wCw//sAsX/7ALH/+wCyf/sAsv/7ALN/+wCz//sAtH/7ALT/+wC1f/sAtf/7AOe/+wDxP/sA8j/7APL/+wD5v/sA+z/7APx/+wD///sBAH/7AQC/+wEDv/sBB3/7AQ3/+wEOf/sBDv/7AQ9/+wEP//sBEH/7ARD/+wERf/sBFn/7ARb/+wEXf/sBGH/7ASc/+wEqf/sBKv/7AAYAFP/7AEY/+wCq//sAqz/7AKt/+wCrv/sAq//7AL5/+wC+//sAv3/7AOk/+wDqv/sA8b/7AQM/+wEEP/sBEv/7ARN/+wET//sBFH/7ART/+wEVf/sBFf/7ARf/+wEoP/sAAYAEP+EABL/hAGG/4QBiv+EAY7/hAGP/4QAEQAu/+wAOf/sApX/7AKW/+wCl//sApj/7ALl/+wDFP/sAxb/7AMY/+wDGv/sAxz/7AMe/+wDsv/sBGL/7ARk/+wEwf/sACAABv/yAAv/8gBa//MAXf/zAL3/8wD2//UBGv/zAYT/8gGF//IBh//yAYj/8gGJ//ICtP/zArX/8wMj//MDpv/zA8n/8wPS//MD2v/zA9v/8gPc//ID3//yA+v/8wPz//MEFP/zBBb/8wQY//MEcf/zBHP/8wR1//MEw//zBMX/8wA/ACf/8wAr//MAM//zADX/8wCD//MAk//zAJj/8wCz//MAxAANANP/8wEI//MBF//zARv/8wEd//MBH//zASH/8wFB//MBav/zAkX/8wJG//MCSP/zAkn/8wKG//MCkP/zApH/8wKS//MCk//zApT/8wK8//MCvv/zAsD/8wLC//MC0P/zAtL/8wLU//MC1v/zAvj/8wL6//MC/P/zAy3/8wOK//MDl//zA73/8wPA//MD7f/zA/D/8wQL//MEDf/zBA//8wRK//METP/zBE7/8wRQ//MEUv/zBFT/8wRW//MEWP/zBFr/8wRc//MEXv/zBGD/8wSf//MEuP/zAEAAJ//mACv/5gAz/+YANf/mAIP/5gCT/+YAmP/mALP/5gC4/8IAxAAQANP/5gEI/+YBF//mARv/5gEd/+YBH//mASH/5gFB/+YBav/mAkX/5gJG/+YCSP/mAkn/5gKG/+YCkP/mApH/5gKS/+YCk//mApT/5gK8/+YCvv/mAsD/5gLC/+YC0P/mAtL/5gLU/+YC1v/mAvj/5gL6/+YC/P/mAy3/5gOK/+YDl//mA73/5gPA/+YD7f/mA/D/5gQL/+YEDf/mBA//5gRK/+YETP/mBE7/5gRQ/+YEUv/mBFT/5gRW/+YEWP/mBFr/5gRc/+YEXv/mBGD/5gSf/+YEuP/mADgAJf/kADz/0gA9/9MAsv/kALT/5ADE/+IA2v/SAQ3/5AEz/9IBQ//SAV3/0gJ//+QCgP/kAoH/5AKC/+QCg//kAoT/5AKF/+QCmf/TArb/5AK4/+QCuv/kAyL/0wMk/9MDhv/kA4v/0wOO/+QDmv/TA5v/0gOd/9MDtv/kA8L/0gPZ/9MD4v/kA/L/0wP1/9ID+P/kA/r/5AQD/9IEHv/kBCD/5AQi/+QEJP/kBCb/5AQo/+QEKv/kBCz/5AQu/+QEMP/kBDL/5AQ0/+QEcP/TBHL/0wR0/9MEhv/TBJn/5AAoABD/HgAS/x4AJf/NALL/zQC0/80Ax//yAQ3/zQGG/x4Biv8eAY7/HgGP/x4Cf//NAoD/zQKB/80Cgv/NAoP/zQKE/80Chf/NArb/zQK4/80Cuv/NA4b/zQOO/80Dtv/NA+L/zQP4/80D+v/NBB7/zQQg/80EIv/NBCT/zQQm/80EKP/NBCr/zQQs/80ELv/NBDD/zQQy/80ENP/NBJn/zQABAMQADgACAMr/7QD2/8AAugBH/9wASP/cAEn/3ABL/9wAUf/zAFL/8wBT/9YAVP/zAFX/3ABZ/90AWv/hAF3/4QCU/9wAmf/cAJv/3QC7/9wAvf/hAL7/7gC//+YAwf/zAML/6wDD/+kAxf/wAMb/5wDI/9wAyf/cAMr/4wDL/90AzP/OAM3/1ADO/9sA7P/zAPD/8wDx//MA8//zAPT/8wD1//MA9//cAPj/8wD6//MA+//zAP7/8wEA//MBA//cAQX/8wEY/9YBGv/hAR7/3AEi/9wBK//zATb/8wE8//MBPv/zAUL/3AFT//MBVf/zAVf/8wFc//MBYP/cAWH/3AFr/9wCof/cAqL/3AKj/9wCpP/cAqX/3AKq//MCq//WAqz/1gKt/9YCrv/WAq//1gKw/90Csf/dArL/3QKz/90CtP/hArX/4QK9/9wCv//cAsH/3ALD/9wCxf/cAsf/3ALJ/9wCy//cAs3/3ALP/9wC0f/cAtP/3ALV/9wC1//cAvL/8wL0//MC9v/zAvf/8wL5/9YC+//WAv3/1gMV/90DF//dAxn/3QMb/90DHf/dAx//3QMj/+EDnv/cA6D/8wOi/90DpP/WA6b/4QOp/90Dqv/WA6v/3QPE/9wDxf/z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A8f/0QPJ/+YDyv/vA8z/0QPR/9ED0v/mA9n/0wPa/+YD2//KA9z/ygPf/8oD4f/RA+f/0QPq/9QD6//mA/L/0wPz/+YD9f/0A/b/7wQD//QEBP/vBAj/0QQK/9EEE//tBBT/5gQV/+0EFv/mBBf/7QQY/+YEGf/hBBz/0QRw/9MEcf/mBHL/0wRz/+YEdP/TBHX/5gR3/9IEef/hBHz/0QSG/9MEmP/RBLX/0QS3/9EEv//SBML/1ATD/+YExP/UBMX/5gAoADj/vgBa/+8AXf/vAL3/7wDS/74A1v++AOb/yQD2/98BCf/tARr/7wEg/+sBOf++ATr/3wFF/74BTP/pAWP/9QFt/+ACtP/vArX/7wMO/74DEP++AxL/vgMj/+8Dpv/vA8H/vgPJ/+8D0v/vA9r/7wPr/+8D8//vBBT/7wQW/+8EGP/vBHH/7wRz/+8Edf/vBHf/vgS//74Ew//vBMX/7wA/ADj/5gA6/+cAPP/yAD3/5wBc//EA0v/mANb/5gDa//IA3v/uAOH/6ADm/+YA7v/xAPb/0AEZ/+cBM//yATT/8QE5/+YBOv/OAUP/8gFE//EBRf/mAUf/6AFJ/+gBXf/yAV7/8QFi/+cBZP/tAWz/5gFt/9ACmf/nAw7/5gMQ/+YDEv/mAyL/5wMk/+cDi//nA5r/5wOb//IDnf/nA7X/7gPB/+YDwv/yA8r/8QPZ/+cD6v/nA/L/5wP1//ID9v/xBAP/8gQE//EEE//uBBX/7gQX/+4EGf/oBHD/5wRy/+cEdP/nBHf/5gR5/+gEhv/nBL//5gTC/+cExP/nAJgAJQAQACf/6AAr/+gAM//oADX/6AA4/+AAOv/gAD3/3wCD/+gAk//oAJj/6ACyABAAs//oALQAEADS/+AA0//oANQAEADW/+AA2QAUAN0AEADh/+EA5v/gAO0AEwDyABAA+f/gAQQAEAEI/+gBDQAQARf/6AEZ/+ABG//oAR3/6AEf/+gBIf/oATn/4AFB/+gBRf/gAUf/4QFI/+ABSf/hAUr/4AFN/+EBUAAQAVEAEAFY/+kBYv/fAWT/3gFmABABav/oAWz/3wFu//IBbwAQAXAAEAJF/+gCRv/oAkj/6AJJ/+gCfwAQAoAAEAKBABACggAQAoMAEAKEABAChQAQAob/6AKQ/+gCkf/oApL/6AKT/+gClP/oApn/3wK2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"
	Static 14 = "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AEkASQAcAEwATAAdAFEAVAAeAFYAVgAiAFoAWgAjAFwAXgAkAIoAigAnAJYAlgAoALEAtAApAL0AvQAtAMEAwQAuAMcAxwAvANQA1QAwANcA1wAyANoA2gAzANwA3gA0AOAA5gA3AOwA7AA+AO4A7gA/APcA9wBAAPwA/ABBAP4A/wBCAQQBBQBEAQoBCgBGAQ0BDQBHARgBGgBIAS4BMABLATMBNQBOATcBNwBRATkBOQBSATsBOwBTAUMBRABUAVQBVABWAVYBVgBXAVgBWABYAVwBXgBZAYQBigBcAY4BjwBjAdgB2ABlAd0B3QBmAeAB4QBnAesB7QBpAf8B/wBsAg4CEABtAjACMABwAjMCMwBxAkUCRQByAkcCSABzAnoCewB1An0CfQB3An8CpQB4AqoCrwCfArQCxAClAsYCzwC2AtgC2gDAAtwC3ADDAt4C3gDEAuAC4ADFAuIC4gDGAuUC5QDHAucC5wDIAukC6QDJAusC6wDKAu0C7QDLAu8C7wDMAvEC/QDNAv8C/wDaAwEDAQDbAwMDAwDcAw4DDgDdAxADEADeAxIDEgDfAxQDFADgAxYDFgDhAxgDGADiAxoDGgDjAxwDHADkAx4DHgDlAyADIADmAyIDKgDnAy8DOADwA0MDRwD6A00DTwD/A1QDVAECA2UDaQEDA20DbwEIA3gDeAELA4YDiwEMA44DnQESA6ADoAEiA6QDpAEjA6YDpgEkA6oDqgElA60DrgEmA7ADuQEoA7sDvQEyA78DxAE1A8YDzAE7A9ID0wFCA9UD1QFEA9cD1wFFA9kD3AFGA98D5AFKA+YD5gFQA+oD6wFRA/AD+wFTA/4D/wFfBAEEBAFhBAsEDAFlBBAEEAFnBBIEGAFoBB4ERgFvBEgESAGYBEoEVwGZBF8EXwGnBGIEYgGoBGQEZAGpBHAEdQGqBHcEdwGwBHsEfAGxBH8EfwGzBIEEggG0BIQEhAG2BIYEhgG3BJcEmwG4BJ0EnQG9BJ8EoAG+BKIEogHABKYEqAHBBKoEqgHEBKwErgHFBLAEsAHIBLIEsgHJBLQEugHKBLwEvAHRBL8EvwHSBMEExgHTBMgEywHZBM8EzwHdBNIE0gHeBNgE2AHfBN0E3QHgBOgE6AHhBOoE6gHiBPEE8QHjBPUE9QHkAAIBdAAGAAYAGQALAAsAGQAQABAAIQAS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AAEAAwAhAAMAAwAAAAAAAwAAAAMAAAAAAAEAGwADAAAAAAACAAAAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAAAAACAAQAHQAJAAIAAAACAAEAAgAAAAIAAQAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAABEAFQAAAAMAAAAAAAsAAAAAAAMAAAADAAAAAAACAAEAEQAVAAsAAAAgACEAAAAAAAAAAAAAAAAAAAAZABsAAAADAAAAAwAAAAMAAAAAAAAAAAADABEAFQAAAAEAAQAAAAAAAAAAABkAAAAAAAAAAgABAAAAAAAAABkAGwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8AHwAAABQAFAAaABQAFAAUABoAAAAAAAAAGgAaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFwAcACQAAAASABgAHgAAAAgAAAAIAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAADQAIAA0AAAAAAAAAAAAAAAAAGAAIAAAAAAAYAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAcAAAAAAAYAAgAFwAcABgAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAAAAgACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAfAAAAAAAAAAAAAAAGAAYABgAGAAYABgAGAAIAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAgACAAoACgAKAAoADAAHAAcABwAHAAcABwAHAAEAAQABAAEAAQAAAAAAAAAAAAMABAAEAAQABAAEAAUABQAFAAUACQAJAAYABwAGAAcABgAHAAIAAQACAAEAAgABAAIAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQACAAEAAgABAAIAAQACAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAADAAAAAwADAAIABAACAAQAAgAEAAAAAAAAAAAAAAAAABAADgAQAA4AEAAOABAADgAQAA4ACwAAAAsAAAALAAAACgAFAAoABQAKAAUACgAFAAoABQAKAAUAFgAAAAwACQAMABMADwATAA8AEwAPAAAAAAACAAAAAAAAAAAADQANAA0ADQANAA0ADQAIAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAgACAASABIAEgASABcADQANAA0ACAAIAAgACAAAAAAAAAAAAAAAAAAIAAgACAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAAAAAAAAB4AHgAeAB4AAAAYAAAAEgASABIAEgASABIAJAAXABcAAAAAAAAABgAAAAAAAAACAAwAAAAAAAYAAAAAABMAAAAAAAAAAAAAAAIAAAAAAAwAEQAAAAwAAQAAAAMAAAAFAAAABAAAAAkAAAAAAAUABAAFAAAAAAAAAAAAAAAAACMAAAAAACIABgAAAAAAAAAAAAAAAAACAAAAAAACAAsAEQAHAAEAAwAEAAMAAQAJABUAAQADAA4AAAAAAAAAAwAJABYAAAAWAAAAFgAAAAwACQAUABQAAAAAABQAAAADAAYABwAAAAAAAQADAAAAAAAdAAkAAQACAAAAAAACAAEADAAJAAAAEQAVAAAABgAHAAYABwAAAAAAAAABAAAAAQABABEAFQAAAAAAAAADAAAAAwACAAQAAgABAAIABAAAAAAAIgAJACIACQAiAAkAIAAhAAAAAwABAAYABwAGAAcABgAHAAYABwAGAAcABgAHAAYABwAGAAcABgAHAAYABwAGAAcABgAHAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAAAAAAAAAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAgABAAIAAQACAAEAAgAEAAIAAQAKAAUACgAFAAAABQAAAAUAAAAFAAAABQAAAAUADAAJAAwACQAMAAkAAAALAAAAIAAhAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAfAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAYABwAAAAEAAAAAAAIABAAAAAAAAAAFAAAAAAAAAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAMAAgAAAAAAAAAAABAADgALAAAACgAdAAkAHQAJABYAAAATAA8AAAANAAAAAAAAAAgAFwAAAA0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAABcAHAAAABcAAAAAAAAAAAAAAAAAAAAAAA0AAAAAAAAAAAAAAAAACAAAAAAACAAYABwAAAAAAAgAFwABAAAACgFiApIABERGTFQAGmN5cmwAGmdyZWsAGmxhdG4ASAAEAAAAAP//ABIAAAABAAIAAwAEAAgADAANAA4ADwAQABEAEgATABQAFQAWABcALgAHQVpFIADkQ1JUIADkRlJBIABaTU9MIAC2TkFWIACIUk9NIAC2VFJLIADkAAD//wATAAAAAQACAAMABAAHAAgADAANAA4ADwAQABEAEgATABQAFQAWABcAAP//ABQAAAABAAIAAwAEAAYACAAJAAwADQAOAA8AEAARABIAEwAUABUAFgAXAAD//wAUAAAAAQACAAMABAAGAAgACwAMAA0ADgAPABAAEQASABMAFAAVABYAFwAA//8AFAAAAAEAAgADAAQABgAIAAoADAANAA4ADwAQABEAEgATABQAFQAWABcAAP//ABMAAAABAAIAAwAEAAUACAAMAA0ADgAPABAAEQASABMAFAAVABYAFwAYYzJzYwCSY2NtcACYZGxpZwCgZG5vbQCmZnJhYwCsbGlnYQC2bGlnYQC8bGlnYQDIbG51bQDQbG9jbADWbG9jbADcbG9jbADibnVtcgDob251bQDucG51bQD0c21jcAD6c3MwMQEAc3MwMgEGc3MwMwEMc3MwNAESc3MwNQEYc3MwNgEec3MwNwEkdG51bQEqAAAAAQAAAAAAAgACAAQAAAABAAoAAAABABgAAAADABYAFwAZAAAAAQAJAAAABAAIAAkACAAJAAAAAgAIAAkAAAABABUAAAABAAcAAAABAAUAAAABAAYAAAABABkAAAABABIAAAABABMAAAABAAEAAAABAAsAAAABAAwAAAABAA0AAAABAA4AAAABAA8AAAABABAAAAABABEAAAABABQAGgA2BDAH7gigCMoPbg+ED64Pwg/mEBAQTBBgEHQQiBCaELQQ9hEUEWYRrBIOEmwSgBKwEtIAAQAAAAEACAACAfoA+gHnAnEB0QHQAc8BzgHNAcwBywHKAckByAIzAjICMQIwAigB5gHlAeQB4wHiAeEB4AHfAd4B3QHcAdsB2gHZAdgB1wHWAdUB1AHTAdIB6AHpAnMCdQJ0AnYCcgJ3AlIB6gHrAewB7QHuAe8B8AHxAfIB8wH0AfUB9gH3AfgB+QH6AfsB/AH9Af4CAAIBBP4CAgIDAgQCBQIGAgcCCAIJAgoCCwI7Ag0CDgIPAhAE+AIRAhMCFAIVAhYCFwIYAhkCGwIcAh4CHQMvAzADMQMyAzMDNAM1AzYDNwM4AzkDOgM7AzwDPQM+Az8DQANBA0IDQwNEA0UDRgNHA0gDSQNKA0sDTANNA04DTwNQA1EDUgNTA1QDVQNWA1cDWANZA1oDWwNcA10DXgNfA2ADYQNiA2ME/wNkA2UDZgNnA2gDaQNqA2sDbANtA24DbwNwA3EDcgNzA3QDdQUCA3YDdwN5A3gDegN7A3wDfQN+A38DgAOBA4IDgwOEA4UFAAUBBMsEzATNBM4EzwTQBNEE0gTTBNQE1QTWBNcE2ATZBNoE2wTcBN0E3gTfBOAE4QTiBOME5ATlBOYE5wH/BOgE6QTqBOsE7ATtBO4E7wTwBPEE8gTzBPQE9QT2BQMFBAUFBQYE9wT5BPoE/AIaBP0E+wIMAhIFCwUMAAEA+gAIAAoAFAAVABYAFwAYABkAGgAbABwAHQAlACYAJwAoACkAKgArACwALQAuAC8AMAAxADIAMwA0ADUANgA3ADgAOQA6ADsAPAA9AD4AZQBnAIEAgwCEAIwAjwCRAJMAsQCyALMAtAC1ALYAtwC4ALkAugDSANMA1ADVANYA1wDYANkA2gDbANwA3QDeAN8A4ADhAOIA4wDkAOUA5gDnAOgA6QEvATMBNQE3ATkBOwFBAUMBRQFJAUsBTAFYAVkBlwGdAaIBpQJ6AnsCfQJ/AoACgQKCAoMChAKFAoYChwKIAokCigKLAowCjQKOAo8CkAKRApICkwKUApUClgKXApgCmQK2ArgCugK8Ar4CwALCAsQCxgLIAsoCzALOAtAC0gLUAtYC2ALaAtwC3gLgAuIC4wLlAucC6QLrAu0C7wLxAvMC9QL4AvoC/AL+AwADAgMEAwYDCAMKAwwDDgMQAxIDFAMWAxgDGgMcAx4DIAMiAyQDJQMnAykDKwMtA4YDhwOIA4kDigOLA4wDjgOPA5ADkQOSA5MDlAOVA5YDlwOYA5kDmgObA5wDnQOtA64DrwOwA7EDsgOzA7QDtQO2A7cDuAO5A7oDuwO8A70DvgO/A8ADwQPCA9MD1QPXA9kD7gPwA/IEBwQNBBMEfQSCBIYFBwUJAAEAAAABAAgAAgHcAOsCcQIzAjICMQIwAigB5gHlAeQB4wHiAeEB4AHfAd4B3QHcAdsB2gHZAdgB1wHWAdUB1AHTAdICZAJzAzACdQJ0Ay8B4wJyAncCUgTSBNMB6gHrBNQE1QTWAewE1wHtAe4B7wTc"
	Static 15 = "AfAB8ATdBN4B8QHyAfMB+gTrBOwB+wH8Af0B/gH/AgAE7wTwBPIE9QT+AgICAwIEAgUCBgIHAggCCQIKAgsB9AH1AfYB9wH4AfkCOwINAg4CDwIQBPgCEQITAhQCFQIXAhkCdgMxAzIDMwM0AzUDNgM3AzgDOQM6AzsDPAM9Az4DPwNAA0EDQgNDA0QDRQNGA0cDSANJA0oDSwNMA4IDTQNOA08DUANRA1IDUwNUA1UDVgNXA1gDWQNaA1sDXANdA14DXwNgA2EDYgT/A2QDZQNmA2cDaANpA2oDawNsA20DbgNvA3ADcQNyA3MDdAN1BQIDdgN3A3kDeAN6A3sDfAN9A34DfwOAA4EDgwOEA4UFAAUBBMsEzATNBM4E2ATbBNkE2gTfBOAE4QTPBNAE0QTqBO0E7gTxBPME9AIBBPYE4gTjBOQE5QTmBOcE6ATpBQMFBAUFBQYE9wT5BPoCGAT8AhoE/QT7AhYCDAISBQsFDAABAOsACgBFAEYARwBIAEkASgBLAEwATQBOAE8AUABRAFIAUwBUAFUAVgBXAFgAWQBaAFsAXABdAF4AhQCGAIcAiQCKAIsAjQCQAJIAlAC7ALwAvQC+AL8AwADBAMIAwwDEAMUAxgDHAMgAyQDKAMsAzADNAM4A6gDrAOwA7QDuAO8A8ADxAPIA8wD0APUA9gD3APgA+QD6APsA/AD9AP4A/wEAAQEBAgEDAQQBBQEGAQcBMAE0ATYBOAE6ATwBQgFEAUYBSgFNAVoCfAJ+ApoCmwKcAp0CngKfAqACoQKiAqMCpAKlAqYCpwKoAqkCqgKrAqwCrQKuAq8CsAKxArICswK0ArUCtwK5ArsCvQK/AsECwwLFAscCyQLLAs0CzwLRAtMC1QLXAtkC2wLdAt8C4QLkAuYC6ALqAuwC7gLwAvIC9AL2AvkC+wL9Av8DAQMDAwUDBwMJAwsDDQMPAxEDEwMVAxcDGQMbAx0DHwMhAyMDJgMoAyoDLAMuA54DnwOgA6EDowOkA6UDpgOnA6gDqQOqA6sDrAPDA8QDxQPGA8cDyAPJA8oDywPMA80DzgPPA9AD0QPSA9QD1gPYA9oD7wPxA/MEAQQIBA4EFAR+BH8EgwSHBQgFCgAGAAAABgASACoAQgBaAHIAigADAAAAAQASAAEAkAABAAAAAwABAAEATQADAAAAAQASAAEAeAABAAAAAwABAAEATgADAAAAAQASAAEAYAABAAAAAwABAAEC4QADAAAAAQASAAEASAABAAAAAwABAAEDzgADAAAAAQASAAEAMAABAAAAAwABAAED0AADAAAAAQASAAEAGAABAAAAAwABAAEESQACAAIAqACsAAABJAEnAAUAAQAAAAEACAACABIABgJhAl8CYgJjAmAFDQABAAYATQBOAuEDzgPQBEkABAAAAAEACAABBjIANgByAKQArgC4AMoA/AEOARgBSgFkAX4BkAG6AfYCAAIiAjwCTgKKApwCtgLgAvIDJAMuAzgDSgN8A4YDkAOaA7QDzgPgBAoEPARGBGgEggSUBMYE2ATyBRwFLgU4BUIFTAVWBYAFqgXUBf4GKAAGAA4AFAAaACAAJgAsAoAAAgCpBB4AAgCtAn8AAgCoBCAAAgCrAoIAAgCqBJkAAgCsAAEABASmAAIArQABAAQCvAACAKkAAgAGAAwEqgACAboEqAACAK0ABgAOABQAGgAgACYALAKIAAIAqQQ2AAIArQKHAAIAqAQ4AAIAqwQ6AAIAqgSbAAIArAACAAYADASVAAIAqQLWAAIBugABAAQErAACAK0ABgAOABQAGgAgACYALAKMAAIAqQRIAAIArQKLAAIAqARGAAIAqwLaAAIAqgSdAAIArAADAAgADgAUBK4AAgCpAucAAgG6BLAAAgCtAAMACAAOABQC6QACAKkC6wACAboEsgACAK0AAgAGAAwD4AACAKkEtAACAK0ABQAMABIAGAAeACQC8QACAKkC8wACAboEtgACAK0ElwACAKgCjwACAKoABwAQABgAHgAkACoAMAA2BLgAAwCqAKkCkQACAKkESgACAK0CkAACAKgETAACAKsCkwACAKoEnwACAKwAAQAEBLkAAgCpAAQACgAQABYAHAL+AAIAqQMAAAIBugS7AAIArQShAAIArAADAAgADgAUAwQAAgCpAwoAAgG6BL0AAgCtAAIABgAMAw4AAgG6BL8AAgCtAAcAEAAYAB4AJAAqADAANgTBAAMAqgCpApYAAgCpBGIAAgCtApUAAgCoBGQAAgCrAxQAAgCqBKMAAgCsAAIABgAMBMQAAgCtBMIAAgCqAAMACAAOABQD1QACAKkExgACAK0D0wACAKgABQAMABIAGAAeACQCmQACAKkEcAACAK0D2QACAKgEcgACAKsEdAACAKoAAgAGAAwDJQACAKkEyAACAK0ABgAOABQAGgAgACYALAKbAAIAqQQfAAIArQKaAAIAqAQhAAIAqwKdAAIAqgSaAAIArAABAAQEpwACAK0AAQAEAr0AAgCpAAIABgAMBKsAAgG6BKkAAgCtAAYADgAUABoAIAAmACwCowACAKkENwACAK0CogACAKgEOQACAKsEOwACAKoEnAACAKwAAQAEBJYAAgCpAAEABAStAAIArQABAAQESQACAK0AAwAIAA4AFASvAAIAqQLoAAIBugSxAAIArQADAAgADgAUAuoAAgCpAuwAAgG6BLMAAgCtAAIABgAMA+EAAgCpBLUAAgCtAAUADAASABgAHgAkAvIAAgCpAvQAAgG6BLcAAgCtBJgAAgCoAqoAAgCqAAYADgAUABoAIAAmACwCrAACAKkESwACAK0CqwACAKgETQACAKsCrgACAKoEoAACAKwAAQAEBLoAAgCpAAQACgAQABYAHAL/AAIAqQMBAAIBugS8AAIArQSiAAIArAADAAgADgAUAwUAAgCpAwsAAgG6BL4AAgCtAAIABgAMAw8AAgG6BMAAAgCtAAYADgAUABoAIAAmACwCsQACAKkEYwACAK0CsAACAKgEZQACAKsDFQACAKoEpAACAKwAAgAGAAwExQACAK0EwwACAKoAAwAIAA4AFAPWAAIAqQTHAAIArQPUAAIAqAAFAAwAEgAYAB4AJAK0AAIAqQRxAAIArQPaAAIAqARzAAIAqwR1AAIAqgACAAYADAMmAAIAqQTJAAIArQABAAQDKwACAKkAAQAEAy0AAgCpAAEABAMsAAIAqQABAAQDLgACAKkABQAMABIAGAAeACQCpwACAKkCpgACAKgERwACAKsC2wACAKoEngACAKwABQAMABIAGAAeACQEWAACAKkEYAACAK0EWgACAKgEXAACAKsEXgACAKoABQAMABIAGAAeACQEWQACAKkEYQACAK0EWwACAKgEXQACAKsEXwACAKoABQAMABIAGAAeACQEZgACAKkEbgACAK0EaAACAKgEagACAKsEbAACAKoABQAMABIAGAAeACQEZwACAKkEbwACAK0EaQACAKgEawACAKsEbQACAKoAAQAEBKUAAgCpAAIAEQAlACkAAAArAC0ABQAvADQACAA2ADsADgA9AD4AFABFAEkAFgBLAE0AGwBPAFQAHgBWAFsAJABdAF4AKgCBAIEALACDAIMALQCGAIYALgCJAIkALwCNAI0AMACYAJsAMQDQANAANQABAAAAAQAIAAEABgACAAEAAgMIAwkAAQAAAAEACAACABIABgUHBQgFCQUKBQsFDAABAAYCugK7AswCzQNPA1gAAQAAAAEACAABAAYAAQABAAEBewAEAAAAAQAIAAEAQAABAAgAAgAGAA4BvgADAEoATQG8AAIATQAEAAAAAQAIAAEAHAABAAgAAgAGAA4BvwADAEoAUAG9AAIAUAABAAEASgAEAAAAAQAIAAEAKgADAAwAFgAgAAEABAG7AAIASgABAAQBwQACAFgAAQAEAcAAAgBYAAEAAwBKAFcAlQABAAAAAQAIAAEABgHeAAEAAQBLAAEAAAABAAgAAQAGAW8AAQABALsAAQAAAAEACAABAAYB9QABAAEANgABAAAAAQAIAAIAHAACAiwCLQABAAAAAQAIAAIACgACAi4CLwABAAIALwBPAAEAAAABAAgAAgAeAAwCRQJHAkYCSAJJAmcCaAJpAmoCawJsAm0AAQAMACcAKAArADMANQBGAEcASABLAFMAVABVAAEAAAABAAgAAgAMAAMCbgJvAm8AAQADAEkASwJqAAEAAAABAAgAAgAuABQCWgJeAlgCVQJXAlYCWwJZAl0CXAJPAkoCSwJMAk0CTgAaABwCUwJlAAIABAAUAB0AAAJmAmYACgJwAnAACwSNBJQADAABAAAAAQAIAAIALgAUBJQCcASNBI4EjwSQBJECZgSSBJMCTAJOAk0CSwJPAmUAGgJTABwCSgACAAIAFAAdAAACVQJeAAoAAQAAAAEACAACAC4AFAJbAl0CXgJYAlUCVwJWAlkCXAJaABsAFQAWABcAGAAZABoAHAAdABQAAQAUABoAHAJKAksCTAJNAk4CTwJTAmUCZgJwBI0EjgSPBJAEkQSSBJMElAABAAAAAQAIAAIALgAUBJEEkgJwBI0EjgSPBJACZgSTABcAGQAYABYAGwAUABoAHQAcABUElAACAAYAGgAaAAAAHAAcAAECSgJPAAICUwJTAAgCVQJeAAkCZQJlABMAAQAAAAEACAABAAYBgQABAAEAEwAGAAAAAQAIAAMAAQASAAEAbAAAAAEAAAAYAAIAAwGUAZQAAAHFAccAAQIfAiUABAABAAAAAQAIAAIAPAAKAccBxgHFAh8CIAIhAiICIwIkAiUAAQAAAAEACAACABoACgI+AHoAcwB0Aj8CQAJBAkICQwJEAAIAAQAUAB0AAA=="
	if (!HasData)
		return -1
	if (!ExtractedData) {
		ExtractedData := True, Ptr := A_IsUnicode ? "Ptr" : "UInt", VarSetCapacity(TD, 235197 * (A_IsUnicode ? 2 : 1))
		Loop, 15
			TD .= %A_Index%, %A_Index% := ""
		VarSetCapacity(Out_Data, Bytes := 171676, 0), DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int"), TD := ""
	}
	if (FileExist(_Filename))
		FileDelete, %_Filename%
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0), DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 171676, "UInt", 0, "UInt", 0), DllCall("CloseHandle", Ptr, h)
	if (_DumpData)
		VarSetCapacity(Out_Data, 171676, 0), VarSetCapacity(Out_Data, 0), HasData := 0
}