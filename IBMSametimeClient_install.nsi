; OBJETIVO.......: INSTALAR O SAMETIME CLIENT
; DATA DE CRIA��O: 04/03/2015
; AUTORES........: KRAUCER FERNANDES MAZUCO <kraucer@bb>
;		               RODRIGO MARTINS <rodrigo.martins@bb>
;                  ENIO BASSO <ebasso>
; Controle de Versoes:
; 03/12/2015: ajustado o path para "Program Files (x86)" - PMR 58017,999,631 no arquivo setup.msi
; 18/09/2015: bug enviado pelo Roque sobre problemas com o estouro de limite no nome de arquivos/pastas quando da gera��o da ISO. Rodrigo Martins confirmou e repassou solu��o.
;             Ajustado o path de "IBM\Sametime Connect" para "IBM\ST". Arquivo setup.msi tamb�m foi ajustado.
; 22/12/2015: Ajustado hot fix para suporte a windows 10.
; 29/01/2016: Melhoria na documenta��o
;             Altera��o do arquivo setup.msi para o install do Cliente
;             Altera��o do arquivo setup.msi para o hotfix do cliente
!define INSTALLER_VERSION "2016.01"
!define SOURCE_FILES "C:\Sametime_files"     ; Arquivos usados para montagem do pacote do nsis
!define INSTALL_TEMP "C:\Sametime_install"   ; Diretorio tempor�rio para extracao dos arquivos
!define SAMETIME_INSTALL_DIR "$PROGRAMFILES32\IBM\SametimeConnect"
!define /date NOW "%Y-%m-%d-%H-%M-%S"

Name "Instalador do IBM Sametime Client for Windows ${INSTALLER_VERSION}"
OutFile "${SOURCE_FILES}\BB_SametimeCliente_${INSTALLER_VERSION}.exe"

ShowInstDetails show
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
RequestExecutionLevel user ;apenas para o Windows Vista + UAC

Function .onInit
	SetSilent Silent
	ClearErrors
FunctionEnd

