; EventHandlers.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
;
; Handlers for SPLOOSH-Selector Events

; ##----------------------------------------------------##
; #|                    App Events                      |#
; ##----------------------------------------------------##
; Main Window Escaped
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

; ##----------------------------------------------------##
; #|                    Mouse Events                    |#
; ##----------------------------------------------------##
; On Mouse-Movement
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
    global                                                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local x_mouse                                                                               ; Mouse's X Position
    local y_mouse                                                                               ; Mouse's Y Position
    local ctrl_mouse                                                                            ; Control under the Mouse
    local list_buttons := []                                                                    ; Buton window handles
    local is_button := false                                                                    ; Flag for handlers

    list_buttons.push({key: hCategoryElementNormal, hwnd: hCategoryElementHover, ui: "Top"})
    list_buttons.push({key: hCategoryPlayerNormal, hwnd: hCategoryPlayerHover, ui: "Top"})
    list_buttons.push({key: hCategoryUIColorNormal, hwnd: hCategoryUIColorHover, ui: "Top"})
    list_buttons.push({key: hBrowseGameDirectoryNormal, hwnd: hBrowseGameDirectoryHover, ui: "Top"})
    list_buttons.push({key: hSidebarApplyNormal, hwnd: hSidebarApplyHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetAllNormal, hwnd: hSidebarResetAllHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetGameplayNormal, hwnd: hSidebarResetGameplayHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetUIColorNormal, hwnd: hSidebarResetUIColorHover, ui: "Side"})
    list_buttons.push({key: hSidebarResetHitsoundNormal, hwnd: hSidebarResetHitsoundHover, ui: "Side"})

    ; Get Mouse info
    MouseGetPos, x_mouse, y_mouse,, ctrl_mouse, 3
    GuiControlGet, ctrl_mouse, Pos, % ctrl_mouse

    ; Iterate over button list -- if the mouse control is one of thse, update && quit
    for i in list_buttons {
        if (ctrl_mouse = list_buttons[i].key) {
            GuiControl, % list_buttons[i].ui "Bar: Show", % list_buttons[i].hwnd
            is_button := true
        } else
            GuiControl, % list_buttons[i].ui "Bar: Hide", % list_buttons[i].hwnd
    }
    if (is_button)
        return

    ; If the mouse is over the color palette, set the below pixel's color to 'hover_color'
    if (ctrl_mouse = hColorPickerPalette)
        var_picker_hover_color := getCoordinateColor(x_mouse, y_mouse)
}

; Left Mouse Button (LMB) Up
OnWM_LBUTTONUP(wParam, lParam, msg, hwnd) {
    global                                                                                      ; Set global Scope inside Function

    ; Define Local Variables
    local ctrl_mouse                                                                            ; Control under the Mouse

    ; Get Mouse info
    MouseGetPos,,,, ctrl_mouse, 3
    GuiControlGet, ctrl_mouse, Pos, % ctrl_mouse
}