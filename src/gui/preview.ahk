; GuiPreview.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; Preview GUI Definition

; Define
GuiPreview() {
    global                                                                                      ; Set global Scope inside Function
    Gui, PreviewPane: +ParentParent                                                             ; Define GUI as a child of Parent
    Gui, PreviewPane: +HWNDhPlayer                                                              ; Assign Window Handle to %hTopBar%
    Gui, PreviewPane: -Caption                                                                  ; Disable Titlebar
    Gui, PreviewPane: -Border                                                                   ; Disable Border
    Gui, PreviewPane: -DpiScale                                                                 ; Disable Windows Scaling
    Gui, PreviewPane: Margin, 0, 0                                                              ; Disable Margin
    Gui, PreviewPane: Color, %bg_preview%                                                       ; Set Background Color
    Gui, PreviewPane: Font, s%fs_preview%, %ff_preview%                                         ; Set font

    ; Define local variables
    local cx_items := 3                                                                         ; Number of items per row
    local cy_items := 1                                                                         ; Number of items per column
    local w_pic := w_preview / cx_items                                                         ; picture width
    local h_pic := h_preview / cy_items                                                         ; picture height
    local a_x := buildPosArray(cy_items, cx_items, 0, w_preview, px_preview, 1)                 ; x positions
    local a_y := buildPosArray(cy_items, cy_items, 0, h_preview, py_preview, 1)                 ; y positions

    ; Add Controls to GUI
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[1] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageOne +Hidden1",
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[2] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageTwo +Hidden1",
    ;Gui, PreviewPane: Add, Picture, % "x" a_x[3] " y" a_y[1] " w" w_pic " h" h_pic " +vPreviewImageThree +Hidden1",
}

; Open URL based on which orm is selected
OpenPreviewLink() {
    global                                                                                      ; Set global Scope inside Function
    if (var_selected_form = "Element")
        Run, % hl_preview_element
    else if (var_selected_form = "Player")
        Run, % hl_preview_player
    else if (var_selected_form = "UIColor")
        Run, % hl_preview_uicolor
}

; Open URL to Source Code
OpenSourceLink() {
    Run, % hl_source_code
}

; Open URL to Skin Download
OpenDownloadLink() {
    Run, % hl_skin_download
}