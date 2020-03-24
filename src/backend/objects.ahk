; BackendObjects.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Object Definitions for Backend

; Define Cursor Objects
defineCursors() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Cursor, follow the follow pattern:
        co_<color> := new Cursor(name, dir, original)

        Definitions:
            name                            The Name or Color of the Cursor to be display in the GUI, eg "Cyan"
            dir                             The name of the directory this object's assets are located, such as "CYAN" for "Cyan"
            original                        An indicator of whether or not this is an original/default element
                                            To indicate a cursor is the original, use 1; otherwise use 0

        See defineGuiSections() for more information
    
        To make additions to this script easier to manage going forward, each Skin customization
        gets added to its' own "list" or "array" of similar objects.  This allows
        the UI to be updated on next run after defining new objects, and adding them
        to their respective lists.

        To ensure proper implementation of additions, simply add the item to the approporate list:

        Cursors         -->         l_cursors.push(co_<name>)
        Hitbursts       -->         l_hitbursts.push(ho_<name>)
        ReverseArrows   -->         l_reversearrows.push(ro_<name>)
        Sliderballs     -->         l_sliderballs.push(so_<name>)
        ScorebarBGs     -->         l_scorebarbgs.psuh(bo_<name>)
        CircleNumbers   -->         l_circlenumbers.push(no_<name>)
        Mania Arrows    -->         l_maniaarrows.push(mao_<name>)
        Mania Bars      -->         l_maniabars.push(mbo_<name>)
        Mania Dots      -->         l_maniadots.push(mdo_<name>)
        UIColors        -->         l_uicolors.push(uo_<name>)
        Players         -->         l_players.push(po_<name>)
    */

    ; Add Cursors to List of Cursor Objects
    l_cursors.push(new Cursor("Cyan", "CYAN", 0))
    l_cursors.push(new Cursor("Eclipse", "ECLIPSE", 0))
    l_cursors.push(new Cursor("Green", "GREEN", 0))
    l_cursors.push(new Cursor("Hot Pink", "HOT PINK", 0))
    l_cursors.push(new Cursor("Orange", "ORANGE", 0))
    l_cursors.push(new Cursor("Pink", "PINK", 0))
    l_cursors.push(new Cursor("Purple", "PURPLE", 0))
    l_cursors.push(new Cursor("Red", "RED", 0))
    l_cursors.push(new Cursor("Turquoise", "TURQUOISE", 0))
    l_cursors.push(new Cursor("Yellow", "YELLOW", 1))
}

; Define Hitburst Objects
defineHitbursts() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Hitburst, follow the following pattern:
        ho_<type> := new Hitburst(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Hitbursts to list of Hitburst Objects
    l_hitbursts.push(new Hitburst("Numbers", "NUMBERS", 0))
    l_hitbursts.push(new Hitburst("Small Bars", "SMALLER BARS", 0))
    l_hitbursts.push(new Hitburst("Default", "DEFAULT", 1))
}

; Define ReverseArrow Objects
defineReverseArrows() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new ReverseArrow, follow the following pattern:
        ro_<type> := new ReverseArrow(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ReverseArrows to list of ReverseArrow Objects
    l_reversearrows.push(new ReverseArrow("Arrow", "ARROW", 0))
    l_reversearrows.push(new ReverseArrow("Half Circle", "HALF CIRCLE", 0))
    l_reversearrows.push(new ReverseArrow("Full Circle", "FULL CIRCLE", 0))
    l_reversearrows.push(new ReverseArrow("Default", "DEFAULT", 1))
}

; Define Sliderball Objects
defineSliderballs() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Sliderball, follow the following pattern:
        ho_<type> := new Sliderball(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Sliderballs to list of Sliderball Objects
    l_sliderballs.push(new Sliderball("Single", "SINGLE", 0))
    l_sliderballs.push(new Sliderball("Double", "DOUBLE", 0))
    l_sliderballs.push(new Sliderball("Default", "DEFAULT", 1))
}

; Define ScorebarBG Objects
defineScorebarBGs() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new ScorebarBG, follow the following pattern:
        ho_<type> := new ScorebarBG(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ScorebarBGs to list of ScorebarBG Objects
    l_scorebarbgs.push(new ScorebarBG("Sidebars", "SIDEBARS", 0))
    l_scorebarbgs.push(new ScorebarBG("Black Box", "BLACK BOX", 0))
    l_scorebarbgs.push(new ScorebarBG("Default", "DEFAULT", 1))
}

