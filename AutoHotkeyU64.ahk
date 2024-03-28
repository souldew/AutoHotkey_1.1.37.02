; メインで使用しているautohotkey
; vk1C: 変換
; vk1D: 無変換
; +: shift | ^: ctrl | !: alt | #: windowsキー
; AppsKey: アプリキー
; <: 左 | >: 右
; SetBatchLines,-1
; KeyHistory

;https://namayakegadget.com/765/
; IME_SET(0)でIMEをオフ
; IME_SET(1)でIMEをオンにできる

keys_all := "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,@,/,vkBB,vkBA,vkBC,Space,Tab,Enter,BS,vkF3,vkF4,vkF2,vkF0"


IME_SET(SetSts, WinTitle="A"){
    ControlGet,hwnd,HWND,,,%WinTitle%
    if (WinActive(WinTitle)) {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI,  0, "UInt")   ;    DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
            ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }

    return DllCall("SendMessage"
        , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
        , UInt, 0x0283  ;Message : WM_IME_CONTROL
        ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
        ,  Int, SetSts) ;lParam  : 0 or 1
}

; :*:zh::←
;無変換でIME-off，変換でIMEon
vk1D::IME_SET(0)
vk1C::IME_SET(1)

; 無変換+Spaceで再変換を行う
vk1D & Space:: Send,{Blind}{vk1C}

; vimのkeybinding（マウスも定義）
vk1C & h::Send,{Blind}{Left}
vk1C & j::Send,{Blind}{Down}
vk1C & k::Send,{Blind}{Up}
vk1C & l::Send,{Blind}{Right}
; Shiftを押しながら使えるようにvimキーと合わせて，変換を使った定義にする
vk1C & N::Send,{Blind}{Home}
vk1C & M::Send,{Blind}{PgDn}
vk1C & ,::Send,{Blind}{PgUp}
vk1C & .::Send,{Blind}{End}

; ----------------------------------
; 変換 + セミコロン(vkBB)をBackSpace
; 変換 + コロン(vkBA)をDelete
; 変換 + スペースをEnter
; ----------------------------------
vk1C & vkBB::Bs
vk1C & vkBA::Delete
vk1C & Space::Enter


!Tab::
    Send {Blind}!{Tab}
    Sleep, 150
    while (GetKeyState("Alt", "P")){
        If (GetKeyState("h", "P")){
            Send, {Blind}{Left}
            Sleep, 150
        } Else If (GetKeyState("j", "P")){
            Send, {Blind}{Down}
            Sleep, 150
        } Else If (GetKeyState("k", "P")){
            Send, {Blind}{Up}
            Sleep, 150
        } Else If (GetKeyState("l", "P")){
            Send, {Blind}{Right}
            Sleep, 150
        } Else If (GetKeyState("Tab", "P")){
            If (GetKeyState("Shift", "P")){
                ; shift込の場合は勝手に押したことになる
                ; Send, {Blind}+{Tab}
                Sleep, 150
            } Else{
                Send, {Blind}{Tab}
                Sleep, 150
            }
        }
    }
    return

; Window移動を「Shift+window」hjklで実行可能に
+LWin::
#Shift::
    while (GetKeyState("Shift", "P")){
        If (GetKeyState("h", "P")){
            Send, {Blind}{Left}
            Sleep, 150
        } Else If (GetKeyState("j", "P")){
            Send, {Blind}{Down}
            Sleep, 150
        } Else If (GetKeyState("k", "P")){
            Send, {Blind}{Up}
            Sleep, 150
        } Else If (GetKeyState("l", "P")){
            Send, {Blind}{Right}
            Sleep, 150
        }
    }
    return

