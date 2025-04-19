; TodoTools 설치 프로그램 스크립트
; Inno Setup을 사용하여 작성됨

#define MyAppName "TodoTools"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "TodoTools Team"
#define MyAppURL "https://todotools.com/"
#define MyAppExeName "todotools.exe"

[Setup]
; NOTE: AppId 값은 각 애플리케이션마다 고유해야 합니다
AppId={{5F66A626-01F7-4D3B-A03F-8A75D87E7DB9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; 관리자 권한 요청 없음 - 로컬 사용자 디렉토리에 설치
PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename=TodoTools_Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "TodoTools_Portable\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "TodoTools_Portable\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// 애플리케이션 초기 실행 시 설정하는 코드
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // 기존 데이터 파일이 있다면 초기화 (배포용)
    // 이 부분은 Inno Setup 내에서는 필요 없을 수 있습니다.
    // 앱 자체에서 이미 초기화 코드가 포함되어 있기 때문입니다.
  end;
end;

// 제거 작업 시 데이터 삭제 여부 확인
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  mRes: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    mRes := MsgBox('프로그램 데이터도 함께 삭제하시겠습니까?' + #13#10 + 
                   '(아니오를 선택하면 설정과 데이터가 보존됩니다)', 
                   mbConfirmation, MB_YESNO or MB_DEFBUTTON2);
                   
    if mRes = IDYES then
    begin
      // 사용자 데이터 폴더 삭제 로직
      DelTree(ExpandConstant('{app}\data'), True, True, True);
    end;
  end;
end; 