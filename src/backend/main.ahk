; Backend.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; SPLOOSH-Selector Backend

; Initialize Environment
InitEnv() {
    global                                                                                      ; Set global Scope inside Function

    ; Define Initial Backend Variables (global)
    defineColors()                                                                              ; Define Global Colors
    defineFonts()                                                                               ; Define Global Fonts
    defineDimensions()                                                                          ; Define Global Positioning & Dimension Values
    defineNames()                                                                               ; Define Global Names
    defineRunVars()                                                                             ; Define Global Runtime/Backend Variables
    defineURLs()                                                                                ; Define Global URL/Hyperlinks
    defineDirectories()                                                                         ; Define Global Directory Values
    defineObjLists()                                                                            ; Define Global Object Lists
    defineMenuLists()                                                                           ; Define Global Menu Lists

    ; Instatiate Objects & fill out their respective global lists
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

    Menu, Tray, Tip, %n_app%                                                                    ; Define SysTray Icon with Application Name
    
    ; Define Local Variables
    local file_list := {}                                                                       ; Define assets to be extracted
    file_list.push({name: "categoryElementsNormal", type: "png"})                               ; To add an assets, define its 'name' and file 'type'
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
    file_list.push({name: "resetHitsoundNormal", type: "png"})
    file_list.push({name: "resetHitsoundHover", type: "png"})
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
}

; Define Colors
defineColors() {
    global                                                                                      ; Set global Scope inside Function
    
    ; Background Colors
    bg_app := "002D52"                                                                          ; Application/Parent
    bg_topbar := "002D52"                                                                       ; TopBar
    bg_sidebar := "002D52"                                                                      ; SideBar
    bg_preview := "002D52"                                                                      ; Preview
    bg_form := "002D52"                                                                         ; Element, UIColor & Player
                            
    ; Foreground Colors                         
    fg_app := "000000"                                                                          ; Application/Parent
    fg_topbar := "FFFFFF"                                                                       ; TopBar
    fg_sidebar := "FFFFFF"                                                                      ; SideBar
    fg_preview := "FFFFFF"                                                                      ; Preview
    fg_form := "FFFFFF"                                                                         ; Element, UIColor & Player
    fg_input := "000000"                                                                        ; Inputs

    ; Debug Background Colors
    bg_debug_topbar := "FF8E77"                                                                 ; Distinct BG color for Topbar
    bg_debug_sidebar := "6DFF79"                                                                ; Distinct BG color for Sidebar
    bg_debug_preview := "002D52"                                                                ; Distinct BG color for PreviewPane
    bg_debug_form := "93D7FF"                                                                   ; Distinct BG Color for Forms
}

; Define Fonts
defineFonts() {
    global                                                                                      ; Set global Scope inside Function

    ; Font Faces                            
    ff_app := "Debussy"                                                                         ; Application/Parent
    ff_topbar := "Debussy"                                                                      ; TopBar
    ff_sidebar := "Debussy"                                                                     ; SideBar
    ff_preview := "Debussy"                                                                     ; Preview
    ff_form := "Debussy"                                                                        ; Element, UIColor & Player
    ff_input := "Roboto"                                                                        ; Inputs
                            
    ; Font Sizes                            
    fs_app := 10                                                                                ; Application/Parent
    fs_topbar := 14                                                                             ; TopBar
    fs_sidebar := 10                                                                            ; SideBar
    fs_preview := 10                                                                            ; Preview
    fs_form := 14                                                                               ; Element, UIColor & Player
    fs_input := 10                                                                              ; Inputs
}

