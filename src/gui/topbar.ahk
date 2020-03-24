; GuiTopBar.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; TopBar GUI Definition

; Define
GuiTopBar() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: +ParentParent                                                                  ; Define GUI as a child of Parent
    Gui, TopBar: +HWNDhTopBar                                                                   ; Assign Window Handle to %hTopBar%
    Gui, TopBar: -Caption                                                                       ; Disable Titlebar
    Gui, TopBar: -Border                                                                        ; Disable Border
    Gui, TopBar: -DpiScale                                                                      ; Disable Windows Scaling
    Gui, TopBar: Margin, 0, 0                                                                   ; Disable Margin
    Gui, TopBar: Color, %bg_topbar%                                                             ; Set Background Color
    Gui, TopBar: Font, s%fs_topbar% c%fg_topbar%, %ff_topbar%                                   ; Font for Text

    ; Define Local Variables for sizing and placement
    local cx_items := 4                                                                         ; Number of Items per Row
    local cy_items := 2                                                                         ; Number of Items per Column
    local w_text := w_sidebar                                                                   ; Text Width
    local w_button := (w_topbar / cx_items) - (px_topbar * 2)                                   ; Button Width
    local w_edit := 0                                                                           ; Edit Width
	local w_pic := 127											                                ; Picture Width
    local h_text := (h_topbar / cy_items) - (py_topbar * 2)                                     ; Text Height
    local h_button := h_text                                                                    ; Button Height
    local h_edit := h_text                                                                      ; Edit Height
    local r_edit := 1                                                                           ; Rows of Edit
    local a_x := buildPosArray(cx_items, cx_items, 0, w_topbar, px_topbar, 1, 1)                ; X Positions
    local a_y := buildPosArray(cx_items, cy_items, 0, h_topbar, py_topbar, 1)                   ; Y Positions
    local playerNormal := d_asset "\categoryPlayersNormal.png"		                            ; PlayerNormal image
    local uicolorNormal := d_asset "\categoryUIColorsNormal.png"	                            ; UIColorNormal image
    local elementNormal := d_asset "\categoryElementsNormal.png"	                            ; ElementNormal image
    local browseNormal := d_asset "\browseGameDirectoryNormal.png"	                            ; BrowseNormal image
    local playerHover := d_asset "\categoryPlayersHover.png"		                            ; PlayerHover image
    local uicolorHover := d_asset "\categoryUIColorsHover.png"		                            ; UIColorHover image
    local elementHover := d_asset "\categoryElementsHover.png"		                            ; ElementHover image
    local browseHover := d_asset "\browseGameDirectoryHover.png"	                            ; BrowseHover image
    local playerActive := d_asset "\categoryPlayersActive.png"		                            ; PlayerActive image
    local uicolorActive := d_asset "\categoryUIColorsActive.png"	                            ; UIColorActive image
    local elementActive := d_asset "\categoryElementsActive.png"	                            ; ElementActive image

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

; Get Form: PlayerForm
GetPlayerForm() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    var_selected_form := "Player"                                                               ; Update Selected Form
    toggleForm(var_selected_form)                                                               ; Show Form
}

; Get Form: UIColorForm
GetUIColorForm() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, UIColorForm: Submit, NoHide                                                            ; Get +vVar values without hiding GUI
    var_selected_form := "UIColor"                                                              ; Update Selected Form
    toggleForm(var_selected_form)                                                               ; Show Form
    updateUIColorColors(!UIColorOptionSaveIni)                                                  ; Update selected UIColors
    updateTreeViewBackground()                                                                  ; Update Combo Colors
}

; Get Form: ElementForm
GetElementForm() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    var_selected_form := "Element"                                                              ; Update Selected Form
    toggleForm(var_selected_form)                                                               ; Show Form
}

; Hide all Forms & Active Controls
hideForms() {
    global                                                                                      ; Set global scope inside function
    for k, v in ["Player", "Element", "UIColor"]
        Gui, %v%Form: Show, Hide                                                                ; Hide each Form
    GuiControl, TopBar: Hide, % hCategoryElementActive		                                    ; Hide ElementActive
    GuiControl, TopBar: Hide, % hCategoryPlayerActive		                                    ; Hide PlayerActive
    GuiControl, TopBar: Hide, % hCategoryUIColorActive		                                    ; Hide UIColorActive
}

; Toggle Visibility of Form(s)
toggleForm(name) {
    global                                                                                      ; Set global Scope inside Function

	; Define Local Variables
	local hwndCtrl                                                                              ; Placeholder var for the FormActive button HWND

	; Determine FormActive Control update
	if (name = "Element")
		hwndCtrl := hCategoryElementActive
	else if (name = "Player")
		hwndCtrl := hCategoryPlayerActive
	else if (name = "UIColor")
		hwndCtrl := hCategoryUIColorActive
    else {
        OutputDebug, %A_Now%: Failed to determine the FormActive control to modify`n%e%
        return
    }

    ; Handler for "ALL" name
    hideForms()

    ; Update visibility
    Gui, % name . "Form: Show"                                                                  ; Show the selected form
    GuiControl, TopBar: Show, % hwndCtrl                                                        ; Display the FormActive control
}