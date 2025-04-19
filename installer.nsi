; TodoTools 인스톨러 스크립트
; NSIS(Nullsoft Scriptable Install System)를 사용하여 작성됨

; 설치 프로그램 이름과 파일 정의
!define APPNAME "TodoTools"
!define COMPANYNAME "TodoTools"
!define DESCRIPTION "할 일 관리 및 생산성 도구"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0

; 압축 방식 설정
SetCompressor /SOLID lzma

; 기본 설정
Name "${APPNAME}"
OutFile "TodoTools_Setup.exe"
InstallDir "$PROGRAMFILES64\${APPNAME}"
InstallDirRegKey HKLM "Software\${COMPANYNAME}\${APPNAME}" "Install_Dir"
RequestExecutionLevel admin

; 인터페이스 설정
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "windows\runner\resources\app_icon.ico"

; 페이지 설정
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; 언어 설정
!insertmacro MUI_LANGUAGE "Korean"

; 설치 섹션
Section "Install"
  ; 설치 디렉터리 설정
  SetOutPath "$INSTDIR"
  
  ; 필요한 파일 복사
  File "build\windows\x64\runner\Release\todotools.exe"
  File "build\windows\x64\runner\Release\flutter_windows.dll"
  File "build\windows\x64\runner\Release\sqlite3.dll"
  File "build\windows\x64\runner\Release\sqlite3_flutter_libs_plugin.dll"
  File "build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"
  
  ; 데이터 폴더 복사
  CreateDirectory "$INSTDIR\data"
  SetOutPath "$INSTDIR\data"
  File /r "build\windows\x64\runner\Release\data\*.*"
  
  ; 기본 디렉터리로 복귀
  SetOutPath "$INSTDIR"
  
  ; 시작 메뉴 바로가기 생성
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\todotools.exe" "" "$INSTDIR\todotools.exe" 0
  CreateShortCut "$SMPROGRAMS\${APPNAME}\제거.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  
  ; 바탕화면 바로가기 생성
  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\todotools.exe" "" "$INSTDIR\todotools.exe" 0
  
  ; 레지스트리에 설치 정보 저장
  WriteRegStr HKLM "Software\${COMPANYNAME}\${APPNAME}" "Install_Dir" "$INSTDIR"
  
  ; Windows 제어판 프로그램 추가/제거에 정보 추가
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\todotools.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
  
  ; 제거 프로그램 작성
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

; 제거 섹션
Section "Uninstall"
  ; 프로그램 파일 제거
  Delete "$INSTDIR\todotools.exe"
  Delete "$INSTDIR\flutter_windows.dll"
  Delete "$INSTDIR\sqlite3.dll"
  Delete "$INSTDIR\sqlite3_flutter_libs_plugin.dll"
  Delete "$INSTDIR\url_launcher_windows_plugin.dll"
  Delete "$INSTDIR\uninstall.exe"
  
  ; 데이터 폴더와 내용 제거
  RMDir /r "$INSTDIR\data"
  
  ; 바로가기 제거
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\제거.lnk"
  RMDir "$SMPROGRAMS\${APPNAME}"
  Delete "$DESKTOP\${APPNAME}.lnk"
  
  ; 레지스트리 항목 제거
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
  DeleteRegKey HKLM "Software\${COMPANYNAME}\${APPNAME}"
  
  ; 설치 디렉터리 제거
  RMDir "$INSTDIR"
SectionEnd 