; Define CircleNumber Objects
defineCircleNumbers() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Circle Number, follow the following pattern:
        ho_<type> := new Circle Number(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add CircleNumbers to list of CircleNumber Objects
    l_circlenumbers.push(new CircleNumber("Default", "DEFAULT", 1))
    l_circlenumbers.push(new CircleNumber("Squared", "SQUARED", 0))
    l_circlenumbers.push(new CircleNumber("Dots", "DOTS", 0))
}

; Define FollowPoint Objects
defineFollowPoints() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new FollowPoint, follow the following pattern:
        ho_<type> := new FollowPoint(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add FollowPoint to list of FollowPoint Objects
    l_followpoints.push(new FollowPoint("Blue", "BLUE", 0))
    l_followpoints.push(new FollowPoint("Default", "DEFAULT", 1))
    l_followpoints.push(new FollowPoint("Green", "GREEN", 0))
    l_followpoints.push(new FollowPoint("None", "NONE", 0))
    l_followpoints.push(new FollowPoint("Pink", "PINK", 0))
    l_followpoints.push(new FollowPoint("Red", "RED", 0))
    l_followpoints.push(new FollowPoint("Turquoise", "TURQUOISE", 0))
    l_followpoints.push(new FollowPoint("Yellow", "YELLOW", 0))
}

; Define Hitsound Pack Objects
defineHitsounds() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Hitsound Pack, follow the following pattern:
        ho_<type> := new Hitsound Pack(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add Hitsound Pack to list of Hitsound Pack Objects
    l_hitsounds.push(new Hitsound("Clacks 1", "CLACKS 1", 0))
    l_hitsounds.push(new Hitsound("Clacks 2", "CLACKS 2", 0))
    l_hitsounds.push(new Hitsound("Default", "DEFAULT", 1))
    l_hitsounds.push(new Hitsound("Hats", "HATS", 0))
    l_hitsounds.push(new Hitsound("Kicks", "KICKS", 0))
    l_hitsounds.push(new Hitsound("osu!", "OSU", 0))
    l_hitsounds.push(new Hitsound("Pong", "PONG", 0))
    l_hitsounds.push(new Hitsound("Pops", "POPS", 0))
    l_hitsounds.push(new Hitsound("SDVX 1", "SDVX 1", 0))
    l_hitsounds.push(new Hitsound("SDVX 2", "SDVX 2", 0))
    l_hitsounds.push(new Hitsound("Slim", "SLIM", 0))
    l_hitsounds.push(new Hitsound("Ticks", "TICKS", 0))
    l_hitsounds.push(new Hitsound("Tofu", "TOFU", 0))
    l_hitsounds.push(new Hitsound("Wood", "WOOD", 0))
}

; Define ManiaArrow Objects
defineManiaArrows() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mao_<type := new ManiaArrow(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Arrow Objects
    l_maniaarrows.push(new ManiaArrow("Blue", "BLUE"))
    l_maniaarrows.push(new ManiaArrow("Cyan", "CYAN"))
    l_maniaarrows.push(new ManiaArrow("Dark Gray", "DARK GRAY"))
    l_maniaarrows.push(new ManiaArrow("Evergreen", "EVERGREEN"))
    l_maniaarrows.push(new ManiaArrow("Hot Pink", "HOT PINK"))
    l_maniaarrows.push(new ManiaArrow("Light Gray", "LIGHT GRAY"))
    l_maniaarrows.push(new ManiaArrow("Orange", "ORANGE"))
    l_maniaarrows.push(new ManiaArrow("Purple", "PURPLE"))
    l_maniaarrows.push(new ManiaArrow("Red", "RED"))
    l_maniaarrows.push(new ManiaArrow("Yellow", "YELLOW"))
}