; Define Dimension & Positional Values
defineDimensions() {
    global                                                                                      ; Set global Scope inside Function
                            
    ; Width Definitions
    w_app := 624                                                                                ; Application/Parent -- Default: 624
    w_picker := 600                                                                             ; ColorPicker
    w_topbar := w_app                                                                           ; TopBar
    w_sidebar := w_app / 4                                                                      ; SideBar
    w_preview := w_app - w_sidebar                                                              ; Preview
    w_form := w_app - w_sidebar                                                                 ; Element, UIColor & Player

    ; Height Defintions
    h_app := 685                                                                                ; Application/Parent -- Default: 685
    h_picker := 600                                                                             ; ColorPicker
    h_topbar := h_app / 5                                                                       ; TopBar
    h_sidebar := h_app - h_topbar                                                               ; SideBar
    h_preview := h_app / 8                                                                      ; Preview
    h_form := h_app - h_topbar - h_preview                                                      ; Element, UIColor & Player

    ; X Positioning relative to Application
    x_app := Round(A_ScreenWidth, 0)                                                            ; Application/Parent
    x_topbar := 0                                                                               ; TopBar
    x_sidebar := 0                                                                              ; SideBar
    x_preview := w_sidebar                                                                      ; Preview
    x_form := w_sidebar                                                                         ; Element, UIColor & Player

    ; Y Positioning relative to Application
    y_app := Round(A_ScreenHeight, 0)                                                           ; Application/Parent
    y_topbar := 0                                                                               ; TopBar
    y_sidebar := h_topbar                                                                       ; SideBar
    y_preview := h_topbar + h_form                                                              ; Preview
    y_form := h_topbar                                                                          ; Element, UIColor & Player

    ; Horizontal Padding
    px_app := 0                                                                                 ; Application/Parent
    px_topbar := 10                                                                             ; TopBar
    px_sidebar := 10                                                                            ; SideBar
    px_preview := 10                                                                            ; Preview
    px_form := 10                                                                               ; Element, UIColor & Player

    ; Vertical Padding
    py_app := 0                                                                                 ; Application/Parent
    py_topbar := 10                                                                             ; TopBar
    py_sidebar := 10                                                                            ; SideBar
    py_preview := 10                                                                            ; Preview
    py_form := 10                                                                               ; Element, UIColor & Player
}

; Define Names
defineNames() {
    global                                                                                      ; Set global Scope inside Function
    n_app := "SPLOOSH Selector"                                                                 ; Application Name
    n_skin := "SPLOOSH"                                                                         ; Skin Name
    n_ver := "(S+)"												                                ; Skin Version required
}

; Define Backend Global Values
defineRunVars() {
    global                                                                                      ; Set global Scope inside Function
    var_selected_form := "Player"								                                ; Selected Form (Element|Player|UIColor) -- Determines Default Form too
    var_cursor_changed := 0                                                                     ; Flag to indicate if the cursor has been changed
    var_picker_selected_color := "FFFFFF"                                                       ; ColorPicker Selected Color
    var_picker_hover_color := "FFFFFF"                                                          ; ColorPicker Preview Color
    var_picker_cursor_changed := 0                                                              ; ColorPicker SystemCursor Changed
    var_picker_cursor_current := ""                                                             ; ColorPicker Current Cursor
    var_combo_color_1 := "1978FF"                                                               ; Combo Color 1
    var_combo_color_2 := "1978FF"                                                               ; Combo Color 2
    var_combo_color_3 := "1978FF"                                                               ; Combo Color 3
    var_combo_color_4 := "1978FF"                                                               ; Combo Color 4
    var_combo_color_5 := "1978FF"                                                               ; Combo Color 5
    var_slider_border_color := "DEDEDE"                                                         ; Slider Border Color
    var_slider_track_color := "212121"                                                          ; Slider Track Color
    var_picker_count := 0                                                                       ; Flag to indicate which TreeView to update
}

; Define Hyperlinks
defineURLs() {
    global                                                                                      ; Set global Scope inside Function
    hl_preview_element := ""									                                ; Elements Preview
    hl_preview_uicolor := ""									                                ; UI Color Preview
    hl_preview_player := ""										                                ; Player/Packs Preview
    hl_source_code := "https://github.com/Stewie410/SPLOOSH-Selector"	                        ; Source Code
    hl_skin_download := ""                                                                      ; Skin Download
}

