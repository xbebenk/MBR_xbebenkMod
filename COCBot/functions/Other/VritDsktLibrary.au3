#include <Constants.au3>
#include <Array.au3>
Opt("MustDeclareVars", True)

#cs ----------------------------------------------------------------------------

	AutoIt Version : 3.3.14.5
	Script Date : 21.09.2021
	Script Version 1.0
	Author : HerMano
	Great Contribution And THANKS To : Nine And kafu
	Discussion area : https : / / www.autoitscript.com / forum / topic / 206559 - virtual - desktop - manager - under - windows - 10 / ? tab = comments & _fromLogin = 1

#ce ----------------------------------------------------------------------------

;If @OSVersion <> "WIN_10" Then Exit MsgBox($MB_SYSTEMMODAL, "", "This script only runs on Win 10")
Global $oVirtualDesktopManagerInternal
Global $oApplicationViewCollection
Global $oVirtualDesktopPinnedApps

#Region ####ALL FUNCTIONS
;~										***** INIT FUNCIONS  *****
;~ _VrtDesktObjCreation()      					Creates key objects, needs to be launched as first
;~ _VrtDesktObjDestroy ()						Destroys global objects
;~
;~										***** INFO FUNCIONS  *****
;~ _GetEnumVirtDskt()					Returns the number of virtual VrtDeskts
;~ _GetCurrVrtDesktop()					Returns pointer to the current vrtDeskt
;~ _AddressOfAllVirutalDesktops()		Returns an array With all VrtDeskt Ptr, element [0]=Number of VDsk
;~ _GetApplicationObj_FromWinHandle($hWnd)				Returns the application Object. Methods listed inside func
;~ _GetApplicationID_FromWinHandle($hWnd)				Returns the application user model ID -AUMID-
;~ _GetApplicationcCollectionView_FromWinHandle ($hWnd)	Returns the application View
;~ _IsWinViewPinned($hWnd)				Boolean check to see if the window view is pinned
;~ _IsWinIDPinned ($hWnd)				Boolean check to see if the window ID is pinned
;~
;~										***** ACTION FUNCIONS  *****
;~ _CreateNewVirtDskt()					Creates a new VrtDeskt
;~ _CreateNewVirtDsktAndSwitch()		Creates and swtitches to new VrtDeskt, retruns=ptr ptr=pVrtDeskt
;~ _SwitchToRightVrtDesktop()			Switches to VrtDeskt to the right, retruns=0/ptr 0=fail ptr=pVrtDeskt
;~ _SwitchToRightVrtDesktopLooped()  	Switches one/time till last then loops back to first one
;~ _SwitchToLeftVrtDesktop()			Switches to VrtDeskt to the left, retruns=0/ptr 0=fail ptr=pVrtDeskt
;~ _SwitchToSpecificVrtDesktop(int=1)	Switches to the requested VrtDeskt[1,2, ..], returns error code
;~ _SplashVirtDsktNumber($pVrtDskt,bool)Writes ID of VrtDeskt on screen (2s) if Bool=True, return VrtDskt Idx
;~ _PinWinView_ToAllDskt ($hWnd)		Shows window on all desktops, returns error
;~ _PinWinID_ToAllDskt ($hWnd)			Shows windows from same app on all desktops, returns error
;~ _UnPinWinView_FromAllDskt ($hWnd)	Unpin single window, returns error
;~ _UnPinWinID_FromAllDskt ($hWnd)		Unpin all windows, returns error
;~ _MoveAppToSpecificDesktop($hWnd, $iDsktNumb = 2)			Moves windows to virtdskt, default #2
;~ _CloseDesktop($iDsktNumb)			Closes the specified virtdskt [1,2.. ] and defaults back open win on #1
#EndRegion ####ALL FUNCTIONS

;~ _VrtDesktObjCreation()
;~ #include <Misc.au3>

;~ __Example1() ; create/destroy | Create+switch/splashname | SwitchtoSpecific/splashname

;~ HotKeySet("^q", __Example2)	;loops desktop rotation
;~ Do
;~ 	Sleep (50)
;~ Until _IsPressed ("1B")

;~ __Example3()		;check for pinned view and id | pins | unpins Does the same for WinID
;~ 					;to test WinId pinning just open 2 notepads on the same VirtDskt

;~ __Example4()  ; moves a window to a chosen VirtDskt and swaps

;~ _VrtDesktObjDestroy()

