const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');

// 개발 중인지 여부 체크
const isDev = process.env.NODE_ENV === 'development';

// 메인 윈도우 참조를 유지
let mainWindow;

function createWindow() {
  // 브라우저 윈도우 생성
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
    icon: path.join(__dirname, 'assets/icons/icon.png')
  });

  // 메인 HTML 파일 로드
  mainWindow.loadFile('index.html');

  // 개발 중에는 개발자 도구 열기
  if (isDev) {
    mainWindow.webContents.openDevTools();
  }

  // 윈도우가 닫힐 때 발생하는 이벤트
  mainWindow.on('closed', function () {
    mainWindow = null;
  });
}

// Electron이 초기화됐을 때 윈도우 생성
app.whenReady().then(createWindow);

// 모든 창이 닫힐 때 앱 종료 (macOS 제외)
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
  // macOS에서는 앱 아이콘을 클릭하면 창을 다시 생성
  if (mainWindow === null) createWindow();
});

// IPC 핸들러 설정
// 예: Todo 항목 저장, 가져오기 등의 기능을 여기에 구현 