; <C-[>でEsc（Emacsキーバインド）
; ^[::Send, {Esc}
vk1D & e:: Send,{Esc} ; Esc

;よく使うCtrl + αを「無変換＋α」で代用する
vk1D & c:: Send,{Blind}^c ; copy
vk1D & x:: Send,{Blind}^x ; cut
vk1D & v:: Send,{Blind}^v ; paste
vk1D & s:: Send,{Blind}^s ; save
vk1D & z:: Send,{Blind}^z ; undo
vk1D & y:: Send,{Blind}^+z ; redoこうした方が，汎用性が高い？scrapboxはこれじゃないとダメ
vk1D & f:: Send,{Blind}^f ; find
vk1D & a:: Send,{Blind}^a ; all
vk1D & Tab:: Send,{Blind}^{Tab} ; ctrl + Tab

; vscodeを開いている時だけ
#IfWinActive, ahk_exe Code.exe
    vk1D & d:: Send,{Blind}^d ; vscodeでワード指定
    return
#IfWinActive

; ; マウスの定義（無変換を使う）pattern 右手十字
vk1D & J::
vk1D & K::
vk1D & I::
vk1D & L::
    CoordMode,Mouse,Client
    While (GetKeyState("vk1D", "P"))                 ; 変換キーが押され続けている間マウス移動の処理をループさせる
    {
        ; original 11 *10 *0.3
        MoveX := 0, MoveY := 0
        MoveY += GetKeyState("I", "P") ? -24 : 0     ; 変換キーと一緒にIJKLが押されている間はカーソル座標を変化させ続ける
        MoveX += GetKeyState("J", "P") ? -24 : 0
        MoveY += GetKeyState("K", "P") ? 24 : 0
        MoveX += GetKeyState("L", "P") ? 24 : 0
        MoveX *= GetKeyState("Ctrl", "P") ? 64/24 : 1   ; Ctrlキーが押されている間は座標を10倍にし続ける(スピードアップ)
        MoveY *= GetKeyState("Ctrl", "P") ? 64/24 : 1
        MoveX *= GetKeyState("Shift", "P") ? 5/24 : 1 ; Shiftキーが押されている間は座標を30%にする（スピードダウン）
        MoveY *= GetKeyState("Shift", "P") ? 5/24 : 1
        MouseMove, %MoveX%, %MoveY%, 0, R            ; マウスカーソルを移動する
        Sleep, 0                                     ; 負荷が高い場合は設定を変更 設定できる値は-1、0、10～m秒 詳細はSleep
    }
    Return
;clickの定義
vk1D & W::MouseClick,RIGHT,,,,,D
vk1D & W Up::MouseClick,RIGHT,,,,,U
vk1D & Q::MouseClick,left,,,,,D
vk1D & Q Up::MouseClick,left,,,,,U

get_current_dir() {
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    If (explorerHwnd) {
        for window in ComObjCreate("Shell.Application").Windows {
            If (window.hwnd==explorerHwnd)
                Return window.Document.Folder.Self.Path
        }
    }
}

; 無変換 + vでカレントディレクトリをvscodeで開く
#IfWinActive, ahk_exe explorer.exe
Insert::
    a := get_current_dir()
    a = " %a% " ; スペースがあっても表示できるように「""」を補完
    Run, "C:\Users\%A_UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe" %a%
    return
#IfWinActive

;!マウス操作
toggle := false

hotkeys_define(keys, label, OnOff) {
    ; MsgBox,%keys%
Loop, PARSE, keys, `,
{
    Hotkey, %A_LoopField%, %label%, %OnOff%
    ; MsgBox,%A_LoopField%
}
; MsgBox,"foo"
Return
}

; キー無効化用ラベル(Hotkeyコマンドでラベルとして指定する)
disable_keys:
Return

;* キーボードマウス開始
vk1D & /::
    toggle := "a"
    toggle_activation(toggle)
    hotkeys_define(keys_all, "disable_keys", "On")
    Gosub, toggle_deactivation
    Gosub, keybd_mouse
    return


; セカンダリキー入力待ちにし、タイムアウトをSetTimerする
toggle_activation(toggle) {
    time_limitation := 2000
    SetTimer, toggle_deactivation, -%time_limitation%
}

toggle_deactivation:
    toggle := false
    hotkeys_define(keys_all, "disable_keys", "Off")
    SetTimer, toggle_deactivation, Off
    SetTimer, watch_hotkey_done, Off
    Return

; セカンダリキーの入力があった場合、toggleをfalseにし、SetTimerしたタイムアウト設定を解除する
watch_hotkey_done:
    new_ThisHotkey := A_ThisHotkey
    ; toggleにはプライマリキー送信時のA_ThisHotkeyが格納されている
    ; 何らかのホットキー(つまりセカンダリキー)が実行されたとき、A_ThisHotkeyが書き換わることを利用する
    If (new_ThisHotkey != toggle)
        Goto, toggle_deactivation
Return

keybd_mouse:
    ; キー設定///////////////////////////////////
    exit_this       := "/"      ; keybd_mouse終了

    mouse_up        := "e"      ; ↑
    mouse_down      := "d"      ; ↓
    mouse_left      := "s"      ; ←
    mouse_right     := "f"      ; →
    mouse_LB        := "h"      ; 左クリック
    mouse_RB        := "i"      ; 右クリック
    mouse_MB        := "u"      ; 中クリック
    scroll_up       := "k"      ; 上スクロール
    scroll_down     := "j"      ; 下スクロール

    accel_key       := "vkBB"   ; カーソル加速（セミコロンvkbb or oどちらか）
    decel_key       := "l"   ; カーソル減速

    ; 低:5 中:24 高:64 
    default_speed   := 12        ; 規定のカーソル移動速度
    accel_vol       := 24       ; accelKey押下時のカーソル移動速度の増加量
    slow_vol        := 5        ; decel_key押下時のカーソル移動速度
    move_ratio      := 1     ; 縦横移動量倍率

    ;////////////////////////////////////////////

    hotkeys_define(keys_all, "disable_keys", "On")
    Hotkey, %exit_this%, toggle_keybd_mouse

    Gosub, toggle_keybd_mouse

    SetTimer, mouse_button_checker, 100

    While (toggle_keybd_mouse == true) {
        ; 速度設定///////////////////////////
        speed := default_speed
        move_X := 0
        move_Y := 0

        If (GetKeyState(accel_key, "P"))
        speed += accel_vol
        If (GetKeyState(decel_key, "P"))
        speed := slow_vol
        ;////////////////////////////////////

        ; 移動方向設定///////////////////////
        If (GetKeyState(mouse_up, "P"))
        move_Y += speed
        If (GetKeyState(mouse_down, "P"))
        move_Y += -speed
        If (GetKeyState(mouse_left, "P"))
        move_X += -speed * move_ratio
        If (GetKeyState(mouse_right, "P"))
        move_X += speed * move_ratio
        ;////////////////////////////////////

        ; 移動///////////////////////////////
        MouseMove, move_X, -move_Y, 0, R
        ; ///////////////////////////////////
    }

    SetTimer, mouse_button_checker, Off

    hotkeys_define(keys_all, "disable_keys", "Off")
    Hotkey, %mouse_LB%, left_click_on, "Off"
    Hotkey, %mouse_LB% Up, left_click_off, "Off"
    Hotkey, %mouse_RB%, right_click_on, "Off"
    Hotkey, %mouse_RB% Up, right_click_off, "Off"
    Hotkey, %scroll_up%, fn_scroll_up, "Off"
    Hotkey, %scroll_down%, fn_scroll_down, "Off"
    Hotkey, %exit_this%, toggle_keybd_mouse, Off
Return


;////////////////////////////////////////////
;サブルーチン////////////////////////////////
;////////////////////////////////////////////

; トグル/////////////////////////////////////
toggle_keybd_mouse:
toggle_keybd_mouse := !toggle_keybd_mouse
Return
;////////////////////////////////////////////


; マウス/////////////////////////////////////
mouse_button_checker:
; マウス/////////////////////////////
Hotkey, %mouse_LB%, left_click_on, "On"
Hotkey, %mouse_LB% Up, left_click_off, "On"
Hotkey, %mouse_RB%, right_click_on, "On"
Hotkey, %mouse_RB% Up, right_click_off, "On"
keybd_mouse_click(mouse_MB, "M")
keybd_mouse_click(mouse_RB, "R")
keybd_mouse_scroll(scroll_up, "Up", accel_key, decel_key, accel_vol)
keybd_mouse_scroll(scroll_down, "Down", accel_key, decel_key, accel_vol)
;////////////////////////////////////
Return

left_click_on:
    MouseClick,left,,,,,D
    return
left_click_off:
    MouseClick,left,,,,,U
    return
right_click_on:
    MouseClick,right,,,,,D
    return
right_click_off:
    MouseClick,right,,,,,U
    return
fn_scroll_up:
    MouseClick, WheelUp,,,,2
    return
fn_scroll_down:
    MouseClick,WheelDown,,,,10
    return


keybd_mouse_click(key, button) {
;引数について////////////////////////
; 変数%button%B_downの値を引き継ぐ
; %button%B_downは直前に押したか離したかを記録
Global

; 上記変数を用いた連打対策///////////
; 押すとき
If (GetKeyState(key, "P") == true) {
    If (%button%B_down != true) {
    Send, {Blind}{%button%Button Down}
    %button%B_down := true

    ; 押下したら一瞬カーソルを止める
    Sleep, 150
    }
; 離すとき
} Else {
    If (%button%B_down == true) {
    Send, {Blind}{%button%Button Up}
    %button%B_down := false
    }
}
;////////////////////////////////////
}


keybd_mouse_scroll(key, scroll, accel_key, decel_key, accel_vol) {
While (GetKeyState(key, "P")) {
    ; スクロール中はカーソルを固定
    If (GetKeyState(key, "P"))
    Send, {Blind}{Wheel%scroll%}

    ; スクロール速度の設定
    scroll_wait := 100
    If (GetKeyState(accel_key, "P"))
    scroll_wait -= accel_vol * 5
    If (GetKeyState(decel_key, "P"))
    scroll_wait := 200

    Sleep, scroll_wait
}
}
;////////////////////////////////////////////

Insert::
    Send,{F13}
    return