#Region #### EXAMPLES
	Func __Example1()
		Local $iNumD = _GetEnumVirtDskt()
		_CreateNewVirtDskt()
		Send("#{TAB}")
		Sleep(1000)
		Send("{ESC}")
		_CloseDesktop($iNumD + 1)
		Local $pNew = _CreateNewVirtDsktAndSwitch()
		_SplashVirtDsktNumber($pNew, True)
		$pNew = _SwitchToSpecificVrtDesktop(2)
		_SplashVirtDsktNumber($pNew, True)
	EndFunc   ;==>__Example1

	Func __Example2()
		Local $ires = _SwitchToRightVrtDesktopLooped()
		_SplashVirtDsktNumber($ires, True)
	EndFunc   ;==>__Example2

	Func __Example3()
		;Local $hWnd = WinGetHandle("[CLASS:Notepad]")
		Local $hWnd = $g_hAndroidWindow
		Local $bRes = _IsWinViewPinned($hWnd)
		Local $bRes1 = _IsWinIDPinned($hWnd)
		ConsoleWrite("Is WinView pinned = " & $bRes & " || Is WinID pinned = " & $bRes1 & @CRLF)
		If $bRes = False Then _PinWinView_ToAllDskt($hWnd)
		Send("#{TAB}")
		Sleep(3000)
		Send("{ESC}")
		_UnPinWinView_FromAllDskt($hWnd)

		If $bRes1 = False Then _PinWinID_ToAllDskt($hWnd)
		Send("#{TAB}")
		Sleep(3000)
		Send("{ESC}")
		_UnPinWinID_FromAllDskt($hWnd)
	EndFunc   ;==>__Example3

	Func __Example4()
		;Local $hWnd = WinGetHandle("[CLASS:Notepad]")
		Local $hWnd = $g_hAndroidWindow
		Local $ires = _MoveAppToSpecificDesktop($hWnd, 2)
		Local $pNew = _SwitchToSpecificVrtDesktop(2)
		_SplashVirtDsktNumber($pNew, True)
	EndFunc   ;==>__Example4

#EndRegion #### EXAMPLES

