; KeypressOSD.ahk - main file
; Latest version at:
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.
;
;--------------------------------------------------------------------------------------------------------------------------
;
; Keyboard language definitions file:
;   keypress-osd-languages.ini
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-languages.ini
;   File required for AutoDetectKBD = 1, to detect keyboard layouts.
;   File must be placed in the same folder with the script.
;   It adds support for around 110 keyboard layouts covering about 55 languages.;
;
; Change log file:
;   keypress-osd-changelog.txt
;   http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd-changelog.txt
;
/*
AVAILABLE SHORTCUTS:
 Ctrl+Alt+Shift+F7
 Toggles between two predefined keyboard layouts. You can define these layouts at Main menu > Preferences > Keyboard.

 Ctrl+Alt+Shift+F8
 Toggles "Show single key" option. Useful when you type passwords, but you do not want it entirely disabled.

 Ctrl+Alt+Shift+F9
 Toggles between two OSD positions. You can define these at Main menu > Preferences > OSD appearances.

 Ctrl+Alt+Shift+F11
 Enables the automatic detection of keyboard layouts.

 Ctrl+Alt+Shift+F12
 Reinitializes/restarts the OSD.

 Shift+Pause/Break
 Suspends the script and all of its functionality. 


PRESENTATION:
 This program is an On Screen Display or a Heads-Up Display for keys. It displays every key or mouse button press at a clearly visible text size. I developed it for people like me, with poor eye sight or low vision. It is meant to aid desktop computer usage. It is especially useful while chatting or for occasional typing. The user no longer has to squint at the screen or zoom in the entire screen to see what s/he wrote for every text field.
 
 Numerous options and settings are available in the different Preferences windows provided in the program, such that everyone can find a way to adapt it to personal needs.
 
 This program was developed for Windows 10 and Windows 7.

 The keyboard layouts have changed since Win XP or Win 98.
 Windows 10 also no longer switches keyboard layouts based
 on the currently active app. As such, automatic keyboard
 layout detection may not work on all systems.
 
 This application has support only for Latin-based keyboards. I did not test or developed it having in mind support for Chinese, Cyrillic or Japanese scripts. While developing it. I learned it has limited support for Cyrillic keyboards.

 It is too complex for me to implement support for other alphabets or writing systems.

 If other programmers are willing to invest time in this application and to extend it, are welcomed to do so. Anyone is free to transform it into anything they wish. The source code is available. However, keep in mind, I am no programmer. I learned to code just to develop this application. The code quality is definitely poor :-).

 I developed this application with the great support and help from the people on #ahk (irc.freenode.net).

FEATURES:
  - Support for 105 keyboard layouts covering about 55 languages. It recognizes keys with Shift, AltGr and dead keys for each of these layouts.
  - Automatic detection of keyboard layouts.
  - Show previously pressed key if fired quickly.
  - Count key presses or key fires and mouse clicks.
  - Indicators for Caps Lock, Num Lock and Scroll Lock states.
  - Option to ignore specific keys

  - Typing mode. It shows what you are typing in an expanding text area.
  - Virtual caret/cursor navigation: you can navigate through typed text in the OSD in synch with the text field of the host application.
  - Only typing mode option.
  - Typed text history with Page Up/Down. On pressing Enter or Escape, it records the written line and you can get back to it with Page Up. On clipboard change, if you press Page Down, you can get to the clipboard content.

  - Automatic resizing of OSD/HUD or fixed size.
  - Customizable size, position and colors.
  - Hides or switches position automatically when mouse runs over it.
  - Customizable visual mouse clicks and idle mouse highlighter.
  - Distinct beepers for different types of keys and buttons or when typing with Capslock.
  - Clipboard monitor. It displays briefly texts copied to clipboard.

  - Live text capture with Capture2Text*
    With this option, KeyPress OSD continously displays the texts detected by Capture2Text underneath the mouse cursor.
    * you must have Capture2Text running and Pause/Break set as a shortcut for "Text line capture" and copy to clipboard option enabled.

  - Multi-monitor support
  
  - Portable. No need to install/uninstall. Settings stored in an easy to read INI file
 
  - Easy to configure with many options in Settings windows to toggle features and customize behavior and look.

  - Option to update to the latest version.
*/
 ; 
;----------------------------------------------------------------------------

; Initialization

 #SingleInstance force
 #NoEnv
 #MaxHotkeysPerInterval 500
 #MaxThreads 255
 #MaxThreadsPerHotkey 255
 #MaxThreadsBuffer On
 SetTitleMatchMode, 2
 SetBatchLines, -1
 ListLines, Off
 SetWorkingDir, %A_ScriptDir%

; Default Settings / Customize:

 global IgnoreAdditionalKeys  := 0
 , IgnorekeysList        := "a.b.c"
 , NoBindedDeadKeys      := 0
 , AutoDetectKBD         := 1     ; at start, detect keyboard layout
 , ConstantAutoDetect    := 1     ; continously check if the keyboard layout changed; if AutoDetectKBD=0, this is ignored
 , SilentDetection       := 0     ; do not display information about language switching
 , audioAlerts           := 0     ; generate beeps when key bindings fail
 , ForceKBD              := 0     ; force detection of a specific keyboard layout ; AutoDetectKBD must be set to 1
 , ForcedKBDlayout1      := "00010418" ; enter here the HEX code of your desired keyboards
 , ForcedKBDlayout2      := "0000040c"
 , ForcedKBDlayout       := 0
 , enableAltGrUser       := 1
 
 , DisableTypingMode     := 0     ; do not echo what you write
 , OnlyTypingMode        := 0
 , enableTypingHistory   := 0
 , enterErasesLine       := 1
 , pgUDasHE              := 0    ; page up/down behaves like home/end
 , UpDownAsHE            := 0    ; up/down behaves like home/End
 , UpDownAsLR            := 0    ; up/down behaves like Left/Right
 , ShowDeadKeys          := 0
 , autoRemDeadKey        := 1
 , ShowSingleKey         := 1     ; show only key combinations ; it disables typing mode
 , HideAnnoyingKeys      := 1     ; Left click and PrintScreen can easily get in the way.
 , ShowMouseButton       := 1     ; in the OSD
 , StickyKeys            := 0     ; how modifiers behave; set it to 1 if you use StickyKeys in Windows
 , ShowSingleModifierKey := 1     ; make it display Ctrl, Alt, Shift when pressed alone
 , DifferModifiers       := 0     ; differentiate between left and right modifiers
 , ShowPrevKey           := 1     ; show previously pressed key, if pressed quickly in succession
 , ShowPrevKeyDelay      := 300
 , ShowKeyCount          := 1     ; count how many times a key is pressed
 , ShowKeyCountFired     := 0     ; show only key presses (0) or catch key fires as well (1)
 , NeverDisplayOSD       := 0
 , ReturnToTypingUser    := 15    ; in seconds
 , DisplayTimeTypingUser := 10    ; in seconds
 , synchronizeMode       := 0
 , alternativeJumps      := 0
 , pasteOSDcontent       := 1
 
 , DisplayTimeUser       := 3     ; in seconds
 , JumpHover             := 0
 , OSDborder             := 0
 , GUIposition           := 1     ; toggle between positions with Ctrl + Alt + Shift + F9
 , GuiXa                 := 40
 , GuiYa                 := 250
 , GuiXb                 := 60
 , GuiYb                 := 800
 , GuiWidth              := 350
 , maxGuiWidth           := 500
 , FontName              := "Arial"
 , FontSize              := 19
 , FavorRightoLeft       := 0
 , NeverRightoLeft       := 0
 , OSDbgrColor           := "111111"
 , OSDtextColor          := "ffffff"
 , CapsColorHighlight    := "88AAff"
 , OSDautosize           := 1     ; make adjustments to the growth factors to match your font size
 , OSDautosizeFactory    := round(A_ScreenDPI / 1.18)
 
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , deadKeyBeeper         := 1
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , BeepHiddenKeys        := 0     ; [when any beeper enabled] to beep or not when keys are not displayed by OSD/HUD
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall
 , LowVolBeeps           := 1
 , beepFiringKeys        := 0

 , KeyboardShortcuts     := 1     ; system-wide shortcuts
 , ClipMonitor           := 1     ; show clipboard changes
 , ShiftDisableCaps      := 1

 , VisualMouseClicks     := 0     ; shows visual indicators for different mouse clicks
 , MouseVclickAlpha      := 150   ; from 0 to 255
 , ClickScaleUser        := 10
 , ShowMouseHalo         := 0     ; constantly highlight mouse cursor
 , MouseHaloRadius       := 35
 , MouseHaloColor        := "eedd00"  ; HEX format also accepted
 , MouseHaloAlpha        := 130   ; from 0 to 255
 , FlashIdleMouse        := 0     ; locate an idling mouse with a flashing box
 , MouseIdleRadius       := 40
 , MouseIdleAfter        := 10    ; in seconds
 , IdleMouseAlpha        := 70   ; from 0 to 255
 , UseINIfile            := 1
 , IniFile               := "keypress-osd.ini"
 , version               := "3.82.5"
 , releaseDate := "2017 / 12 / 21"
 
; Initialization variables. Altering these may lead to undesired results.

    IniRead, firstRun, %IniFile%, SavedSettings, firstRun
    if (firstRun=0) && (UseINIfile=1)
    {
        LoadSettings()
    } else if (UseINIfile=1)
    {
        CheckSettings()
        ShaveSettings()
    }

 global typed := "" ; hack used to determine if user is writing
 , visible := 0
 , ClickScale := ClickScaleUser/10
 , DisplayTime := DisplayTimeUser*1000
 , DisplayTimeTyping := DisplayTimeTypingUser*1000
 , ReturnToTypingDelay := ReturnToTypingUser*1000
 , prefixed := 0 ; hack used to determine if last keypress had a modifier
 , Capture2Text := 0
 , tickcount_start2 := A_TickCount
 , tickcount_start := 0 ; timer to count repeated key presses
 , keyCount := 0
 , modifiers_temp := 0
 , GuiX := GuiX ? GuiX : GuiXa
 , GuiY := GuiY ? GuiY : GuiYa
 , GuiHeight := 50
 , maxAllowedGuiWidth := A_ScreenWidth
 , rightoleft := 0
 , prefOpen := 0
 , MouseClickCounter := 0
 , shiftPressed := 0
 , AltGrPressed := 0
 , enableAltGr := enableAltGrUser
 , visibleTextField := ""
 , text_width := 60
 , CaretPos := "1"
 , maxTextChars := "4"
 , lastTypedSince := 0
 , editingField := "3"
 , editField1 := " "
 , editField2 := " "
 , editField3 := " "
 , backTyped := ""
 , backTyped2 := ""
 , backTypedUndo := ""
 , CurrentKBD := "Default: English US"
 , loadedLangz := A_IsCompiled ? 1 : 0
 , kbLayoutRaw := 0
 , LangChanged := 0
 , DeadKeys := 0
 , DKnotShifted_list := ""
 , DKshift_list := ""
 , DKaltGR_list := ""
 , SCnames := ""
 , SCnames2 := "▪"
 , FontList := []
 , missingAudios := 1
 , deadKeyPressed := "9500"

 SetFormat, integer, H
   global InputLocaleID := % DllCall("GetKeyboardLayout", Int,DllCall("GetWindowThreadProcessId", int,WinActive("A"), Int,0))
 SetFormat, integer, D
   StringReplace, InputLocaleID, InputLocaleID, -, 
   global NewInputLocaleID := InputLocaleID

   Thread, priority, 10
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth

if (visualMouseClicks=1)
{
    CoordMode Mouse, Screen
    CreateMouseGUI()
}

if (FlashIdleMouse=1)
{
    CoordMode Mouse, Screen
    SetTimer, ShowMouseIdleLocation, 1000, -15
}

if (ShowMouseHalo=1)
{
    CoordMode Mouse, Screen
    SetTimer, MouseHalo, 70, -12
}

CreateOSDGUI()
CreateHotkey()
CreateGlobalShortcuts()
CheckInstalledLangs()
InitializeTray()
verifyNonCrucialFiles()
if (ClipMonitor=1)
    OnClipboardChange("ClipChanged")
return

; The script

TypedLetter(key) {
   Thread, priority, 40
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
      Critical, on

   if (ShowSingleKey=0 || DisableTypingMode=1)
   {
      typed := ""
      Return
   }

   if (enableAltGr=1) && (StickyKeys=1) && (AltGrPressed=1)
      typed := backTyped
   
   global lastTypedSince := A_TickCount

   vk := "0x0" SubStr(key, InStr(key, "vk", 0, 0)+2)
   sc := "0x0" GetKeySc("vk" vk)

   key := toUnicodeExtended(vk, sc)
   typed := InsertChar2caret(key)

   if (enableAltGr=1) && (StickyKeys=0) && (AltGrPressed=1)
      backTyped := typed
   
   AltGrPressed := 0

   return typed
}

replaceSelection() {
  
  backTypedUndo := typed

  lola := "│"
  lola2 := "║"

  StringGetPos, CaretPos, typed, %lola%
  StringGetPos, CaretPos2, typed, %lola2%
  if (CaretPos2 > CaretPos)
  {
    loca := st_subString(typed, lola, direction:="B", match:=1, lola2)
  } else
  {
    loca := st_subString(typed, lola2, direction:="B", match:=1, lola)
  }
  StringReplace, typed, typed, %loca%, %lola%
  StringReplace, typed, typed, %lola2%
  StringReplace, typed, typed, %lola%
}

InsertChar2caret(char) {
  Thread, priority, 40
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  lola := "│"
  lola2 := "║"

  if (st_count(typed, lola2)>0)
     replaceSelection()

  if (CaretPos = 2000)
     CaretPos := 1

  if (CaretPos = 3000)
     CaretPos := StrLen(typed)+1

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%
  CaretPos := CaretPos+1
  typed := ST_Insert(char lola, typed, CaretPos)

  CalcVisibleText()

  Return typed
}


CalcVisibleTextFieldDummy() {
    CalcVisibleText()
    ShowHotkey(visibleTextField)
    SetTimer, HideGUI, % -DisplayTime
; SoundBeep
    SetTimer,, off
}

st_subString(string,search1,direction:="R",match:=1,search2:="",CaseSensitive:="") { ;Credit @ AfterLemon
  s:=string,A=search1,d=direction,m=match,B=Search2,V=CaseSensitive,c=InStr(s,A,V),(d="B"&&B=""?B:=A:"")
  StringCaseSense,% (V?"On":"Off")
  StringReplace,s,s,%A%,%A%,UseErrorLevel
    E:=(ErrorLevel<m?1:0)
  If !E{
  While(--m?c:=InStr(s,A,V,c+1):""){
  }R:=SubStr(s,1,--c),(d="R"?R:=SubStr(s,StrLen(R)+StrLen(A)+1):(d="B"?(InStr(s,B,V,c+1)>0?R:=SubStr(s,c+StrLen(A)+1,InStr(s,B,V,c+StrLen(A)+1)-c-StrLen(A)-StrLen(B)):R:=SubStr(s,StrLen(R)+StrLen(A)+1)):R))
}return (E?"":R)
}

