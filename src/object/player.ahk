; ClassPlayer.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Player Objects

; Root Player
Class Player {
    ; Instance Variables
    name :=                                                                                     ; String: Name of the Player
    dir :=                                                                                      ; String: Name of the Player's Directory
    listNames :=                                                                                ; Name of Options
    listDirs :=                                                                                 ; Directory Names of Options
    listMiddle :=                                                                               ; Names of Verions to contain cursormiddle.png & cursormiddle@2x.png
    require :=                                                                                  ; Integer: 1/0 (T/F) are options required to select skin?

    ; Static Variables
    Static playersDir := "PLAYER PACKS"                                                         ; Name of the Player Packs Directory

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