;~ --------------------------------------------------------------------------------------------------
Func _VrtDesktObjCreation()                                                             ;>>>***<<<
	; Instanciation objects
	Local $CLSID_ImmersiveShell = "{c2f03a33-21f5-47fa-b4bb-156362a2f239}"
	Local $IID_IUnknown = "{00000000-0000-0000-c000-000000000046}"
	Local $IID_IServiceProvider = "{6D5140C1-7436-11CE-8034-00AA006009FA}"
	Local $tIID_IServiceProvider = __uuidof($IID_IServiceProvider)
	Local $tagIServiceProvider = _
			"QueryService hresult(struct*;struct*;ptr*);"

	; VirtualDesktopManagerInternal object
	Local $CLSID_VirtualDesktopManagerInternal = "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}"
	Local $tCLSID_VirtualDesktopManagerInternal = __uuidof($CLSID_VirtualDesktopManagerInternal)
	Local $IID_IVirtualDesktopManagerInternal = "{F31574D6-B682-4CDC-BD56-1827860ABEC6}"
	Local $tIID_IVirtualDesktopManagerInternal = __uuidof($IID_IVirtualDesktopManagerInternal)
	Local $tagIVirtualDesktopManagerInternal = _
			"GetCount hresult(int*);" & _
			"MoveViewToDesktop hresult(ptr;ptr);" & _
			"CanViewMoveDesktops hresult(ptr;bool*);" & _
			"GetCurrentDesktop hresult(ptr*);" & _
			"GetDesktops hresult(ptr*);" & _
			"GetAdjacentDesktop hresult(ptr;int;ptr*);" & _
			"SwitchDesktop hresult(ptr);" & _
			"CreateDesktopW hresult(ptr*);" & _
			"RemoveDesktop hresult(ptr;ptr);" & _
			"FindDesktop hresult(struct*;ptr*);"

	; ApplicationViewCollection object
	Local $CLSID_IApplicationViewCollection = "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}"
	Local $tCLSID_IApplicationViewCollection = __uuidof($CLSID_IApplicationViewCollection)
	Local $IID_IApplicationViewCollection = "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}"
	Local $tIID_IApplicationViewCollection = __uuidof($IID_IApplicationViewCollection)
	Local $tagIApplicationViewCollection = _
			"GetViews hresult(struct*);" & _
			"GetViewsByZOrder hresult(struct*);" & _
			"GetViewsByAppUserModelId hresult(wstr;struct*);" & _
			"GetViewForHwnd hresult(hwnd;ptr*);" & _
			"GetViewForApplication hresult(ptr;ptr*);" & _
			"GetViewForAppUserModelId hresult(wstr;int*);" & _
			"GetViewInFocus hresult(ptr*);"

	; VirtualDesktopPinnedApps object
	Local $CLSID_VirtualDesktopPinnedApps = "{b5a399e7-1c87-46b8-88e9-fc5747b171bd}"
	Local $tCLSID_VirtualDesktopPinnedApps = __uuidof($CLSID_VirtualDesktopPinnedApps)
	Local $IID_IVirtualDesktopPinnedApps = "{4ce81583-1e4c-4632-a621-07a53543148f}"
	Local $tIID_IVirtualDesktopPinnedApps = __uuidof($IID_IVirtualDesktopPinnedApps)
	Local $tagIVirtualDesktopPinnedApps = _
			"IsAppIdPinned hresult(wstr;bool*);" & _
			"PinAppID hresult(wstr);" & _
			"UnpinAppID hresult(wstr);" & _
			"IsViewPinned hresult(ptr;bool*);" & _
			"PinView hresult(ptr);" & _
			"UnpinView hresult(ptr);"

	; objects creation
	Local $pService
	Local $oImmersiveShell = ObjCreateInterface($CLSID_ImmersiveShell, $IID_IUnknown, "")
	;ConsoleWrite("Immersive shell = " & IsObj($oImmersiveShell) & @CRLF)
	$oImmersiveShell.QueryInterface($tIID_IServiceProvider, $pService)
	;ConsoleWrite("Service pointer = " & $pService & @CRLF)
	Local $oService = ObjCreateInterface($pService, $IID_IServiceProvider, $tagIServiceProvider)
	;ConsoleWrite("Service = " & IsObj($oService) & @CRLF)

	Local $pApplicationViewCollection, $pVirtualDesktopManagerInternal, $pVirtualDesktopPinnedApps
	$oService.QueryService($tCLSID_IApplicationViewCollection, $tIID_IApplicationViewCollection, $pApplicationViewCollection)
	;ConsoleWrite("View collection pointer = " & $pApplicationViewCollection & @CRLF)
	$oApplicationViewCollection = ObjCreateInterface($pApplicationViewCollection, $IID_IApplicationViewCollection, $tagIApplicationViewCollection)
	;ConsoleWrite("View collection = " & IsObj($oApplicationViewCollection) & @CRLF)

	$oService.QueryService($tCLSID_VirtualDesktopManagerInternal, $tIID_IVirtualDesktopManagerInternal, $pVirtualDesktopManagerInternal)
	;ConsoleWrite("Virtual Desktop pointer = " & $pVirtualDesktopManagerInternal & @CRLF)
	$oVirtualDesktopManagerInternal = ObjCreateInterface($pVirtualDesktopManagerInternal, $IID_IVirtualDesktopManagerInternal, $tagIVirtualDesktopManagerInternal)
	;ConsoleWrite("Virtual Desktop = " & IsObj($oVirtualDesktopManagerInternal) & @CRLF)

	$oService.QueryService($tCLSID_VirtualDesktopPinnedApps, $tIID_IVirtualDesktopPinnedApps, $pVirtualDesktopPinnedApps)
	;ConsoleWrite("Virtual Desktop Pinned Apps = " & $pVirtualDesktopPinnedApps & @CRLF)
	$oVirtualDesktopPinnedApps = ObjCreateInterface($pVirtualDesktopPinnedApps, $IID_IVirtualDesktopPinnedApps, $tagIVirtualDesktopPinnedApps)
	;ConsoleWrite("Virtual Desktop Pinned Apps = " & IsObj($oVirtualDesktopPinnedApps) & @CRLF)
EndFunc   ;==>_VrtDesktObjCreation

Func _VrtDesktObjDestroy()                                                              ;>>>***<<<
	$oVirtualDesktopManagerInternal = 0
	$oApplicationViewCollection = 0
	$oVirtualDesktopPinnedApps = 0

EndFunc   ;==>_VrtDesktObjDestroy

Func _CreateNewVirtDskt()                                                               ;>>>***<<<
	Local $pNew
	Local $iHresult = $oVirtualDesktopManagerInternal.CreateDesktopW($pNew)
	ConsoleWrite("- ###DEBUG Create Dskt= " & $pNew & "/" & $iHresult & @CRLF)
