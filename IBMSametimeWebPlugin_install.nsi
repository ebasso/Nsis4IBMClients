; OBJETIVO.......: INSTALAR O IBM Sametime Web Audio/Video Plugin for MS Windows
; DATA DE CRIAÇÃO: 29/01/2016
; AUTORES........: KRAUCER FERNANDES MAZUCO <kraucer@bb>
;		               RODRIGO MARTINS <rodrigo.martins@bb>
;                  ENIO BASSO <ebasso>
;
; Controle de Versoes:
; 				   20160129: Versao 0.0
; 				   20160202: Primeira Versao
; Versoes do Sametime
; AGAR-9WNDRP_SametimeMediaManager
;    WebPlayer=9,0,0,1529
;    Softphone=9.0.0.1529
;    Windows Version=9.000.13083
; AGUA_SametimeMediaManager
;    WebPlayer=9,0,0,1529
;    Softphone=9.0.0.1529
;    Windows Version=9.000.13087

!define INSTALLER_VERSION "9.000.13083"
!define SOURCE_FILES "C:\stwebplugin_files"     ; Arquivos usados para montagem do pacote do nsis
!define INSTALL_TEMP "C:\stwebplugin_install"   ; Diretorio temporário para extracao dos arquivos
!define /date NOW "%Y-%m-%d-%H-%M-%S"

Name "Instalador do IBM Sametime Web Audio/Video Plugin for Windows"
OutFile "${SOURCE_FILES}\BB_SametimeWebPlugin_${INSTALLER_VERSION}.exe"

ShowInstDetails show
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
RequestExecutionLevel user ;apenas para o Windows Vista + UAC

Function .onInit
	SetSilent Silent
	ClearErrors
FunctionEnd

Section "Instala o IBM Sametime WebAVPlugin"
	SetOverwrite on
    SetOutPath "${INSTALL_TEMP}"  ; Obrigatorio

	; -----------------------------------------------------------	Arquivos a serem incluidos
	File  "${SOURCE_FILES}\setup.exe"

	Var /Global MyFileOutput

    FileOpen $MyFileOutput "${INSTALL_TEMP}\BB_SametimeWebPlugin_${NOW}.log" w
    FileWrite $MyFileOutput "---------------------------- Started at ${NOW} ----------------------------"
    FileWrite $MyFileOutput "$\n---------------------------- Running setup.exe - Start ----------------------------"
    	; -----------------------------------------------------------

    ClearErrors
	ExecWait 'setup.exe /S /V"/Lvx* sametime_webav_plg_install.log /qn INSTALLSCOPE=machine FF_VERSION=\"31.0 ESR (x86 pt-BR)\" " ' $R0
    IfErrors Handle_Error
    FileWrite $MyFileOutput "$\nError on command - ResultCode=[$R0]"
	FileWrite $MyFileOutput "$\nRunning setup.exe - End"

    FileWrite $MyFileOutput "$\n---------------------------- Limpeza dos diretorios - Start ----------------------------"
    Delete ${INSTALL_TEMP}\setup.exe
    FileWrite $MyFileOutput "$\nLimpeza dos diretorios - End"
    Goto Done

Handle_Error:
    FileWrite $MyFileOutput "$\nError on command - ResultCode=[$R0]"
Done:
    FileClose $MyFileOutput
SectionEnd
