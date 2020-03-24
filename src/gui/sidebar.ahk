; GuiSideBar.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; SideBar GUI Definition

; Define
GuiSideBar() {
    global                                                                                      ; Set global Scope inside Function
    Gui, SideBar: +ParentParent                                                                 ; Define GUI as a child of Parent
    Gui, SideBar: +HWNDhSideBar                                                                 ; Assign Window Handle to %hTopBar%
    Gui, SideBar: -Caption                                                                      ; Disable Titlebar
    Gui, SideBar: -Border                                                                       ; Disable Border
    Gui, SideBar: -DpiScale                                                                     ; Disable Windows Scaling
    Gui, SideBar: Margin, 0, 0                                                                  ; Disable Margin
    Gui, SideBar: Color, %bg_sidebar%                                                           ; Set Background Color
    Gui, SideBar: Font, s%fs_sidebar%, %ff_sidebar%                                             ; Set font

    ; Define Local Variables for sizing and placement
	local cx_items := 1											                                ; Number of items per row
	local cy_items := 4										                                    ; Number of items per column
	local gx_items := 1											                                ; Number of items per row in "group"
	local gy_items := 5											                                ; Number of items per column in "group"
	local w_outline := 140										                                ; reset outline width
	local w_button := 110										                                ; button width
    local w_sbutton := w_button - (px_sidebar * 1)                                              ; button width of submit button
	local w_gbutton := w_button - (px_sidebar * 3)				                                ; button width inside "group"
	local h_outline := 400										                                ; reset outline height
	local h_button := 110										                                ; button height
    local h_sbutton := h_button - (py_sidebar * 1)                                              ; button height of submit button
	local h_gbutton := h_button - (py_sidebar * 3)				                                ; button height inside "group"
	local a_x := buildPosArray(cy_items, cx_items, 0, w_sidebar, px_sidebar, 1)                 ; x positions
	local a_y := buildPosArray(cy_items, cy_items, 0, h_sidebar, py_sidebar, 1, 1)              ; y positions
	local g_x := []												                                ; x positions inside "group"
	local g_y := []												                                ; y positions inside "group"
    local x_sbutton := (w_sidebar - w_outline) + (px_sidebar * 1.5)                             ; x position of submit button
	local resetOutline := d_asset "\sidebarResetOutline.png"		                            ; ResetOutline image
	local applyNormal := d_asset "\applyNormal.png"					                            ; ApplyNormal image
	local resetAllNormal := d_asset "\resetAllNormal.png"			                            ; ResetAllNormal image
	local resetGameplayNormal := d_asset "\resetGameplayNormal.png"	                            ; ResetGameplayNormal image
	local resetUIColorNormal := d_asset "\resetUIColorNormal.png"	                            ; ResetUIColorNormal image
    local resetHitsoundNormal := d_asset "\resetHitsoundNormal.png"                             ; ResetHitsoundNormal image
	local applyHover := d_asset "\applyHover.png"					                            ; ApplyHover image
	local resetAllHover := d_asset "\resetAllHover.png"				                            ; ResetAllHover image
	local resetGameplayHover := d_asset "\resetGameplayHover.png"	                            ; ResetGameplayHover image
	local resetUIColorHover := d_asset "\resetUIColorHover.png"		                            ; ResetUIColorHover image
    local resetHitsoundHover := d_asset "\resetHitsoundHover.png"                               ; ResetHitsoundHover image

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
    Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[5] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +gResetHitsound +HWNDhSidebarResetHitsoundNormal", %resetHitsoundNormal%
    Gui, SideBar: Add, Picture, % "x" g_x[1] " y" g_y[5] " w" w_gbutton " h" h_gbutton " +" SS_CENTERIMAGE " +HWNDhSidebarResetHitsoundHover +Hidden1", %resetHitsoundHover%
}

; SubmitForm
SubmitForm() {
    global                                                                                      ; Set global Scope inside Function
    try {
        Gui, TopBar: Submit, NoHide
        Gui, SideBar: Submit, NoHide
        Gui, ElementForm: Submit, NoHide
        Gui, UIColorForm: Submit, NoHide
        Gui, PlayerForm: Submit, NoHide
    } catch e {
        OutputDebug, %A_Now%: Failed to Apply Submit all GUI Forms`n%e%
    }
    applyForm()                                                                                 ; Apply Configuration, based on selected form
}

; Reset: All
ResetAll() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                                                ; Get vVar values without hiding GUI
    resetSkin("gameplay")                                                                       ; Reset Gameplay elements
    resetSkin("uicolor")                                                                        ; Reset UI Color elements
    resetSkin("hitsounds")                                                                      ; Reset Hitsounds
}

; Reset: Gameplay
ResetGameplay() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                                                ; Get vVar values without hiding GUI
    resetSkin("gameplay")                                                                       ; Reset Gameplay
}

; Reset: UI Color
ResetUIColor() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                                                ; Get vVar values without hiding GUI
    resetSkin("uicolor")                                                                        ; Reset UIColor
}

; Reset: Hitsounds
ResetHitsound() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI
    Gui, SideBar: Submit, NoHide                                                                ; Get vVar values without hiding GUI
    resetSkin("hitsounds")                                                                      ; Reset Hitsounds
}