; SPLOOSH-Selector.ahk
; Author:       u/stewie410 <stewie410@gmail.com>
; 
; Asset Selection for the SPLOOSH (S+) osu! Skin

; ##----------------------------------------------------##
; #|            Environment Configuration               |#
; ##----------------------------------------------------##
#SingleInstance, Force                                          ; Allow only one running instance of script
#Persistent                                                     ; Keep the script running until explicitly closed
#NoEnv                                                          ; Avoid checking empty variables for environment
#Warn ClassOverwrite                                            ; Enable warnings, Warn on class overwrite
SetWorkingDir, %A_ScriptDir%                                    ; Set the Working Directory to Script's current directory
FileEncoding UTF-8                                              ; Set Encoding to UTF-8
SetBatchLines, -1                                               ; Set speed of execution
SendMode, Input                                                 ; Send keystrokes/mouseclicks as "input"
DetectHiddenWindows, On                                         ; Allow script to see hidden windows
SetWinDelay, -1                                                 ; Delay after modifying a window
SetControlDelay, -1                                             ; Delay after modifying a control
OnExit("Cleanup")                                               ; Call Cleanup() On ExitApp Event

; ##----------------------------------------------------##
; #|                      Includes                      |#
; ##----------------------------------------------------##
; Libraries
#Include, %A_ScriptDir%\lib
#Include, tf.ahk

; Backend
#Include, %A_ScriptDir%\backend
#Include, main.ahk
#Include, objects.ahk
#Include, events.ahk
#Include, embed.ahk

; File Handling
#Include, %A_ScriptDir%\file
#Include, parser.ahk
#Include, writer.ahk

; Objects/Classes
#Include, %A_ScriptDir%\object
#Include, element.ahk
#Include, player.ahk
#Include, uicolor.ahk
#Include, mania.ahk

; GUIs
#Include, %A_ScriptDir%\gui
#Include, parent.ahk
#Include, topbar.ahk
#Include, sidebar.ahk
#Include, element.ahk
#Include, uicolor.ahk
#Include, player.ahk
#Include, preview.ahk
#Include, picker.ahk

; Main
#Include, %A_ScriptDir%

; ##----------------------------------------------------##
; #|                        Run                         |#
; ##----------------------------------------------------##
; Initialize
InitEnv()

; Display the GUI
Gui, TopBar: Show, % "x" x_topbar " y" y_topbar " w" w_topbar " h" h_topbar
Gui, SideBar: Show, % "x" x_sidebar " y" y_sidebar " w" w_sidebar " h" h_sidebar
Gui, ElementForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide" 
Gui, UIColorForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, PlayerForm: Show, % "x" x_form " y" y_form " w" w_form " h" h_form " Hide"
Gui, PreviewPane: Show, % "x" x_preview " y" y_preview " w" w_preview " h" h_preview
Gui, Parent: Show, % "w" w_app " h" h_app, %n_app%

; Show Default Selected Form
toggleForm(var_selected_form)

; Check GameDirectory now, if there's an issue finding the skin, notify the user
initCheckPath()

; On Mouse Movement, run "WM_MOUSEMOVE()" func
OnMessage(0x0200, "WM_MOUSEMOVE")

; On Left Mouse-Button Up, run "OnWM_LBUTTONUP()" func
OnMessage(0x202, "OnWM_LBUTTONUP")