EndFunc   ;==>_CreateNewVirtDskt

Func _CreateNewVirtDsktAndSwitch()                                                      ;>>>***<<<
	Local $pNew
	Local $iHresult = $oVirtualDesktopManagerInternal.CreateDesktopW($pNew)
	ConsoleWrite("- ###DEBUG Create Dskt and Switch= " & $pNew & "/" & $iHresult & @CRLF)
	Sleep(30)
	$iHresult = $oVirtualDesktopManagerInternal.SwitchDesktop($pNew)
	Return _GetCurrVrtDesktop()
EndFunc   ;==>_CreateNewVirtDsktAndSwitch

Func _GetEnumVirtDskt()                                                                 ;>>>***<<<
	Local $iCount
	Local $iHresult = $oVirtualDesktopManagerInternal.GetCount($iCount)
	ConsoleWrite("- ###DEBUG Number of Desktops = " & $iCount & "/" & $iHresult & @CRLF)
	Return $iCount
EndFunc   ;==>_GetEnumVirtDskt

Func _AddressOfAllVirutalDesktops()                                                     ;>>>***<<<
	_VrtDesktObjCreation() ;virtual desktop object
	Local $pArray, $aArrayDsktPtr[2], $ii, $iCount, $pDskt, $iHresult, $oArray
	Local $IID_IObjectArray = "{92ca9dcd-5622-4bba-a805-5e9f541bd8c9}"
	Local $tagIObjectArray = _
			"GetCount hresult(int*);" & _
			"GetAt hresult(int;ptr;ptr*);"
	Local $IID_IVirtualDesktop = "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}"
	Local $tIID_IVirtualDesktop = __uuidof($IID_IVirtualDesktop)
	Local $tagIVirtualDesktop = _
			"IsViewVisible hresult(ptr;bool*);" & _
			"GetId hresult(clsid*);"

	$iHresult = $oVirtualDesktopManagerInternal.GetDesktops($pArray)
	$oArray = ObjCreateInterface($pArray, $IID_IObjectArray, $tagIObjectArray)
	$oArray.GetCount($iCount)
;~ 	ConsoleWrite("- ###DEBUG Deskt Count = " & $iCount & @CRLF) ;- ###DEBUG
	For $ii = 0 To $iCount - 1
		$oArray.GetAt($ii, DllStructGetPtr($tIID_IVirtualDesktop), $pDskt)
		$aArrayDsktPtr[$ii + 1] = $pDskt
		_ArrayAdd($aArrayDsktPtr, $pDskt)
	Next
	$aArrayDsktPtr[0] = $iCount
	_ArrayPop($aArrayDsktPtr)
;~ 	_ArrayDisplay($aArrayDsktPtr)				;- ###DEBUG
	Return $aArrayDsktPtr
EndFunc   ;==>_AddressOfAllVirutalDesktops

Func _GetCurrVrtDesktop()                                                               ;>>>***<<<
	Local $pCurrent
	Local $iHresult = $oVirtualDesktopManagerInternal.GetCurrentDesktop($pCurrent)
	Return $pCurrent
EndFunc   ;==>_GetCurrVrtDesktop

Func _SwitchToRightVrtDesktop()                                                         ;>>>***<<<
	Const Enum $eLeftDirection = 3, $eRightDirection
	Local $pRight
	Local $iHresult = $oVirtualDesktopManagerInternal.GetAdjacentDesktop(_GetCurrVrtDesktop(), $eRightDirection, $pRight)
	ConsoleWrite("- ###DEBUG Deskt to Right = " & $pRight & @CRLF)
	Sleep(10)
	If $pRight <> 0 Then $oVirtualDesktopManagerInternal.SwitchDesktop($pRight)
	Return $pRight
EndFunc   ;==>_SwitchToRightVrtDesktop

Func _SwitchToRightVrtDesktopLooped()                                                   ;>>>***<<<
	Const Enum $eLeftDirection = 3, $eRightDirection
	Local $aVirtDskt = _AddressOfAllVirutalDesktops()
	Local $pRight
	Local $iHresult = $oVirtualDesktopManagerInternal.GetAdjacentDesktop(_GetCurrVrtDesktop(), $eRightDirection, $pRight)
	ConsoleWrite("- ###DEBUG Deskt to Right = " & $pRight & @CRLF)
	Sleep(10)
	If $pRight = 0 Then $pRight = $aVirtDskt[1]
	$oVirtualDesktopManagerInternal.SwitchDesktop($pRight)
	Return $pRight
