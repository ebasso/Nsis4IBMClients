; OBJETIVO.......: Installer IBM Connections Plugin for Windows Explorer/Office/Outlook
; DATA DE CRIAÇÃO: 29/01/2016
; AUTORES........: KRAUCER FERNANDES MAZUCO <kraucer@bb>
;		   RODRIGO MARTINS <rodrigo.martins@bb>
;                  ENIO BASSO <ebasso>
;
; Controle de Versoes:
; 				   20160129: Versao 0.0
; 				   20160201: Primeira Versao

!define INSTALLER_VERSION "16.1"
!define SOURCE_FILES "C:\connections_files"     ; Arquivos usados para montagem do pacote do nsis
!define INSTALL_TEMP "C:\connections_install"   ; Diretorio temporário para extracao dos arquivos
!define IBM_CONNECTIONS_TITLE "Connections"
!define IBM_CONNECTIONS_URL "https://connections.company.com.br"
!define /date NOW "%Y-%m-%d-%H-%M-%S"

Name "Instalador do IBM Connections Plugins for Windows ${INSTALLER_VERSION}"
OutFile "${SOURCE_FILES}\BB_ConnectionsPlugin_${INSTALLER_VERSION}.exe"

ShowInstDetails show
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
RequestExecutionLevel user ;apenas para o Windows Vista + UAC

Function .onInit
	SetSilent Silent
	ClearErrors
FunctionEnd
	
Section "Instala o IBM Connections Plugin"
	SetOverwrite on
    SetOutPath "${INSTALL_TEMP}"
    
	; -----------------------------------------------------------	Arquivos a serem incluidos
	File  "${SOURCE_FILES}\IBMConnectionsMSDesktop.exe"	

    Var /Global MyFileOutput
    
    FileOpen $MyFileOutput "${INSTALL_TEMP}\BB_ConnectionsPlugin_${NOW}.log" a
    FileWrite $MyFileOutput "$\nRunning IBMConnectionsMSDesktop.exe - Start"
	; -----------------------------------------------------------

    
	; Opções de reinicialização 
    ;   /norestart      => Não reinicia depois que a instalação for concluída
	;   /promptrestart  => Solicita que o usuário reinicie, caso necessário
	;   /forcerestart   => Sempre reinicia o computador após a instalação
    ; ADDLOCAL=WindowsExplorer,MicrosoftOffice,MicrosoftOutlook
    ClearErrors
	ExecWait "IBMConnectionsMSDesktop.exe /install /quiet /norestart /Lv connections_plugin_install.log" $0
    IfErrors Handle_Error

	FileWrite $MyFileOutput "$\nRunning IBMConnectionsMSDesktop.exe - End"
	
    
    FileWrite $MyFileOutput "$\nWriting Regedit - Start"
    FileWrite $MyFileOutput "$\nWriting Regedit - DefaultConnectURL"
    WriteRegStr HKLM "SOFTWARE\Wow6432Node\IBM\Social Connectors\Settings" "DefaultConnectURL" "${IBM_CONNECTIONS_URL}"
    IfErrors Handle_Error
    
    FileWrite $MyFileOutput "$\nWriting Regedit - DefaultConnectName"
	WriteRegStr HKLM "SOFTWARE\Wow6432Node\IBM\Social Connectors\Settings" "DefaultConnectName" "${IBM_CONNECTIONS_TITLE}"
    IfErrors Handle_Error
    FileWrite $MyFileOutput "$\nWriting Regedit - End"
    Goto Done
    
Handle_Error:
    FileWrite $MyFileOutput "$\nError on command - ResultCode=[$0]"
Done:
    FileClose $MyFileOutput   
    Delete "${INSTALL_TEMP}\IBMConnectionsMSDesktop.exe"
SectionEnd