CalcVisibleText() {
   Thread, priority, 10
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

   if (A_TickCount-tickcount_start2 < 30) && (A_TickCount-deadKeyPressed > 1500)
   {
     SetTimer, CalcVisibleTextFieldDummy, 150, 100
     Return
   }

   visibleTextField := typed

   maxTextLimit := 0
   text_width0 := GetTextExtentPoint(typed, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
   if (text_width0 > maxAllowedGuiWidth) && typed
      maxTextLimit := 1

   if (maxTextLimit>0)
   {
      lola := "│"
      lola2 := "║"
      maxA_Index := (maxTextChars<6) ? StrLen(typed) : round(maxTextChars*1.3)

      if (st_count(typed, lola2)>0)
      {
         StringGetPos, RealCaretPos, typed, %lola%
         StringGetPos, SelCaretPos, typed, %lola2%
         addSelMarker := 1
         addSelMarkerLocation := (SelCaretPos < RealCaretPos) ? 1 : 2
         lola := lola2
      }
      LoopJumpStart := (maxTextChars > StrLen(typed)-5) ? 1 : Round(maxTextChars/2)

      Loop
      {
        StringGetPos, vCaretPos, typed, %lola%
        Stringmid, NEWvisibleTextField, typed, vCaretPos+1+round(maxTextChars/3.5), LoopJumpStart+A_Index, L
        text_width2 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
        if (text_width2 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
           allGood := 1
      }
      Until (allGood=1) || (A_Index=maxA_Index)

      if (allGood!=1)
      {
          Loop
          {
            Stringmid, NEWvisibleTextField, typed, vCaretPos+A_Index, , L
            text_width3 := GetTextExtentPoint(NEWvisibleTextField, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
            if (text_width3 >= maxAllowedGuiWidth-30-(OSDautosizeFactory/15))
               stopLoop2 := 1
          }
          Until (stopLoop2 = 1) || (A_Index=round(maxA_Index/1.25))
      }

      if (addSelMarker=1)
         NEWvisibleTextField := (addSelMarkerLocation=2) ? "├ " NEWvisibleTextField : NEWvisibleTextField " ┤" 

      visibleTextField := NEWvisibleTextField
      maxTextChars := maxTextChars<3 ? maxTextChars : StrLen(visibleTextField)+3
   }
}

ST_Insert(insert,input,pos=1) {
  Thread, priority, 15
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

  Length := StrLen(input)
  ((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
  output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
  If (StrLen(output) > StrLen(input) + StrLen(insert))
    ((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
  return, output
}

caretMover(direction) {
  Thread, priority, 40
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  lola := "│"
  lola2 := "║"
  StringGetPos, CaretPos, typed, %lola%
  if (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos2, typed, %lola2%
     if ((CaretPos2 > CaretPos) && (direction=2)) || ((CaretPos2 < CaretPos) && (direction=0))
     {
        CaretPos := CaretPos2
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     } Else
     {
        CaretPos := (direction=2) ? CaretPos - 2 : CaretPos + 1
     }
  }
  StringReplace, typed, typed, %lola%
  StringReplace, typed, typed, %lola2%
  CaretPos := CaretPos + direction
  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)

  if (InStr(typed, "▫" lola))
  {
     StringGetPos, CaretPos, typed, %lola%
     StringReplace, typed, typed, %lola%
     CaretPos := CaretPos + direction
     typed := ST_Insert(lola, typed, CaretPos)
  }
  CalcVisibleText()
}

caretMoverSel(direction) {
  Thread, priority, 40
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  lola2 := "│"
  lola := "║"

  StringGetPos, CaretPos, typed, %lola2%
  if (st_count(typed, lola)>0)
  {
     StringGetPos, CaretPos, typed, %lola%
  } else
  {
     StringGetPos, CaretPos, typed, %lola2%
     CaretPos := (direction=1) ? CaretPos + 1 : CaretPos
  }

  StringReplace, typed, typed, %lola%
  CaretPos := (direction=1) ? CaretPos + 2 : CaretPos
  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1

  typed := ST_Insert(lola, typed, CaretPos)

  if (InStr(typed, "▫" lola))
  {
     StringGetPos, CaretPos, typed, %lola%
     StringReplace, typed, typed, %lola%
     CaretPos := CaretPos + direction
     typed := ST_Insert(lola, typed, CaretPos)
  }

  if (InStr(typed, lola lola2) || InStr(typed, lola2 lola))
     StringReplace, typed, typed, %lola%

  CalcVisibleText()
}

st_count(string, searchFor="`n") {
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}

caretJumpMain(direction) {
  Critical, On

  if (CaretPos<=1)
     CaretPos := 1.5

  theRegEx := "i)((?=[[:space:]│!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~])[\p{L}\p{M}\p{Z}\p{N}\p{P}\p{S}]\b(?=\S)|\s(?!\s)(?=\p{L}))"
  alternativeRegEx := "i)(((\p{L}|\p{N}|\w)(?=\S))([\p{M}\p{Z}!""@#$%^&*()_¡°¿+{}\[\]|;:<>?/.,\-=``~\p{S}\p{C}])|\s+[[:punct:]])"
  if (direction=1)
  {
     CaretuPos := RegExMatch(typed, theRegEx, , CaretPos+1) + 1
     if (alternativeJumps=1)
     {
        CaretuPosa := RegExMatch(typed, alternativeRegEx, , CaretPos+1) + 1
        if (CaretuPosa>CaretPos)
           CaretuPos := CaretuPosa < CaretuPos ? CaretuPosa : CaretuPos
     }
     CaretPos := CaretuPos < CaretPos ? StrLen(typed)+1 : CaretuPos
  }

  if (direction=0)
  {
     typed := ST_Insert(" z.", typed, StrLen(typed)+1)

     if (CaretPos<=1)
        skipLoop := 1

     Loop
     {
       CaretuPos := CaretPos - A_Index
       CaretelPos := RegExMatch(typed, theRegEx, , CaretuPos)+1
       if (alternativeJumps=1)
       {
          CaretelPosa := RegExMatch(typed, alternativeRegEx, , CaretuPos)+1
          CaretelPos := CaretelPosa < CaretelPos ? CaretelPosa : CaretelPos
       }
       CaretelPos := CaretelPos < CaretuPos ? StrLen(typed)+1 : CaretelPos
       if (CaretelPos < CaretPos+1)
       {
          CaretPos := CaretelPos > CaretPos ? 1 : CaretelPos
          allGood := 1
       }
       if (CaretelPos < CaretuPos+1) || (A_Index>CaretPos+5)
          skipLoop := 1
     } Until (skipLoop=1 || allGood=1 || A_Index=300)

     StringTrimRight, typed, typed, 3
  }

  if (CaretPos<=1)
     CaretPos := 1
  if (CaretPos >= (StrLen(typed)+1) )
     CaretPos := StrLen(typed)+1
}


caretJumper(direction) {
  Critical, on
  lola := "│"
  lola2 := "║"
  if (st_count(typed, lola2)>0)
     caretMover(direction*2)

  StringGetPos, CaretPos, typed, %lola%
  StringReplace, typed, typed, %lola%

  caretJumpMain(direction)

  typed := ST_Insert(lola, typed, CaretPos)
}

caretJumpSelector(direction) {
  lola := "│"
  lola2 := "║"
  if (st_count(typed, lola2)>0)
  {
     StringGetPos, CaretPos, typed, %lola2%
     StringReplace, typed, typed, %lola2%
  } Else
  {
     StringGetPos, CaretPos, typed, %lola%
     CaretPos := (direction=1) ? CaretPos+1 : CaretPos
  }

  caretJumpMain(direction)

  typed := ST_Insert(lola2, typed, CaretPos)

  if (InStr(typed, lola lola2) || InStr(typed, lola2 lola))
     StringReplace, typed, typed, %lola2%

}

st_delete(string, start=1, length=1) {
  Thread, priority, 20
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

   if (abs(start+length) > StrLen(string))
      return string
   if (start>0)
      return substr(string, 1, start-1) . substr(string, start + length)
   else if (start<=0)
      return substr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}

toUnicodeExtended(uVirtKey,uScanCode,wFlags:=0) {
; Many thanks to Helgef:
; https://autohotkey.com/boards/viewtopic.php?f=5&t=41065&p=187582#p187582

  nsa := DllCall("MapVirtualKey", "Uint", uVirtKey, "Uint", 2)

  if (nsa<=0) && (DeadKeys=0)
  {
     if (deadKeyBeeper = 1) && (ShowSingleKey = 1) && (NoBindedDeadKeys=0) || (deadKeyBeeper = 1) && (BeepHiddenKeys = 1) && (NoBindedDeadKeys=0)
        deadKeysBeeper()

     if (ShowDeadKeys=1) && (NoBindedDeadKeys=0)
     {
       RmDkSymbol := (autoRemDeadKey=1) ? "▫" : "▪"
       InsertChar2caret(RmDkSymbol)
     }

     if (StrLen(typed)<3) && (NoBindedDeadKeys=0)
     {
        ShowHotkey("[dead key]")
        Sleep, 350
     }

     Return
   }

  thread := DllCall("GetWindowThreadProcessId", "ptr", WinActive("A"), "ptr", 0)
  hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")
  cchBuff := 3            ; number of characters the buffer can hold
  VarSetCapacity(lpKeyState,256,0)
  VarSetCapacity(pwszBuff, (cchBuff+1) * (A_IsUnicode ? 2 : 1), 0)  ; this will hold cchBuff (3) characters and the null terminator on both unicode and ansi builds.

  for modifier, vk in {Shift:0x10, Control:0x11, Alt:0x12}
      NumPut(128*(GetKeyState("L" modifier) || GetKeyState("R" modifier)) , lpKeyState, vk, "Uchar")
  
  if (StickyKeys=1)
  {
     if (shiftPressed=1)
        NumPut(128*shiftPressed, lpKeyState, 0x10, "Uchar")
     if (AltGrPressed=1)
     {
        NumPut(128*AltGrPressed, lpKeyState, 0x12, "Uchar")
        NumPut(128*AltGrPressed, lpKeyState, 0x11, "Uchar")
     }
  }

  if NumGet(lpKeyState, 0x11, "Uchar") && NumGet(lpKeyState, 0x11, "Uchar") && (StickyKeys=0)
     AltGrPressed := 1

  NumPut(GetKeyState("CapsLock", "T") , &lpKeyState+0, 0x14, "Uchar")

  n := DllCall("ToUnicodeEx", "Uint", uVirtKey, "Uint", uScanCode, "UPtr", &lpKeyState, "ptr", &pwszBuff, "Int", cchBuff, "Uint", wFlags, "ptr", hkl)
  if (DeadKeys=1)
     n := DllCall("ToUnicodeEx", "Uint", uVirtKey, "Uint", uScanCode, "UPtr", &lpKeyState, "ptr", &pwszBuff, "Int", cchBuff, "Uint", wFlags, "ptr", hkl)
  return StrGet(&pwszBuff, n, "utf-16")
}


OnMousePressed() {
    if (Visible=1)
       tickcount_start := A_TickCount-500

    shiftPressed := 0
    AltGrPressed := 0

    try {
        key := GetKeyStr()
        if (ShowMouseButton=1)
        {
            typed := (OnlyTypingMode=1) ? typed : "" ; concerning TypedLetter(" ") - it resets the content of the OSD
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        }
    }

    if ((MouseBeeper = 1) && (ShowMouseButton = 1) && (ShowSingleKey = 1) || (MouseBeeper = 1) && (ShowSingleKey = 0) && (BeepHiddenKeys = 1) || (visualMouseClicks=1) && (MouseBeeper = 1) )
       clickyBeeper()

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       ShowMouseClick(mkey)
    }
}

OnRLeftPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Left|Right))") && (ShowSingleKey=1)
        {
            deadKeyProcessing()

            if ((key ~= "i)^(Left)"))
               caretMover(0)

            if ((key ~= "i)^(Right)"))
               caretMover(2)

            if ((key ~= "i)^(.?Shift \+ Left)"))
               caretMoverSel(-1)

            if ((key ~= "i)^(.?Shift \+ Right)"))
               caretMoverSel(1)

            if (!(CaretPos=StrLen(typed)) && (CaretPos!=1))
               global lastTypedSince := A_TickCount

            dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (keyCount>10) && (OnlyTypingMode=0) ? 1 : 0
            if (CaretPos=StrLen(typed) && (dropOut=1)) || ((CaretPos=1) && (dropOut=1))
               global lastTypedSince := A_TickCount - ReturnToTypingDelay

            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnUpDownPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Up|Down))") && (ShowSingleKey=1)
        {
            deadKeyProcessing()
            if (UpDownAsHE=1) && (UpDownAsLR=0)
            {
                lola := "│"
                lola2 := "║"

                if (key ~= "i)^(Up)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%

                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := 3
                }

                if (key ~= "i)^(Down)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := StrLen(typed)+1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := StrLen(typed)+2
                }

                if (key ~= "i)^(.?Shift \+ Down)")
                   SelectHomeEnd(1)

                if (key ~= "i)^(.?Shift \+ Up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
            }

            if (UpDownAsLR=1) && (UpDownAsHE=0)
            {
                if ((key ~= "i)^(Up)"))
                   caretMover(0)

                if ((key ~= "i)^(Down)"))
                   caretMover(2)

                if ((key ~= "i)^(.?Shift \+ Up)"))
                   caretMoverSel(-1)

                if ((key ~= "i)^(.?Shift \+ Down)"))
                   caretMoverSel(1)

                if (!(CaretPos=StrLen(typed)) && (CaretPos!=1))
                   global lastTypedSince := A_TickCount

                dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (keyCount>10) && (OnlyTypingMode=0) ? 1 : 0
                if (CaretPos=StrLen(typed) && (dropOut=1)) || ((CaretPos=1) && (dropOut=1))
                   global lastTypedSince := A_TickCount - ReturnToTypingDelay
            }

            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnHomeEndPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?(Home|End))") && (ShowSingleKey=1) && (keyCount<10)
        {
            deadKeyProcessing()
            lola := "│"
            lola2 := "║"

            if (key ~= "i)^(Home)")
            {
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               CaretPos := 1
               typed := ST_Insert(lola, typed, CaretPos)
               maxTextChars := 3
            }

            if (key ~= "i)^(End)")
            {
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               CaretPos := StrLen(typed)+1
               typed := ST_Insert(lola, typed, CaretPos)
               maxTextChars := StrLen(typed)+2
            }

            if (key ~= "i)^(.?Shift \+ End)")
               SelectHomeEnd(1)

            if (key ~= "i)^(.?Shift \+ Home)")
               SelectHomeEnd(0)

            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)) || (keyCount>10) && OnlyTypingMode=0 )
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltgrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

SelectHomeEnd(direction) {

  lola := "│"
  lola2 := "║"
  StringGetPos, CaretPos3, typed, %lola%

  if ((CaretPos3 >= StrLen(typed)-1) && (direction=1)) || ((CaretPos3<=1) && (direction=0))
  {
     StringReplace, typed, typed, %lola2%
     Return
  }

  if (typed ~= "i)^(║)") && (direction=0) || (typed ~= "i)(║)$") && (direction=1) || (CaretPos<=1) && (direction!=1) || (CaretPos >= StrLen(typed)) && (direction=1)
     Return

  StringReplace, typed, typed, %lola2%
  CaretPos2 := (direction=0) ? 1 : StrLen(typed)+1
  typed := ST_Insert(lola2, typed, CaretPos2)
  if (direction=1)
     maxTextChars := StrLen(typed)+2
}

OnPGupDnPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try
    {
        key := GetKeyStr()
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (DisableTypingMode=0) && (key ~= "i)^((.?Shift \+ )?Page )") && (ShowSingleKey=1) && (keyCount<10)
        {
            lola := "│"
            lola2 := "║"
            deadKeyProcessing()

            if (pgUDasHE=1) && (key ~= "i)^(.?Shift \+ )")
            {
                if (key ~= "i)^(.?Shift \+ Page down)")
                   SelectHomeEnd(1)

                if (key ~= "i)^(.?Shift \+ Page up)")
                   SelectHomeEnd(0)

                CalcVisibleText()
                ShowHotkey(visibleTextField)
                SetTimer, HideGUI, % -DisplayTimeTyping
                Return
            }

            if (enableTypingHistory=1)
            {
                if (key ~= "i)^(Page Down)") && !visible && StrLen(typed)<3
                {
                   global lastTypedSince := A_TickCount - ReturnToTypingDelay
                   if (StrLen(typed)<2)
                      typed := (OnlyTypingMode=1) ? typed : ""
                   ShowHotkey(key)
                   SetTimer, HideGUI, % -DisplayTime
                   Return
                }

                StringReplace, typed, typed, %lola%
                StringReplace, typed, typed, %lola2%
                StringReplace, editField1, editField1, %lola%
                StringReplace, editField2, editField2, %lola%
                StringReplace, editField3, editField3, %lola%

                if (key ~= "i)^(Page Up)")
                {
                   if (editingField=3)
                      backTyped := typed
                   editingField := (editingField<=1) ? 1 : editingField-1
                   typed := editField%editingField%
                }

                if (key ~= "i)^(Page Down)")
                {
                   if (editingField=3)
                      backTyped := typed
                   editingField := (editingField>=3) ? 3 : editingField+1
                   typed := (editingField=3) ? backTyped : editField%editingField%
                }

                CaretPos := (typed=" ") ? StrLen(typed) : StrLen(typed)+1
                typed := ST_Insert(lola, typed, 0)
            }

            if (enableTypingHistory=0) && (pgUDasHE=1)
            {
                if (key ~= "i)^(Page up)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := 1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := 3
                }

                if (key ~= "i)^(Page down)")
                {
                   StringReplace, typed, typed, %lola%
                   StringReplace, typed, typed, %lola2%
                   CaretPos := StrLen(typed)+1
                   typed := ST_Insert(lola, typed, CaretPos)
                   maxTextChars := StrLen(typed)+2
                }
            }
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed && !((key ~= "i)^(.?Shift \+)")) || !typed || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50))) || (keyCount>10) && (OnlyTypingMode=0)
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) || prefixed && !((key ~= "i)^(.?Shift \+)"))
           typed := (OnlyTypingMode=1) ? typed : ""

        if (StrLen(typed)>1) && (DisableTypingMode=0) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (keyCount<10)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }
    shiftPressed := 0
    AltgrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnKeyPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try {
        backTyped2 := typed || (A_TickCount-lastTypedSince > DisplayTimeTyping) ? typed : backTyped2
        key := GetKeyStr()
        AltGrPressed := 0
        TypingFriendlyKeys := "i)^((.?shift \+ )?(Num|Caps|Scroll|Insert|Tab)|AppsKey|Volume |Media_|Wheel |◐|unknown)"
        
        if ((key ~= "i)(enter|esc)") && (DisableTypingMode=0) && (ShowSingleKey=1))
        {
            if (enterErasesLine=0) && (OnlyTypingMode=1)
               InsertChar2caret(" ")

            if (enterErasesLine=0) && (OnlyTypingMode=1) && (key ~= "i)(esc)")
               dontReturn := 1

            backTypedUndo := typed
            backTyped2 := ""

            if (strlen(typed)>4) && (enableTypingHistory=1)
            {
               StringReplace, typed, typed, %lola%
               StringReplace, typed, typed, %lola2%
               editField1 := editField2
               editField2 := typed
               editingField := 3
            }
            if (enterErasesLine=1)
               typed := ""
        }

        AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr .?|.?ctrl \+ (alt|altgr) \+ )|^(altgr \(spe)"
        if (!(key ~= TypingFriendlyKeys)) && (DisableTypingMode=0)
        {
           if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1)
           {
             test := SubStr(key, InStr(key, "+", 0, 0)+2)
             if (!test) || InStr(key, "special key")
                AltGrPressed := 1
           }
           backTyped := !typed && (AltGrPressed=1) && (enableAltGr=1) ? backTyped : typed
           typed := (OnlyTypingMode=1) ? typed : ""
        } else if ((key ~= "i)^((.?Shift \+ )?Tab)") && typed && (DisableTypingMode=0))
        {
            InsertChar2caret(" ")
        }
        ShowHotkey(key)
        SetTimer, HideGUI, % -DisplayTime
        if (StrLen(typed)>1) && (dontReturn!=1)
           SetTimer, returnToTyped, % -DisplayTime/4.5
    }

    if (VisualMouseClicks=1)
    {
       mkey := SubStr(A_ThisHotkey, 3)
       if InStr(mkey, "wheel")
          SetTimer, visualMouseClicksDummy, 10, -10
    }

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20

}

visualMouseClicksDummy() {
    Thread, priority, -10
    mkey := SubStr(A_ThisHotkey, 3)
    ShowMouseClick(mkey)
    SetTimer, , off
}

OnLetterPressed() {
    Thread, priority, 40

    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.25) && strlen(typed)<3 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && strlen(typed)>4
       InsertChar2caret(" ")

    try {
        if (DeadKeys=1 && (A_TickCount-deadKeyPressed < 1100))      ; this delay helps with dead keys, but it generates errors; the following actions: stringleft,1 and stringlower help correct these
        {
            sleep, 80
        } else if (typed && DeadKeys=1)
        {
            sleep, 20
        }

        if (typed && DeadKeys=1 && NoBindedDeadKeys=1)
            sleep, 100

        AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr \(spe)"
        key := GetKeyStr(1)     ; consider it a letter

        if (prefixed || DisableTypingMode=1)
        {
            if (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) || ((AltGrPressed=1) && (DisableTypingMode=0) && (StrLen(key)<2) && (ShowSingleKey=1) && (StickyKeys=1)) && (enableAltGr=1)
            {
               typed := (enableAltGr=1) ? TypedLetter(A_ThisHotkey) : ""
               if ((StrLen(typed)>2) && (OnlyTypingMode=0)) || ((StrLen(typed)>2) && (OnlyTypingMode=1))
               {
                  ShowHotkey(visibleTextField)
                  SetTimer, HideGUI, % -DisplayTimeTyping
               } else
               {
                  typed := (key ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) ? typed : ""
                  ShowHotkey(key)
               }
            } else
            {
               typed := (OnlyTypingMode=1) ? typed : ""
               ShowHotkey(key)
            }

            if (ShowSingleKey=1) && (DisableTypingMode=0)
            {
                if (key ~= "i)^(.?Shift \+ ((.)$|(.)[\r\n \,]))")
                {
                   TypedLetter(A_ThisHotkey)
                   ShowHotkey(visibleTextField)
                }
            }
            SetTimer, HideGUI, % -DisplayTime

        } else
        {

            TypedLetter(A_ThisHotkey)
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
            shiftPressed := 0
            AltGrPressed := 0
        }
    }
    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnCtrlAction() {
  if (StickyKeys=1)
     typed := backTyped2
  key := GetKeyStr()
  ShowHotkey(key)
  SetTimer, HideGUI, % -DisplayTime

  if (StrLen(typed)>3)
     SetTimer, returnToTyped, 2
}

OnCtrlAup() {
  if (StickyKeys=1)
     typed := backTyped2
  if (ShowSingleKey=1) && (DisableTypingMode=0) && (StrLen(typed)>2)
  {
    lola := "│"
    lola2 := "║"
    StringReplace, typed, typed, %lola%
    StringReplace, typed, typed, %lola2%
    CaretPos := StrLen(typed)+1
    typed := ST_Insert(lola2, typed, CaretPos)
    CaretPos := 1
    typed := ST_Insert(lola, typed, CaretPos)
    CalcVisibleText()
  }

  if (KeyBeeper = 1)
     keysBeeper()

  if (StrLen(typed)>3)
  {
     global lastTypedSince := A_TickCount
     SetTimer, returnToTyped, 2
  } else
  {
    SetTimer, HideGUI, % -DisplayTime
  }
}

OnCtrlRLeft() {
  key := GetKeyStr()
  if (StickyKeys=1)
     typed := backTyped2

  if (StrLen(typed)<3)
  {
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  } else
  {
      if ((key ~= "i)^(.?Ctrl \+ Left)"))
         caretJumper(0)

      if ((key ~= "i)^(.?Ctrl \+ Right)"))
         caretJumper(1)

      if ((key ~= "i)^(.?Ctrl \+ .?Shift \+ Left)"))
         caretJumpSelector(0)

      if ((key ~= "i)^(.?Ctrl \+ .?Shift \+ Right)"))
         caretJumpSelector(1)

      CalcVisibleText()

      global lastTypedSince := A_TickCount
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTime
  }
}

OnCtrlDelBack() {
  key := GetKeyStr()
  if (StickyKeys=1)
     typed := backTyped2

  if (StrLen(typed)<3)
  {
      ShowHotkey(key)
      SetTimer, HideGUI, % -DisplayTime
  } else
  {
      backTypedUndo := typed
      lola := "│"
      StringGetPos, CaretzoiPos, typed, %lola%

      if ((key ~= "i)^(.?Ctrl \+ Backspace)"))
      {
         caretJumper(0)
         if (CaretzoiPos >= strlen(typed)-1)
         {
            typed := typed "zzz"
            removeEnd := 3
         }
         StringGetPos, CaretzoaiaPos, typed, %lola%
         typed := st_delete(typed, CaretzoaiaPos+1, CaretzoiPos - CaretzoaiaPos+1)
         if (removeEnd>1)
             StringTrimRight, typed, typed, 3

         if (st_count(typed, lola)<1)
            typed := ST_Insert(lola, typed, CaretzoaiaPos+1)
      }

      if ((key ~= "i)^(.?Ctrl \+ Delete)"))
      {
         caretJumper(1)
         StringGetPos, CaretzoaiaPos, typed, %lola%
         typed := st_delete(typed, CaretzoiPos+1, CaretzoaiaPos - CaretzoiPos)
         if (st_count(typed, lola)<1)
            typed := ST_Insert(lola, typed, CaretzoaiaPos)
      }

      CalcVisibleText()

      global lastTypedSince := A_TickCount
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTime
  }
}

OnCtrlVup() {
  if (StickyKeys=1)
     typed := backTyped2
  toPaste := Clipboard
  if (ShowSingleKey=1) && (DisableTypingMode=0) && (StrLen(toPaste)>0)
  {
    backTypedUndo := typed
    Stringleft, toPaste, toPaste, 950
    StringReplace, toPaste, toPaste, `r`n, %A_SPACE%, All
    InsertChar2caret(toPaste)
    CaretPos := CaretPos + StrLen(toPaste)
    maxTextChars := StrLen(typed)+2
    CalcVisibleText()
    ShowHotkey(visibleTextField)
  }

  if (KeyBeeper = 1)
     keysBeeper()

  if (StrLen(typed)>3)
  {
     global lastTypedSince := A_TickCount
     SetTimer, returnToTyped, 2
  } else
  {
    SetTimer, HideGUI, % -DisplayTime
  }
}

OnCtrlXup() {
  if (StickyKeys=1)
     typed := backTyped2
  lola2 := "║"

  if (StrLen(typed)>3)
  {
     if (ShowSingleKey=1) && (DisableTypingMode=0) && (st_count(typed, lola2)>0)
     {
        replaceSelection()
        CalcVisibleText()
     }
     ShowHotkey(visibleTextField)
     global lastTypedSince := A_TickCount
     SetTimer, returnToTyped, 2
  } else
  {
    SetTimer, HideGUI, % -DisplayTime
  }
  if (KeyBeeper = 1)
     keysBeeper()
}

OnCtrlZup() {
  if (StickyKeys=1)
     typed := backTyped2

  if (StrLen(typed)>0) && (ShowSingleKey=1) && (DisableTypingMode=0)
  {
      blahBlah := typed
      typed := (strLen(backTypedUndo)>1) ? backTypedUndo : typed
      backTypedUndo := (strlen(blahBlah)>1) ? blahBlah : backTypedUndo
      CalcVisibleText()
      ShowHotkey(visibleTextField)
      SetTimer, HideGUI, % -DisplayTimeTyping
  }

  if (KeyBeeper = 1)
     keysBeeper()

  if (StrLen(typed)>2)
  {
     global lastTypedSince := A_TickCount
     SetTimer, returnToTyped, 2
  } else
  {
    SetTimer, HideGUI, % -DisplayTime
  }
}

OnSpacePressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    try {
          key := GetKeyStr()
          if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1)
          {
             if (typed ~= "i)(▫│)$")
             {
                typed := SubStr(typed, 1, StrLen(typed) - 2)
                InsertChar2caret("▪")
             } else
             {
                InsertChar2caret(" ")
             }
             deadKeyProcessing()
             ShowHotkey(visibleTextField)
             SetTimer, HideGUI, % -DisplayTimeTyping
          }

          if (prefixed || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
          {
             if (StrLen(typed)<2)
                typed := (OnlyTypingMode=1) ? typed : ""
             ShowHotkey(key)
             SetTimer, HideGUI, % -DisplayTime
          }

          if (DisableTypingMode=1) || (prefixed && !(key ~= "i)^(.?Shift \+ )"))
             typed := (OnlyTypingMode=1) ? typed : ""
    }

    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnBspPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20

    try
    {
        key := GetKeyStr()
        dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (CaretPos = 2000) && (keyCount>10) && (OnlyTypingMode=0) ? 1 : 0
        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (dropOut=0)
        {
            lola := "│"
            lola2 := "║"

            if (st_count(typed, lola2)>0)
            {
               replaceSelection()
               CalcVisibleText()
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }

            deadKeyProcessing()
            StringGetPos, CaretPos, typed, % lola
            CaretPos := (CaretPos < 1) ? 2000 : CaretPos
            if (CaretPos = 2000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }

            global lastTypedSince := A_TickCount
            typedLength := StrLen(typed)
            CaretPosy := (CaretPos = typedLength) ? 0 : CaretPos
            typed := (caretpos<1) ? typed : st_delete(typed, CaretPosy, 1)
            if InStr(typed, "▫" lola)
            {
               StringGetPos, CaretPos, typed, % lola
               CaretPos := (CaretPos < 1) ? 2000 : CaretPos
               CaretPosy := (CaretPos = typedLength) ? CaretPos-1 : CaretPos
               typed := st_delete(typed, CaretPosy, 1) = typed ? SubStr(typed, 1, StrLen(typed) - 1) : st_delete(typed, CaretPosy, 1)
            }
            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }

        if (prefixed || (dropOut=1) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) ||  (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0

}

OnDelPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20

    try
    {
        key := GetKeyStr()
        dropOut := (A_TickCount-lastTypedSince > DisplayTimeTyping/2) && (CaretPos = 3000) && (keyCount>10) && (OnlyTypingMode=0) ? 1 : 0

        if (A_TickCount-lastTypedSince < ReturnToTypingDelay) && strlen(typed)>1 && (DisableTypingMode=0) && (ShowSingleKey=1) && (dropOut=0)
        {
            lola := "│"
            lola2 := "║"

            if (st_count(typed, lola2)>0)
            {
               replaceSelection()
               CalcVisibleText()
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTimeTyping
               Return
            }

            deadKeyProcessing()
            if (CaretPos = 3000)
            {
               ShowHotkey(visibleTextField)
               SetTimer, HideGUI, % -DisplayTime*2
               Return
            }

            StringGetPos, CaretPos, typed, % lola

            if (CaretPos >= StrLen(typed)-2 )
               endReached := 1

            if InStr(typed, lola "▫")
               deleteNext := 1

            if (endReached!=1) && InStr(typed, lola)
            {
               global lastTypedSince := A_TickCount
               typed := st_delete(typed, CaretPos+2, 1)
               StringGetPos, CaretPos, typed, % lola
               CaretPos := CaretPos+1
            } else if (CaretPos!=3000)
            {
               StringGetPos, CaretPos, typed, % lola
               if (CaretPos > StrLen(typed)-2 ) 
                  endNow := 1

               CaretPos := 3000
               
               if (endNow!=1)
                   typed := st_delete(typed, CaretPos+1, 1) = typed ? st_delete(typed, 0, 1) : st_delete(typed, CaretPos+1, 1)
            }

            if (deleteNext=1)
            {
               StringGetPos, CaretPos, typed, % lola
               l2 := StrLen(typed)
               typed := st_delete(typed, CaretPos+2, 1)
               l2b := StrLen(typed)
               if (l2b = l2)
                  typed := st_delete(typed, 0, 1)

               CaretPos := CaretPos+1
            }

            CalcVisibleText()
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
        if (prefixed || (dropOut=1) || strlen(typed)<2 || (A_TickCount-lastTypedSince > (ReturnToTypingDelay+50)))
        {
           if (keyCount>10) && (OnlyTypingMode=0)
              global lastTypedSince := A_TickCount - ReturnToTypingDelay
           if (StrLen(typed)<2)
              typed := (OnlyTypingMode=1) ? typed : ""
           ShowHotkey(key)
           SetTimer, HideGUI, % -DisplayTime
        }

        if (DisableTypingMode=1) ||  (prefixed && !(key ~= "i)^(.?Shift \+ )"))
           typed := (OnlyTypingMode=1) ? typed : ""
    }
    shiftPressed := 0
    AltGrPressed := 0

}

OnNumpadsPressed() {
    Thread, priority, 30
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.25) && strlen(typed)<3 && (OnlyTypingMode=0)
       typed := ""

    if (A_TickCount-lastTypedSince > ReturnToTypingDelay*1.75) && strlen(typed)>4
       InsertChar2caret(" ")

    try {
        key := GetKeyStr(1)     ; consider it a letter
        if ((prefixed && !(key ~= "i)^(.?Shift \+ )")) || DisableTypingMode=1)
        {
            typed := (OnlyTypingMode=1) ? typed : ""
            ShowHotkey(key)
            SetTimer, HideGUI, % -DisplayTime
        } else if (ShowSingleKey=1)
        {
            key := SubStr(key, 3, 1)
            InsertChar2caret(key)
            global lastTypedSince := A_TickCount
            ShowHotkey(visibleTextField)
            SetTimer, HideGUI, % -DisplayTimeTyping
        }
    }
    shiftPressed := 0
    AltGrPressed := 0

    if (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 2, -20
}

OnKeyUp() {
    Thread, priority, 10
    if (prioritizeBeepers=1)
    {
       Thread, priority, 100
       Critical, on
    }

    global tickcount_start := A_TickCount

    shiftPressed := 0
    AltGrPressed := 0
    SetTimer, capsHighlightDummy, 100, -20

    GetKeyState, CapsState, CapsLock, T

    if typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
    {
        If CapsState = D
           {
               capsBeeper()
           }
           else if (KeyBeeper = 1) && (ShowSingleKey = 1)
           {
               keysBeeper()
           }
    }

    If (CapslockBeeper = 0) && (KeyBeeper = 1) && (ShowSingleKey = 1)
       {
           keysBeeper()
       }
       else if (CapslockBeeper = 1) && (KeyBeeper = 0)
       {
           Return
       }
       else if !typed && (CapslockBeeper = 1) && (ShowSingleKey = 1)
       {
           keysBeeper()
       }

    if (BeepHiddenKeys = 1) && (KeyBeeper = 1) && (ShowSingleKey = 0)
       keysBeeper()
}

capsHighlightDummy() {

    GetKeyState, CapsState, CapsLock, T
    If CapsState = D
       GuiControl, OSD:, CapsDummy, 100

    If CapsState != D
       GuiControl, OSD:, CapsDummy, 0

    SetTimer,, off
}

capsBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-caps%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, capsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 450, 120
}