Section "Instala o Sametime Client"
	; -----------------------------------------------------------	Arquivos a serem incluidos
    SetOverwrite on
    SetOutPath "${INSTALL_TEMP}"              ; Obrigatorio
	File  "${SOURCE_FILES}\cacerts"
    SetOutPath "${INSTALL_TEMP}\inst_st_cli_90"
    File  "${SOURCE_FILES}\inst_st_cli_90\setup.msi"
    File  /r "${SOURCE_FILES}\inst_st_cli_90\deploy"
    File  /r "${SOURCE_FILES}\inst_st_cli_90\updateSite"
    SetOutPath "${INSTALL_TEMP}\fix_20150825-0430"
	File  "${SOURCE_FILES}\fix_20150825-0430\setup.msi"
    File  /r "${SOURCE_FILES}\fix_20150825-0430\deploy"
    File  /r "${SOURCE_FILES}\fix_20150825-0430\updateSite"
    SetOutPath "${INSTALL_TEMP}"

    Var /Global MyFileOutput
    FileOpen $MyFileOutput "${INSTALL_TEMP}\BB_SametimeCliente_${NOW}.log" w

    FileWrite $MyFileOutput "---------------------------- Started at ${NOW} ----------------------------"
    FileWrite $MyFileOutput "$\nPROGRAMFILES =[$PROGRAMFILES]"
    FileWrite $MyFileOutput "$\nPROGRAMFILES32 =[$PROGRAMFILES32]"

    FileWrite $MyFileOutput "$\n$\n---------------------------- Generating silentinstall.ini - Start----------------------------"

    Var /Global SilentIniOutput
    FileOpen $SilentIniOutput "${INSTALL_TEMP}\silentinstall.ini" w
    FileWrite $SilentIniOutput "[Properties]"
    FileWrite $SilentIniOutput "$\nLAPAGREE=YES"
    FileWrite $SilentIniOutput "$\nCREATECOMMUNITYTEMPLATE=true"
    FileWrite $SilentIniOutput "$\nSTSERVERNAME=vipst.bb.com.br"
    FileWrite $SilentIniOutput "$\nSTCOMMUNITYNAME=VipstBB"
    FileWrite $SilentIniOutput "$\nSTSERVERPORT=1533"
    FileWrite $SilentIniOutput "$\nSTSENDKEEPALIVE=true"
    FileWrite $SilentIniOutput "$\nSTKEEPALIVETIME=60"
    FileWrite $SilentIniOutput "$\nSTCONNECTIONTYPE75=direct"
    FileWrite $SilentIniOutput "$\nSTPROXYHOST="
    FileWrite $SilentIniOutput "$\nSTPROXYPORT="
    FileWrite $SilentIniOutput "$\nSTRESOLVELOCALY75="
    FileWrite $SilentIniOutput "$\nSTPROXYUSERNAME="
    FileWrite $SilentIniOutput "$\nSTPROXYPASSWORD="
    FileWrite $SilentIniOutput "$\nSTCOUNTRYLANG=pt_br"
    FileWrite $SilentIniOutput "$\nSTAUTHSERVERURL="
    FileWrite $SilentIniOutput "$\nSTLOGINBYTOKEN=false"
    FileWrite $SilentIniOutput "$\nSTAUTHTYPE=TAM-SPNEGO"
    FileWrite $SilentIniOutput "$\nSTLOGINATSTARTUP=false"
    FileWrite $SilentIniOutput "$\nSTUNINSTALL75=1"
    FileWrite $SilentIniOutput "$\nSTUNINSTALLPRE75=1"
    FileClose $SilentIniOutput

    FileWrite $MyFileOutput "$\nGenerating silentinstall.ini - End"

	; -----------------------------------------------------------	Realiza a instalacao do Sametime Client 9.0
    FileWrite $MyFileOutput "$\n$\n---------------------------- Running inst_st_cli_90\setup.msi - Start ----------------------------"
    FileWrite $MyFileOutput '$\n[msiexec /i setup.msi /Lv "..\sametime_install.log" /qn SETUPEXEDIR="${INSTALL_TEMP}\inst_st_cli_90" INSTALLDIR="${SAMETIME_INSTALL_DIR}" STSILENTINIFILE="..\silentinstall.ini" STSILENTINSTALL=TRUE]'
    SetOutPath "${INSTALL_TEMP}\inst_st_cli_90"
    ClearErrors
	ExecWait 'msiexec /i setup.msi /Lv "..\sametime_install.log" /qn SETUPEXEDIR="${INSTALL_TEMP}\inst_st_cli_90" INSTALLDIR="${SAMETIME_INSTALL_DIR}" STSILENTINIFILE="..\silentinstall.ini" STSILENTINSTALL=TRUE' $R0
    IfErrors Handle_Error

    FileWrite $MyFileOutput "$\nRunning inst_st_cli_90\setup.msi - End"

	; -----------------------------------------------------------	Realiza a instalacao do HotFix
    FileWrite $MyFileOutput "$\n$\n---------------------------- Running fix_20150825\setup.msi - Start ----------------------------"
    FileWrite $MyFileOutput '$\n[msiexec /i setup.msi /Lvx* "..\sametime_hotfix_install.log" /qn]'
    SetOutPath "${INSTALL_TEMP}\fix_20150825-0430"
    ClearErrors
	ExecWait 'msiexec /i setup.msi /Lvx* "..\sametime_hotfix_install.log" /qn' $R0
    IfErrors Handle_Error

    FileWrite $MyFileOutput "$\nRunning fix_20150825\setup.msi - End"

    ; ----------------------------------------------------------- Instalacao dos certificados SSL do Banco do Brasil -----------------------------------------------------------
    FileWrite $MyFileOutput "$\n$\n---------------------------- Instalacao dos certificados SSL do Banco do Brasil  - Start ----------------------------"
    ClearErrors
	IfFileExists "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20121108a-201308170230\jre\lib\security\cacerts.bkp" +3 0
		CopyFiles "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20121108a-201308170230\jre\lib\security\cacerts" "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20121108a-201308170230\jre\lib\security\cacerts.bkp"
        CopyFiles "${INSTALL_TEMP}\cacerts" "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20121108a-201308170230\jre\lib\security\cacerts"

    IfErrors Handle_Error

    IfFileExists "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20141026a-201505051418\jre\lib\security\cacerts.bkp" +3 0
		CopyFiles "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20141026a-201505051418\jre\lib\security\cacerts" "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20141026a-201505051418\jre\lib\security\cacerts.bkp"
        CopyFiles "${INSTALL_TEMP}\cacerts" "${SAMETIME_INSTALL_DIR}\rcp\eclipse\plugins\com.ibm.rcp.j2se.win32.x86_1.6.0.20141026a-201505051418\jre\lib\security\cacerts"

    IfErrors Handle_Error
    FileWrite $MyFileOutput "$\nInstalacao dos certificados SSL do Banco do Brasil  - End"

    FileWrite $MyFileOutput "$\n---------------------------- Limpeza dos diretorios - Start ----------------------------"
	RMDir /r ${INSTALL_TEMP}\inst_st_cli_90
	RMDir /r ${INSTALL_TEMP}\fix_20150825-0430
    Delete ${INSTALL_TEMP}\cacerts
	;Delete ${INSTALL_TEMP}\silentinstall.ini
    FileWrite $MyFileOutput "$\nLimpeza dos diretorios - End"
    Goto Done

Handle_Error:
    FileWrite $MyFileOutput "$\nError on command - ResultCode=[$R0]"
Done:
    FileClose $MyFileOutput
SectionEnd
