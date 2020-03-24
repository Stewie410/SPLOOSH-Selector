; GuiParent.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; Parent/App GUI Definition

; Define
GuiParent() {
    global                                                                                      ; Set global Scope inside Function
    Gui, Parent: +HWNDhParent                                                                   ; Define Parent GUI, Assign Window Handle to %hParent%
    Gui, Parent: +LastFound                                                                     ; Make Parent the LastFound window
    Gui, Parent: -Resize                                                                        ; Disallow Parent GUI to be resize
    Gui, Parent: Margin, 0, 0                                                                   ; Disable Parent GUI's Margin
    Gui, Parent: Color, %bg_app%                                                                ; Set Parent GUI's Background Color
}

; Create a Modal Message Box
modalMsgBox(title := "", message := "", guiname := "") {
    global                                                                                      ; Set global Scope inside Function
    Gui, %guiname%: +OwnDialogs                                                                 ; Enable Modal Dialogues for the specified GUI
    MsgBox,, %title%, %message%                                                                 ; Display the MsgBox
    Gui, %guiname%: -OwnDialogs                                                                 ; Disable Modal Dialogues for the specified GUI
}

; Toggle State of all child windows while GuiColorPicker is active
toggleParentWindow(vis := 0) {
    global                                                      ; Set global Scope inside Function
    vis := vis = 0 ? "+" : "-"                                  ; Set $vis to either "+" or "-"
    try {
        for k, v in ["TopBar", "SideBar", "ElementForm", "UIColorForm", "PlayerForm", "PreviewPane"]
            Gui, % v . ": " . vis . "Disabled"
    } catch e {
        OutputDebug, %A_Now%: Failed to toggle child GUI disabled state`n%e%
    }
}