capsBeeperTimer() {
   soundbeep, 450, 120
   SetTimer, , off
}

keysBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-keys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, keysBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1900, 45
}

keysBeeperTimer() {
   soundbeep, 1900, 45
   SetTimer, , off
}

volBeeperTimer() {
   Thread, priority, -10
   soundbeep, 150, 40
   SetTimer, , off
}

deadKeysBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-deadkeys%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, deadKeysBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 600, 40
}

deadKeysBeeperTimer() {
   soundbeep, 600, 40
   SetTimer, , off
}

modsBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-mods%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, modsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1000, 65
}

modsBeeperTimer() {
   soundbeep, 1000, 65
   SetTimer, , off
}

shiftBeeperTimer() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-mods%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, modsBeeperTimer, 15, -20

   if (ErrorLevel=1) && (prioritizeBeepers=1)
      soundbeep, 1000, 65

   SetTimer, , off
}

clickyBeeper() {
   if (prioritizeBeepers=0)
   {
      Thread, Priority, -20
      Critical, off
   }

   SoundPlay, sound-clicks%LowVolBeeps%.wav, %prioritizeBeepers%
   if (ErrorLevel=1) && (prioritizeBeepers=0)
      SetTimer, clickyBeeperTimer, 15, -20

    if (ErrorLevel=1) && (prioritizeBeepers=1)
       soundbeep, 2500, 70
}

clickyBeeperTimer() {
   soundbeep, 2500, 70
   SetTimer, , off
}

firedBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   SoundPlay, sound-firedkey%LowVolBeeps%.wav
   if (ErrorLevel=1)
      soundbeep, 500, 25

   SetTimer, , off
}

OnModPressed() {
    Thread, priority, 10
    Critical, on

    if (A_TickCount-tickcount_start2 < 40) || (A_TickCount-lastTypedSince < 35)
       Return

    static modifierz := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    static repeatCount := 1

    for i, mod in modifierz
    {
        if GetKeyState(mod)
           fl_prefix .= mod " + "
    }

    if GetKeyState("Shift")
    {
       shiftPressed := 1

       If (StrLen(typed)>1) && (DisableTypingMode=0)
          GuiControl, OSD:, CapsDummy, 60

       if (ShowKeyCountFired=0) && (ShowKeyCount=1) && (A_TickCount-tickcount_start2 > 150)
          repeatCount := (A_TickCount-tickcount_start2 > 5) ? repeatCount+1 : repeatCount

       if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) && (A_TickCount-tickcount_start2 > 150) || (ModBeeper = 1) && (BeepHiddenKeys = 1) && (A_TickCount-tickcount_start2 > 150)
          SetTimer, shiftBeeperTimer, 15, -10

       if (ModBeeper = 0) && (beepFiringKeys = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) && (A_TickCount-tickcount_start2 > 150) || (BeepHiddenKeys = 1) && (A_TickCount-tickcount_start2 > 150)
          SetTimer, firedBeeperTimer, 15, -10

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }

    if (StickyKeys=0)
       fl_prefix := RTrim(fl_prefix, "+ ")

    fl_prefix := CompactModifiers(fl_prefix)

    keya := A_ThisHotkey

    if !fl_prefix
    {
       if instr(keya, "RCtrl")
       {
          fl_prefix := "AltGr (special key)"
       } else if keya
       {
          fl_prefix := keya
       } Else
       {
         fl_prefix := "Unknown key"
       }
       keyCount := 0.1
       shiftPressed := 0
       AltGrPressed := 1
    }

    if InStr(fl_prefix, modifiers_temp)
    {
        valid_count := 1
        if (repeatCount>1)
           keyCount := 0.1
    } else
    {
        valid_count := 0
        modifiers_temp := fl_prefix
        if (StickyKeys=0 && !prefixed)
           keyCount := 0.1
    }

    if (valid_count=1) && (ShowKeyCountFired=0) && (ShowKeyCount=1) && !InStr(fl_prefix, "AltGr")
    {
       trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
       repeatCount := (trackingPresses=0 && repeatCount<2) ? repeatCount+1 : repeatCount
       if (trackingPresses=1)
          repeatCount := !repeatCount ? 1 : repeatCount+1
       ShowKeyCountValid := 1
    } else if (valid_count=1) && (ShowKeyCountFired=1) && (ShowKeyCount=1)
    {
       repeatCount := !repeatCount ? 0 : repeatCount+1
       if InStr(fl_prefix, "AltGr") && repeatCount>3
          repeatCount := repeatCount-1+0.49
       ShowKeyCountValid := 1
    } else
    {
       repeatCount := 1
       ShowKeyCountValid := 0
    }

    if (ShowKeyCountValid=1) && (StickyKeys=0)
    {
        if !InStr(fl_prefix, "+") {
            modifiers_temp := fl_prefix
            fl_prefix .= " (" round(repeatCount) ")"
        } else
        {
            repeatCount := 1
        }
   }

   AltGrMatcher := "i)^((.?ctrl \+ )?(AltGr|.?Ctrl \+ Alt) \+ (.?shift \+ )?((.)$|(.)[\r\n \,]))|^(altgr|.?ctrl \+ (alt|altgr))|^(altgr \(spe)|^(.?ctrl)"
   if (fl_prefix ~= AltGrMatcher) && (DisableTypingMode=0) && (enableAltGr=1) && (StickyKeys=0) && (strLen(typed)>2)
      backTyped := !typed ? backTyped : typed

   if ((strLen(typed)>1) && (fl_prefix ~= "i)^(.?Shift.?.?.?)$") && (visible=1) && (A_TickCount-lastTypedSince < DisplayTimeTyping)) || (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && visible && !typed && keycount>7) || (OnlyTypingMode=1)
   {
      sleep, 10
   } else
   {
      if (ShowSingleModifierKey=1)
      {
         ShowHotkey(fl_prefix)
         SetTimer, HideGUI, % -DisplayTime/2
      }
      if !InStr(fl_prefix, " + ")
         SetTimer, returnToTyped, % -DisplayTime/4.5
   }

   if (beepFiringKeys=1) && (StickyKeys=0)
      SetTimer, firedBeeperTimer, 2, -20

}

OnModUp() {
    Thread, priority, 10
    if (prioritizeBeepers=1)
    {
       Thread, priority, 100
       Critical, on
    }

    global tickcount_start := A_TickCount

    if (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
       modsBeeper()

    if (StickyKeys=0) && StrLen(typed)>1
       SetTimer, returnToTyped, % -DisplayTime/4.5
}

OnDeadKeyPressed() {
  Thread, priority, 10
  Critical, on
  global deadKeyPressed := A_TickCount
  RmDkSymbol := "▪"
  TrueRmDkSymbol := A_ThisHotkey
  if inStr(A_ThisHotkey, "sc0")
     TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  RmDkSymbol := TrueRmDkSymbol

  if (autoRemDeadKey=1)
     RmDkSymbol := "▫"

  if ((ShowDeadKeys=1) && typed && (DisableTypingMode=0) && (ShowSingleKey=1))
  {
       if (typed ~= "i)(▫│)")
       {
           InsertChar2caret("▪")
       } else
       {
           InsertChar2caret(RmDkSymbol)
       }
  }

  if ((autoRemDeadKey=1) && (StrLen(typed)>1) && (DisableTypingMode=0)) || ((ShowDeadKeys=0) && (StrLen(typed)>1) && (DisableTypingMode=0))
  {
     lola := "│"
     StringReplace, visibleTextField, visibleTextField, % lola, % TrueRmDkSymbol
     ShowHotkey(visibleTextField)
     CalcVisibleText()
  }
  SetTimer, returnToTyped, 800, -10

  shiftPressed := 0
  AltGrPressed := 0
  keyCount := 0.1

  if (StrLen(typed)<3)
  {
     if (ShowDeadKeys=1) && (DisableTypingMode=0)
        InsertChar2caret(RmDkSymbol)

     if (A_ThisHotkey ~= "i)^(~\+)")
     {
        TrueRmDkSymbol := "Shift + " TrueRmDkSymbol
        ShowHotkey(TrueRmDkSymbol " [dead key]")
     } else if (ShowSingleKey=1)
     {
        ShowHotkey(TrueRmDkSymbol " [dead key]")
     }
     SetTimer, HideGUI, % -DisplayTime
  }

  if (deadKeyBeeper = 1) && (ShowSingleKey = 1) || (deadKeyBeeper = 1) && (BeepHiddenKeys = 1)
     deadKeysBeeper()
}

deadKeyProcessing() {
  Thread, priority, 10
  if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
     Critical, on

  if (ShowDeadKeys=0) || (DisableTypingMode=1) || (autoRemDeadKey=0) || (ShowSingleKey=0) || (DeadKeys=0)
     Return

  Loop, 5
  {
    deadkeyPosition := RegExMatch(typed, "▫[^[:alpha:]]")
    nextChar := SubStr(typed, deadkeyPosition+1, 1)

    if (nextChar!="▫") && (deadkeyPosition>=1)
       typed := st_overwrite("▪", typed, deadkeyPosition)
  }
}

OnAltGrDeadKeyPressed() {
  Thread, priority, 10
  Critical, on
  
  global deadKeyPressed := A_TickCount

  RmDkSymbol := "▪"
  TrueRmDkSymbol := A_ThisHotkey
  if inStr(A_ThisHotkey, "sc0")
     TrueRmDkSymbol := GetDeadKeySymbol(A_ThisHotkey)
  StringRight, TrueRmDkSymbol, TrueRmDkSymbol, 1
  RmDkSymbol := TrueRmDkSymbol

  if (autoRemDeadKey=1)
     RmDkSymbol := "▫"

  if (DisableTypingMode=0) && (ShowSingleKey=1)
     typed := backTyped

  if (ShowDeadKeys=1) && (DisableTypingMode=0) && (ShowSingleKey=1)
  {
       typed := backTyped
       global lastTypedSince := A_TickCount
       if (typed ~= "i)(▫│)")
       {
           InsertChar2caret("▪")
       } else
       {
           InsertChar2caret(RmDkSymbol)
       }
       SetTimer, returnToTyped, 800, -10
  }

  AltGrPressed := 0
  shiftPressed := 0
  keyCount := 0.1

  if ((StrLen(typed)>2) && (ShowDeadKeys=0) && (DisableTypingMode=0)) || ((autoRemDeadKey=1) && (StrLen(typed)>2) && (ShowDeadKeys=1) && (DisableTypingMode=0))
  {
     lola := "│"
     StringReplace, visibleTextField, visibleTextField, % lola, % TrueRmDkSymbol
     ShowHotkey(visibleTextField)
     CalcVisibleText()
     SetTimer, returnToTyped, 800, -10
  }

  if (autoRemDeadKey=0) && (StrLen(typed)>2) && (ShowDeadKeys=1)
     SetTimer, returnToTyped, 90, -10

  if (StrLen(typed)<3)
  {
     if (A_ThisHotkey ~= "i)^(~\^!)")
        DeadKeyMods := "Ctrl + Alt + " TrueRmDkSymbol

     if (A_ThisHotkey ~= "i)^(~\+\^!)")
        DeadKeyMods := "Ctrl + Alt + Shift + " TrueRmDkSymbol

     if (A_ThisHotkey ~= "i)^(~<\^>!)")
        DeadKeyMods := "AltGr + " TrueRmDkSymbol

     ShowHotkey(DeadKeyMods " [dead key]")
     SetTimer, HideGUI, % -DisplayTime
  }

  if (deadKeyBeeper = 1) && (ShowSingleKey = 1) || (deadKeyBeeper = 1) && (BeepHiddenKeys = 1)
     deadKeysBeeper()
}

st_overwrite(overwrite, into, pos=1) {
   Thread, priority, 15
   if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
      Critical, on

  ; String Things - Common String & Array Functions, 2014
  ; function by tidbit https://autohotkey.com/board/topic/90972-string-things-common-text-and-array-functions/

   If (abs(pos) > StrLen(into))
      return into
   else If (pos>0)
      return substr(into, 1, pos-1) . overwrite . substr(into, pos+StrLen(overwrite))
   else If (pos<0)
      return SubStr(into, 1, pos) . overwrite . SubStr(into " ",(abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0),abs(pos+StrLen(overwrite)))
   else If (pos=0)
      return into . overwrite
}

returnToTyped() {
    if (StrLen(typed) > 2) && (keycount<10) && (A_TickCount-lastTypedSince < ReturnToTypingDelay) && (ShowSingleKey=1) && (DisableTypingMode=0) && !A_IsSuspended
    {
        ShowHotkey(visibleTextField)
        SetTimer, HideGUI, % -DisplayTime*2
    }
    SetTimer, , off
}

CreateOSDGUI() {
    global

    CapsDummy := 1
    Gui, OSD: destroy
    Gui, OSD: +AlwaysOnTop -Caption +Owner +LastFound +ToolWindow
    Gui, OSD: Margin, 20, 10
    Gui, OSD: Color, %OSDbgrColor%
    Gui, OSD: Font, c%OSDtextColor% s%FontSize% bold, %FontName%, -wrap

    if (OSDautosize=0)
    {
        widthDelimitator := FavorRightoLeft=1 ? 1.25 : 1.05+FontSize/450
        rightoleft := (GuiWidth > A_ScreenWidth - GuiX*1.1) ? 1 : 0
    } else
    {
        widthDelimitator := FavorRightoLeft=1 ? 1.85 : 1.4+FontSize/250
        rightoleft := (GuiX > A_ScreenWidth/widthDelimitator) ? 1 : 0
    }

    if (NeverRightoLeft=1)
       rightoleft := 0

    textAlign := "left"
    widtha := A_ScreenWidth - 50
    positionText := 10

    if ((rightoleft=1) && (NeverRightoLeft=0) && (OSDautosize=1)) || ((rightoleft=1) && (FavorRightoLeft=1))
    {
       textAlign := "right"
       positionText := -10
    }

    if (A_OSVersion!="WIN_XP")
       Gui, OSD: Add, Edit, -E0x200 x%positionText% -multi %textAlign% readonly -WantCtrlA -wrap w%widtha% vHotkeyText, %HotkeyText%

    if (A_OSVersion="WIN_XP")
       Gui, OSD: Add, Text, 0x80 w%widtha% vHotkeyText %textOrientation% %wrappy%

    if (OSDborder=1)
    {
        WinSet, Style, +0xC40000
        WinSet, Style, -0xC00000
        WinSet, Style, +0x800000   ; small border
    }
    progressHeight := FontSize*2.5 < 60 ? 60 : FontSize*2.5
    progressWidth := FontSize/2 < 11 ? 11 : FontSize/2
    Gui, OSD: Add, Progress, x0 y0 w%progressWidth% h%progressHeight% Background%OSDbgrColor% c%CapsColorHighlight% vCapsDummy, 0
}

CreateHotkey() {
    #MaxThreads 255
    #MaxThreadsPerHotkey 255
    #MaxThreadsBuffer On

    if (AutoDetectKBD=1)
       IdentifyKBDlayout()

    static mods_noShift := ["!", "!#", "!#^", "!#^+", "!+", "!+^", "!^", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    static mods_list := ["!", "!#", "!#^", "!#^+", "!+", "#", "#!", "#!+", "#!^", "#+^", "#^", "+#", "+^", "^"]
    megaDeadKeysList := DKaltGR_list "." DKshift_list "." DKnotShifted_list

; bind to the lisst of possible letters/chars
    Loop, 256
    {
        k := A_Index
        code := Format("{:x}", k)

        n := GetKeyName("vk" code)

        if (n = "")
           n := GetKeyChar("vk" code)

        if (n = " ") || (n = "") || (StrLen(n)>1)
           continue

        if (DeadKeys=1)
        {
          for each, char2skip in StrSplit(megaDeadKeysList, ".")        ; dead keys to ignore
          {
            if (InStr(char2skip, "vk" code) || (n = char2skip))
              continue, 2
          }
        }
 
        if (IgnoreAdditionalKeys=1)
        {
          for each, char2skip in StrSplit(IgnorekeysList, ".")        ; dead keys to ignore
          {
            if ((n = char2skip) && (IgnoreAdditionalKeys=1))
               continue, 2
          }
        }
 
        Hotkey, % "~*vk" code, OnLetterPressed, useErrorLevel
        Hotkey, % "~*vk" code " Up", OnKeyUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

; bind to dead keys to show the proper symbol when such a key is pressed

    if (DeadKeys=1) && (NoBindedDeadKeys=0)
    {
        Loop, parse, DKaltGR_list, .
        {
            for i, mod in mods_list
            {
                if (enableAltGr=1)
                {
                  Hotkey, % "~^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField, OnAltGrDeadKeyPressed, useErrorLevel
                }

                if (enableAltGr=0)
                {
                  Hotkey, % "~^!" A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~^!" A_LoopField " Up", OnKeyUp, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField , OnLetterPressed, useErrorLevel
                  Hotkey, % "~+^!" A_LoopField " Up", OnKeyUp, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField , OnLetterPressed, useErrorLevel
                  Hotkey, % "~<^>!" A_LoopField " Up", OnKeyUp, useErrorLevel
                }

                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKshift_list, A_LoopField)
                {
                   Hotkey, % "~+" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnKeyUp, useErrorLevel
                }

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnKeyUp, useErrorLevel
                }
            }
        }

        Loop, parse, DKshift_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~+" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKnotShifted_list, A_LoopField)
                {
                   Hotkey, % "~" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~" A_LoopField " Up", OnKeyUp, useErrorLevel
                }

            }
        }

        Loop, parse, DKnotShifted_list, .
        {
            for i, mod in mods_list
            {
                Hotkey, % "~" A_LoopField, OnDeadKeyPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel

                if !InStr(DKShift_list, A_LoopField)
                {
                   Hotkey, % "~+$" A_LoopField, OnLetterPressed, useErrorLevel
                   Hotkey, % "~+" A_LoopField " Up", OnKeyUp, useErrorLevel
                }
            }
        }

        ShiftRelatedDKlist := DKshift_list "." DKnotShifted_list

        Loop, parse, ShiftRelatedDKlist, .
        {
            for i, mod in mods_noShift
            {
               if !InStr(DKaltGR_list, A_LoopField) && (enableAltGr=1)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel
               }

               if (enableAltGr=0)
               {
                  Hotkey, % "~" mod A_LoopField, OnLetterPressed, useErrorLevel
                  Hotkey, % "~" mod A_LoopField " Up", OnKeyUp, useErrorLevel
               }
            }
        }
    }  ; dead keys parser

; bind the AltGr dead keys when AltGr support is not enabled

    if (enableAltGr=0) && (NoBindedDeadKeys=1)
    {
        ShiftRelatedDKlist := DKshift_list "." DKnotShifted_list

        Loop, parse, DKaltGR_list, .
        {
           if !InStr(ShiftRelatedDKlist, A_LoopField)
           {
              Hotkey, % "~*" A_LoopField, OnLetterPressed, useErrorLevel
              Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
              if (errorlevel!=0) && (audioAlerts=1)
                 soundbeep, 1900, 50
           }
        }
    }

