#NoTrayIcon
#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <WinAPIFiles.au3> ; <-- TAMBAHKAN INI

Global $g_iParentPID = ($CmdLine[0] > 0) ? Number($CmdLine[1]) : 0
Global Const $g_sUniqueSuffix = ($g_iParentPID > 0) ? "_" & $g_iParentPID : ""

Global Const $g_sTessDir     = @ScriptDir
Global Const $g_sTessDLLPath = $g_sTessDir & "\libtesseract-5.dll"
Global Const $g_sTessDataDir = $g_sTessDir & "\tessdata"

; RESOLVE PATH MENJADI ABSOLUTE PATH BERSIH (Tanpa tanda '..')
Global Const $g_sDebugDir    = _WinAPI_GetFullPathName(@ScriptDir & "\..\debug\ocr")
If Not FileExists($g_sDebugDir) Then DirCreate($g_sDebugDir)

; Konstanta pasti format 32-bit ARGB untuk GDI+
Global Const $GDIP_PXF32ARGB_CONST = 0x0026200A

Global $g_hTessDLL = 0, $g_pTessAPI = 0

; Inisialisasi GDI+
_GDIPlus_Startup()

; 1. Load DLL Tesseract
DllCall("kernel32.dll", "bool", "SetDllDirectoryW", "wstr", $g_sTessDir)
$g_hTessDLL = DllOpen($g_sTessDLLPath)
If $g_hTessDLL = -1 Then Exit 1

Local $aRet = DllCall($g_hTessDLL, "ptr:cdecl", "TessBaseAPICreate")
$g_pTessAPI = $aRet[0]

Local $aInit = DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPIInit3", "ptr", $g_pTessAPI, "str", $g_sTessDataDir, "str", "eng")
If @error Or $aInit[0] <> 0 Then
    DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPIInit3", "ptr", $g_pTessAPI, "str", $g_sTessDir & "\tessdata_legacy", "str", "eng")
EndIf

DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPISetVariable", "ptr", $g_pTessAPI, "str", "load_system_dawg", "str", "0")
DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPISetVariable", "ptr", $g_pTessAPI, "str", "load_freq_dawg", "str", "0")

; 2. Shared Memory
Global Const $SHM_SIZE = 4194304
Global $g_hMapFile = DllCall("kernel32.dll", "handle", "CreateFileMappingW", _
        "handle", -1, "ptr", 0, "dword", 0x04, "dword", 0, "dword", $SHM_SIZE, "wstr", "MBR_OCR_SHM" & $g_sUniqueSuffix)[0]
Global $g_pSharedBuf = DllCall("kernel32.dll", "ptr", "MapViewOfFile", _
        "handle", $g_hMapFile, "dword", 0xF001F, "dword", 0, "dword", 0, "ulong_ptr", $SHM_SIZE)[0]

; 3. GUI Hidden
Global Const $WM_OCR_TRIGGER = 0x0465
Global $g_sWorkerTitle = "MBR_OCR_Worker" & $g_sUniqueSuffix
Global $g_hWorkerGUI = GUICreate($g_sWorkerTitle)
GUIRegisterMsg($WM_OCR_TRIGGER, "_OnOcrRequest")

While True
    If $g_iParentPID > 0 And Not ProcessExists($g_iParentPID) Then Exit
    Sleep(1000)
WEnd

