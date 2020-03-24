; ClassUIColor.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; UIColor Objects

; Root UIColor
Class UIColor {
    ; Instance Variables
    name :=                                                                                     ; String: Name (color) of the UI Color
    dir :=                                                                                      ; String: Name of the UI Color's Directory
    original :=                                                                                 ; Integer: 1/0 (T/F) is the original cursor 

    ; Static Variables
    Static uiColorDir := "UI COLORS"                                                            ; Name of the UI Colors Directory

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