; get dead key symbols

    if (DeadKeys=1) && (NoBindedDeadKeys=0)
    {
       StickyKeys := 1
   /*
       Loop, parse, DKnotShifted_list, .
       {
               backupSymbol := SubStr(A_LoopField, InStr(A_LoopField, "sc"), 9)
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc)
               {
                  SCnames2 .= toUnicodeExtended(vk, sc) "~" A_LoopField
               } else if GetKeyName(backupSymbol)
               {
                  SCnames2 .= GetKeyName(backupSymbol) "~" A_LoopField
               }
       }
   */
       Loop, parse, DKShift_list, .
       {
               shiftPressed := 1
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc)
                  SCnames2 .= toUnicodeExtended(vk, sc) "~+" A_LoopField
               shiftPressed := 0
       }
       Loop, parse, DKaltGR_list, .
       {
               AltGrPressed := 1
               vk := "0x0" SubStr(A_LoopField, InStr(A_LoopField, "vk", 0, 0)+2)
               sc := "0x0" GetKeySc("vk" vk)
               if toUnicodeExtended(vk, sc)
               {
                  SCnames2 .= toUnicodeExtended(vk, sc) "~^!" A_LoopField
                  SCnames2 .= toUnicodeExtended(vk, sc) "~+^!" A_LoopField
                  SCnames2 .= toUnicodeExtended(vk, sc) "~<^>!" A_LoopField
               }
               AltGrPressed := 0
       }
       IniRead, StickyKeys, %inifile%, SavedSettings, StickyKeys, %StickyKeys%
    }

    Hotkey, ~*Left, OnRLeftPressed, useErrorLevel
    Hotkey, ~*Left Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Right, OnRLeftPressed, useErrorLevel
    Hotkey, ~*Right Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Up, OnUpDownPressed, useErrorLevel
    Hotkey, ~*Up Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Down, OnUpDownPressed, useErrorLevel
    Hotkey, ~*Down Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Home, OnHomeEndPressed, useErrorLevel
    Hotkey, ~*Home Up, OnKeyUp, useErrorLevel
    Hotkey, ~*End, OnHomeEndPressed, useErrorLevel
    Hotkey, ~*End Up, OnKeyUp, useErrorLevel
    Hotkey, ~*PgUp, OnPGupDnPressed, useErrorLevel
    Hotkey, ~*PgUp Up, OnKeyUp, useErrorLevel
    Hotkey, ~*PgDn, OnPGupDnPressed, useErrorLevel
    Hotkey, ~*PgDn Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Del, OnDelPressed, useErrorLevel
    Hotkey, ~*Del Up, OnKeyUp, useErrorLevel
    Hotkey, ~*BackSpace, OnBspPressed, useErrorLevel
    Hotkey, ~*BackSpace Up, OnKeyUp, useErrorLevel
    Hotkey, ~*Space, OnSpacePressed, useErrorLevel
    Hotkey, ~*Space Up, OnKeyUp, useErrorLevel

    if (DisableTypingMode=0)
    {
       Hotkey, ~^vk41, OnCtrlAction, useErrorLevel
       Hotkey, ~^vk41 Up, OnCtrlAup, useErrorLevel
       Hotkey, ~^vk43, OnCtrlAction, useErrorLevel   ; ctrl+c
       Hotkey, ~^vk56, OnCtrlAction, useErrorLevel
       Hotkey, ~^vk56 Up, OnCtrlVup, useErrorLevel
       Hotkey, ~^vk58, OnCtrlAction, useErrorLevel
       Hotkey, ~^vk58 Up, OnCtrlXup, useErrorLevel
       Hotkey, ~^vk5A, OnCtrlAction, useErrorLevel
       Hotkey, ~^vk5A Up, OnCtrlZup, useErrorLevel

       Hotkey, ~^BackSpace, OnCtrlDelBack, useErrorLevel
       Hotkey, ~^Del, OnCtrlDelBack, useErrorLevel
       Hotkey, ~^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, ~^Right, OnCtrlRLeft, useErrorLevel
       Hotkey, ~+^Left, OnCtrlRLeft, useErrorLevel
       Hotkey, ~+^Right, OnCtrlRLeft, useErrorLevel
    }

    if (OnlyTypingMode!=1)
    {
      Loop, 24 ; F1-F24
      {
          Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
          Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
          if (errorlevel!=0) && (audioAlerts=1)
             soundbeep, 1900, 50
      }
    }

    NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
    Loop, parse, NumpadKeysList, |
    {
       Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          soundbeep, 1900, 50
    }

    Loop, 10 ; Numpad0 - Numpad9 ; numlock on
    {
        Hotkey, % "~*Numpad" A_Index - 1, OnNumpadsPressed, UseErrorLevel
        Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"

    Loop, parse, NumpadSymbols, |
    {
       Hotkey, % "~*" A_LoopField, OnNumpadsPressed, useErrorLevel
       Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
       if (errorlevel!=0) && (audioAlerts=1)
          soundbeep, 1900, 50
    }

    Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
               . "|Insert|CapsLock|ScrollLock|NumLock|Pause|sc146|sc123|sc11dvkDF"
    Loop, parse, Otherkeys, |
    {
        Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
        Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    if (ShowMouseButton=1) || (visualMouseClicks=1)
    {
        Loop, Parse, % "LButton|MButton|RButton", |
        Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
        if (errorlevel!=0) && (audioAlerts=1)
           soundbeep, 1900, 50
    }

    If (StickyKeys=0)
    {
        for i, mod in ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        {
           Hotkey, % "~*" mod, OnModPressed, useErrorLevel
           Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
           if (errorlevel!=0) && (audioAlerts=1)
              soundbeep, 1900, 50
        }
    }

    if (StickyKeys=1)
    {
        for i, mod in ["LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        {
            Hotkey, % "~*" mod, OnKeyPressed, useErrorLevel
            Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
            if (errorlevel!=0) && (audioAlerts=1)
               soundbeep, 1900, 50
        }

        for i, mod in ["LShift", "RShift"]
        {
            Hotkey, % "~*" mod, OnModPressed, useErrorLevel
            Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
            if (errorlevel!=0) && (audioAlerts=1)
               soundbeep, 1900, 50
        }
    }
}

ShowHotkey(HotkeyStr) {
    Thread, Priority, 50
    Critical, on

    global tickcount_start2 := A_TickCount

    if (HotkeyStr ~= "i)( \+ )$") && !typed && ShowSingleModifierKey=0 && StickyKeys=1 || (NeverDisplayOSD=1) ; || (OnlyTypingMode=1)
       Return

    if (HotkeyStr ~= "i)(Shift \+ )$") && (ShowSingleModifierKey=0) && (StickyKeys=1)
       Return

    if (HotkeyStr ~= "i)( \+ )") && !(typed ~= "i)( \+ )") && (OnlyTypingMode=1)
       Return

    if (OSDautosize=1)
    {
        growthIncrement := (FontSize/2)*(OSDautosizeFactory/150)
        startPoint := GetTextExtentPoint(HotkeyStr, FontName, FontSize, bBold) / (OSDautosizeFactory/100) + 30
        if (startPoint > text_width+growthIncrement) || (startPoint < text_width-growthIncrement)
           text_width := startPoint
        text_width := (text_width > maxAllowedGuiWidth) || (text_width > maxAllowedGuiWidth-growthIncrement*2) ? maxAllowedGuiWidth : text_width

    } else if (OSDautosize=0)
    {
        text_width := maxAllowedGuiWidth
    }

    dGuiX := GuiX

    GuiControl, OSD: , HotkeyText, %HotkeyStr%

    if (rightoleft=1)
    {
        GuiGetSize(W, H, 1)
        dGuiX := w ? GuiX - w : GuiX
        GuiControl, OSD: Move, HotkeyText, w%text_width% Left
    }

    SetTimer, checkMousePresence, on, 400, -5
    Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%text_width%, KeypressOSD

    if (rightoleft=1)
    {
        GuiGetSize(W, H, 1)
        dGuiX := w ? GuiX - w : GuiX
        Gui, OSD: Show, NoActivate x%dGuiX% y%GuiY% h%GuiHeight% w%text_width%, KeypressOSD
    }
    WinSet, AlwaysOnTop, On, KeypressOSD
    visible := 1

}

ShowLongMsg(stringo) {
   text_width2 := GetTextExtentPoint(stringo, FontName, FontSize, bBold) / (OSDautosizeFactory/100)
   maxAllowedGuiWidth := text_width2 + 30
   ShowHotkey(stringo)
   maxAllowedGuiWidth := (OSDautosize=1) ? maxGuiWidth : GuiWidth
}

GetTextExtentPoint(sString, sFaceName, nHeight, bBold = 1, bItalic = False, bUnderline = False, bStrikeOut = False, nCharSet = 0) {   ; by Sean from https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363

  hDC := DllCall("GetDC", "Uint", 0)
  nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

  hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 10 + 1 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
  hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

  DllCall("GetTextExtentPoint32", "Uint", hDC, "str", sString, "int", StrLen(sString), "int64P", nSize)

  DllCall("SelectObject", "Uint", hDC, "Uint", hFold)
  DllCall("DeleteObject", "Uint", hFont)
  DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

  nWidth := nSize & 0xFFFFFFFF
  nWidth := (nWidth<35) ? 36 : nWidth
  minHeight := FontSize*1.5
  GuiHeight := nSize >> 32 & 0xFFFFFFFF
  GuiHeight := GuiHeight / (OSDautosizeFactory/100) + (OSDautosizeFactory/10) + 4
  GuiHeight := (GuiHeight<minHeight) ? minHeight+1 : GuiHeight

  Return nWidth
}

GuiGetSize( ByRef W, ByRef H, vindov) {          ; function by VxE from https://autohotkey.com/board/topic/44150-how-to-properly-getset-gui-size/
  if (vindov=1)
     Gui, OSD: +LastFoundExist
  if (vindov=2)
     Gui, MouseH: +LastFoundExist
  if (vindov=3)
     Gui, MouseIdlah: +LastFoundExist
  if (vindov=4)
     Gui, Mouser: +LastFoundExist
  VarSetCapacity( rect, 16, 0 )
  DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
  W := NumGet( rect, 8, "int" )
  H := NumGet( rect, 12, "int" )
}

GetKeyStr(letter := 0) {
    Thread, priority, 15
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    modifiers_temp := 0
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    FriendlyKeyNames := {NumpadDot:"[ . ]", NumpadDiv:"[ / ]", NumpadMult:"[ * ]", NumpadAdd:"[ + ]", NumpadSub:"[ - ]", numpad0:"[ 0 ]", numpad1:"[ 1 ]", numpad2:"[ 2 ]", numpad3:"[ 3 ]", numpad4:"[ 4 ]", numpad5:"[ 5 ]", numpad6:"[ 6 ]", numpad7:"[ 7 ]", numpad8:"[ 8 ]", numpad9:"[ 9 ]", NumpadEnter:"[Enter]", NumpadDel:"[Delete]", NumpadIns:"[Insert]", NumpadHome:"[Home]", NumpadEnd:"[End]", NumpadUp:"[Up]", NumpadDown:"[Down]", NumpadPgdn:"[Page Down]", NumpadPgup:"[Page Up]", NumpadLeft:"[Left]", NumpadRight:"[Right]", NumpadClear:"[Clear]", Media_Play_Pause:"Media_Play/Pause", MButton:"Middle Click", RButton:"Right Click", Del:"Delete", PgUp:"Page Up", PgDn:"Page Down"}

    ; If any mod but Shift, go ; If shift, check if not letter

    for i, mod in modifiers
    {
        if (mod = "LShift" && typed || mod = "RShift" && typed ? (!letter && GetKeyState(mod)) : GetKeyState(mod))
    ;    if GetKeyState(mod)
            prefix .= mod " + "
    }

    if (!prefix && !ShowSingleKey)
        throw

    key := A_ThisHotkey
    StringRight, backupKey, key, 1
    if (key ~= "i)^(~\+\$sc0)") ;  || (key ~= "i)^(~\+\$.?)$")
       StringReplace, key, key, ~+$,
    key := RegExReplace(key, "i)^(~\+\$.?)$", "[ ▪ ]")
    key := RegExReplace(key, "i)^(~\+\^!|~\+<!<\^|~\+<!>\^|~<\^>!|~!#\^\+|~<\^<!|~>\^>!|~\^!|~#!\+|~#!\^|~#\+\^|~\+!\^|~!#\^|~!\+\^|~!#|~\+#|~#\^|~!\+|~!\^|~\+\^|~#!|~\*|~\^|~!|~#|~\+)")
    StringReplace, key, key, ~,

    if (StrLen(key)=2) && (enableAltGr=0)
    {
          if !(key ~= "i)^(up|f[0-9])")
              StringRight, key, key, 1
    }

    if GetKeyState("Shift")
    {
       If (ModBeeper = 1) && (ShowSingleKey = 1) && (ShowSingleModifierKey = 1) || (ModBeeper = 1) && (BeepHiddenKeys = 1)
          modsBeeper()

       if (ShiftDisableCaps=1)
          SetCapsLockState, off
    }

    if (key ~= "i)^(LCtrl|RCtrl|LShift|RShift|LAlt|RAlt|LWin|RWin)$")
    {
        if (ShowSingleKey = 0) || ((A_TickCount-tickcount_start > 1800) && visible && !typed && keycount>5)
        {
            throw
        } else
        {
            backupKey := key
            key := ""
            if (StickyKeys=0)
               throw
        }

        prefix := CompactModifiers(prefix)
        if (!prefix && !key)
        {
           if backupKey
           {
              prefix := backupKey="RCtrl" ? "AltGr (special key)" : backupKey
           } else
           {
              prefix := backupKey="RCtrl" ? "AltGr (special key)" : "Unknown key"
           }
           keyCount := 0.1
           shiftPressed := 0
        }
    } else
    {
        backupKey := !key ? backupKey : key
        if (StrLen(key)=1)
        {
            StringLeft, key, key, 2
            key := GetKeyChar(key)
        } else if (SubStr(key, 1, 2) = "sc") && (key != "ScrollLock") || (SubStr(key, 1, 2) = "vk") {
            key := (GetSpecialSC(key) || GetSpecialSC(key)=0) ? GetSpecialSC(key) : key
        } else if (StrLen(key)<1) && !prefix {
            key := (ShowDeadKeys=1) ? "◐" : "(unknown key)"
            key := backupKey ? backupKey : key
        } else if FriendlyKeyNames.hasKey(key) {
            key := FriendlyKeyNames[key]
        } else if (key = "Volume_Up") {
            Sleep, 40
            SoundGet, master_volume
            key := "Volume up: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "Volume_Down") {
            Sleep, 40
            SoundGet, master_volume
            key := "Volume down: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "Volume_mute") {
            SoundGet, master_volume
            SoundGet, master_mute, , mute
            if master_mute = on
               key := "Volume mute"
            if master_mute = off
               key := "Volume level: " round(master_volume)
            SetTimer, volBeeperTimer, 15, -10
        } else if (key = "PrintScreen") {
            if (HideAnnoyingKeys=1 && !prefix)
                throw
            key := "Print Screen"
        } else if (key ~= "i)(wheel)") {
            if (ShowMouseButton=0)
            {
               throw
            } else
            {
              StringReplace, key, key, wheel, wheel%A_Space%
            }
        } else if (key = "LButton") && IsDoubleClick() {
            key := "Double Click"
        } else if (key ~= "i)(lock)") && !prefixed {
            key := GetCrayCrayState(key)
        } else if (key = "LButton") {
            if (HideAnnoyingKeys=1 && !prefix)
            {
                if (!(typed ~= "i)(  │)") && strlen(typed)>3 && (ShowMouseButton=1)) {
                    typed := InsertChar2caret(" ")
                }
                throw
            }
            key := "Left Click"
        }

        _key := key        ; what's this for? :)

        prefix := CompactModifiers(prefix)

        static pre_prefix, pre_key
        StringUpper, key, key, T
        if InStr(key, "lock on")
           StringUpper, key, key
        StringUpper, pre_key, pre_key, T
        keyCount := (key=pre_key) && (prefix = pre_prefix) && (repeatCount<1.5) ? keyCount : 1
        if ((ShowPrevKey=1) && (keyCount<2) && (A_TickCount-tickcount_start < ShowPrevKeyDelay) && (!(pre_key ~= "i)^(Media_|Volume|Caps lock|Num lock|Scroll lock)")))
        {
            ShowPrevKeyValid := 0
            if ((prefix != pre_prefix && key=pre_key) || (key!=pre_key && !prefix) || (key!=pre_key && pre_prefix))
            {
               ShowPrevKeyValid := 1
               if (InStr(pre_key, " up") && StrLen(pre_key)=4)
                   StringLeft, pre_key, pre_key, 1
            }
        } else
        {
            ShowPrevKeyValid := 0
        }
        
        if (key=pre_key) && (ShowKeyCountFired=0) && (ShowKeyCount=1) && !(key ~= "i)(volume)")
        {
           trackingPresses := tickcount_start2 - tickcount_start < 100 ? 1 : 0
           keyCount := (trackingPresses=0 && keycount<2) ? keycount+1 : keycount
           if (trackingPresses=1)
              keyCount := !keycount ? 1 : keyCount+1
           if (trackingPresses=0) && InStr(prefix, "+") && (A_TickCount-tickcount_start < 600) && (tickcount_start2 - tickcount_start < 500)
              keyCount := !keycount ? 1 : keyCount+1
           ShowKeyCountValid := 1
        } else if (key=pre_key) && (ShowKeyCountFired=1) && (ShowKeyCount=1) && !(key ~= "i)(volume)")
        {
           keyCount := !keycount ? 0 : keyCount+1
           ShowKeyCountValid := 1
        } else if (key=pre_key) && (ShowKeyCount=0) && (DisableTypingMode=0)
        {
           keyCount := !keycount ? 0 : keyCount+1
           ShowKeyCountValid := 0
        } else
        {
           keyCount := 1
           ShowKeyCountValid := 0
        }
        
        if (InStr(prefix, "+")) || ((!letter) && DisableTypingMode=0) || (DisableTypingMode=1)
        {
            if (prefix != pre_prefix)
            {
                result := (ShowPrevKeyValid=1) ? prefix key " {" pre_prefix pre_key "}" : prefix key
                keyCount := 1
            } else if (ShowPrevKeyValid=1)
            {
                key := (round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" round(keyCount) ")") : (key ", " pre_key)
            } else if (ShowPrevKeyValid=0)
            {
                key := (round(keyCount)>1) && (ShowKeyCountValid=1) ? (key " (" round(keyCount) ")") : (key)
            }
        } else {
            keyCount := 1
        }
        pre_prefix := prefix
        pre_key := _key
    }

    prefixed := prefix ? 1 : 0
    return result ? result : prefix . key
}

CompactModifiers(stringy) {
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    if (DifferModifiers = 1)
    {
        StringReplace, stringy, stringy, LCtrl + RAlt, AltGr, All
        StringReplace, stringy, stringy, LCtrl + RCtrl + RAlt, RCtrl + AltGr, All
        StringReplace, stringy, stringy, RAlt, AltGr, All
        StringReplace, stringy, stringy, LAlt, Alt, All
    } else if (DifferModifiers = 0)
    {
        StringReplace, stringy, stringy, LCtrl + RAlt, AltGr, All
        ; StringReplace, stringy, stringy, LCtrl + RCtrl + RAlt, RCtrl + AltGr, All
        StringReplace, stringy, stringy, LCtrl, Ctrl, All
        StringReplace, stringy, stringy, RCtrl, Ctrl, All
        StringReplace, stringy, stringy, LShift, Shift, All
        StringReplace, stringy, stringy, RShift, Shift, All
        StringReplace, stringy, stringy, LAlt, Alt, All
        StringReplace, stringy, stringy, LWin, WinKey, All
        StringReplace, stringy, stringy, RWin, WinKey, All
        StringReplace, stringy, stringy, Ctrl + Ctrl, Ctrl, All
        StringReplace, stringy, stringy, Shift + Shift, Shift, All
        StringReplace, stringy, stringy, WinKey + WinKey, WinKey, All
        StringReplace, stringy, stringy, RAlt, AltGr, All
    }
    return stringy
}

GetCrayCrayState(key) {
    Thread, priority, 30
    Critical, on

    GetKeyState, keyState, %key%, T

    If (keyState = "D")
    {
       tehResult := key " ON"
       if (key = "capslock") && (CapslockBeeper=1)
          capsBeeper()
    }
    else {
       tehResult := key " off"
    }
    StringReplace, tehResult, tehResult, lock, %A_SPACE%lock
    Return tehResult
}

GetSpecialSC(sc) {
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

    k := {sc11dvkDF: "(special key)", sc146: "Pause/Break", sc123: "Genius LuxeMate Scroll"}

    if (!k[sc] && (AutoDetectKBD=1) && InStr(CurrentKBD, "latvian")) && kbLayoutRaw="00000426"
       k := {sc029vkC0: "–"}

    if !k[sc] && (AutoDetectKBD=1) && (CurrentKBD ~= "i)(vietnamese)")
       k := {sc006vk35:"``", sc007vk36:"ˇ", sc008vk37:"´", sc009vk38:"'", sc00Avk39:"."}

    if !k[sc]
    {
       brr := GetKeyChar(sc)
       StringLeft, brr, brr, 1
       k[sc] := brr
    }

    if !k[sc]
       k[sc] := GetKeyName(sc)

    return k[sc]
}


GetDeadKeySymbol(sc) {
    Thread, priority, 10
    if ((prioritizeBeepers=0) && (missingAudios=0)) || ((prioritizeBeepers=1) && (missingAudios=0))
       Critical, on

   lenghty := InStr(SCnames2, sc)
   lenghty := (lenghty=0) ? 2 : lenghty

   symbol := SubStr(SCnames2, lenghty-1, 1)

   backupSymbol := SubStr(sc, InStr(sc, "sc"), 9)

   if (AutoDetectKBD=1)
      k := SCnames

   if (!k[backupSymbol] && AutoDetectKBD=1)
      k := {sc01AvkBA: "'", sc01AvkBB: "+", sc00DvkBB: "+", sc02BvkDE: "#", sc02BvkDC: "\", sc029vkDF: "``", sc029vkC0: "–", sc029vkBF: "§", sc028vkC0: "'", sc028vkDE: "·", sc00DvkDD: "`", sc00DvkBF: "´", sc01BvkDD: ")", sc00CvkBD: "=", sc035vkBF: "/", sc027vkBA: ";", sc002vk31:"1", sc003vk32:"2", sc004vk33:"3", sc005vk34:"4", sc006vk35:"5", sc007vk36:"6", sc008vk37:"7", sc009vk38:"8", sc00Avk39:"9", sc00Bvk30:"0", sc056vkE2: "\", sc01BvkBA: "'", sc034vkBE: "."}

   tehResult := (symbol="▪") || (symbol="") ? k[backupSymbol] : symbol

   if !tehResult
      tehResult := "▪"

   return tehResult
}

; <tmplinshi>: thanks to Lexikos: https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236

GetKeyChar(Key) {

    if (key ~= "i)^(vk)")
    {
       sc := "0x0" GetKeySC(Key)
       sc := sc + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 3)
    } else if (StrLen(key)>7)
    {
       sc := SubStr(key, InStr(key, "sc")+2, 3) + 0
       vk := "0x0" SubStr(key, InStr(key, "vk")+2, 2)
       vk := vk + 0
    } else
    {
       sc := GetKeySC(Key)
       vk := GetKeyVK(Key)
    }

    nsa := DllCall("MapVirtualKey", "Uint", vk, "Uint", 2)
    if (nsa<=0) && (DeadKeys=0)
       Return

    thread := DllCall("GetWindowThreadProcessId", "ptr", WinActive("A"), "ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")

    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)

    n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc, "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", hkl)
    if (DeadKeys=1)
       n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc, "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", hkl)
    return StrGet(&char, n, "utf-16")
}

global LastKBDchangeTime := A_TickCount

