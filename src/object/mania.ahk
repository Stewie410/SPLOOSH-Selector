; ClassMania.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Mania Objects

; Root Mania
Class Mania {
    ; Instance Variables
    type :=                                                                                     ; String: Mania Type (Arrow/Bar/Dot)
    rootDir :=                                                                                  ; String: Name of the Type's directory

    ; Static Variables
    Static maniaDir := "MANIA PACKS"                                                            ; Name of the mania packs directory

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

; Arrow Mania
Class ManiaArrow Extends Mania {
    ; Instance Variables
    name :=                                                                                     ; String: Name of the Color of Arrow
    dir :=                                                                                      ; String: Name of the color's directory

    ; Static Variables
    Static arrowDir := "ARROWS"                                                                 ; Name of the Arrows directory

    ; Constructor
    __new(n, d) {
        base.__new("arrow", arrowDir)
        this.name := n
        this.dir := d
    }
}

; Bar Mania
Class ManiaBar Extends Mania {
    ; Instance Variables
    name :=                                                                                     ; String: Name of the Color of Bar
    dir :=                                                                                      ; String: Name of the color's directory

    ; Static Variables
    Static barDir := "BARS"                                                                     ; Name of the Bars directory

    ; Constructor
    __new(n, d) {
        base.__new("bar", barDir)
        this.name := n
        this.dir := d
    }
}

; Dot Mania
Class ManiaDot Extends Mania {
    ; Instance Variables
    name :=                                                                                     ; String: Name of the Color of Dot
    dir :=                                                                                      ; String: Name of the color's directory

    ; Static Variables
    Static dotDir := "DOTS"                                                                     ; Name of the Dots directory

    ; Constructor
    __new(n, d) {
        base.__new("dot", dotDir)
        this.name := n
        this.dir := d
    }
}