EndFunc   ;==>_SwitchToRightVrtDesktopLooped

Func _SwitchToLeftVrtDesktop()                                                          ;>>>***<<<
	Const Enum $eLeftDirection = 3, $eRightDirection
	Local $pLeft
	Local $iHresult = $oVirtualDesktopManagerInternal.GetAdjacentDesktop(_GetCurrVrtDesktop(), $eRightDirection, $pLeft)
	ConsoleWrite("- ###DEBUG Deskt to Right = " & $pLeft & @CRLF)
	Sleep(10)
	If $pLeft <> 0 Then $oVirtualDesktopManagerInternal.SwitchDesktop($pLeft)
	Return $pLeft
EndFunc   ;==>_SwitchToLeftVrtDesktop

Func _SwitchToSpecificVrtDesktop($iDsktNumb = 1)                                        ;>>>***<<<
	Local $aVirtDskt = _AddressOfAllVirutalDesktops()
	If $iDsktNumb > $aVirtDskt[0] Or $iDsktNumb = 0 Then Return -1 ;wrong dskt
	Local $iHresult = $oVirtualDesktopManagerInternal.SwitchDesktop($aVirtDskt[$iDsktNumb])
	ConsoleWrite("- ###DEBUG Specific Deskt switch = " & $iHresult & @CRLF)
	Return _GetCurrVrtDesktop()
EndFunc   ;==>_SwitchToSpecificVrtDesktop

Func _SplashVirtDsktNumber($pVrtDskt, $bDisplay)                                        ;>>>***<<<
	Local $aVirtDskt = _AddressOfAllVirutalDesktops()
	Local $iIndex = _ArraySearch($aVirtDskt, $pVrtDskt)
	If $bDisplay Then
		SplashTextOn("", "Desktop: " & $iIndex, 110, 24, -1, 10, 1 + 4 + 32, "", 12, 600)
		Sleep(3000)
		SplashOff()
	EndIf
	Return $iIndex
EndFunc   ;==>_SplashVirtDsktNumber

Func _GetApplicationObj_FromWinHandle($hWnd)                                            ;>>>***<<<
	Local $iHresult
	Local $pView, $oApplicationView
	Local $IID_IApplicationView = "{372E1D3B-38D3-42E4-A15B-8AB2B178F513}"
	Local $tagIApplicationView = _
			"GetIids hresult(ulong*;ptr*);" & _
			"GetRuntimeClassName hresult(str*);" & _
			"GetTrustLevel hresult(int*);" & _
			"SetFocus hresult();" & _
			"SwitchTo hresult();" & _
			"TryInvokeBack hresult(ptr);" & _
			"GetThumbnailWindow hresult(hwnd*);" & _
			"GetMonitor hresult(ptr*);" & _
			"GetVisibility hresult(int*);" & _
			"SetCloak hresult(int;int);" & _
			"GetPosition hresult(clsid;ptr*);" & _
			"SetPosition hresult(ptr);" & _
			"InsertAfterWindow hresult(hwnd);" & _
			"GetExtendedFramePosition hresult(struct*);" & _
			"GetAppUserModelId hresult(wstr*);" & _
			"SetAppUserModelId hresult(wstr);" & _
			"IsEqualByAppUserModelId hresult(wstr;int*);" & _
			"GetViewState hresult(uint*);" & _
			"SetViewState hresult(uint);" & _
			"GetNeediness hresult(int*);"

	$iHresult = $oApplicationViewCollection.GetViewForHwnd($hWnd, $pView)                    ;>>>***<<<
	;If $g_bDebugSetlog Then ConsoleWrite("- ###DEBUG View from handle = " & $pView & "/" & $iHresult & @CRLF)
	$oApplicationView = ObjCreateInterface($pView, $IID_IApplicationView, $tagIApplicationView)
	;ConsoleWrite("- ###DEBUG Appl view obj = " & IsObj($oApplicationView) & @CRLF)
	Return $oApplicationView
EndFunc   ;==>_GetApplicationObj_FromWinHandle

Func _GetApplicationID_FromWinHandle($hWnd)                                             ;>>>***<<<
	Local $iHresult
	Local $sW_ID
	Local $oApplicationView = _GetApplicationObj_FromWinHandle($hWnd)
	Local $iHresult = $oApplicationView.GetAppUserModelId($sW_ID)
	ConsoleWrite("- ###DEBUG Appl view ID = " & $sW_ID & "/" & $iHresult & @CRLF)
	Return $sW_ID