IdentifyKBDlayout() {
  if (AutoDetectKBD=1) && (ForceKBD=0)
  {
     VarSetCapacity(kbLayoutRaw, 32, 0)
     DllCall("GetKeyboardLayoutName", "Str", kbLayoutRaw)
     backupkbLayoutRaw := kbLayoutRaw
     IniRead, kbLayoutRaw2, %inifile%, TempSettings, kbLayoutRaw2, 0

     if (kbLayoutRaw=kbLayoutRaw2)
     {
        SetFormat, Integer, H
           perWindowKbLayout := % DllCall("GetKeyboardLayout", Int,DllCall("GetWindowThreadProcessId", int,WinActive("A"), Int,0))
        SetFormat, Integer, D
        StringReplace, perWindowKbLayout, perWindowKbLayout, -,
        if !(perWindowKbLayout ~= "i)^(0x0|0x1|0x2|0x7|0xC)$")
           usePerWindowKbLayout := 1
     }

     IniWrite, %kbLayoutRaw%, %IniFile%, TempSettings, kbLayoutRaw2
  }

  if (ForceKBD=1)
     kbLayoutRaw := (ForcedKBDlayout = 0) ? ForcedKBDlayout1 : ForcedKBDlayout2

  #Include *i %A_Scriptdir%\keypress-osd-languages.ini

  if (!FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled) || (FileExist("keypress-osd-languages.ini") && (AutoDetectKBD=1) && (loadedLangz!=1) && !A_IsCompiled)
  {
      soundbeep
      ShowLongMsg("Downloading language definitions file... Please wait.")
      downLangFile()
      SetTimer, HideGUI, % -DisplayTime*2
  }

  if (A_IsCompiled && (loadedLangz!=1))
  {
      ReloadCounter := 1000
      IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
      ForceKBD := 0
      AutoDetectKBD := 0
      SoundBeep
      IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
      IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
      MsgBox, File compiled without language definitions.
  }

  IniRead, LangChanged, %inifile%, TempSettings, LangChanged, 0
  IniRead, LangChanged2This, %IniFile%, TempSettings, LangChanged2This
  if ((LangChanged=1) && (ForceKBD=0)) || ((usePerWindowKbLayout=1) && (ForceKBD=0))
  {
       if (usePerWindowKbLayout=1)
          LangChanged2This := perWindowKbLayout

       StringLeft, LangChanged2Thiz, LangChanged2This, 5

       if (LangChanged2This ~= "i)^(0x100c|0x1009|0x1809|0x4009)")
          StringLeft, LangChanged2Thiz, LangChanged2This, 6

       if ConvertLangCodeList1.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList1[LangChanged2Thiz]
       } else if ConvertLangCodeList2.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList2[LangChanged2Thiz]
       } else if ConvertLangCodeList3.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList3[LangChanged2Thiz]
       } else if ConvertLangCodeList4.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList4[LangChanged2Thiz]
       } else if ConvertLangCodeList5.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList5[LangChanged2Thiz]
       } else if ConvertLangCodeList6.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList6[LangChanged2Thiz]
       } else if ConvertLangCodeList7.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList7[LangChanged2Thiz]
       } else if ConvertLangCodeList8.hasKey(LangChanged2Thiz)
       {
          kbLayoutRaw := "000" ConvertLangCodeList8[LangChanged2Thiz]
       } else
       {
          kbLayoutRaw := backupkbLayoutRaw
          if (kbLayoutRaw=kbLayoutRaw2)
             LangIDfailed := (LangChanged=1) ? 1 : 2
       }
       global LastKBDchangeTime := A_TickCount
  }

  StringRight, kbLayout, kbLayoutRaw, 4

  #IncludeAgain *i %A_Scriptdir%\keypress-osd-languages.ini
  
  check_kbd := StrLen(LangName_%kbLayout%)>2 ? 1 : 0
  check_kbd_exact := StrLen(LangRaw_%kbLayoutRaw%)>2 ? 1 : 0

  if (check_kbd_exact=0)
      partialKBDmatch = (Partial match)

  if (check_kbd=0) && (loadedLangz=1)
  {
      ShowLongMsg("Unrecognized layout: (kbd " kbLayoutRaw ").")
      SetTimer, HideGUI, % -DisplayTime
      CurrentKBD := kbLayoutRaw ". " perWindowKbLayout ". Layout unrecognized:"
      soundbeep, 500, 900
  }

  StringLeft, kbLayoutSupport, LangName_%kbLayout%, 1
  if (kbLayoutSupport="-") && (check_kbd=1) && (loadedLangz=1)
  {
      ShowLongMsg("Unsupported layout: " LangName_%kbLayout% " (kbd" kbLayout ").")
      SetTimer, HideGUI, % -DisplayTime
      soundbeep, 500, 900
      CurrentKBD := LangName_%kbLayout% " unsupported. " kbLayoutRaw " / " perWindowKbLayout
  }

  if (DeadKeysPresent_%kbLayoutRaw%=1)
  {
      DeadKeys := 1
      if DKaltGR_%kbLayoutRaw%
         DKaltGR_list := DKaltGR_%kbLayoutRaw%
      if DKshift_%kbLayoutRaw%
         DKshift_list := DKshift_%kbLayoutRaw%
      if DKnotShifted_%kbLayoutRaw%
         DKnotShifted_list := DKnotShifted_%kbLayoutRaw%
  }

  if (kbLayoutSupport!="-") && (check_kbd=1) && (loadedLangz=1)
  {
      identifiedKbdName := (check_kbd_exact=1) ? LangRaw_%kbLayoutRaw% : LangName_%kbLayout%
      CurrentKBD := "Auto-detected: " identifiedKbdName ". " kbLayoutRaw " / " perWindowKbLayout
      if (LangIDfailed=2)
         CurrentKBD := "Default layout: " identifiedKbdName ". " kbLayoutRaw " / " perWindowKbLayout
      if (LangIDfailed=1)
         CurrentKBD := "Layout identification failed. Default: " identifiedKbdName ". " kbLayoutRaw " / " perWindowKbLayout
      If (ForceKBD=1)
         CurrentKBD := "Enforced: " identifiedKbdName ". " kbLayoutRaw

      if (SilentDetection=0)
      {
          if (ForceKBD!=1) && (LangIDfailed!=1) && (LangIDfailed!=2)
             ShowLongMsg("Layout detected: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)
          SetTimer, HideGUI, % -DisplayTime
          Sleep, 200
          if (ForceKBD=1)
             ShowLongMsg("Enforced layout: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)

          if (LangIDfailed=2)
             ShowLongMsg("Default layout: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)

          if (LangIDfailed=1)
             ShowLongMsg("Layout identification failed. Default: " identifiedKbdName " (kbd" kbLayout "). " partialKBDmatch)

          SetTimer, HideGUI, % -DisplayTime
      }
  }
  LangChanged := 0
  IniWrite, %LangChanged%, %IniFile%, TempSettings, LangChanged

    if (AutoDetectKBD=1) && (loadedLangz=1)
    {
       identifiedKbdName := Strlen(identifiedKbdName)>3 ? identifiedKbdName : "unsupported layout"
       StringLeft, clayout, identifiedKbdName, 25
       Menu, tray, add, %clayout%, dummy
       Menu, tray, Disable, %clayout%
       Menu, tray, add

       If (check_kbd_exact=1) && (ForceKBD=0)
       {
          SetFormat, Integer, H
          ThisInputLocaleID := % DllCall("GetKeyboardLayout", Int,DllCall("GetWindowThreadProcessId", int,WinActive("A"), Int,0))
          SetFormat, Integer, D
          StringReplace, ThisInputLocaleID, ThisInputLocaleID, -, 
          IniWrite, %identifiedKbdName%, %IniFile%, Languages, %ThisInputLocaleID%
       }
    }

    if (ConstantAutoDetect=1) && (AutoDetectKBD=1) && (loadedLangz=1) && (ForceKBD=0)
       SetTimer, dummyDelayer, 5000, 915

}

checkInstalledLangs() {

  #IncludeAgain *i %A_Scriptdir%\keypress-osd-languages.ini

  Loop, 25
  {
    RegRead, langInstalled, HKEY_CURRENT_USER, Keyboard Layout\Preload, %A_Index%
    if (ErrorLevel=1)
       stopNow := 1

    RegRead, langRealInstalled, HKEY_CURRENT_USER, Keyboard Layout\Substitutes, %langInstalled%
    if (ErrorLevel=1)
       langRealInstalled := langInstalled

    StringRight, ShortlngCode, langRealInstalled, 4

    if (LangRaw_%langRealInstalled%)
    {
       StringRight, langRealInstalledCode, langRealInstalled, 5
       niceMenuName := LangRaw_%langRealInstalled%
       if !niceMenuName
          niceMenuName := LangName_%ShortlngCode%
       StringRight, testKBDselected, kbLayoutRaw, 5
       Menu, kbdList, add, %langRealInstalledCode% %niceMenuName%, ForceSpecificLanguage
       if (langRealInstalledCode = testKBDselected) && (LangIDfailed!=2) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %langRealInstalledCode% %niceMenuName%
    } else if (LangName_%ShortlngCode%)
    {
       niceMenuName := LangName_%ShortlngCode%
       StringRight, ShortlngCode, langRealInstalled, 5
       Menu, kbdList, add, %ShortlngCode% %niceMenuName%, dummy
       Menu, kbdList, Disable, %ShortlngCode% %niceMenuName%
       if (langRealInstalled = kbLayoutRaw) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %ShortlngCode% %niceMenuName%
    } else if (langRealInstalled)
    {
       StringRight, ShortlangRealInstalledCode, langRealInstalled, 5
       Menu, kbdList, add, %ShortlangRealInstalledCode% unrecognized layout, dummy
       Menu, kbdList, Disable, %ShortlangRealInstalledCode% unrecognized layout
       if (langRealInstalled = kbLayoutRaw) && (AutoDetectKBD=1)
          Menu, kbdList, Check, %ShortlangRealInstalledCode% unrecognized layout
    }
  } Until (stopNow=1)
}

ForceSpecificLanguage() {
    ForceKBD := 1
    AutoDetectKBD := 1
    StringLeft, MenuSelected, A_ThisMenuItem, 5
    if (ForcedKBDlayout=0)
       ForcedKBDlayout1 := "000" MenuSelected
    if (ForcedKBDlayout=1)
       ForcedKBDlayout2 := "000" MenuSelected
    CreateOSDGUI()
    ShowLongMsg("Switching keyboard layout...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    IniWrite, %ForcedKBDlayout1%, %IniFile%, SavedSettings, ForcedKBDlayout1
    IniWrite, %ForcedKBDlayout2%, %IniFile%, SavedSettings, ForcedKBDlayout2
    sleep, 1100
    Reload
}

dummyDelayer() {
  kbdList_count := DllCall("GetMenuItemCount", "ptr", MenuGetHandle("kbdList"))
  if (kbdList_count>1)
     SetTimer, ConstantKBDtimer, 950, -25

  SetTimer,, off
}

ConstantKBDtimer() {
    if A_IsSuspended
       Return

    SetFormat, Integer, H
    NewInputLocaleID := % DllCall("GetKeyboardLayout", Int,DllCall("GetWindowThreadProcessId", int,WinActive("A"), Int,0))
    StringReplace, NewInputLocaleID, NewInputLocaleID, -, 

    if (NewInputLocaleID ~= "i)^(0x0|0x1|0x2|0x7|0xC)$")
       Return

    if (InputLocaleID != NewInputLocaleID)
    {
       InputLocaleID := NewInputLocaleID
       SetFormat, Integer, D
       LangChanged := 1
       global LastKBDchangeTime := A_TickCount
    }

    if (LangChanged=1)
    {
       ConstantKBDlayoutChanger()
       sleep, 50
    }
}

ConstantKBDlayoutChanger() {
    Thread, priority, -20

    if A_IsSuspended
       Return

    SetFormat, Integer, H
    IniRead, currentLayout, %IniFile%, TempSettings, LangChanged2This

    if (currentLayout=InputLocaleID)
    {
       LangChanged := 0
       sleep, 50
    }

    if (A_TickCount - LastKBDchangeTime > 1000) && (A_TickCount - lastTypedSince > 2000) && (A_TickCount - tickcount_start > 2000) && (currentLayout!=InputLocaleID)
    {
        InputLocaleID := NewInputLocaleID
        lastKBDid := InputLocaleID
        LangChanged := 1
        IniWrite, %LangChanged%, %IniFile%, TempSettings, LangChanged
        IniWrite, %lastKBDid%, %IniFile%, TempSettings, LangChanged2This
        IniRead, InputLocaleName, %inifile%, Languages, %InputLocaleID%, %InputLocaleID%

        if (SilentDetection=0)
        {
           InputLocaleName := Strlen(InputLocaleName)>3 && !InStr(InputLocaleName, "unsupported") ? InputLocaleName : lastKBDid
           ShowLongMsg("Layout changed to: " InputLocaleName)
           sleep, 1000
        }
        Reload
    }
}


IsDoubleClick(MSec = 300) {
    Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < MSec)
}

IsDoubleClickEx(MSec = 300) {
    preHotkey := RegExReplace(A_PriorHotkey, "i) Up$")
    Return (A_ThisHotKey = preHotkey) && (A_TimeSincePriorHotkey < MSec)
}

HideGUI() {
    visible := 0
    Gui, OSD: Hide
    SetTimer, checkMousePresence, off
}

checkMousePresence() {
    id := mouseIsOver()
    title := getWinTitleFromID(id)
    if (title = "KeypressOSD") && (JumpHover=0)
    {
       HideGUI()
    } else if (title = "KeypressOSD") && (JumpHover=1)
    {
       Gosub, TogglePosition
    }
}

mouseIsOver() {
    MouseGetPos,,, id
    return id
}

getWinTitleFromID(id) {
    WinGetTitle, title, % "ahk_id " id
    return title
}

CreateGlobalShortcuts() {
   if (pasteOSDcontent=1)
      Hotkey, ^+Insert, sendOSDcontent
   
   if (KeyboardShortcuts=1) {
      Hotkey, !+^F7, ToggleForcedLanguage
      Hotkey, !+^F8, ToggleShowSingleKey
      Hotkey, !+^F9, TogglePosition
      Hotkey, !+^F11, DetectLangNow
      Hotkey, !+^F12, ReloadScript
      Hotkey, #Insert, SynchronizeApp
      Hotkey, !Pause, ToggleCapture2Text   ; Alt+Pause/Break
      Hotkey, +Pause, SuspendScript   ; shift+Pause/Break
    }
}

SynchronizeApp:
  Critical, on
  lola := "│"
  lola2 := "║"
  loalee := Clipboard
  Clipboard := ""
  if (synchronizeMode=0)
  {
      sleep 10
      Sendinput {LCtrl Down}
      sleep 10
      Sendinput a
      sleep 10
      Sendinput c
      sleep 10
      Sendinput {LCtrl Up}
      sleep 10
      Sendinput {Right}
      sleep 10
      Sendinput {End 2}
  } Else
  {
      sleep 10
      Sendinput {LShift Down}
      sleep 10
      Sendinput {Up 2}
      sleep 10
      Sendinput {Home}
      sleep 10
      Sendinput {LShift Up}
      sleep 10
      Sendinput ^c
      sleep 10
      Sendinput {Right}
  }
  if (StrLen(Clipboard)>0)
     StringRight, typed, Clipboard, 950
  CaretPos := StrLen(typed)+1
  typed := ST_Insert(lola, typed, CaretPos)
  global lastTypedSince := A_TickCount
  CalcVisibleText()
  ShowHotkey(visibleTextField)
  SetTimer, HideGUI, % -DisplayTimeTyping
  Clipboard := loalee
  loalee := " "
Return

sendOSDcontent:
  Critical, on
  typed := backTyped2 ? backtyped2 : backtyped

  if (StrLen(typed)>2)
  {
     loalee := Clipboard
     lola := "│"
     lola2 := "║"
     StringReplace, typed, typed, %lola%
     StringReplace, typed, typed, %lola2%
     Clipboard := typed
     sleep 10
     Sendinput ^v
     sleep 10
     CaretPos := StrLen(typed)+1
     typed := ST_Insert(lola, typed, CaretPos)
     global lastTypedSince := A_TickCount
     CalcVisibleText()
     ShowHotkey(visibleTextField)
     Clipboard := loalee
     loalee := " "
     SetTimer, HideGUI, % -DisplayTimeTyping
  }
Return

SuspendScript:         ; Shift+Pause/Break
   Suspend, Permit

   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   Menu, Tray, UseErrorLevel
   Menu, Tray, Rename, &KeyPress activated,&KeyPress deactivated
   if (ErrorLevel=1)
   {
      Menu, Tray, Rename, &KeyPress deactivated,&KeyPress activated
      Menu, Tray, Check, &KeyPress activated
   }
   Menu, Tray, Uncheck, &KeyPress deactivated
   IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
   IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
   CreateOSDGUI()
   ShowLongMsg("KeyPress OSD toggled")
   SetTimer, HideGUI, % -DisplayTime/6
   Sleep, DisplayTime/6+15
   Suspend
return

ToggleConstantDetection:
   if ((prefOpen = 1) && (A_IsSuspended=1))
   {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
   }

   AutoDetectKBD := 1
   ConstantAutoDetect := (ConstantAutoDetect=0) ? 1 : 0
   IniWrite, %ConstantAutoDetect%, %IniFile%, SavedSettings, ConstantAutoDetect
   IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD

   if (ConstantAutoDetect=1)
   {
      SetTimer, ConstantKBDtimer, 950, -25
      Menu, Tray, Check, &Monitor keyboard layout
   }

   if (ConstantAutoDetect=0)
   {
      Menu, Tray, Uncheck, &Monitor keyboard layout
      SetTimer, ConstantKBDtimer, off
   }

   Sleep, 500
return

ToggleNeverDisplay:
   NeverDisplayOSD := (NeverDisplayOSD=0) ? 1 : 0
   IniWrite, %NeverDisplayOSD%, %IniFile%, SavedSettings, NeverDisplayOSD

   if (NeverDisplayOSD=1)
      Menu, SubSetMenu, Check, &Never show the OSD

   if (NeverDisplayOSD=0)
      Menu, SubSetMenu, unCheck, &Never show the OSD

   Sleep, 300
return

ToggleShowSingleKey:
    ShowSingleKey := (!ShowSingleKey) ? 1 : 0
    if (ShowSingleKey=0)
       OnlyTypingMode := 0

    if (ShowSingleKey=1)
       IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%

    CreateOSDGUI()
    IniWrite, %ShowSingleKey%, %IniFile%, SavedSettings, ShowSingleKey

    ShowLongMsg("Show single keys = " ShowSingleKey)
    SetTimer, HideGUI, % -DisplayTime/2
return

TogglePosition:

    if (A_IsSuspended=1)
    {
      SoundBeep, 300, 900
      WinActivate, KeyPress OSD
      Return
    }
 
    GUIposition := (GUIposition=1) ? 0 : 1
    Gui, OSD: hide

    if (GUIposition=1)
    {
       GuiY := GuiYa
       GuiX := GuiXa
    } else
    {
       GuiY := GuiYb
       GuiX := GuiXb
    }

    Gui, OSD: Destroy
    sleep, 20
    CreateOSDGUI()
    sleep, 20

    if (Capture2Text!=1)
    {
        IniWrite, %GUIposition%, %IniFile%, SavedSettings, GUIposition
        ShowLongMsg("OSD position changed")
        sleep, 450
        ShowLongMsg("OSD position changed")
        SetTimer, HideGUI, % -DisplayTime/3
        Gui, OSD: Destroy
        sleep, 20
        CreateOSDGUI()
        sleep, 20 
    }
return

ToggleForcedLanguage:
    ReloadCounter := 1
    IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    ForceKBD := 1
    AutoDetectKBD := 1
    ForcedKBDlayout := (ForcedKBDlayout = 0) ? 1 : 0
    niceNaming := (ForcedKBDlayout = 0) ? "A" : "B"
    CreateOSDGUI()
    ShowLongMsg("Switching layout to preset " niceNaming "...")
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %ForcedKBDlayout%, %IniFile%, SavedSettings, ForcedKBDlayout
    sleep, 1100
    Reload
return

DetectLangNow:
    ReloadCounter := 1
    IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    CreateOSDGUI()
    ForceKBD := 0
    AutoDetectKBD := 1
    IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
    IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
    ShowLongMsg("Detecting keyboard layout...")
    sleep, 1100
    Reload
return

ReloadScript:
    CreateOSDGUI()
    ShowLongMsg("Reinitializing...")
    sleep, 1100
    Reload
return

ToggleCapture2Text:        ; Alt+Pause/Break
   if (A_IsSuspended=1)
   {
      SoundBeep, 300, 900
      Return
   }

   DetectHiddenWindows, on

   IfWinNotExist, Capture2Text
   {
        if (Capture2Text!=1)
        {
            SoundBeep, 1900
            MsgBox, 4,, Capture2Text was not detected. Do you want to continue?
            IfMsgBox Yes
            {
                featureValidated := 1
            } else
            {
                featureValidated := 0
            }
        }
   }

    featureValidated := featureValidated=0 ? 0 : 1

    if (featureValidated=1)
    {
        Menu, Tray, UseErrorLevel
        Menu, Tray, Rename, &Capture2Text enable, &Capture2Text enabled
        if (ErrorLevel=1)
           Menu, Tray, Rename, &Capture2Text enabled, &Capture2Text enable
        Menu, Tray, Uncheck, &Capture2Text enable
        Menu, Tray, Check, &Capture2Text enabled

        Sleep, 300
        Capture2Text := (Capture2Text=1) ? 0 : 1
    }

    if (Capture2Text=1) && (featureValidated=1)
    {
        JumpHover := 1
        if (ClipMonitor=0)
        {
           ClipMonitor := 1
           OnClipboardChange("ClipChanged")
        }
        SetTimer, MouseHalo, off
        Gui, MouseH: Hide
        SetTimer, capturetext, 1500, -10
        ShowLongMsg("Enabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime/7
    } else if (featureValidated=1)
    {
        Capture2Text := (Capture2Text=1) ? 0 : 1
        IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
        if (GUIposition=1)
        {
           GuiY := GuiYa
           GuiX := GuiXa
        } else
        {
           GuiY := GuiYb
           GuiX := GuiXb
        }
        IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
        Gui, OSD: Destroy
        sleep, 50
        CreateOSDGUI()
        sleep, 50
        IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
        IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
        SetTimer, capturetext, off
        Capture2Text := (Capture2Text=1) ? 0 : 1
        ShowLongMsg("Disabled automatic Capture 2 Text")
        SetTimer, HideGUI, % -DisplayTime
        if (ShowMouseHalo=1)
           SetTimer, MouseHalo, on
    }

   DetectHiddenWindows, off
Return

capturetext() {
    if ((A_TimeIdlePhysical < 2000) && !A_IsSuspended)
       Send, {Pause}             ; set here the keyboard shortcut configured in Capture2Text
}

ClipChanged(Type) {
    Critical, on
    sleep, 200
    if ((type=1) && (ClipMonitor=1) && !A_IsSuspended && (A_TickCount-lastTypedSince > DisplayTime/2))
    {
       troll := clipboard
       Stringleft, troll, troll, 150
       StringReplace, troll, troll, `r`n, %A_SPACE%, All
       StringReplace, troll, troll, %A_TAB%, %A_SPACE%, All
       StringReplace, troll, troll, %A_SPACE%%A_SPACE%, , All
       ShowLongMsg(troll)
       SetTimer, HideGUI, % -DisplayTime*2
    } else if (type=2 && ClipMonitor=1 && !A_IsSuspended)
    {
       ShowLongMsg("Clipboard data changed")
       SetTimer, HideGUI, % -DisplayTime/7
    }
}

CreateMouseGUI() {
    global

    Gui, Mouser: +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, Mouser: Margin, 0, 0
}

ShowMouseClick(clicky) {
    Thread, priority, -10
    GuiGetSize(Wa, Ha, 4)
    SetTimer, HideMouseClickGUI, 900, -22
    Sleep, 150
    Gui, Mouser: Destroy
    MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
    TransparencyLevel := MouseVclickAlpha - MouseClickCounter*4
    BoxW := 15*ClickScale
    BoxH := 40*ClickScale
    MouseDistance := 10 * ClickScale
    MouseGetPos, mX, mY
    mY := mY - Ha/2
    if InStr(clicky, "LButton")
    {
       mX := mX - Wa*2 - MouseDistance
    } else if InStr(clicky, "MButton")
    {
       BoxW := 45 * ClickScale
       mX := mX - Wa/2
    } else if InStr(clicky, "RButton")
    {
       mX := mX + MouseDistance*2.5
    } else if InStr(clicky, "Wheelup")
    {
       BoxW := 50 * ClickScale
       BoxH := 15 * ClickScale
       mX := mX - Wa/2
       mY := mY - MouseDistance*2.5
    } else if InStr(clicky, "Wheeldown")
    {
       BoxW := 50 * ClickScale
       BoxH := 15 * ClickScale
       mX := mX - Wa/2
       mY := mY + Ha*2 + MouseDistance/2
    }

    InnerColor := "555555"
    OuterColor := "aaaaaa"
    BorderSize := 4
    RectW := BoxW - BorderSize*2
    RectH := BoxH - BorderSize*2

    CreateMouseGUI()

    Gui, Mouser: Color, %OuterColor%  ; outer rectangle
    Gui, Mouser: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
    Gui, Mouser: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarWin
    WinSet, Transparent, %TransparencyLevel%, MousarWin
    Sleep, 250
    WinSet, AlwaysOnTop, On, MousarWin
}

HideMouseClickGUI() {
    Thread, priority, -10
    Loop, {
       MouseDown := 0
       if GetKeyState("LButton","P")
          MouseDown := 1
       if GetKeyState("RButton","P")
          MouseDown := 1
       if GetKeyState("MButton","P")
          MouseDown := 1

       If (MouseDown=0)
       {
          Sleep, 250
          Gui, Mouser: Hide
          MouseClickCounter := 20
          SetTimer, HideMouseClickGUI, off
          Break
       } else
       {
          WinSet, Transparent, 55, MousarWin
       }
    }
}

ShowMouseIdleLocation() {
    Thread, priority, -10
    If (FlashIdleMouse=1) && (A_TimeIdlePhysical > (MouseIdleAfter*1000)) && !A_IsSuspended
    {
       MouseClickCounter := (MouseClickCounter > 10) ? 1 : 11
       AlphaVariator := IdleMouseAlpha - MouseClickCounter*3
       MouseGetPos, mX, mY
       BoxW := MouseIdleRadius
       BoxH := BoxW
       GuiGetSize(W, H, 3)
       mX := mX - W/2
       mY := mY - W/2
       BorderSize := 4
       RectW := BoxW - BorderSize*2
       RectH := BoxH - BorderSize*2
       InnerColor := "111111"
       OuterColor := "eeeeee"
       Gui, MouseIdlah: +AlwaysOnTop -Caption +ToolWindow +E0x20
       Gui, MouseIdlah: Color, %OuterColor%  ; outer rectangle
       Gui, MouseIdlah: Add, Progress, x%BorderSize% y%BorderSize% w%RectW% h%RectH% Background%InnerColor% c%InnerColor%, 100   ; inner rectangle
       Gui, MouseIdlah: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MouseIdlah
       WinSet, Transparent, %AlphaVariator%, MouseIdlah
       WinSet, AlwaysOnTop, On, MouseIdlah
    } else
    {
        Gui, MouseIdlah: Destroy
    }
    if (FlashIdleMouse=1) && A_IsSuspended
    {
       Gui, MouseIdlah: Destroy
       FlashIdleMouse := 0
    }
}

MouseHalo() {
    Thread, priority, -10
    If (ShowMouseHalo=1) && !A_IsSuspended
    {
       MouseGetPos, mX, mY
       BoxW := MouseHaloRadius
       BoxH := BoxW
       GuiGetSize(W, H, 2)
       mX := mX - W/2
       mY := mY - W/2
       Gui, MouseH: +AlwaysOnTop -Caption +ToolWindow +E0x20
       Gui, MouseH: Margin, 0, 0
       Gui, MouseH: Color, %MouseHaloColor%
       Gui, MouseH: Show, NoActivate x%mX% y%mY% w%BoxW% h%BoxH%, MousarHallo
       WinSet, Transparent, %MouseHaloAlpha%, MousarHallo
       WinSet, AlwaysOnTop, On, MousarHallo
    }

    If (ShowMouseHalo=1) && A_IsSuspended
    {
       Gui, MouseH: Destroy
       ShowMouseHalo := 0
    }
}

InitializeTray() {

    Menu, SubSetMenu, add, &Keyboard, ShowKBDsettings
    Menu, SubSetMenu, add, &Mouse, ShowMouseSettings
    Menu, SubSetMenu, add, &Sounds, ShowSoundsSettings
    Menu, SubSetMenu, add, &Typing mode, ShowTypeSettings
    Menu, SubSetMenu, add, &OSD appearances, ShowOSDsettings
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, &Never show the OSD, ToggleNeverDisplay
    if (NeverDisplayOSD=1)
       Menu, SubSetMenu, Check, &Never show the OSD
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, Restore defaults, DeleteSettings
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, Key &history, KeyHistoryWindow
    Menu, SubSetMenu, add
    Menu, SubSetMenu, add, &Update now, updateNow
    Menu, tray, tip, KeyPress OSD v%version%
    Menu, tray, NoStandard

    kbdList_count := DllCall("GetMenuItemCount", "ptr", MenuGetHandle("kbdList"))

    if (AutoDetectKBD=1) && (ForceKBD=0) && (loadedLangz=1) && (kbdList_count>1)
    {
       Menu, tray, add, &Monitor keyboard layout, ToggleConstantDetection
       Menu, tray, check, &Monitor keyboard layout
       if (ConstantAutoDetect=0)
          Menu, tray, uncheck, &Monitor keyboard layout
    }

    if (loadedLangz=1) && (kbdList_count>1)
       Menu, tray, add, &Installed keyboard layouts, :kbdList

    if (ConstantAutoDetect=0) && (ForceKBD=0) && (loadedLangz=1)
    {
       Menu, tray, add, &Detect keyboard layout now, DetectLangNow
       if (kbdList_count>1)
          Menu, tray, add, &Monitor keyboard layout, ToggleConstantDetection
    }
    Menu, tray, add
    Menu, tray, add, &Preferences, :SubSetMenu
    Menu, tray, add

    if (ForceKBD=1) && (loadedLangz=1)
    {
       niceNaming := (ForcedKBDlayout = 0) ? "A" : "B"
       Menu, tray, add, Toggle &forced layout (%niceNaming%), ToggleForcedLanguage
       Menu, tray, add
    }

    if (ConstantAutoDetect=0) && (loadedLangz=1)
       Menu, tray, add, &Detect keyboard layout now, DetectLangNow

    Menu, tray, add, &Toggle OSD positions, TogglePosition
    Menu, tray, add, &Capture2Text enable, ToggleCapture2Text
    Menu, tray, add
    Menu, tray, add, &KeyPress activated, SuspendScript
    Menu, tray, Check, &KeyPress activated
    Menu, tray, add, &Restart, ReloadScript
    Menu, tray, add
    Menu, tray, add, &Help, dummy
    Menu, tray, add, &About, AboutWindow
    Menu, tray, add
    Menu, tray, add, E&xit, KillScript
}

OnExit, KillScript

KeyHistoryWindow() {
  KeyHistory
}

DeleteSettings() {
    MsgBox, 4,, Are you sure you want to delete the stored settings?
    IfMsgBox Yes
    {
       FileSetAttrib, -R, %IniFile%
       FileDelete, %IniFile%
       Reload
    }
}

KillScript:
   ShaveSettings()
   ShowHotkey("Bye byeee :-)")
   Sleep, 300
ExitApp

SettingsGUI() {
   Global
   Gui, SettingsGUIA: destroy
   Gui, SettingsGUIA: Default
   Gui, SettingsGUIA: -sysmenu
   Gui, SettingsGUIA: margin, 15, 15
}

ShowTypeSettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()

    global editF1, editF2    
    deadKstatus := (DeadKeys=1) && !InStr(CurrentKBD, "unsupported") && !InStr(CurrentKBD, "unrecognized") ? "Dead keys present." : " "

    Gui, Add, Checkbox, x15 y15 gVerifyTypeOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys in the OSD, not just key combinations
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%DisableTypingMode% vDisableTypingMode, Disable typing mode
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%OnlyTypingMode% vOnlyTypingMode, Typing mode only

    Gui, Add, Checkbox, xp+0 yp+30 gVerifyTypeOptions Checked%enableTypingHistory% venableTypingHistory, Typed text history (with Page Up / Down)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%pgUDasHE% vpgUDasHE, Page Up / Down should behave as Home / End
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%UpDownAsHE% vUpDownAsHE, Up / Down arrow keys should behave as Home / End
    Gui, Add, Checkbox, xp+15 yp+20 gVerifyTypeOptions Checked%UpDownAsLR% vUpDownAsLR, ... or as the Left / Right keys
    Gui, Add, Checkbox, xp-15 yp+30 gVerifyTypeOptions Checked%pasteOSDcontent% vpasteOSDcontent, Ctrl+Shift+Insert to paste the OSD content into active text field
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%synchronizeMode% vsynchronizeMode, Synchronize with host app (Win+Ins) using Shift+Up, Home
    Gui, Add, text, xp+15 yp+15, By default, Ctrl+A [select all] is used to collect the text.

    Gui, Add, text, xp-15 yp+30, Display time when typing (in seconds)
    Gui, Add, Edit, xp+265 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %DisplayTimeTypingUser%
    Gui, Add, UpDown, vDisplayTimeTypingUser Range2-99, %DisplayTimeTypingUser%
    Gui, Add, text, xp-265 yp+20, Timer to resume typing with text related keys (in sec.)
    Gui, Add, Edit, xp+265 yp+0 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %ReturnToTypingUser%
    Gui, Add, UpDown, vReturnToTypingUser Range2-99, %ReturnToTypingUser%

    Gui, Add, Checkbox, x330 y15 gVerifyTypeOptions Checked%enterErasesLine% venterErasesLine, Enter and Escape keys erase texts from the OSD
    Gui, Add, Checkbox, xp+0 yp+20 Checked%enableAltGrUser% venableAltGrUser, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%CapslockBeeper% vCapslockBeeper, Make beeps when typing with CapsLock turned on

    Gui, Add, Checkbox, xp+0 yp+30 gVerifyTypeOptions Checked%ShowDeadKeys% vShowDeadKeys, Insert the dead key symbol in the OSD when typing
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%autoRemDeadKey% vautoRemDeadKey, Do not treat dead keys as a different character (generic symbol)
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyTypeOptions Checked%NoBindedDeadKeys% vNoBindedDeadKeys, Do not bind (ignore) known dead keys
    Gui, Add, text, xp+15 yp+15, Check this if you cannot use dead keys on supported layouts.
    Gui, Add, Checkbox, xp-15 yp+30 gVerifyTypeOptions Checked%alternativeJumps% valternativeJumps, Alternative rules to jump between words with Ctrl+Left/Right
    Gui, Add, text, xp+15 yp+15, Please note, applications have inconsistent rules for this.

    Gui, SettingsGUIA: font, bold
    Gui, SettingsGUIA: Add, text, xp+0 yp+30, Keyboard layout status: %deadKstatus%
    Gui, SettingsGUIA: font, normal
    Gui, Add, text, xp+0 yp+15 w280, %CurrentKBD%.
    
    Gui, SettingsGUIA: add, Button, xp+150 yp+20 w70 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Typing mode settings: KeyPress OSD
    VerifyTypeOptions()
}

VerifyTypeOptions() {
    GuiControlGet, DisableTypingMode
    GuiControlGet, ShowSingleKey
    GuiControlGet, enableAltGrUser
    GuiControlGet, enableTypingHistory
    GuiControlGet, ShowDeadKeys
    GuiControlGet, autoRemDeadKey
    GuiControlGet, DisplayTimeTypingUser
    GuiControlGet, ReturnToTypingUser
    GuiControlGet, OnlyTypingMode
    GuiControlGet, enterErasesLine
    GuiControlGet, pgUDasHE
    GuiControlGet, UpDownAsHE
    GuiControlGet, UpDownAsLR
    GuiControlGet, editF1
    GuiControlGet, editF2
    GuiControlGet, NoBindedDeadKeys

    if (ShowSingleKey=0)
    {
       GuiControl, Disable, DisableTypingMode
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, UpDownAsHE
       GuiControl, Disable, UpDownAsLR
       GuiControl, Disable, pgUDasHE
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, DisableTypingMode
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, autoRemDeadKey
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, pgUDasHE
       GuiControl, Enable, UpDownAsHE
       GuiControl, Enable, UpDownAsLR
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }
  
    if (DisableTypingMode=1)
    {
       GuiControl, Disable, CapslockBeeper
       GuiControl, Disable, enableTypingHistory
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
       GuiControl, Disable, DisplayTimeTypingUser
       GuiControl, Disable, ReturnToTypingUser
       GuiControl, Disable, OnlyTypingMode
       GuiControl, Disable, pgUDasHE
       GuiControl, Disable, UpDownAsHE
       GuiControl, Disable, UpDownAsLR
       GuiControl, Disable, enterErasesLine
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else if (ShowSingleKey!=0)
    {
       GuiControl, Enable, CapslockBeeper
       GuiControl, Enable, enableTypingHistory
       GuiControl, Enable, ShowDeadKeys
       GuiControl, Enable, autoRemDeadKey
       GuiControl, Enable, DisplayTimeTypingUser
       GuiControl, Enable, ReturnToTypingUser
       GuiControl, Enable, OnlyTypingMode
       GuiControl, Enable, enterErasesLine
       GuiControl, Enable, pgUDasHE
       GuiControl, Enable, UpDownAsHE
       GuiControl, Enable, UpDownAsLR
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    if (ShowDeadKeys=0)
    {
       GuiControl, Disable, autoRemDeadKey
    } else if ((DisableTypingMode!=1) || (ShowSingleKey!=1))
    {
       GuiControl, Enable, autoRemDeadKey
    }

    if (ShowSingleKey!=1)
       GuiControl, Disable, autoRemDeadKey

    if ((ForceKBD=0) && (AutoDetectKBD=0))
    {
       GuiControl, Disable, enableAltGrUser
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
    }

    if (OnlyTypingMode=0)
       GuiControl, Disable, enterErasesLine

    if (NoBindedDeadKeys=1)
    {
       GuiControl, Disable, ShowDeadKeys
       GuiControl, Disable, autoRemDeadKey
    } else if (DisableTypingMode=0)
    {
       GuiControl, Enable, ShowDeadKeys
       if (ShowDeadKeys=1)
          GuiControl, Enable, autoRemDeadKey
    }

    if (UpDownAsHE=1)
       GuiControl, , UpDownAsLR, 0

    if (UpDownAsLR=1)
       GuiControl, , UpDownAsHE, 0      
}

ShowSoundsSettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()

    Gui, SettingsGUIA: add, text, x15 y15, Make a beep when the following keys are released:
    Gui, Add, Checkbox, gVerifySoundsOptions xp+15 yp+20 Checked%KeyBeeper% vKeyBeeper, All bound keys
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%deadKeyBeeper% vdeadKeyBeeper, Recognized dead keys
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%ModBeeper% vModBeeper, Modifiers (Ctrl, Alt, WinKey, Shift)
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, On mouse clicks
    Gui, Add, Checkbox, xp+0 yp+20 Checked%BeepHiddenKeys% vBeepHiddenKeys, Even if such keys are not displayed in the OSD

    Gui, Add, Checkbox, gVerifySoundsOptions xp-15 yp+30 Checked%CapslockBeeper% vCapslockBeeper, Beep distinctively when typing with CapsLock turned on
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%beepFiringKeys% vbeepFiringKeys, Generic beep for every key fire
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%audioAlerts% vaudioAlerts, At start, beep for every failed key binding
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+30 Checked%LowVolBeeps% vLowVolBeeps, Play beeps at reduced volume
    Gui, Add, Checkbox, gVerifySoundsOptions xp+0 yp+20 Checked%prioritizeBeepers% vprioritizeBeepers, Prioritize beeps (may interfere with typing mode)
    if (missingAudios=1)
    {
       Gui, font, bold
       Gui, add, text, xp+0 yp+30, WARNING. Sound files are missing.
       Gui, add, text, xp+0 yp+30, The attempts to download them seem to have failed.
       Gui, add, text, xp+0 yp+30, The beeps will be synthesized at a high volume.
       Gui, font, normal
    }

    Gui, SettingsGUIA: add, Button, xp+0 yp+40 w70 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Sounds settings: KeyPress OSD
    VerifySoundsOptions()

    verifyNonCrucialFilesRan := 2
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

    verifyNonCrucialFiles()
}

VerifySoundsOptions() {

    if (ShowMouseButton=0 && VisualMouseClicks=0)
    {
       GuiControl, Disable, MouseBeeper
    } else 
    {
       GuiControl, Enable, MouseBeeper
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0)) || (NoBindedDeadKeys=1)
       GuiControl, Disable, deadKeyBeeper

    if (DisableTypingMode=1)
       GuiControl, Disable, CapslockBeeper

    if (missingAudios=1)
    {
       GuiControl, Disable, LowVolBeeps
       GuiControl, , LowVolBeeps, 0
    }
}

ShowKBDsettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()

    Gui, Add, text, x15 y15 w220, Status: %CurrentKBD%
    Gui, SettingsGUIA: add, text, xp+0 yp+40, Settings regarding keyboard layouts:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%AutoDetectKBD% vAutoDetectKBD, Detect keyboard layout at start
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ConstantAutoDetect% vConstantAutoDetect, Continuously detect layout changes
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%SilentDetection% vSilentDetection, Silent detection (no messages)
    Gui, Add, Checkbox, xp+0 yp+20 Checked%audioAlerts% vaudioAlerts, Beep for failed key bindings
    Gui, Add, Checkbox, xp+0 yp+20 Checked%enableAltGrUser% venableAltGrUser, Enable Ctrl+Alt / AltGr support
    Gui, Add, Checkbox, xp+0 yp+20 gForceKbdInfo Checked%ForceKBD% vForceKBD, Force detected keyboard layout (A / B)
    Gui, Add, Edit, xp+20 yp+20 w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout1, %ForcedKBDlayout1%
    Gui, Add, Edit, xp+73 yp+0 w68 r1 limit8 -multi -wantCtrlA -wantReturn -wantTab -wrap vForcedKBDlayout2, %ForcedKBDlayout2%
    Gui, Add, Checkbox, xp-93 yp+30 gVerifyKeybdOptions Checked%IgnoreAdditionalKeys% vIgnoreAdditionalKeys, Ignore specific keys (dot separated)
    Gui, Add, Edit, xp+20 yp+20 w140 r1 -multi -wantReturn -wantTab -wrap vIgnorekeysList, %IgnorekeysList%

    Gui, SettingsGUIA: add, text, x260 y15, Display behavior:
    Gui, Add, Checkbox, xp+10 yp+20 gVerifyKeybdOptions Checked%ShowSingleKey% vShowSingleKey, Show single keys
    Gui, Add, Checkbox, xp+0 yp+20 Checked%HideAnnoyingKeys% vHideAnnoyingKeys, Hide Left Click and PrintScreen
    Gui, Font, Bold
    Gui, Add, Checkbox, xp+0 yp+20 Checked%StickyKeys% vStickyKeys, Sticky keys mode
    Gui, Font, Normal
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowSingleModifierKey% vShowSingleModifierKey, Display modifiers
    Gui, Add, Checkbox, xp+0 yp+20 Checked%DifferModifiers% vDifferModifiers, Differ left and right modifiers
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCount% vShowKeyCount, Show key count
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowKeyCountFired% vShowKeyCountFired, Count number of key fires
    Gui, Add, Checkbox, xp+0 yp+20 gVerifyKeybdOptions Checked%ShowPrevKey% vShowPrevKey, Show previous key (delay in ms)
    Gui, Add, Edit, xp+180 yp+0 w24 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap vShowPrevKeyDelay, %ShowPrevKeyDelay%

    Gui, SettingsGUIA: add, text, xp-190 yp+35, Other options:
    Gui, Add, Checkbox, xp+10 yp+20 Checked%KeyboardShortcuts% vKeyboardShortcuts, Global keyboard shortcuts
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ShiftDisableCaps% vShiftDisableCaps, Shift turns off Caps Lock
    Gui, Add, Checkbox, xp+0 yp+20 Checked%ClipMonitor% vClipMonitor, Monitor clipboard changes

    Gui, SettingsGUIA: add, Button, x15 yp+10 w70 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Keyboard settings: KeyPress OSD
    VerifyKeybdOptions()
}

VerifyKeybdOptions() {
    GuiControlGet, AutoDetectKBD
    GuiControlGet, ConstantAutoDetect
    GuiControlGet, IgnoreAdditionalKeys
    GuiControlGet, ForceKBD
    GuiControlGet, ForcedKBDlayout1
    GuiControlGet, ForcedKBDlayout2
    GuiControlGet, ShowSingleKey
    GuiControlGet, HideAnnoyingKeys
    GuiControlGet, SilentDetection
    GuiControlGet, ShowSingleModifierKey
    GuiControlGet, ShowKeyCount
    GuiControlGet, ShowKeyCountFired
    GuiControlGet, ShowPrevKey
    GuiControlGet, enableAltGrUser

    if (ShowSingleModifierKey=0)
    {
       GuiControl, Disable, DifferModifiers
    } else
    {
       GuiControl, Enable, DifferModifiers
    }

    if (ShowPrevKey=0)
    {
       GuiControl, Disable, ShowPrevKeyDelay
    } else
    {
       GuiControl, Enable, ShowPrevKeyDelay
    }

    if (ShowKeyCount=0)
    {
       GuiControl, Disable, ShowKeyCountFired
    } else
    {
       GuiControl, Enable, ShowKeyCountFired
    }

    if (ShowSingleKey=0)
    {
       GuiControl, Disable, HideAnnoyingKeys
       GuiControl, Disable, ShowSingleModifierKey
    } else
    {
       GuiControl, Enable, HideAnnoyingKeys
       GuiControl, Enable, ShowSingleModifierKey
    }
  
    if (AutoDetectKBD=1)
    {
       GuiControl, Enable, ConstantAutoDetect
       GuiControl, Enable, ForceKBD
    } else 
    {
       GuiControl, Disable, ConstantAutoDetect
       GuiControl, , ForceKBD, 0
       GuiControl, Disable, ForceKBD
       GuiControl, Disable, ForcedKBDlayout1
       GuiControl, Disable, ForcedKBDlayout2
    }

    if (ForceKBD=1) && (AutoDetectKBD=1)
    {
       GuiControl, Enable, ForcedKBDlayout1
       GuiControl, Enable, ForcedKBDlayout2
       GuiControl, Disable, ConstantAutoDetect
    } else
    {
       GuiControl, Disable, ForcedKBDlayout1
       GuiControl, Disable, ForcedKBDlayout2
    }

    if ((ForceKBD=0) && (AutoDetectKBD=0))
    {
       GuiControl, Disable, SilentDetection
       GuiControl, Disable, enableAltGrUser
    } else
    {
       GuiControl, Enable, SilentDetection
       GuiControl, Enable, enableAltGrUser
    }

    if (IgnoreAdditionalKeys=1)
    {
       GuiControl, Enable, IgnorekeysList
    } else
    {
       GuiControl, Disable, IgnorekeysList
    }
}

ForceKbdInfo() {
    GuiControlGet, ForceKBD
    if (ForceKBD=1)
       MsgBox, , About Force Keyboard Layout, Please enter the keyboard layout codes you want to enforce. Please use the "Installed keyboard layouts" menu to easily define these. You can toggle between the two layouts with Ctrl+Alt+Shift+F7. See Help for more details.

    VerifyKeybdOptions()
}

ShowMouseSettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }
    
    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()
    global editF1, editF2, editF3, editF4, editF5, editF6, editF7, btn1

    Gui, Add, Checkbox, gVerifyMouseOptions x15 x15 Checked%ShowMouseHalo% vShowMouseHalo, Mouse halo / highlight
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%FlashIdleMouse% vFlashIdleMouse, Flash idle mouse to locate it
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%ShowMouseButton% vShowMouseButton, Show mouse clicks in the OSD
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%MouseBeeper% vMouseBeeper, Beep on mouse clicks
    Gui, Add, Checkbox, gVerifyMouseOptions xp+0 yp+20 Checked%VisualMouseClicks% vVisualMouseClicks, Visual mouse clicks (scale, alpha)
    Gui, Add, Edit, xp+16 yp+20 w45 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %ClickScaleUser%
    Gui, Add, UpDown, vClickScaleUser Range3-90, %ClickScaleUser%
    Gui, Add, Edit, xp+50 yp+0 w45 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %MouseVclickAlpha%
    Gui, Add, UpDown, vMouseVclickAlpha Range10-240, %MouseVclickAlpha%

    Gui, Add, Edit, x335 y15 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %MouseHaloRadius%
    Gui, Add, UpDown, vMouseHaloRadius Range5-950, %MouseHaloRadius%
    Gui, Add, Progress, xp+0 yp+25 w35 h20 BackgroundBlack c%MouseHaloColor% vMouseHaloColor, 100
    Gui, Add, Button, xp+36 yp+0 w25 h20 gChooseColorHalo vBtn1, P
    Gui, Add, Edit, xp-36 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %MouseHaloAlpha%
    Gui, Add, UpDown, vMouseHaloAlpha Range10-240, %MouseHaloAlpha%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %MouseIdleAfter%
    Gui, Add, UpDown, vMouseIdleAfter Range3-950, %MouseIdleAfter%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %MouseIdleRadius%
    Gui, Add, UpDown, vMouseIdleRadius Range5-950, %MouseIdleRadius%
    Gui, Add, Edit, xp+0 yp+25 w60 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %IdleMouseAlpha%
    Gui, Add, UpDown, vIdleMouseAlpha Range10-240, %IdleMouseAlpha%

    Gui, Add, text, x210 y15, Halo radius:
    Gui, Add, text, xp+0 yp+25, Halo color:
    Gui, Add, text, xp+0 yp+25, Halo alpha:
    Gui, Add, text, xp+0 yp+25, Mouse idle after (in sec.)
    Gui, Add, text, xp+0 yp+25, Idle halo radius:
    Gui, Add, text, xp+0 yp+25, Idle halo alpha:

    Gui, SettingsGUIA: add, Button, x15 y160 w70 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, Mouse settings: KeyPress OSD

    VerifyMouseOptions()
}