; Define ManiaBar Objects
defineManiaBars() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mbo_<type := new ManiaBar(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Bars Objects
    l_maniabars.push(new ManiaBar("Blue", "BLUE"))
    l_maniabars.push(new ManiaBar("Cyan", "CYAN"))
    l_maniabars.push(new ManiaBar("Dark Gray", "DARK GRAY"))
    l_maniabars.push(new ManiaBar("Evergreen", "EVERGREEN"))
    l_maniabars.push(new ManiaBar("Hot Pink", "HOT PINK"))
    l_maniabars.push(new ManiaBar("Light Gray", "LIGHT GRAY"))
    l_maniabars.push(new ManiaBar("Orange", "ORANGE"))
    l_maniabars.push(new ManiaBar("Purple", "PURPLE"))
    l_maniabars.push(new ManiaBar("Red", "RED"))
    l_maniabars.push(new ManiaBar("Yellow", "YELLOW"))
}

; Define ManiaDot Objects
defineManiaDots() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new Mania Arrow type, follow the following pattern
        mdo_<type := new ManiaDot(name, dir)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Add ManiaArrows to list of Mania Dots Objects
    l_maniadots.push(new ManiaDot("Blue", "BLUE"))
    l_maniadots.push(new ManiaDot("Cyan", "CYAN"))
    l_maniadots.push(new ManiaDot("Dark Gray", "DARK GRAY"))
    l_maniadots.push(new ManiaDot("Evergreen", "EVERGREEN"))
    l_maniadots.push(new ManiaDot("Hot Pink", "HOT PINK"))
    l_maniadots.push(new ManiaDot("Light Gray", "LIGHT GRAY"))
    l_maniadots.push(new ManiaDot("Orange", "ORANGE"))
    l_maniadots.push(new ManiaDot("Purple", "PURPLE"))
    l_maniadots.push(new ManiaDot("Red", "RED"))
    l_maniadots.push(new ManiaDot("Yellow", "YELLOW"))
}

; Define UIColor Objects
defineUIColors() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new UIColor, follow the following pattern:
        ho_<type> := new UIColor(name, dir, original)

        See defineCursors() & defineGuiSections() for more information
    */

    ; Ad UIColors to list of UIColor Objects
    l_uicolors.push(new UIColor("Cyan", "CYAN", 0))
    l_uicolors.push(new UIColor("Dark Gray", "DARK GRAY", 0))
    l_uicolors.push(new UIColor("Evergreen", "EVERGREEN", 0))
    l_uicolors.push(new UIColor("Hot Pink", "HOT PINK", 0))
    l_uicolors.push(new UIColor("Light Gray", "LIGHT GRAY", 0))
    l_uicolors.push(new UIColor("Orange", "ORANGE", 0))
    l_uicolors.push(new UIColor("Purple", "PURPLE", 0))
    l_uicolors.push(new UIColor("Red", "RED", 0))
    l_uicolors.push(new UIColor("Yellow", "YELLOW", 0))
    l_uicolors.push(new UIColor("Blue", "BLUE", 1))
}

