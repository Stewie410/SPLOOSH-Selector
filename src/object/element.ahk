; ClassElement.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Element Objects

; Root Element
Class Element {
    ; Instance Variables
    type :=                                                                                     ; String: Element Type (Cursor, Hitburst, Reverse Arrow, Sliderball, etc)
    rootDir :=                                                                                  ; String: Name of Element Type's Directory
    original :=                                                                                 ; Integer: 1/0 (T/F) is the original element

    ; Static Variables
    Static elementsDir := "ELEMENT PACKS"                                                       ; Name of the ELement Packs Directory

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

; Cursor Element
Class Cursor Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Cursor Name (color)
    dir :=                                                                                      ; String: Name of the Cursor's Directory

    ; Static Variables
    Static cursorsDir := "CURSORS"                                                              ; Name of the Cursors Directory
	Static cursorColorDir := "COLOR"							                                ; Name of the Cursor Colors Directory
	Static cursorSmokeDir := "SMOKE"							                                ; Name of the Cursor Smoke Directory
	Static cursorTrailDir := "TRAIL"							                                ; Name of the Cursor Trail Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("cursor", cursorDir, o)
        this.name := n
        this.dir := d
    }
}

; Hitburst Element
Class Hitburst Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Hitburst Name (type)
    dir :=                                                                                      ; String: Name of the Hitburst's Directory

    ; Static Variables
    Static hitburstsDir := "HITBURSTS"                                                          ; Name of the Hitburst Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitburst", hitburstsDir, o)
        this.name := n
        this.dir := d
    }
}

; Reverse Arrow Element
Class ReverseArrow Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Reverse Arrow Name (type)
    dir :=                                                                                      ; String: Name of the Reverse Arrow's Directory

    ; Static Variables
    Static reverseArrowDir := "REVERSEARROWS"                                                   ; Name of the Reverse Arrow Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitburst", reverseArrowDir, o)
        this.name := n
        this.dir := d
    }
}

; Sliderball Element
Class Sliderball Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Sliderball Name (type)
    dir :=                                                                                      ; String: Name of the Sliderball's Directory

    ; Static Variables
    Static sliderballDir := "SLIDERBALLS"                                                       ; Name of the Sliderball Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("sliderball", sliderballDir, o)
        this.name := n
        this.dir := d
    }
}

; Scorebar BG Element
Class ScorebarBG Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: ScorebarBG Name (type)
    dir :=                                                                                      ; String: Name of the ScorebarBG's Directory

    ; Static Variables
    Static scorebarbgDir := "SCOREBAR BGS"                                                      ; Name of the ScorebarBG Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("scorebarbg", scorebarbgDir, o)
        this.name := n
        this.dir := d
    }
}

; Numbers Element
Class CircleNumber Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Circle Number's Name (type)
    dir :=                                                                                      ; String: Name of the Circle Number's Directory

    ; Static Variables
    Static circleNumberDir := "NUMBERS"                                                         ; Name of the Circle Numbers Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("numbers", circleNumberDir, o)
        this.name := n
        this.dir := d
    }
}

; Hitsound Pack Element
Class Hitsound Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: Hitsound Pack Name (type)
    dir :=                                                                                      ; String: Name of the Hitsound Pack's Directory

    ; Static Variables
    Static hitsoundDir := "HITSOUNDS"                                                           ; Name of the Hitsound Packs Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("hitsound", hitsoundDir, o)
        this.name := n
        this.dir := d
    }
}

; Follow Point Element
Class FollowPoint Extends Element {
    ; Instance Variables
    name :=                                                                                     ; String: FollowPoint Name (type)
    dir :=                                                                                      ; String: Name of the FollowPoint's Directory

    ; Static Variables
    Static followpointDir := "FOLLOWPOINTS"                                                     ; Name of the FollowPoint Pack's Directory

    ; Constructor
    __new(n, d, o) {
        base.__new("followpoint", followpointDir, o)
        this.name := n
        this.dir := d
    }
}