ChooseColorHalo() {
    if (ShowMouseHalo=0)
       Return

    cc := 0
    cc := dlg_color(cc,hwnd)
    MouseHaloColor := hexRGB(cc)
    StringRight, MouseHaloColor, MouseHaloColor, 6
    GuiControl, +c%MouseHaloColor%, MouseHaloColor
}

hexRGB(c) {
  setformat, IntegerFast, H
  c := (c&255)<<16|(c&65280)|(c>>16),c:=SubStr(c,1)
  SetFormat, IntegerFast, D
  return c
}

Dlg_Color(Color,hwnd) {
  static
  if !cc {
    VarSetCapacity(CUSTOM,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
    Loop, 16 {
      NumPut(col,CUSTOM,(A_Index-1)*4,"UInt")
    }
  }

  NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr")
  ,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
  ,NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
  ret := DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")

  if !ret
     exit

  Loop,16
    NumGet(custom,(A_Index-1)*4,"UInt")

  Color := NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt")
  return Color
}

VerifyMouseOptions() {
    GuiControlGet, FlashIdleMouse
    GuiControlGet, ShowMouseHalo
    GuiControlGet, ShowMouseButton
    GuiControlGet, VisualMouseClicks

    if (ShowMouseButton=0 && VisualMouseClicks=0)
    {
       GuiControl, Disable, MouseBeeper
    } else 
    {
       GuiControl, Enable, MouseBeeper
    }

    if (VisualMouseClicks=0)
    {
       GuiControl, Disable, ClickScaleUser
       GuiControl, Disable, MouseVclickAlpha
       GuiControl, Disable, editF1
       GuiControl, Disable, editF2
    } else
    {
       GuiControl, Enable, ClickScaleUser
       GuiControl, Enable, MouseVclickAlpha
       GuiControl, Enable, editF1
       GuiControl, Enable, editF2
    }

    if (FlashIdleMouse=0)
    {
       GuiControl, Disable, MouseIdleAfter
       GuiControl, Disable, MouseIdleRadius
       GuiControl, Disable, IdleMouseAlpha
       GuiControl, Disable, editF5
       GuiControl, Disable, editF6
       GuiControl, Disable, editF7
    } else
    {
       GuiControl, Enable, MouseIdleAfter
       GuiControl, Enable, MouseIdleRadius
       GuiControl, Enable, IdleMouseAlpha
       GuiControl, Enable, editF5
       GuiControl, Enable, editF6
       GuiControl, Enable, editF7
    }

    disabledColor := "cccccc"
    if (ShowMouseHalo=0)
    {
       GuiControl, Disable, MouseHaloRadius
       GuiControl, +c%disabledColor%, MouseHaloColor
       GuiControl, Disable, MouseHaloAlpha
       GuiControl, Disable, btn1
       GuiControl, Disable, editF3
       GuiControl, Disable, editF4
    } else
    {
       GuiControl, Enable, MouseHaloRadius
       GuiControl, +c%MouseHaloColor%, MouseHaloColor
       GuiControl, Enable, MouseHaloAlpha
       GuiControl, Enable, btn1
       GuiControl, Enable, editF3
       GuiControl, Enable, editF4
    }
}

ShowOSDsettings() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    if (A_IsSuspended!=1)
       Gosub, SuspendScript

    Sleep, 50
    prefOpen := 1
    SettingsGUI()
    EnumFonts()

    static positionB
    global editF1, editF2, editF3, editF4, editF5, editF6, editF7, editF8, editF9, btn1, btn2, btn3, btn4, btn5
    GUIposition := GUIposition + 1

    Gui, SettingsGUIA: Add, Radio, x15 y35 gVerifyOsdOptions Checked vGUIposition, Position A (x, y)
    Gui, Add, Radio, xp+0 yp+25 gVerifyOsdOptions Checked%GUIposition% vPositionB, Position B (x, y)
    Gui, Add, Button, xp+145 yp-25 w25 h20 gLocatePositionA vBtn1, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF1, %GuiXa%
    Gui, Add, UpDown, vGuiXa 0x80 Range-9995-9998, %GuiXa%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF2, %GuiYa%
    Gui, Add, UpDown, vGuiYa 0x80 Range-9995-9998, %GuiYa%
    Gui, Add, Button, xp-86 yp+25 w25 h20 gLocatePositionB vBtn2, L
    Gui, Add, Edit, xp+27 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF3, %GuiXb%
    Gui, Add, UpDown, vGuiXb 0x80 Range-9995-9998, %GuiXb%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit4 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF4, %GuiYb%
    Gui, Add, UpDown, vGuiYb 0x80 Range-9995-9998, %GuiYb%
    Gui, Add, DropDownList, xp-150 yp+25 w145 Sort Choose1 vFontName, %FontName%
    Gui, Add, Edit, xp+150 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF5, %FontSize%
    Gui, Add, UpDown, vFontSize Range7-295, %FontSize%
    Gui, Add, Progress, xp-60 yp+25 w55 h20 BackgroundBlack c%OSDtextColor% vOSDtextColor, 100
    Gui, Add, Button, xp+60 yp+0 w55 h20 gChooseColorTEXT vBtn3, Pick
    Gui, Add, Progress, xp-60 yp+25 w55 h20 BackgroundBlack c%OSDbgrColor% vOSDbgrColor, 100
    Gui, Add, Button, xp+60 yp+0 w55 h20 gChooseColorBGR vBtn4, Pick
    Gui, Add, Progress, xp-60 yp+25 w55 h20 BackgroundBlack c%CapsColorHighlight% vCapsColorHighlight, 100
    Gui, Add, Button, xp+60 yp+0 w55 h20 gChooseCapsColor vBtn5, Pick
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit2 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF6, %DisplayTimeUser%
    Gui, Add, UpDown, vDisplayTimeUser Range2-99, %DisplayTimeUser%
    Gui, Add, Edit, xp+0 yp+25 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF7, %GuiWidth%
    Gui, Add, UpDown, vGuiWidth Range55-990, %GuiWidth%
    Gui, Add, Edit, xp+60 yp+0 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF8, %maxGuiWidth%
    Gui, Add, UpDown, vmaxGuiWidth Range55-995, %maxGuiWidth%
    Gui, Add, Edit, xp-60 yp+25 w55 r1 limit3 -multi number -wantCtrlA -wantReturn -wantTab -wrap veditF9, %OSDautosizeFactory%
    Gui, Add, UpDown, vOSDautosizeFactory Range10-400, %OSDautosizeFactory%

    Gui, Add, text, x15 y15, OSD location presets. Click L to define each.
    Gui, Add, text, xp+0 yp+72, Font
    Gui, Add, text, xp+0 yp+25, Text color
    Gui, Add, text, xp+0 yp+25, Background color
    Gui, Add, text, xp+0 yp+25, Caps lock highlight color
    Gui, Add, text, xp+0 yp+25, Display time (in seconds)
    Gui, Add, text, xp+0 yp+25, Width (fixed size / dynamic max,)
    Gui, Add, text, xp+0 yp+25, Text width factor (lower = larger)
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%OSDautosize% vOSDautosize, Auto-resize OSD (screen DPI: %A_ScreenDPI%)
    Gui, Add, Checkbox, xp+0 yp+25 Checked%OSDborder% vOSDborder, System border around OSD
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%FavorRightoLeft% vFavorRightoLeft, Favor right alignment
    Gui, Add, Checkbox, xp+0 yp+25 gVerifyOsdOptions Checked%NeverRightoLeft% vNeverRightoLeft, Never align to the right
    Gui, Add, text, xp+15 yp+15 w250, Recommended if you want to place the OSD on a secondary screen
    Gui, Add, Checkbox, xp-15 yp+35 Checked%JumpHover% vJumpHover, Toggle OSD positions when mouse runs over it

    Loop, % FontList.MaxIndex() {
      GuiControl, , FontName, % FontList[A_Index]
    }

    Gui, SettingsGUIA: add, Button, xp+0 yp+40 w70 h30 Default gApplySettings, A&pply
    Gui, SettingsGUIA: add, Button, xp+75 yp+0 w70 h30 gCloseSettings, C&ancel
    Gui, SettingsGUIA: show, autoSize, OSD appearances: KeyPress OSD

    VerifyOsdOptions()
}