Func _OnOcrRequest($hWnd, $iMsg, $wParam, $lParam)
    If $g_pSharedBuf = 0 Then Return 0
    Local $hTimer = TimerInit()

    ; Header Baru (Offset piksel digeser ke byte 256)
    Local $tHeader = DllStructCreate("int Width;int Height;int PSM;int SaveImg;int WriteLog;char Whitelist[64];char TagName[64]", $g_pSharedBuf)
    Local $iW       = DllStructGetData($tHeader, "Width")
    Local $iH       = DllStructGetData($tHeader, "Height")
    Local $iPSM     = DllStructGetData($tHeader, "PSM")
    Local $iSaveImg = DllStructGetData($tHeader, "SaveImg")
    Local $iWriteLog= DllStructGetData($tHeader, "WriteLog")
    Local $sWL      = DllStructGetData($tHeader, "Whitelist")
    Local $sTag     = DllStructGetData($tHeader, "TagName")

    If $iW <= 0 Or $iH <= 0 Then Return 0

    Local $pPixels = $g_pSharedBuf + 256 ; Buffer piksel dimulai dari offset 256
    Local $iStride = $iW * 4

    ; 1. SIMPAN GAMBAR DEBUG JIKA DIMINTA
    If $iSaveImg = 1 Then
        Local $sTime = @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC & "_" & @MSEC
        Local $sImgPath = $g_sDebugDir & "\" & $sTag & "_" & $sTime & ".png"

        ; Gunakan konstanta format yang sudah didefinisikan secara pasti
        Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iW, $iH, $iStride, $GDIP_PXF32ARGB_CONST, $pPixels)
        If $hBitmap <> 0 Then
            _GDIPlus_ImageSaveToFile($hBitmap, $sImgPath)
            _GDIPlus_BitmapDispose($hBitmap)
        EndIf
    EndIf

    ; 2. PROSES OCR
    DllCall($g_hTessDLL, "none:cdecl", "TessBaseAPISetPageSegMode", "ptr", $g_pTessAPI, "int", $iPSM)
    If $sWL <> "" Then
        DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPISetVariable", "ptr", $g_pTessAPI, "str", "tessedit_char_whitelist", "str", $sWL)
    Else
        DllCall($g_hTessDLL, "int:cdecl", "TessBaseAPISetVariable", "ptr", $g_pTessAPI, "str", "tessedit_char_whitelist", "str", "")
    EndIf

    DllCall($g_hTessDLL, "none:cdecl", "TessBaseAPISetImage", "ptr", $g_pTessAPI, "ptr", $pPixels, "int", $iW, "int", $iH, "int", 4, "int", $iStride)
    Local $aRetText = DllCall($g_hTessDLL, "ptr:cdecl", "TessBaseAPIGetUTF8Text", "ptr", $g_pTessAPI)
    Local $pText = $aRetText[0]
    Local $sResult = ""

    If $pText <> 0 Then
        Local $tStr = DllStructCreate("char[1024]", $pText)
        $sResult = DllStructGetData($tStr, 1)
        DllCall($g_hTessDLL, "none:cdecl", "TessDeleteText", "ptr", $pText)
    EndIf

    ; 3. TULIS LOG PEKERJAAN JIKA DIMINTA
    If $iWriteLog = 1 Then
        Local $fDiff = Round(TimerDiff($hTimer), 2)
        Local $sLogLine = StringFormat("[%s-%s-%s %s:%s:%s] [%s] Size: %dx%d | PSM: %d | WL: '%s' | Time: %0.2fms | Res: '%s'\r\n", _
                @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC, $sTag, $iW, $iH, $iPSM, $sWL, $fDiff, StringStripWS($sResult, 3))
        Local $hLog = FileOpen($g_sDebugDir & "\ocrworker" & $g_sUniqueSuffix & ".log", 1)
        If $hLog <> -1 Then
            FileWrite($hLog, $sLogLine)
            FileClose($hLog)
        EndIf
    EndIf

    ; 4. TULIS HASIL KE AWAL MEMORI
    DllCall("kernel32.dll", "none", "RtlZeroMemory", "ptr", $g_pSharedBuf, "ulong_ptr", 1024)
    Local $tOut = DllStructCreate("char[1024]", $g_pSharedBuf)
    DllStructSetData($tOut, 1, $sResult)

    Return 1
EndFunc

Func OnAutoItExit()
    If $g_pTessAPI <> 0 Then
        DllCall($g_hTessDLL, "none:cdecl", "TessBaseAPIEnd", "ptr", $g_pTessAPI)
        DllCall($g_hTessDLL, "none:cdecl", "TessBaseAPIDelete", "ptr", $g_pTessAPI)
    EndIf
    If $g_hTessDLL <> 0 Then DllClose($g_hTessDLL)
    _GDIPlus_Shutdown()
    If $g_pSharedBuf <> 0 Then DllCall("kernel32.dll", "bool", "UnmapViewOfFile", "ptr", $g_pSharedBuf)
    If $g_hMapFile <> 0 Then DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $g_hMapFile)
EndFunc