; Define Directories
defineDirectories() {
    global                                                                                      ; Set global Scope inside Function
    d_user := "C:\Users\" A_UserName                                                            ; User's Home Directory
    d_game := d_user "\AppData\Local\osu!"                                                      ; Game Installation Path
    d_asset := A_Temp "\SPLOOSH-Selector"                                                       ; Script's Assets Path (FileInstall)
    d_conf := "ASSET PACKS"                                                                     ; Directory containing Skin Configuration Elements
    d_default := "DEFAULT ASSETS"								                                ; Directory containing Default/Reset Assets
    d_default_gameplay := d_default "\GP"         				                                ; Directory containing Original Gameplay Elements
    d_default_uicolor := d_default "\UI"				                                        ; Directory containing Original UI Color Elements
    d_default_hitsounds := d_default "\HS"                                                      ; Directory containing Original Hitsounds
    d_cursor_notrail := "Z NO CT"                          		                                ; Directory containing ELements to disable Cursor Trails
    d_cursor_solidtrail := "Z CM"                     			                                ; Directory containing Elements to enable a solid cursor trail
    d_uicolor_instafade := "SKIN.INI FOR INSTAFADE HITCIRCLE"                                   ; Directory containing Elements to enable instant-fade circles
    d_mania_current := "CURRENT MANIA"                                                          ; Directory containing the current Mania elements
}

; Define Object Lists
defineObjLists() {
    global                                                                                      ; Set global Scope inside Function
    l_cursors := []                                                                             ; List of Cursors
    l_hitbursts := []                                                                           ; List of Hitbursts
    l_reversearrows := []                                                                       ; List of ReverseArrows
    l_sliderballs := []                                                                         ; List of Sliderballs
    l_scorebarbgs := []                                                                         ; List of ScorebarBGs
    l_circlenumbers := []                                                                       ; List of CircleNumbers
    l_followpoints := []                                                                        ; List of FollowPoints
    l_maniaarrows := []                                                                         ; list of ManiaArrows
    l_maniabars := []                                                                           ; List of ManiaBars
    l_maniadots := []                                                                           ; List of ManiaDots
    l_hitsounds := []                                                                           ; List of Hitsounds
    l_uicolors := []                                                                            ; List of UI Colors
    l_players := []                                                                             ; List of Players
}

; Define Menu Lists
defineMenuLists() {
    global                                                                                      ; Set global Scope inside Function
    menu_element_types := "Cursor||Hitburst|Hitsounds|Reverse Arrow|Sliderball|Scorebar BG|Circle Numbers|Mania|Follow Point"
    menu_mania_types := "Arrow|Bar|Dot"
}

; Check if game directory exists
initCheckPath() {
    global                                                                                      ; Set global Scope inside Function
    Gui, TopBar: Submit, NoHide                                                                 ; Get vVar values without hiding GUI
    if (!getDirectoryName(n_skin, GameDirectory "\Skins"))
        modalMsgBox(n_app ": Game Directory", "WARNING: Please update Game Path before continuing!", "Parent")
}

; Cleanup
Cleanup() {
    global                                                                                      ; Set global Scope inside Function

    ; Hide Parent GUI
    Gui, Parent: Hide

    ; Remove Fonts
    DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", d_asset "\debussy.ttf", "UInt", 0x10, "UInt", 0)
    DllCall("Gdi32.dll\RemoveFontResourceEx", "Str", d_asset "\Roboto-Regular.ttf", "UInt", 0x10, "UInt", 0)
}