VerifyOsdOptions() {
    GuiControlGet, OSDautosize
    GuiControlGet, NeverRightoLeft
    GuiControlGet, FavorRightoLeft
    GuiControlGet, GUIposition

    if (NeverRightoLeft=1)
    {
        GuiControl, Disable, FavorRightoLeft
    } else
    {
        GuiControl, Enable, FavorRightoLeft
    }

    if (FavorRightoLeft=1)
    {
        GuiControl, Disable, NeverRightoLeft
        GuiControl, , NeverRightoLeft, 0
    } else
    {
        GuiControl, Enable, NeverRightoLeft
    }

    if (GUIposition=0)
    {
        GuiControl, Disable, GuiXa
        GuiControl, Disable, GuiYa
        GuiControl, Disable, btn1
        GuiControl, Disable, editF1
        GuiControl, Disable, editF2
        GuiControl, Enable, GuiXb
        GuiControl, Enable, GuiYb
        GuiControl, Enable, btn2
        GuiControl, Enable, editF3
        GuiControl, Enable, editF4
    } else
    {
        GuiControl, Enable, GuiXa
        GuiControl, Enable, GuiYa
        GuiControl, Enable, btn1
        GuiControl, Enable, editF1
        GuiControl, Enable, editF2
        GuiControl, Disable, GuiXb
        GuiControl, Disable, GuiYb
        GuiControl, Disable, btn2
        GuiControl, Disable, editF3
        GuiControl, Disable, editF4
    }

    if (OSDautosize=0)
    {
        GuiControl, Enable, GuiWidth
        GuiControl, Enable, editF7
        GuiControl, Disable, maxGuiWidth
        GuiControl, Disable, editF8
    } else
    {
        GuiControl, Disable, GuiWidth
        GuiControl, Disable, editF7
        GuiControl, Enable, maxGuiWidth
        GuiControl, Enable, editF8
    }
}

LocatePositionA() {
    GuiControlGet, GUIposition

    if (GUIposition=0)
       Return

    ToolTip, Move mouse to desired location and click
    CoordMode Mouse, Screen
    KeyWait, LButton, D, T10
    MouseGetPos, x, y
    ToolTip
    GuiControl, , GuiXa, %x%
    GuiControl, , GuiYa, %y%
}

LocatePositionB() {
    GuiControlGet, GUIposition

    if (GUIposition=0)
    {
        ToolTip, Move mouse to desired location and click
        CoordMode Mouse, Screen
        KeyWait, LButton, D, T10
        ToolTip
        MouseGetPos, x, y
        GuiControl, , GuiXb, %x%
        GuiControl, , GuiYb, %y%
    } else
    {
        Return
    }
}

EnumFonts() {
    hDC := DllCall("GetDC", "UInt", DllCall("GetDesktopWindow"))
    Callback := RegisterCallback("EnumFontsCallback", "F")
    DllCall("EnumFontFamilies", "UInt", hDC, "UInt", 0, "Ptr", Callback, "UInt", lParam := 0)
    DllCall("ReleaseDC", "UInt", hDC)
}

EnumFontsCallback(lpelf) {
    FontList.Push(StrGet(lpelf + 28, 32))
    Return True
}

ChooseColorBGR() {
    cc := 0
    cc := dlg_color(cc,hwnd)
    OSDbgrColor := hexRGB(cc)
    StringRight, OSDbgrColor, OSDbgrColor, 6
    GuiControl, +c%OSDbgrColor%, OSDbgrColor
}

ChooseColorTEXT() {
    cc := 0
    cc := dlg_color(cc,hwnd)
    OSDtextColor := hexRGB(cc)
    StringRight, OSDtextColor, OSDtextColor, 6
    GuiControl, +c%OSDtextColor%, OSDtextColor
}

ChooseCapsColor() {
    cc := 0
    cc := dlg_color(cc,hwnd)
    CapsColorHighlight := hexRGB(cc)
    StringRight, CapsColorHighlight, CapsColorHighlight, 6
    GuiControl, +c%CapsColorHighlight%, CapsColorHighlight
}

ApplySettings() {
    Gui, SettingsGUIA: Submit, NoHide

    CheckSettings()
    if (ForceKBD=1) || (AutoDetectKBD=1)
    {
       ReloadCounter := 1
       IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
    }
    Sleep, 20
    ShaveSettings()
    Sleep, 20
    Reload
}

AboutWindow() {
    if (prefOpen = 1)
    {
        SoundBeep, 300, 900
        WinActivate, KeyPress OSD
        return
    }

    SettingsGUI()

    Gui, SettingsGUIA: add, link, x16 y50, AHK script developed by <a href="http://marius.sucan.ro">Marius Șucan</a>. Send <a href="mailto:marius.sucan@gmail.com">feedback</a>.
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Based on KeypressOSD v2.22 by Tmplinshi.
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Freeware. Open source. For Windows XP, Vista, 7, 8, and 10.
    Gui, SettingsGUIA: add, text, xp+0 yp+35, Many thanks to the great people from #ahk (irc.freenode.net), 
    Gui, SettingsGUIA: add, text, xp+0 yp+20, ... in particular to Phaleth, Drugwash, Tidbit and Saiapatsu.
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Special mention: Neuromancer.
    Gui, SettingsGUIA: add, text, xp+0 yp+35, This contains code also from: Maestrith (color picker),
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Alguimist (font list generator), VxE (GuiGetSize),
    Gui, SettingsGUIA: add, text, xp+0 yp+20, Sean (GetTextExtentPoint), Helgef (toUnicodeEx), Tidbit and Lexikos.
    Gui, SettingsGUIA: add, Button, xp+0 yp+35 w75 Default gCloseWindow, &Close
    Gui, SettingsGUIA: add, Button, xp+80 yp+0 w85 gChangeLog, Version &history
    Gui, SettingsGUIA: add, text, xp+90 yp+1, Released: %releaseDate%
    Gui, Font, s20 bold, Arial, -wrap
    Gui, SettingsGUIA: add, text, x15 y15, KeyPress OSD v%version%
    Gui, SettingsGUIA: show, autoSize, About KeyPress OSD v%version%
}

CloseWindow() {
    Gui, SettingsGUIA: Destroy
}

CloseSettings() {
    Reload
}

changelog() {
     Gui, SettingsGUIA: Destroy

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile

     if (!FileExist(historyFile) || (ForceDownloadExternalFiles=1))
     {
         soundbeep
         UrlDownloadToFile, %historyFileURL%, %historyFile%
         Sleep, 4000
     }

     if FileExist(historyFile)
     {
         FileRead, Contents, %historyFile%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                 FileGetTime, fileDate, %historyFile%
                 timeNow := %A_Now%
                 EnvSub, timeNow, %fileDate%, Days

                 if timeNow > 10
                    MsgBox, Version history seems too old. Please use the Update now option from the tray menu. The file will be opened now.

                Run, %historyFile%
             } Else
             {
                SoundBeep
                MsgBox, 4,, Corrupt file: keypress-osd-changelog.txt. The attempt to download it seems to have failed. To try again file must be deleted. Do you agree?
                IfMsgBox Yes
                {
                   FileDelete, %historyFile%
                }
             }
         }
     } else 
     {
         SoundBeep
         MsgBox, Missing file: %historyFile%. The attempt to download it seems to have failed.
     }
}

downLangFile() {

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     langyFile := "keypress-osd-languages.ini"
     langyFileURL := baseURL langyFile
     IniRead, ReloadCounter, %IniFile%, TempSettings, ReloadCounter, 0

     if (!FileExist(langyFile) || (ForceDownloadExternalFiles=1))
     {
         UrlDownloadToFile, %langyFileURL%, %langyFile%
         Sleep, 5000
     }

     if FileExist(langyFile)
     {
         FileRead, Contents, %langyFile%
         if !ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - language definitions")
             {
                langFileDownloaded := 1
                Sleep, 300
             } Else
             {
                langFileDownloaded := 0
                SoundBeep
                FileDelete, %langyFile%
                MsgBox, Incorrect contents for the downloaded file: %langyFile%. File deleted. Automatic keyboard detection is now disabled.
             }
         }
     } else 
     {
         langFileDownloaded := 0
         SoundBeep
         MsgBox, Missing file: %langyFile%. The attempt to download it seems to have failed. Automatic keyboard detection is now disabled.
     }

     if (langFileDownloaded!=1)
     {
        ForceKBD := 0
        AutoDetectKBD := 0
        IniWrite, %AutoDetectKBD%, %IniFile%, SavedSettings, AutoDetectKBD
        IniWrite, %ForceKBD%, %IniFile%, SavedSettings, ForceKBD
        Sleep, 200
        if (ReloadCounter<3)
        {
           ReloadCounter := ReloadCounter+1
           IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
           Reload
        }
     }

     if (langFileDownloaded=1) && (ReloadCounter<3)
     {
        ReloadCounter := ReloadCounter+1
        IniWrite, %ReloadCounter%, %IniFile%, TempSettings, ReloadCounter
        Reload
     }
}

updateNow() {
     if (A_IsSuspended!=1)
        Gosub, SuspendScript

     if A_IsCompiled
        MsgBox, This is a compiled version. The update procedure yields to nothing. In the future this will be fixed. :-)

     MsgBox, 4, Question, Do you want to abort updating?
     IfMsgBox Yes
     {
       Gosub, SuspendScript
       Return
     }

     Sleep, 150
     prefOpen := 1

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileTmp := "temp-keypress-osd-changelog.txt"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile
     langyFileTmp := "temp-keypress-osd-languages.ini"
     langyFile := "keypress-osd-languages.ini"
     langyFileURL := baseURL langyFile
     mainFileTmp := A_IsCompiled ? "source-keypress-osd.ahk" : "temp-keypress-osd.ahk"
     mainFile := "keypress-osd.ahk"
     mainFileURL := baseURL mainFile
     thisFile := A_ScriptName

     ShowLongMsg("Updating files: 1 / 3. Please wait...")
     UrlDownloadToFile, %historyFileURL%, %historyFileTmp%
     Sleep, 4000

     if FileExist(historyFileTmp)
     {
         FileRead, Contents, %historyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                ShowLongMsg("Updating files: Version history. OK")
                Sleep, 1350
                changelogDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Version history: CORRUPT")
                Sleep, 1350
                changelogCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Version history: FAIL")
         Sleep, 1350
         changelogDownloaded := 0
     }

     ShowLongMsg("Updating files: 2 / 3. Please wait...")
     UrlDownloadToFile, %langyFileURL%, %langyFileTmp%
     Sleep, 4000

     if FileExist(langyFileTmp)
     {
         FileRead, Contents, %langyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "; // KeyPress OSD - language definitions")
             {
                ShowLongMsg("Updating files: Language definitions: OK")
                Sleep, 1350
                langsDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Language definitions: CORRUPT")
                Sleep, 1350
                langsCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Language definitions: FAIL")
         Sleep, 1350
         langsDownloaded := 0
     }

     ShowLongMsg("Updating files: 3 / 3. Please wait...")
     UrlDownloadToFile, %mainFileURL%, %mainFileTmp%
     Sleep, 4000

     if FileExist(mainFileTmp)
     {
         FileRead, Contents, %mainFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "; KeypressOSD.ahk - main file")
             {
                ShowLongMsg("Updating files: Main code: OK")
                Sleep, 1350
                ahkDownloaded := 1
             } Else
             {
                ShowLongMsg("Updating files: Main code: CORRUPT")
                Sleep, 1350
                ahkCorrupted := 1
             }
         }
     } else 
     {
         ShowLongMsg("Updating files: Main code: FAIL")
         Sleep, 1350
         ahkDownloaded := 0
     }

     if (changelogCorrupted=1 || changelogDownloaded=0 || langsCorrupted=1 || langsDownloaded=0 || ahkCorrupted=1 || ahkDownloaded=0)
        someErrors := 1

     if (changelogDownloaded=0 && langsDownloaded=0 && ahkDownloaded=0)
        completeFailure := 1

     if (changelogDownloaded=1 && langsDownloaded=1 && ahkDownloaded=1)
        completeSucces := 1

     if (completeFailure=1)
     {
        MsgBox, 4, Error, Unable to download any file. Server is offline or no Internet connection. Do you want to try again?
        IfMsgBox Yes
        {
           updateNow()
        } else
        {
            FileDelete, mainFileTmp
            FileDelete, historyFileTmp
            FileDelete, langyFileTmp
        }
     }

     if (completeSucces=1)
     {
        FileMove, %mainFileTmp%, %thisFile%, 1
        FileMove, %historyFileTmp%, %historyFile%, 1
        FileMove, %langyFileTmp%, %langyFile%, 1
        MsgBox, Update seems to be succesful. No errors detected. The script will now reload.
        Reload
     }

     if (someErrors=1)
     {
        MsgBox, Errors occured during the update. The script will now reload.
        if changelogDownloaded=1
           FileMove, %historyFileTmp%, %historyFile%, 1

        if langsDownloaded=1
           FileMove, %langyFileTmp%, %langyFile%, 1

        if ahkDownloaded=1
           FileMove, %mainFileTmp%, %thisFile%, 1

        if ahkCorrupted=1
           FileDelete, %mainFileTmp%

        if changelogCorrupted=1
           FileDelete, %historyFileTmp%

        if langsCorrupted=1
           FileDelete, %langyFileTmp%

        Reload
     }
}

verifyNonCrucialFiles() {

     baseURL := "http://marius.sucan.ro/media/files/blog/ahk-scripts/"
     historyFileTmp := "temp-keypress-osd-changelog.txt"
     historyFile := "keypress-osd-changelog.txt"
     historyFileURL := baseURL historyFile

     soundFile1 := "sound-firedkey1.wav"
     soundFile2 := "sound-firedkey0.wav"
     soundFile3 := "sound-deadkeys1.wav"
     soundFile4 := "sound-mods1.wav"
     soundFile5 := "sound-clicks1.wav"
     soundFile6 := "sound-caps1.wav"
     soundFile7 := "sound-keys1.wav"
     soundFile8 := "sound-clicks0.wav"
     soundFile9 := "sound-mods0.wav"
     soundFile10 := "sound-deadkeys0.wav"
     soundFile11 := "sound-keys0.wav"
     soundFile12 := "sound-caps0.wav"
     soundFile1url := baseURL soundFile1
     soundFile2url := baseURL soundFile2
     soundFile3url := baseURL soundFile3
     soundFile4url := baseURL soundFile4
     soundFile5url := baseURL soundFile5
     soundFile6url := baseURL soundFile6
     soundFile7url := baseURL soundFile7
     soundFile8url := baseURL soundFile8
     soundFile9url := baseURL soundFile9
     soundFile10url := baseURL soundFile10
     soundFile11url := baseURL soundFile11
     soundFile12url := baseURL soundFile12

     IniRead, verifyNonCrucialFilesRan, %inifile%, TempSettings, verifyNonCrucialFilesRan, 0

     if (verifyNonCrucialFilesRan>3)
     {
        if FileExist(soundFile1) && FileExist(soundFile2) && FileExist(soundFile3) && FileExist(soundFile4) && FileExist(soundFile5) && FileExist(soundFile6) && FileExist(soundFile7) && FileExist(soundFile8) && FileExist(soundFile9) && FileExist(soundFile10) && FileExist(soundFile11) && FileExist(soundFile12)
           missingAudios := 0

        Return
     }

     if !FileExist(soundFile1)
        UrlDownloadToFile, %soundFile1url%, %soundFile1%
     if !FileExist(soundFile2)
        UrlDownloadToFile, %soundFile2url%, %soundFile2%
     if !FileExist(soundFile3)
        UrlDownloadToFile, %soundFile3url%, %soundFile3%
     if !FileExist(soundFile4)
        UrlDownloadToFile, %soundFile4url%, %soundFile4%
     if !FileExist(soundFile5)
        UrlDownloadToFile, %soundFile5url%, %soundFile5%
     if !FileExist(soundFile6)
        UrlDownloadToFile, %soundFile6url%, %soundFile6%
     if !FileExist(soundFile7)
        UrlDownloadToFile, %soundFile7url%, %soundFile7%
     if !FileExist(soundFile8)
        UrlDownloadToFile, %soundFile8url%, %soundFile8%
     if !FileExist(soundFile9)
        UrlDownloadToFile, %soundFile9url%, %soundFile9%
     if !FileExist(soundFile10)
        UrlDownloadToFile, %soundFile10url%, %soundFile10%
     if !FileExist(soundFile11)
        UrlDownloadToFile, %soundFile10url%, %soundFile11%
     if !FileExist(soundFile12)
        UrlDownloadToFile, %soundFile10url%, %soundFile12%

     if !FileExist(historyFile)
        UrlDownloadToFile, %historyFileURL%, %historyFileTmp%

     if FileExist(historyFileTmp)
     {
         FileRead, Contents, %historyFileTmp%
         if not ErrorLevel
         {
             StringLeft, Contents, Contents, 100
             if InStr(contents, "// KeyPress OSD - CHANGELOG")
             {
                FileMove, %historyFileTmp%, %historyFile%, 1
             } Else
             {
                FileDelete, historyFileTmp
             }
         }
     } else 
     {
         changelogDownloaded := 0
     }

    static filesz := ["sound-firedkey1.wav", "sound-firedkey0.wav", "sound-clicks1.wav", "sound-clicks0.wav", "sound-caps1.wav", "sound-caps0.wav", "sound-keys1.wav", "sound-keys0.wav", "sound-mods0.wav", "sound-mods1.wav", "sound-deadkeys0.wav", "sound-deadkeys1.wav"]
    Sleep, 500
    for i, audioz in filesz
    {
      Sleep, 100
      if FileExist(audioz)
      {
          FileRead, Contents, %audioz%
          if not ErrorLevel
          {
              StringLeft, Contents, Contents, 50
              if InStr(contents, "RIFF")
              {
                 audioDownloadFailed := 0
              } Else
              {
                 audioDownloadFailed := 1
                 FileDelete, %audioz%
              }
          }
      }
    }

    Sleep, 500

    verifyNonCrucialFilesRan := verifyNonCrucialFilesRan+1
    IniWrite, %verifyNonCrucialFilesRan%, %inifile%, TempSettings, verifyNonCrucialFilesRan

    if FileExist(soundFile1) && FileExist(soundFile2) && FileExist(soundFile3) && FileExist(soundFile4) && FileExist(soundFile5) && FileExist(soundFile6) && FileExist(soundFile7) && FileExist(soundFile8) && FileExist(soundFile9) && FileExist(soundFile10) && FileExist(soundFile11) && FileExist(soundFile12) && (audioDownloadFailed=0)
       missingAudios := 0
}

ShaveSettings() {
  firstRun := 0

  IniWrite, %alternativeJumps%, %inifile%, SavedSettings, alternativeJumps
  IniWrite, %audioAlerts%, %inifile%, SavedSettings, audioAlerts
  IniWrite, %AutoDetectKBD%, %inifile%, SavedSettings, AutoDetectKBD
  IniWrite, %autoRemDeadKey%, %inifile%, SavedSettings, autoRemDeadKey
  IniWrite, %beepFiringKeys%, %inifile%, SavedSettings, beepFiringKeys
  IniWrite, %BeepHiddenKeys%, %inifile%, SavedSettings, BeepHiddenKeys
  IniWrite, %CapsColorHighlight%, %inifile%, SavedSettings, CapsColorHighlight
  IniWrite, %CapslockBeeper%, %inifile%, SavedSettings, CapslockBeeper
  IniWrite, %ClickScaleUser%, %inifile%, SavedSettings, ClickScaleUser
  IniWrite, %ClipMonitor%, %inifile%, SavedSettings, ClipMonitor
  IniWrite, %ConstantAutoDetect%, %inifile%, SavedSettings, ConstantAutoDetect
  IniWrite, %deadKeyBeeper%, %inifile%, SavedSettings, deadKeyBeeper
  IniWrite, %DifferModifiers%, %inifile%, SavedSettings, DifferModifiers
  IniWrite, %DisableTypingMode%, %inifile%, SavedSettings, DisableTypingMode
  IniWrite, %DisplayTimeTypingUser%, %inifile%, SavedSettings, DisplayTimeTypingUser
  IniWrite, %DisplayTimeUser%, %inifile%, SavedSettings, DisplayTimeUser
  IniWrite, %enableAltGrUser%, %inifile%, SavedSettings, enableAltGrUser
  IniWrite, %enableTypingHistory%, %inifile%, SavedSettings, enableTypingHistory
  IniWrite, %enterErasesLine%, %inifile%, SavedSettings, enterErasesLine
  IniWrite, %FavorRightoLeft%, %inifile%, SavedSettings, FavorRightoLeft
  IniWrite, %firstRun%, %inifile%, SavedSettings, firstRun
  IniWrite, %FlashIdleMouse%, %inifile%, SavedSettings, FlashIdleMouse
  IniWrite, %FontName%, %inifile%, SavedSettings, FontName
  IniWrite, %FontSize%, %inifile%, SavedSettings, FontSize
  IniWrite, %ForcedKBDlayout%, %inifile%, SavedSettings, ForcedKBDlayout
  IniWrite, %ForcedKBDlayout1%, %inifile%, SavedSettings, ForcedKBDlayout1
  IniWrite, %ForcedKBDlayout2%, %inifile%, SavedSettings, ForcedKBDlayout2
  IniWrite, %ForceKBD%, %inifile%, SavedSettings, ForceKBD
  IniWrite, %GUIposition%, %inifile%, SavedSettings, GUIposition
  IniWrite, %GuiWidth%, %inifile%, SavedSettings, GuiWidth
  IniWrite, %GuiXa%, %inifile%, SavedSettings, GuiXa
  IniWrite, %GuiXb%, %inifile%, SavedSettings, GuiXb
  IniWrite, %GuiYa%, %inifile%, SavedSettings, GuiYa
  IniWrite, %GuiYb%, %inifile%, SavedSettings, GuiYb
  IniWrite, %HideAnnoyingKeys%, %inifile%, SavedSettings, HideAnnoyingKeys
  IniWrite, %IdleMouseAlpha%, %inifile%, SavedSettings, IdleMouseAlpha
  IniWrite, %IgnoreAdditionalKeys%, %inifile%, SavedSettings, IgnoreAdditionalKeys
  IniWrite, %IgnorekeysList%, %inifile%, SavedSettings, IgnorekeysList
  IniWrite, %JumpHover%, %inifile%, SavedSettings, JumpHover
  IniWrite, %KeyBeeper%, %inifile%, SavedSettings, KeyBeeper
  IniWrite, %KeyboardShortcuts%, %inifile%, SavedSettings, KeyboardShortcuts
  IniWrite, %LowVolBeeps%, %inifile%, SavedSettings, LowVolBeeps
  IniWrite, %maxGuiWidth%, %inifile%, SavedSettings, maxGuiWidth
  IniWrite, %ModBeeper%, %inifile%, SavedSettings, ModBeeper
  IniWrite, %MouseBeeper%, %inifile%, SavedSettings, MouseBeeper
  IniWrite, %MouseHaloAlpha%, %inifile%, SavedSettings, MouseHaloAlpha
  IniWrite, %MouseHaloColor%, %inifile%, SavedSettings, MouseHaloColor
  IniWrite, %MouseHaloRadius%, %inifile%, SavedSettings, MouseHaloRadius
  IniWrite, %MouseIdleAfter%, %inifile%, SavedSettings, MouseIdleAfter
  IniWrite, %MouseIdleRadius%, %inifile%, SavedSettings, MouseIdleRadius
  IniWrite, %MouseVclickAlpha%, %inifile%, SavedSettings, MouseVclickAlpha
  IniWrite, %NeverDisplayOSD%, %inifile%, SavedSettings, NeverDisplayOSD
  IniWrite, %NeverRightoLeft%, %inifile%, SavedSettings, NeverRightoLeft
  IniWrite, %NoBindedDeadKeys%, %inifile%, SavedSettings, NoBindedDeadKeys
  IniWrite, %OnlyTypingMode%, %inifile%, SavedSettings, OnlyTypingMode
  IniWrite, %OSDautosize%, %inifile%, SavedSettings, OSDautosize
  IniWrite, %OSDautosizeFactory%, %inifile%, SavedSettings, OSDautosizeFactory
  IniWrite, %OSDbgrColor%, %inifile%, SavedSettings, OSDbgrColor
  IniWrite, %OSDborder%, %inifile%, SavedSettings, OSDborder
  IniWrite, %OSDtextColor%, %inifile%, SavedSettings, OSDtextColor
  IniWrite, %pasteOSDcontent%, %inifile%, SavedSettings, pasteOSDcontent
  IniWrite, %pgUDasHE%, %inifile%, SavedSettings, pgUDasHE
  IniWrite, %prioritizeBeepers%, %inifile%, SavedSettings, prioritizeBeepers
  IniWrite, %releaseDate%, %inifile%, SavedSettings, releaseDate
  IniWrite, %ReturnToTypingUser%, %inifile%, SavedSettings, ReturnToTypingUser
  IniWrite, %ShiftDisableCaps%, %inifile%, SavedSettings, ShiftDisableCaps
  IniWrite, %ShowDeadKeys%, %inifile%, SavedSettings, ShowDeadKeys
  IniWrite, %ShowKeyCount%, %inifile%, SavedSettings, ShowKeyCount
  IniWrite, %ShowKeyCountFired%, %inifile%, SavedSettings, ShowKeyCountFired
  IniWrite, %ShowMouseButton%, %inifile%, SavedSettings, ShowMouseButton
  IniWrite, %ShowMouseHalo%, %inifile%, SavedSettings, ShowMouseHalo
  IniWrite, %ShowPrevKey%, %inifile%, SavedSettings, ShowPrevKey
  IniWrite, %ShowPrevKeyDelay%, %inifile%, SavedSettings, ShowPrevKeyDelay
  IniWrite, %ShowSingleKey%, %inifile%, SavedSettings, ShowSingleKey
  IniWrite, %ShowSingleModifierKey%, %inifile%, SavedSettings, ShowSingleModifierKey
  IniWrite, %SilentDetection%, %inifile%, SavedSettings, SilentDetection
  IniWrite, %StickyKeys%, %inifile%, SavedSettings, StickyKeys
  IniWrite, %synchronizeMode%, %inifile%, SavedSettings, synchronizeMode
  IniWrite, %UpDownAsHE%, %inifile%, SavedSettings, UpDownAsHE
  IniWrite, %UpDownAsLR%, %inifile%, SavedSettings, UpDownAsLR
  IniWrite, %version%, %inifile%, SavedSettings, version
  IniWrite, %VisualMouseClicks%, %inifile%, SavedSettings, VisualMouseClicks
}