; Define Player Objects
definePlayers() {
    global                                                                                      ; Set global Scope inside Function
    /*
        To define a new player with additional options, follow this pattern:
            local po_<name> := new Player("<Player Name>", "<Player Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.add("<Option1 Name>", "<Option1 Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.add("<Option2 Name>", "<Option2 Directory Name>", <Include Cursor Middle (0=False; 1=True)>)
            po_<name>.require := 1

        For Players without additional skin options, please see below
    */

    ; Add Mandatory Options to Player Objects
    ; Abyssal
    local po_abyssal := new Player("Abyssal", "ABYSSAL", 0)
    po_abyssal.add("Purple & Pink Combo", "PINK+PURPLE", 0)
    po_abyssal.add("Blue & Red Combo", "BLUE+RED COMBO VER", 0)
	po_abyssal.require := 1

    ; Axarious
    local po_axarious := new Player("Axarious", "AXARIOUS", 0)
    po_axarious.add("Without Slider Ends", "-SLIDERENDS", 0)
    po_axarious.add("With Slider Ends", "+SLIDERENDS", 0)
	po_axarious.require := 1

    ; Azer
    local po_azer := new Player("Azer", "AZER", 0)
    po_azer.add("2017", "2017", 0)
    po_azer.add("2018", "2018", 0)
    po_azer.require := 1

    ; azr8 & GayzMcGee
    local po_azr8 := new Player("azr8 + GayzMcGee", "GAYZR8", 0)
    po_azr8.add("Fire", "FIRE", 0)
    po_azr8.add("ICE", "ICE", 0)
	po_azr8.require := 1

    ; BeastrollMC (YungLing)
    local po_beasttrollmc := new Player("BeasttrollMC", "BEASTTROLLMC", 0)
    po_beasttrollmc.add("v1.3", "V1.3", 0)
    po_beasttrollmc.add("v3", "V3", 0)
    po_beasttrollmc.add("v4", "V4", 0)
    po_beasttrollmc.add("v5", "V5", 0)
    po_beasttrollmc.add("v6", "V6", 0)
    po_beasttrollmc.require := 1

    ; bikko
    local po_bikko := new Player("Bikko", "BIKKO", 1)
    po_bikko.add("Without Slider Ends", "-SLIDERENDS", 1)
    po_bikko.add("With Slider Ends", "+SLIDERENDS", 1)
	po_bikko.require := 1

    ; Comfort
    local po_comfort := new Player("Comfort", "COMFORT", 0)
    po_comfort.add("Standard", "STANDARD", 0)
    po_comfort.add("Nautz", "NAUTZ", 0)
	po_comfort.require := 1

    ; Cookiezi (chocomint)
    local po_cookiezi := new Player("Cookiezi", "COOKIEZI", 0)
    po_cookiezi.add("Burakku Shippu", "BURAKKU SHIPU", 0)
    po_cookiezi.add("Chocomint", "CHOCOMINT", 0)
    po_cookiezi.add("nathan on osu", "NATHAN", 0)
    po_cookiezi.add("Panimi", "PANIMI", 0)
    po_cookiezi.add("Seoulless", "SEOULLESS", 0)
    po_cookiezi.add("Shigetora", "SHIGETORA", 1)
    po_cookiezi.require := 1

    ; Dustice
    local po_dustice := new Player("Dustice", "DUSTICE", 0)
    po_dustice.add("Outer Slider Circle", "+SLIDERCIRCLE", 0)
    po_dustice.add("No Outer Slider Circle", "-SLIDERCIRCLE", 0)
	po_dustice.require := 1

    ; Emilia
    local po_emilia := new Player("Emilia", "EMILIA", 0)
    po_emilia.add("New", "NEW", 0)
    po_emilia.add("Old", "OLD", 0)
    po_emilia.require := 1

    ; FlyingTuna
    local po_flyingtuna := new Player("FlyingTuna", "FLYINGTUNA", 0)
    po_flyingtuna.add("MathiTuna", "MATHITUNA", 0)
    po_flyingtuna.add("Selyu", "SELYU", 0)
    po_flyingtuna.require := 1

    ; idke
    local po_idke := new Player("idke", "IDKE", 0)
    po_idke.add("Old without Slider Ends", "OLD\-SLIDERENDS", 1)
    po_idke.add("Old with Slider Ends", "OLD\+SLIDERENDS", 1)
    po_idke.add("New without Slider Ends", "NEW\-SLIDERENDS", 0)
    po_idke.add("New with Slider Ends", "NEW\+SLIDERENDS", 0)
	po_idke.require := 1

    ; Karhy
    local po_karthy := new Player("Karthy", "KARTHY", 0)
    po_karthy.add("azr8", "KARTHY AZR8", 0)
    po_karthy.add("v5", "KARTHY V5", 0)
    po_karthy.require := 1

    ; Mathi
    local po_mathi := new Player("Mathi", "MATHI", 0)
    po_mathi.add("Flat Hitcircle", "-SHADER", 0)
    po_mathi.add("Shaded Hitcircle", "+SHADER", 0)
	po_mathi.require := 1

    ; Rafis
    local po_rafis := new Player("Rafis", "RAFIS", 0)
    po_rafis.add("Blue", "BLUE", 0)
    po_rafis.add("White", "WHITE", 0)
    po_rafis.add("Yellow", "YELLOW", 0)
    po_rafis.require := 1

    ; Rohulk
    local po_rohulk := new Player("Rohulk", "ROHULK", 0)
    po_rohulk.add("Flat Approach Circle", "-GAMMA", 0)
    po_rohulk.add("Gamma Approach Circle", "+GAMMA", 0)
	po_rohulk.require := 1


    ; rustbell
    local po_rustbell := new Player("Rustbell", "RUSTBELL", 0)
    po_rustbell.add("Without Hit-300 Explosions", "-EXPLOSIONS", 0)
    po_rustbell.add("With Hit-300 Explosions", "+EXPLOSIONS", 0)
	po_rustbell.require := 1

    ; talala
    local po_talala := new Player("talala", "TALALA", 0)
    po_talala.add("White Numbers", "WHITE NUMBERS", 0)
    po_talala.add("Cyan Numbers", "CYAN NUMBERS", 0)
	po_talala.require := 1

    ; Vaxei
    local po_vaxei := new Player("Vaxei", "VAXEI", 0)
    po_vaxei.add("Blue Slider Border", "BLUE SLIDER", 0)
    po_vaxei.add("Red Slider Border", "RED SLIDER", 0)
	po_vaxei.require := 1

    ; WhiteCat
    local po_whitecat := new Player("WhiteCat", "WHITECAT", 0)
    po_whitecat.add("DT", "DT", 0)
    po_whitecat.add("No Mod", "NOMOD", 0)
    po_whitecat.add("Coffee", "COFFEE", 0)
    po_whitecat.require := 1

    ; Xilver & Recia
    local po_xilver := new Player("Xilver X Recia", "XILVER X RECIA", 0)
    po_xilver.add("Orange & Dots", "ORANGE DOT", 0)
    po_xilver.add("Blue & Plus", "BLUE CROSS", 0)
	po_xilver.require := 1

    /*
        Now that all options have been defined, we'll need to add each of our player objects
        to the approrpriate list.  While things are currently pushed to the list in
        alphabetical order, it is essentially irrelevant as the list will be sorted prior to
        being added the GUI...but, it does make it a bit easier to track stuff, especially when
        adding a new player to the list.

        To Add players without any additional options, simply follow the pattern:
            l_players.push(new Player("<Player Name>", "<Player Directory Name>"))

        To Add players WITH options, simply follow the pattern:
            l_players.push(po_<name>)
    */

    ; Add Players to list of Player Objects
    l_players.push(new Player("404AimNotFound", "404ANF", 0))
    l_players.push(po_abyssal)
    l_players.push(new Player("Andros", "ANDROS", 0))
    l_players.push(new Player("Angelsim", "ANGELSIM", 0))
    l_players.push(po_axarious)
    l_players.push(po_azer)
    l_players.push(po_azr8)
    l_players.push(new Player("badeu", "BADEU", 0))
    l_players.push(po_beasttrollmc)
    l_players.push(po_bikko)
    l_players.push(new Player("Bubbleman", "BUBBLEMAN", 0))
    l_players.push(po_comfort)
    l_players.push(po_cookiezi)
    l_players.push(new Player("Doomsday", "DOOMSDAY", 0))
    l_players.push(po_dustice)
    l_players.push(po_emilia)
    l_players.push(po_flyingtuna)
    l_players.push(new Player("Freddie Benson", "FREDDIE BENSON", 0))
    l_players.push(new Player("FunOrange", "FUNORANGE", 0))
    l_players.push(new Player("-GN", "GN", 0))
    l_players.push(new Player("hvick225", "HVICK225", 0))
    l_players.push(po_idke)
    l_players.push(new Player("Informous", "INFORMOUS", 0))
    l_players.push(po_karthy)
    l_players.push(new Player("Koi Fish", "KOI FISH", 0))
    l_players.push(po_mathi)
    l_players.push(new Player("Monko2k", "MONKO2K", 0))
    l_players.push(po_rafis)
    l_players.push(po_rohulk)
    l_players.push(new Player("rrtyui", "RRTYUI", 0))
    l_players.push(po_rustbell)
    l_players.push(new Player("RyuK", "RYUK", 0))
    l_players.push(new Player("Seysant", "SEYSANT", 0))
    l_players.push(new Player("Sotarks", "SOTARKS", 0))
    l_players.push(po_talala)
    l_players.push(new Player("Toy", "TOY", 0))
    l_players.push(new Player("Tranquil-ity", "TRANQUIL-ITY", 0))
    l_players.push(new Player("Varvalian", "VARVALIAN", 0))
    l_players.push(po_vaxei)
    l_players.push(po_whitecat)
    l_players.push(new Player("WubWoofWolf", "WWW", 0))
    l_players.push(po_xilver)
    l_players.push(new Player("Yaong", "YAONG", 0))
}

; Get Default/Standard Option from Object Array
getDefaultObject(arr) {
    ; Determine Default Option
    for k, v in arr {
        if (v.original)
            return v.name
    }

    ; return empty string
    return ""
}