; Browser for a Directory
BrowseDirectory(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    Gui, TopBar: Submit, NoHide                                                                 ; Get +vVar values without hiding GUI

    ; Provide a Directory/Tree Browser
    try {
		; Provide modal dialog
        Gui, TopBar: +OwnDialogs                                                                ; Make Dialog Modal
        FileSelectFolder, d_select, %d_game%, 0, Select Game Folder
        Gui, TopBar: -OwnDialogs                                                                ; Disable Modal Dialogs

		; return value, if selected
		if (d_select) {
			GuiControl, TopBar:, GamePath, %d_select%
			d_game := d_select
            updateUIColorColors(1)                                                              ; Update selected UIColors
            updateTreeViewBackground()                                                          ; Update Combo Colors
		} 
    } catch e {
        OutputDebug, %A_Now%: Failed to retrieve a directory from BrowseDirectory function`n%e%
    }
}

; Get the name of a directory by $string
getDirectoryName(name, path) {
    ; Handle invalid input
    if (!FileExist(path))                                                                       ; If path doesn't exist, return
        return

    ; Define Local Variables
    dir := ""                                                                                   ; Define return val as passed name

    ; Loop through a given path
    Loop, Files, %path%\*, D                                                                    ; return only directories
    {
        if (RegExMatch(A_LoopFileName, "i)"name)) {                                             ; If skin name is found
			if (RegExMatch(A_LoopFileName, "i)"name " " n_ver)) {
                dir := A_LoopFileName                                                           ; Set return val to name
                break                                                                           ; Break loop
			}
            if (FileExist(path "\" A_LoopFileName "\" d_conf)) {
                dir := A_LoopFileName                                                           ; Set return val to name
                break                                                                           ; Break loop
            }
        }
    }
    return dir                                                                                  ; return value
}

; Reset Skin
resetSkin(type) {
    global                                                                                      ; Set global Scope inside Function

    ; Define Local variables
    local src := GamePath "\Skins"                                                              ; Source directory
    local dst := src                                                                            ; Destination directory
    local skin := getDirectoryName(n_skin, src)                                                 ; Skin name

    ; Handle skin not found
    if (!skin) {
        MsgBox,,RESET ERROR, Cannot locate skin in `"%src%`"                                    ; Notify user of error
        OutputDebug, %A_Now%: Failed to locate skin in %src%`n                                  ; Log to Debug Console
        return 1                                                                                ; return
    }

    ; Update local vars
    src .= "\" skin "\" d_conf                                                                  ; Update source directory
    dst .= "\" skin                                                                             ; Update destination directory
    
    ; Reset Skin
    StringLower, type, type                                                                     ; Set all characters in type to lowercase
    if (type = "gameplay") {                                                                    ; If type is gameplay
        FileCopy, %src%\%d_default_gameplay%\*.*, %dst%, 1                                      ; Copy reset-gameplay elements to dst
        FileDelete, %dst%\cursormiddle@2x.png                                                   ; Delete CursorMiddle
        if (!UIColorOptionSaveIni) && (var_selected_form = "UIColor") {                         ; If Overwrite Skin.ini is unchecked
            updateUIColorColors(UIColorOptionSaveIni)                                           ; Update UIColor Combo/Slider Colors
            updateTreeViewBackground()                                                          ; Update TreeView BG Colors
        }
    } else if (type = "uicolor") {                                                              ; If type is uicolor
        FileCopy, %src%\%d_default_uicolor%\*.*, %dst%, 1                                       ; Copy reset-uicolor elements to dst
    } else if (type = "hitsounds") {                                                            ; If type is hitsounds
        FileCopy, %src%\%d_default_hitsounds%\*.*, %dst%, 1                                     ; Copy reset-hitsounds elements to dst
    } else {
        OutputDebug, %A_Now%: Unknown Reset Type: %type%                                        ; Log error to debug console
        return 1
    }
    return 0
}

; Apply Form Configuration
applyForm() {
    global                                                                                      ; Set global Scope inside Function

    ; Define local variables
    local src := GamePath "\Skins"                                                              ; Source Directory
    local dst := src                                                                            ; Destination Directory
    local skin := getDirectoryName(n_skin, src)                                                 ; Skin Name
    local form								                                                    ; Selected Form
    local etype
    StringLower, form, var_selected_form                                                        ; Convert %form% to all lowercase

    ; Handle skin not found
    if (!skin) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate skin in " src, "SideBar")
        return 1                                                                                ; return
    }

    ; Update local vars
    src .= "\" skin "\" d_conf                                                                  ; Update source
    dst .= "\" skin                                                                             ; Update destination

    if (form = "element") {
        StringLower, etype, ElementType                                                         ; Convert $ElementType to all lowercase
        if (etype = "cursors")
            applyElementCursor(src, dst)                                                        ; Apply the Cursor Element Form configuration
        else if (etype = "hitbursts")
            applyElementHitburst(src, dst)                                                      ; Apply the Hitburst Element Form configuration
        else if (etype = "reverse arrows")
            applyElementRevArrow(src, dst)                                                      ; Apply the Reverse Arrow Element Form configuration
        else if (etype = "sliderballs")
            applyElementSliderball(src, dst)                                                    ; Apply the Sliderball Element Form configuration
        else if (etype = "scorebar bgs")
            applyElementScorebarBG(src, dst)                                                    ; Apply the Scorebar BG Element Form configuration
        else if (etype = "circle numbers")
            applyElementCircleNumber(src, dst)                                                  ; Apply the Circle Numbers Element Form configuration
        else if (etype = "hitsounds")
            applyElementHitsound(src, dst)                                                      ; Apply the Hitsounds Element Form configuration
        else if (etype = "follow points")
            applyElementFollowPoint(src, dst)                                                   ; Apply the Follow Points Element Form configuration
        else if (etype = "mania")
            applyElementMania(src)                                                              ; Apply the Mania Element Type & Color configuration
    } else if (form = "uicolor") {
        applyUIColor(src, dst)                                                                  ; Apply the UI Color Form configuration
    } else if (form = "player") {
        applyPlayer(src, dst)                                                                   ; Apply the Player Form conifguration
    }
}

; Apply Cursor Element to Skin
applyElementCursor(dir_src, dir_dst) {
    global                                                                                      ; Set scope to global inside function
    
    ; Declare local variables
    local dir_color
    local dir_trail
    local dir_trail_solid
    local dir_smoke

    ; Get directories for cursor color, trail & smoke
    for i, j in l_cursors {
        if (j.name = CursorElementOptionColor)
            dir_color := dir_src "\" j.elementsDir "\" j.cursorsDirs "\" j.cursorColorDir "\" j.dir
        if (j.name = CursorElementOptionTrail)
            dir_trail := dir_src "\" j.elementsDir "\" j.cursorsDirs "\" j.cursorTrailDir "\" j.dir
        if (j.name = CursorElementOptionSmoke)
            dir_smoke := dir_src "\" j.elementsDir "\" j.cursorsDirs "\" j.cursorSmokeDir "\" j.dir
    }

    ; Handle solid or no cursor trails
    if (CursorElementOptionTrail = "None")
        dir_trail := dir_color "\..\..\" d_cursor_notrail
    else if (CursorElementOptionTrailSolid)
        dir_trail_solid := dir_color "\..\..\" d_cursor_solidtrail

    ; Verify color, trail & smoke directories actually exist -- If not, notify & Abort
    if ((!dir_trail_solid) || (!FileExist(dir_trail_solid))) {
        modalMsgBox(n_app ":tApply Error", "Cannot locate path:`t" dir_color, "ElementForm")
        return
    }
    for i, j in [dir_color, dir_trail, dir_smoke] {
        if ((!j) || (!FileExist(j))) {
            modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" j, "ElementForm")
            return
        }
    }

    ; Delete solid trail image
    FileDelete, %dir_dst%\cusrormiddle@2x.png

    ; Copy cursor color, trail & smoke to destination
    for i, j in [dir_color, dir_smoke, dir_trail]
        FileCopy, %j%\*.*, %dir_dst%, 1

    ; Copy solid trail image to destination, if necessary
    if (dir_trail_solid)
        FileCopy, %dir_trail_solid%\*.*, %dir_dst%, 1
}