LoadSettings() {
  firstRun := 0
  defOSDautosizeFactory := round(A_ScreenDPI / 1.18)
  IniRead, alternativeJumps, %inifile%, SavedSettings, alternativeJumps, %alternativeJumps%
  IniRead, audioAlerts, %inifile%, SavedSettings, audioAlerts, %audioAlerts%
  IniRead, AutoDetectKBD, %inifile%, SavedSettings, AutoDetectKBD, %AutoDetectKBD%
  IniRead, autoRemDeadKey, %inifile%, SavedSettings, autoRemDeadKey, %autoRemDeadKey%
  IniRead, beepFiringKeys, %inifile%, SavedSettings, beepFiringKeys, %beepFiringKeys%
  IniRead, BeepHiddenKeys, %inifile%, SavedSettings, BeepHiddenKeys, %BeepHiddenKeys%
  IniRead, CapsColorHighlight, %inifile%, SavedSettings, CapsColorHighlight, %CapsColorHighlight%
  IniRead, CapslockBeeper, %inifile%, SavedSettings, CapslockBeeper, %CapslockBeeper%
  IniRead, ClickScaleUser, %inifile%, SavedSettings, ClickScaleUser, %ClickScaleUser%
  IniRead, ClipMonitor, %inifile%, SavedSettings, ClipMonitor, %ClipMonitor%
  IniRead, ConstantAutoDetect, %inifile%, SavedSettings, ConstantAutoDetect, %ConstantAutoDetect%
  IniRead, deadKeyBeeper, %inifile%, SavedSettings, deadKeyBeeper, %deadKeyBeeper%
  IniRead, DifferModifiers, %inifile%, SavedSettings, DifferModifiers, %DifferModifiers%
  IniRead, DisableTypingMode, %inifile%, SavedSettings, DisableTypingMode, %DisableTypingMode%
  IniRead, DisplayTimeTypingUser, %inifile%, SavedSettings, DisplayTimeTypingUser, %DisplayTimeTypingUser%
  IniRead, DisplayTimeUser, %inifile%, SavedSettings, DisplayTimeUser, %DisplayTimeUser%
  IniRead, enableAltGrUser, %inifile%, SavedSettings, enableAltGrUser, %enableAltGrUser%
  IniRead, enableTypingHistory, %inifile%, SavedSettings, enableTypingHistory, %enableTypingHistory%
  IniRead, enterErasesLine, %inifile%, SavedSettings, enterErasesLine, %enterErasesLine%
  IniRead, FavorRightoLeft, %inifile%, SavedSettings, FavorRightoLeft, %FavorRightoLeft%
  IniRead, FlashIdleMouse, %inifile%, SavedSettings, FlashIdleMouse, %FlashIdleMouse%
  IniRead, FontName, %inifile%, SavedSettings, FontName, %FontName%
  IniRead, FontSize, %inifile%, SavedSettings, FontSize, %FontSize%
  IniRead, ForcedKBDlayout, %inifile%, SavedSettings, ForcedKBDlayout, %ForcedKBDlayout%
  IniRead, ForcedKBDlayout1, %inifile%, SavedSettings, ForcedKBDlayout1, %ForcedKBDlayout1%
  IniRead, ForcedKBDlayout2, %inifile%, SavedSettings, ForcedKBDlayout2, %ForcedKBDlayout2%
  IniRead, ForceKBD, %inifile%, SavedSettings, ForceKBD, %ForceKBD%
  IniRead, GUIposition, %inifile%, SavedSettings, GUIposition, %GUIposition%
  IniRead, GuiWidth, %inifile%, SavedSettings, GuiWidth, %GuiWidth%
  IniRead, GuiXa, %inifile%, SavedSettings, GuiXa, %GuiXa%
  IniRead, GuiXb, %inifile%, SavedSettings, GuiXb, %GuiXb%
  IniRead, GuiYa, %inifile%, SavedSettings, GuiYa, %GuiYa%
  IniRead, GuiYb, %inifile%, SavedSettings, GuiYb, %GuiYb%
  IniRead, HideAnnoyingKeys, %inifile%, SavedSettings, HideAnnoyingKeys, %HideAnnoyingKeys%
  IniRead, IdleMouseAlpha, %inifile%, SavedSettings, IdleMouseAlpha, %IdleMouseAlpha%
  IniRead, IgnoreAdditionalKeys, %inifile%, SavedSettings, IgnoreAdditionalKeys, %IgnoreAdditionalKeys%
  IniRead, IgnorekeysList, %inifile%, SavedSettings, IgnorekeysList, %IgnorekeysList%
  IniRead, JumpHover, %inifile%, SavedSettings, JumpHover, %JumpHover%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, KeyboardShortcuts, %inifile%, SavedSettings, KeyboardShortcuts, %KeyboardShortcuts%
  IniRead, LowVolBeeps, %inifile%, SavedSettings, LowVolBeeps, %LowVolBeeps%
  IniRead, maxGuiWidth, %inifile%, SavedSettings, maxGuiWidth, %maxGuiWidth%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, MouseHaloAlpha, %inifile%, SavedSettings, MouseHaloAlpha, %MouseHaloAlpha%
  IniRead, MouseHaloColor, %inifile%, SavedSettings, MouseHaloColor, %MouseHaloColor%
  IniRead, MouseHaloRadius, %inifile%, SavedSettings, MouseHaloRadius, %MouseHaloRadius%
  IniRead, MouseIdleAfter, %inifile%, SavedSettings, MouseIdleAfter, %MouseIdleAfter%
  IniRead, MouseIdleRadius, %inifile%, SavedSettings, MouseIdleRadius, %MouseIdleRadius%
  IniRead, MouseVclickAlpha, %inifile%, SavedSettings, MouseVclickAlpha, %MouseVclickAlpha%
  IniRead, NeverDisplayOSD, %inifile%, SavedSettings, NeverDisplayOSD, %NeverDisplayOSD%
  IniRead, NeverRightoLeft, %inifile%, SavedSettings, NeverRightoLeft, %NeverRightoLeft%
  IniRead, NoBindedDeadKeys, %inifile%, SavedSettings, NoBindedDeadKeys, %NoBindedDeadKeys%
  IniRead, OnlyTypingMode, %inifile%, SavedSettings, OnlyTypingMode, %OnlyTypingMode%
  IniRead, OSDautosize, %inifile%, SavedSettings, OSDautosize, %OSDautosize%
  IniRead, OSDautosizeFactory, %inifile%, SavedSettings, OSDautosizeFactory, %OSDautosizeFactory%
  IniRead, OSDbgrColor, %inifile%, SavedSettings, OSDbgrColor, %OSDbgrColor%
  IniRead, OSDborder, %inifile%, SavedSettings, OSDborder, %OSDborder%
  IniRead, OSDtextColor, %inifile%, SavedSettings, OSDtextColor, %OSDtextColor%
  IniRead, pasteOSDcontent, %inifile%, SavedSettings, pasteOSDcontent, %pasteOSDcontent%
  IniRead, pgUDasHE, %inifile%, SavedSettings, pgUDasHE, %pgUDasHE%
  IniRead, prioritizeBeepers, %inifile%, SavedSettings, prioritizeBeepers, %prioritizeBeepers%
  IniRead, ReturnToTypingUser, %inifile%, SavedSettings, ReturnToTypingUser, %ReturnToTypingUser%
  IniRead, ShiftDisableCaps, %inifile%, SavedSettings, ShiftDisableCaps, %ShiftDisableCaps%
  IniRead, ShowDeadKeys, %inifile%, SavedSettings, ShowDeadKeys, %ShowDeadKeys%
  IniRead, ShowKeyCount, %inifile%, SavedSettings, ShowKeyCount, %ShowKeyCount%
  IniRead, ShowKeyCountFired, %inifile%, SavedSettings, ShowKeyCountFired, %ShowKeyCountFired%
  IniRead, ShowMouseButton, %inifile%, SavedSettings, ShowMouseButton, %ShowMouseButton%
  IniRead, ShowMouseHalo, %inifile%, SavedSettings, ShowMouseHalo, %ShowMouseHalo%
  IniRead, ShowPrevKey, %inifile%, SavedSettings, ShowPrevKey, %ShowPrevKey%
  IniRead, ShowPrevKeyDelay, %inifile%, SavedSettings, ShowPrevKeyDelay, %ShowPrevKeyDelay%
  IniRead, ShowSingleKey, %inifile%, SavedSettings, ShowSingleKey, %ShowSingleKey%
  IniRead, ShowSingleModifierKey, %inifile%, SavedSettings, ShowSingleModifierKey, %ShowSingleModifierKey%
  IniRead, SilentDetection, %inifile%, SavedSettings, SilentDetection, %SilentDetection%
  IniRead, StickyKeys, %inifile%, SavedSettings, StickyKeys, %StickyKeys%
  IniRead, synchronizeMode, %inifile%, SavedSettings, synchronizeMode, %synchronizeMode%
  IniRead, UpDownAsHE, %inifile%, SavedSettings, UpDownAsHE, %UpDownAsHE%
  IniRead, UpDownAsLR, %inifile%, SavedSettings, UpDownAsLR, %UpDownAsLR%
  IniRead, VisualMouseClicks, %inifile%, SavedSettings, VisualMouseClicks, %VisualMouseClicks%

  CheckSettings()

  if (GUIposition=1)
  {
     GuiY := GuiYa
     GuiX := GuiXa
  } else
  {
     GuiY := GuiYb
     GuiX := GuiXb
  }
}

CheckSettings() {

; verify check boxes
    alternativeJumps := (alternativeJumps=0 || alternativeJumps=1) ? alternativeJumps : 0
    audioAlerts := (audioAlerts=0 || audioAlerts=1) ? audioAlerts : 0
    AutoDetectKBD := (AutoDetectKBD=0 || AutoDetectKBD=1) ? AutoDetectKBD : 1
    autoRemDeadKey := (autoRemDeadKey=0 || autoRemDeadKey=1) ? autoRemDeadKey : 1
    beepFiringKeys := (beepFiringKeys=0 || beepFiringKeys=1) ? beepFiringKeys : 0
    BeepHiddenKeys := (BeepHiddenKeys=0 || BeepHiddenKeys=1) ? BeepHiddenKeys : 0
    CapslockBeeper := (CapslockBeeper=0 || CapslockBeeper=1) ? CapslockBeeper : 1
    ClipMonitor := (ClipMonitor=0 || ClipMonitor=1) ? ClipMonitor : 1
    ConstantAutoDetect := (ConstantAutoDetect=0 || ConstantAutoDetect=1) ? ConstantAutoDetect : 1
    deadKeyBeeper := (deadKeyBeeper=0 || deadKeyBeeper=1) ? deadKeyBeeper : 1
    DifferModifiers := (DifferModifiers=0 || DifferModifiers=1) ? DifferModifiers : 0
    DisableTypingMode := (DisableTypingMode=0 || DisableTypingMode=1) ? DisableTypingMode : 1
    enableAltGrUser := (enableAltGrUser=0 || enableAltGrUser=1) ? enableAltGrUser : 1
    enableTypingHistory := (enableTypingHistory=0 || enableTypingHistory=1) ? enableTypingHistory : 0
    FavorRightoLeft := (FavorRightoLeft=0 || FavorRightoLeft=1) ? FavorRightoLeft : 0
    FlashIdleMouse := (FlashIdleMouse=0 || FlashIdleMouse=1) ? FlashIdleMouse : 0
    ForcedKBDlayout := (ForcedKBDlayout=0 || ForcedKBDlayout=1) ? ForcedKBDlayout : 0
    ForceKBD := (ForceKBD=0 || ForceKBD=1) ? ForceKBD : 0
    GUIposition := (GUIposition=0 || GUIposition=1) ? GUIposition : 1
    HideAnnoyingKeys := (HideAnnoyingKeys=0 || HideAnnoyingKeys=1) ? HideAnnoyingKeys : 1
    IgnoreAdditionalKeys := (IgnoreAdditionalKeys=0 || IgnoreAdditionalKeys=1) ? IgnoreAdditionalKeys : 0
    JumpHover := (JumpHover=0 || JumpHover=1) ? JumpHover : 0
    KeyBeeper := (KeyBeeper=0 || KeyBeeper=1) ? KeyBeeper : 0
    KeyboardShortcuts := (KeyboardShortcuts=0 || KeyboardShortcuts=1) ? KeyboardShortcuts : 1
    LowVolBeeps := (LowVolBeeps=0 || LowVolBeeps=1) ? LowVolBeeps : 1
    ModBeeper := (ModBeeper=0 || ModBeeper=1) ? ModBeeper : 0
    MouseBeeper := (MouseBeeper=0 || MouseBeeper=1) ? MouseBeeper : 0
    NeverDisplayOSD := (NeverDisplayOSD=0 || NeverDisplayOSD=1) ? NeverDisplayOSD : 0
    NeverRightoLeft := (NeverRightoLeft=0 || NeverRightoLeft=1) ? NeverRightoLeft : 0
    NoBindedDeadKeys := (NoBindedDeadKeys=0 || NoBindedDeadKeys=1) ? NoBindedDeadKeys : 0
    OSDautosize := (OSDautosize=0 || OSDautosize=1) ? OSDautosize : 1
    OSDborder := (OSDborder=0 || OSDborder=1) ? OSDborder : 0
    pasteOSDcontent := (pasteOSDcontent=0 || pasteOSDcontent=1) ? pasteOSDcontent : 1  
    pgUDasHE := (pgUDasHE=0 || pgUDasHE=1) ? pgUDasHE : 0
    prioritizeBeepers := (prioritizeBeepers=0 || prioritizeBeepers=1) ? prioritizeBeepers : 0
    ShiftDisableCaps := (ShiftDisableCaps=0 || ShiftDisableCaps=1) ? ShiftDisableCaps : 1
    ShowDeadKeys := (ShowDeadKeys=0 || ShowDeadKeys=1) ? ShowDeadKeys : 0
    ShowKeyCount := (ShowKeyCount=0 || ShowKeyCount=1) ? ShowKeyCount : 1
    ShowKeyCountFired := (ShowKeyCountFired=0 || ShowKeyCountFired=1) ? ShowKeyCountFired : 1
    ShowMouseButton := (ShowMouseButton=0 || ShowMouseButton=1) ? ShowMouseButton : 1
    ShowMouseHalo := (ShowMouseHalo=0 || ShowMouseHalo=1) ? ShowMouseHalo : 0
    ShowPrevKey := (ShowPrevKey=0 || ShowPrevKey=1) ? ShowPrevKey : 1
    ShowSingleKey := (ShowSingleKey=0 || ShowSingleKey=1) ? ShowSingleKey : 1
    ShowSingleModifierKey := (ShowSingleModifierKey=0 || ShowSingleModifierKey=1) ? ShowSingleModifierKey : 1
    SilentDetection := (SilentDetection=0 || SilentDetection=1) ? SilentDetection : 1
    StickyKeys := (StickyKeys=0 || StickyKeys=1) ? StickyKeys : 0
    synchronizeMode := (synchronizeMode=0 || synchronizeMode=1) ? synchronizeMode : 0
    UpDownAsHE := (UpDownAsHE=0 || UpDownAsHE=1) ? UpDownAsHE : 0
    UpDownAsLR := (UpDownAsLR=0 || UpDownAsLR=1) ? UpDownAsLR : 0
    VisualMouseClicks := (VisualMouseClicks=0 || VisualMouseClicks=1) ? VisualMouseClicks : 0

    if (UpDownAsHE=1) && (UpDownAsLR=1)
       UpDownAsLR := 0

    if (ShowSingleKey=0)
       DisableTypingMode := 1

    if (DisableTypingMode=1)
       OnlyTypingMode := 0

    if (ForceKBD=1)
       AutoDetectKBD := 1

    if (ForceKBD=1) || (AutoDetectKBD=0)
       ConstantAutoDetect := 0

; verify if numeric values, otherwise, defaults
  if ClickScaleUser is not digit
     ClickScaleUser := 10

  if DisplayTimeUser is not digit
     DisplayTimeUser := 3

  if DisplayTimeTypingUser is not digit
     DisplayTimeTypingUser := 10

  if ReturnToTypingUser is not digit
     ReturnToTypingUser := 15

  if FontSize is not digit
     FontSize := 20

  if GuiWidth is not digit
     GuiWidth := 350

  if maxGuiWidth is not digit
     maxGuiWidth := 500

  if IdleMouseAlpha is not digit
     IdleMouseAlpha := 70

  if MouseHaloAlpha is not digit
     MouseHaloAlpha := 130

  if MouseHaloRadius is not digit
     MouseHaloRadius := 35

  if MouseIdleAfter is not digit
     MouseIdleAfter := 10

  if MouseIdleRadius is not digit
     MouseIdleRadius := 40

  if MouseVclickAlpha is not digit
     MouseVclickAlpha := 150

     defOSDautosizeFactory := round(A_ScreenDPI / 1.18)
  if OSDautosizeFactory is not digit
     OSDautosizeFactory := defOSDautosizeFactory

  if ShowPrevKeyDelay is not digit
     ShowPrevKeyDelay := 300

; verify minimum numeric values
    ClickScaleUser := (ClickScaleUser < 3) ? 3 : round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser < 2) ? 2 : round(DisplayTimeUser)
    DisplayTimeTypingUser := (DisplayTimeTypingUser < 3) ? 3 : round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser < DisplayTimeTypingUser) ? DisplayTimeTypingUser+1 : round(ReturnToTypingUser)
    FontSize := (FontSize < 6) ? 7 : round(FontSize)
    GuiWidth := (GuiWidth < 70) ? 72 : round(GuiWidth)
    GuiWidth := (GuiWidth < FontSize*2) ? round(FontSize*5) : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth < 80) ? 82 : round(maxGuiWidth)
    maxGuiWidth := (maxGuiWidth < FontSize*2) ? round(FontSize*6) : round(maxGuiWidth)
    GuiXa := (GuiXa < -9999) ? -9998 : round(GuiXa)
    GuiXb := (GuiXb < -9999) ? -9998 : round(GuiXb)
    GuiYa := (GuiYa < -9999) ? -9998 : round(GuiYa)
    GuiYb := (GuiYb < -9999) ? -9998 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha < 10) ? 11 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha < 10) ? 11 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius < 5) ? 6 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter < 3) ? 3 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius < 5) ? 6 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha < 10) ? 11 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory < 10) ? 11 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay < 100) ? 101 : round(ShowPrevKeyDelay)

    if (GuiXa<0 || GuiXb<0 || GuiYa<0 || GuiYb<0)
       NeverRightoLeft := 0

; verify maximum numeric values
    ClickScaleUser := (ClickScaleUser > 91) ? 90 : round(ClickScaleUser)
    DisplayTimeUser := (DisplayTimeUser > 99) ? 98 : round(DisplayTimeUser)
    DisplayTimeTypingUser := (DisplayTimeTypingUser > 99) ? 98 : round(DisplayTimeTypingUser)
    ReturnToTypingUser := (ReturnToTypingUser > 99) ? 99 : round(ReturnToTypingUser)
    FontSize := (FontSize > 300) ? 290 : round(FontSize)
    GuiWidth := (GuiWidth > 999) ? 999 : round(GuiWidth)
    maxGuiWidth := (maxGuiWidth > 999) ? 999 : round(maxGuiWidth)
    GuiXa := (GuiXa > 9999) ? 9998 : round(GuiXa)
    GuiXb := (GuiXb > 9999) ? 9998 : round(GuiXb)
    GuiYa := (GuiYa > 9999) ? 9998 : round(GuiYa)
    GuiYb := (GuiYb > 9999) ? 9998 : round(GuiYb)
    IdleMouseAlpha := (IdleMouseAlpha > 240) ? 240 : round(IdleMouseAlpha)
    MouseHaloAlpha := (MouseHaloAlpha > 240) ? 240 : round(MouseHaloAlpha)
    MouseHaloRadius := (MouseHaloRadius > 999) ? 900 : round(MouseHaloRadius)
    MouseIdleAfter := (MouseIdleAfter > 999) ? 900 : round(MouseIdleAfter)
    MouseIdleRadius := (MouseIdleRadius > 999) ? 900 : round(MouseIdleRadius)
    MouseVclickAlpha := (MouseVclickAlpha > 240) ? 240 : round(MouseVclickAlpha)
    OSDautosizeFactory := (OSDautosizeFactory > 402) ? 401 : round(OSDautosizeFactory)
    ShowPrevKeyDelay := (ShowPrevKeyDelay > 999) ? 900 : round(ShowPrevKeyDelay)

; verify HEX values

   if (forcedKBDlayout1 ~= "[^[:xdigit:]]") || (strLen(forcedKBDlayout1) < 8) || (strLen(forcedKBDlayout1) > 8)
      ForcedKBDlayout1 := "00010418"

   if (forcedKBDlayout2 ~= "[^[:xdigit:]]") || (strLen(forcedKBDlayout2) < 8) || (strLen(forcedKBDlayout2) > 8)
      ForcedKBDlayout2 := "0000040c"

   if (OSDbgrColor ~= "[^[:xdigit:]]") || (strLen(OSDbgrColor) < 6) || (strLen(OSDbgrColor) > 6)
      OSDbgrColor := "111111"

   if (CapsColorHighlight ~= "[^[:xdigit:]]") || (strLen(CapsColorHighlight) < 6) || (strLen(CapsColorHighlight) > 6)
      CapsColorHighlight := "88AAff"

   if (MouseHaloColor ~= "[^[:xdigit:]]") || (strLen(MouseHaloColor) < 6) || (strLen(MouseHaloColor) > 6)
      MouseHaloColor := "eedd00"
;
   if (OSDtextColor ~= "[^[:xdigit:]]") || (strLen(OSDtextColor) < 6) || (strLen(OSDtextColor) > 6)
      OSDtextColor := "ffffff"

   FontName := StrLen(FontName)>2 ? FontName : "Arial"

}

dummy() {
    MsgBox, This feature is not yet available. It might be implemented soon. Thank you.
}

; !+SPACE::  Winset, Alwaysontop, , A