EndFunc   ;==>_GetApplicationID_FromWinHandle

Func _GetApplicationcCollectionView_FromWinwHandle($hWnd)                               ;>>>***<<<
	Local $pView
	Local $iHresult = $oApplicationViewCollection.GetViewForHwnd($hWnd, $pView)
	;If $g_bDebugSetlog Then ConsoleWrite("- ###DEBUG View from handle = " & $pView & "/" & $iHresult & @CRLF)
	Return $pView
EndFunc   ;==>_GetApplicationcCollectionView_FromWinwHandle

Func _IsWinViewPinned($hWnd)                                                            ;>>>***<<<
	Local $bValue
	Local $pView = _GetApplicationcCollectionView_FromWinwHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.IsViewPinned($pView, $bValue)
	Return $bValue
EndFunc   ;==>_IsWinViewPinned

Func _IsWinIDPinned($hWnd)                                                              ;>>>***<<<
	Local $bValue
	Local $sW_ID = _GetApplicationID_FromWinHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.IsAppIdPinned($sW_ID, $bValue)
	Return $bValue
EndFunc   ;==>_IsWinIDPinned

Func _PinWinView_ToAllDskt($hWnd)                                                       ;>>>***<<<
	Local $pView = _GetApplicationcCollectionView_FromWinwHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.PinView($pView)
	ConsoleWrite("- ###DEBUG Pinned win_View res = " & $iHresult & @CRLF)
	Return $iHresult
EndFunc   ;==>_PinWinView_ToAllDskt

Func _PinWinID_ToAllDskt($hWnd)                                                         ;>>>***<<<
	Local $sW_ID = _GetApplicationID_FromWinHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.PinAppID($sW_ID)
	ConsoleWrite("- ###DEBUG Pinned win_ID res = " & $iHresult & @CRLF)
	Return $iHresult
EndFunc   ;==>_PinWinID_ToAllDskt

Func _UnPinWinView_FromAllDskt($hWnd)                                                   ;>>>***<<<
	Local $pView = _GetApplicationcCollectionView_FromWinwHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.UnPinView($pView)
	ConsoleWrite("- ###DEBUG Pinned win_View res = " & $iHresult & @CRLF)
	Return $iHresult
EndFunc   ;==>_UnPinWinView_FromAllDskt

Func _UnPinWinID_FromAllDskt($hWnd)                                                     ;>>>***<<<
	Local $sW_ID = _GetApplicationID_FromWinHandle($hWnd)
	Local $iHresult = $oVirtualDesktopPinnedApps.UnPinAppID($sW_ID)
	ConsoleWrite("- ###DEBUG Pinned win_ID res = " & $iHresult & @CRLF)
	Return $iHresult
EndFunc   ;==>_UnPinWinID_FromAllDskt

Func _MoveAppToSpecificDesktop($hWnd, $iDsktNumb = 2)                                   ;>>>***<<<
	Local $iHresult
	Local $aVirtDskt = _AddressOfAllVirutalDesktops()
	Local $pView = _GetApplicationcCollectionView_FromWinwHandle($hWnd)

	If $iDsktNumb > $aVirtDskt[0] Or $iDsktNumb = 0 Then Return -1 ;wrong dskt
	Local $iHresult = $oVirtualDesktopManagerInternal.MoveViewToDesktop($pView, $aVirtDskt[$iDsktNumb])
	Sleep(10)
	;If $g_bDebugSetlog Then ConsoleWrite("- ###DEBUG Move = " & $iHresult & @CRLF)
	Return $iHresult
EndFunc   ;==>_MoveAppToSpecificDesktop

Func _CloseDesktop($iDsktNumb)                                                          ;>>>***<<<
	Local $iHresult
	Local $aVirtDskt = _AddressOfAllVirutalDesktops()

	If $iDsktNumb > $aVirtDskt[0] Or $iDsktNumb = 0 Or $iDsktNumb = 1 Then Return -1 ;wrong dskt
	$iHresult = $oVirtualDesktopManagerInternal.RemoveDesktop($aVirtDskt[$iDsktNumb], $aVirtDskt[1])
	Return $iHresult
EndFunc   ;==>_CloseDesktop

Func __uuidof($sGUID)                                                                   ;>>>***<<<
	Local $tGUID = DllStructCreate("ulong Data1;ushort Data2;ushort Data3;byte Data4[8]")
	DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tGUID
EndFunc   ;==>__uuidof