; Apply Hitburst Element to Skin
applyElementHitburst(dir_src, dir_dst) {
    global                                                                                      ; Define global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory for the type
    for i, j in l_hitbursts {
        if (j.name = HitburstElementOptionType) {
            d_opt1 := dir_src "\" j.elementsDir "\" j.hitburstsDir "\" j.dir
            break
        }
    }

    ; Verify the returned path exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy hitburst to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Reverse Arrow Element to Skin
applyElementRevArrow(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of reverse arrow type
    for i, j in l_reversearrows {
        if (j.name = ReverseArrowElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.reverseArrowDir "\" j.dir
            break
        }
    }

    ; Verify the reverse arrow type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy reverse arrow to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Sliderball Element to Skin
applyElementSliderball(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of sliderball type
    for i, j in l_sliderballs {
        if (j.name = SliderballElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.sliderballDir "\" j.dir
            break
        }
    }

    ; Verify the sliderball type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy sliderball to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Scorebar Background Element to Skin
applyElementScorebarBG(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of scorebar bg type
    for i, j in l_scorebarbgs {
        if (j.name = ScorebarBGElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.scorebarbgDir "\" j.dir
            break
        }
    }

    ; Verify the scorebar bg type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy scorebar bg to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Circle Numbers Element to Skin
applyElementCircleNumber(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of circle number type
    for i, j in l_circlenumbers {
        if (j.name = CircleNumberElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.circleNumberDir "\" j.dir
            break
        }
    }

    ; Verify the circle number type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy circle numbers to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1

    ; Update the hitcircle overlap for dots vs numbers
    if (RegExMatch(CircleNumberElementOptionType, "i).*dot.*"))
        updateHitcircleOverlap(48)
    else
        updateHitcircleOverlap()
}

; Apply Hitsounds Element to Skin
applyElementHitsound(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of hitsounds type
    for i, j in l_hitsounds {
        if (j.name = HitsoundElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.hitsoundDir "\" j.dir
            break
        }
    }

    ; Verify the hitsounds type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy sliderball to destination
    resetSkin("hitsounds")
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Follow Points Element to Skin
applyElementFollowPoint(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type

    ; Get directory of follow points type
    for i, j in l_followpoints {
        if (j.name = FollowPointElementOptionType) {
            dir_type := dir_src "\" j.elementsDir "\" j.followpointDir "\" j.dir
            break
        }
    }

    ; Verify the follow points type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy follow points to destination
    FileCopy, %dir_type%\*.*, %dir_dst%, 1
}

; Apply Mania Element to Skin
applyElementMania(dir_src) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_type
    local obj_type
    StringLower, obj_type, ManiaElementOptionType

    ; Get direcotory of mania type & color
    if (obj_type = "arrow") {
        for i, j in l_maniaarrows {
            if (j.name = ManiaElementArrowOptionColor) {
                dir_type := dir_src "\" j.maniaDir "\" j.arrowDir "\" j.dir
                break
            }
        }
    } else if (obj_type = "bar") {
        for i, j in l_maniabars {
            if (j.name = ManiaElementBarOptionColor) {
                dir_type := dir_src "\" j.maniaDir "\" j.barDir "\" j.dir
                break
            }
        }
    } else if (obj_type = "dot") {
        for i, j in l_maniadots {
            if (j.name = ManiaElementDotOptionColor) {
                dir_type := dir_src "\" j.maniaDir "\" j.dotDir "\" j.dir
                break
            }
        }
    }

    ; Verify the sliderball type exists
    if ((!dir_type) || (!FileExist(dir_type))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_type, "ElementForm")
        return
    }

    ; Copy sliderball to destination
    FileCopy, %dir_type%\*.*, %dir_src%\%d_mania_current%, 1
}

; Apply UI Color Options to Skin
applyUIColor(dir_src, dir_dst) {
    global                                                                                      ; Declare global scope inside function

    ; Declare local variables
    local dir_color

    ; Get directory of UI Color
    for i, j in l_uicolors {
        if (j.name = UIColorOptionColor) {
            dir_color := dir_src "\" j.uiColorDir "\" j.dir
            break
        }
    }

    ; Verify the UI Color exists
    if ((!dir_color) || (!FileExist(dir_color))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_color, "ElementForm")
        return
    }

    ; Copy UI Color to destination
    FileCopy, %dir_color%\*.png, %dir_dst%, 1
    FileCopy, %dir_color%\*.jpg, %dir_dst%, 1

    ; Replace skin.ini if preserve not specified
    if (UIColorOptionSaveIni)
        FileCopy, %dir_color%\skin.ini, %dir_dst%, 1

    ; Add instant fade circles if specified
    updateHitcircleOverlap((UIColorOptionInstafade) ? 160 : 3)

    ; Update Combo Colors
    for i, j in [var_combo_color_1, var_combo_color_2, var_combo_color_3, var_combo_color_4, var_combo_color_5] {
        if (i <= UIColorComboColorCount)
            updateComboColor(i, j)                                                              ; If $i <= ComboCount then Update Combo Color
        else
            removeComboColors(i)                                                                ; Else remove Combo Color
    }

    ; Update slider border & track
    ;updateSliderborderColor(var_slider_border_color)
    ;updateSlidertrackColor(var_slider_track_color)
    updateSliderColor("border", var_slider_border_color)
    updateSliderColor("track", var_slider_track_color)
}

; Apply Player Options to Skin
applyPlayer(dir_src, dir_dst) {
    global                                                                                      ; Set global scope inside function

    ; Declare local variables
    local dir_player
    local bool_middle

    ; Get Directories for player & options
    for i, j in l_players {
        if (j.name = PlayerOptionName) {
            dir_player := dir_src "\" j.playersDir "\" j.dir
            if (j.listNames) {
                MsgBox,, FLAG, FLAG
                for k, l in j.getArray("listNames") {
                    if (l = PlayerOptionVersion) {
                        dir_player .=  "\" j.getArray("listDirs")[k]
                        bool_middle := j.getArray("listMiddle")[k]
                        break
                    }
                }
            } else {
                bool_middle := j.mids
            }
            break
        }
    }

    ; Verify Player Options path exists
    if ((!dir_player) || (!FileExist(dir_player))) {
        modalMsgBox(n_app ":`tApply Error", "Cannot locate path:`t" dir_player, "PlayerForm")
        return
    }

    ; Sanitize gameplay elements in destination
    resetSkin("gameplay")

    ; Copy Player files to destination
    FileCopy, %dir_player%\*.*, %dir_dst%, 1

    ; Remove cursor middle, if necessary
    if (!bool_middle)
        FileDelete, %dir_dst%\cusrormiddle@2x.png
}

; Convert Hex (RRGGBB) to RGB (R,G,B)
hexToRGB(color) {    
    ; Define local variables
    a_dec := []                                                                                 ; array of decimal values

    ; split color into each hex value
    Loop, 6
        a_dec.push(hexToDec(SubStr(color, A_Index, 1)))                                         ; Convert character to decimal

    ; return RGB as an array
    return [(a_dec[1] * 16 + a_dec[2]), (a_dec[3] * 16 + a_dec[4]), (a_dec[5] * 16 + a_dec[6])]
}

; Convert RGB (R,G,B) to Hex (RRGGBB)
rgbToHex(arr) {
    ; handle invalid input
    if (arr.MaxIndex() != 3)
        return

    ; Declare local variables
    hex := ""

    ; Convert each decimal value to the hex equivelent
    loop, 3 {
        hex .= decToHex(Floor(arr[A_Index]/16))
        hex .= decToHex(Mod(arr[A_Index], 16))
    }
    
    ; Return hex color
    return hex
}

; Convert decimal ([0-9]|1[0-5]) to hex ([0-F])
decToHex(val) {
    ; handle invlaid input
    if ! ((val >= 0) && (val <= 15))
        return

    ; If the return value is a single digit, return that value
    if (val < 10)
        return val

    ; If value is two digits, return equivalent character
    for i, j in ["A", "B", "C", "D", "E", "F"] {
        if ((i + 9) = val)
            return j
    }
}

; Convert hex ([0-F]) to decimal ([0-9]|1[0-5])
hexToDec(val) {
    ; Handle non-hex input
    if (RegExMatch(val, "i)[^0-9A-F]"))
        return

    ; If value is a digit, return value
    if (RegExMatch(val, "[0-9]"))
        return val

    ; Find and return value
    StringUpper, val, val
    for i, j in ["A", "B", "C", "D", "E", "F"] {
        if (val = j)
            return (i + 9)
    }
}

; Build Positioning Array
buildPosArray(iterations, elements, offset := 0, max := 0, padding := 0, multiplier := 0, subtract := 0) {
    ; Define local variables
    positions := []
    ratio := max / elements
    pad := padding * multiplier

    ; Build Array
    positions.push(offset + padding)
    ;Loop, %iterations% {
    loop, % (iterations - 1) {
        val := (ratio * (A_Index + 1)) - ratio
        positions.push(subtract = 1 ? val - pad : val + pad)
    }

    ; return Posititions array
    return positions
}

; Convert Positioning Array to String
getObjNamesAsString(arr, delim := ",") {
    ; Define local variables
    str := ""

    ; Builds String
    for k, v in arr
        str .= v.name . delim

    ; return String, minus last delimiter
    return SubStr(str, 1, -1)
}

; Get Index of Substring
getIndexOfSubstringInString(haystack, needle, delim := ",") {
    ; Determine index
    for k, v in (StrSplit(haystack, delim)) {
        if (v = needle)
            return k
    }
}

; Get Options List containing $string -- Dynamic DDL
getListFromString(haystack, needle := "*", delim := ",") {
    ; If needle is "*", return the haystack itself
    if (needle = "*")
        return haystack

    ; Declare local variables
    filter := ""                                                                                ; The string of Elements to return

    ; Get delimited list of strings containing substring
    for i, j in StrSplit(haystack, delim) {
        if (InStr(j, needle))
            filter .= j . delim
    }

    ; Return Filtered Haystack, without trailing delim
    return SubStr(filter, 1, -1)
}