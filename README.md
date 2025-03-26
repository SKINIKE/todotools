# TodoTools

TodoTools는 Flutter로 개발된 다양한 생산성 도구를 포함한 할 일 관리 앱입니다. 이 앱은 데스크톱 환경(macOS, Windows, Linux)에 최적화되어 있으며, 직관적인 UI와 다양한 기능을 제공합니다.

## 주요 기능

### 할 일 관리
- 할 일 추가, 수정, 삭제
- 중요도 설정 (높음, 중간, 낮음)
- 고정 표시 기능
- 마감일 설정
- 완료 상태 토글
- 검색 기능
- 오늘 할 일 및 고정된 할 일 필터링

### 아이젠하워 매트릭스
- 중요도와 긴급도에 따라 할 일을 4분면에 분류
- 드래그 앤 드롭으로 할 일 재분류
- 분류에 따른 자동 우선순위 설정

### 캘린더
- 날짜별 할 일 시각화
- 우선순위에 따른 색상 구분
- 날짜 필터링
- 미지정 할 일 목록

### 뽀모도로 타이머
- 집중 모드와 휴식 모드
- 사용자 정의 가능한 타이머 설정
- 자동 세션 전환 옵션
- 시각적 피드백
- 긴 휴식 간격 설정
- 테마 색상 커스터마이징

### 계산기
- 기본 계산 기능
- 이전 계산 기록 저장
- 계산 히스토리 관리

### 앱 설정
- 라이트 모드 / 다크 모드 / 시스템 테마 지원
- 테마 설정 저장

## 기술 스택

- **프레임워크**: Flutter
- **상태 관리**: Riverpod
- **데이터베이스**: Drift (SQLite)
- **UI 컴포넌트**: Material Design 3
- **로컬 저장소**: Shared Preferences
- **캘린더**: table_calendar

## 프로젝트 구조

```
lib/
├── constants/         # 상수 정의
│   └── priority_constants.dart # 우선순위 상수
├── database/          # 데이터베이스 관련 코드
│   ├── database.dart  # 데이터베이스 클래스 및 메서드
│   ├── database.g.dart # 자동 생성된 데이터베이스 코드
│   └── tables.dart    # 테이블 정의
├── providers/         # 상태 관리 프로바이더
│   ├── task_provider.dart      # 할 일 관련 상태 관리
│   ├── pomodoro_provider.dart  # 뽀모도로 관련 상태 관리
│   └── theme_provider.dart     # 테마 상태 관리
├── screens/           # 화면 UI
│   ├── home_screen.dart            # 메인 화면
│   ├── app_settings_screen.dart    # 앱 설정 화면
│   ├── calendar_screen.dart        # 캘린더 화면
│   ├── calculator_screen.dart      # 계산기 화면
│   ├── matrix_content.dart         # 아이젠하워 매트릭스 화면
│   ├── pomodoro_screen.dart        # 뽀모도로 타이머 화면
│   └── pomodoro_settings_screen.dart # 뽀모도로 설정 화면
├── services/          # 서비스 로직
│   └── todo_service.dart  # 할 일 관련 서비스
├── widgets/           # 재사용 가능한 위젯
│   ├── task_list.dart        # 할 일 목록 위젯
│   ├── add_task_dialog.dart  # 할 일 추가 다이얼로그
│   └── edit_task_dialog.dart # 할 일 수정 다이얼로그
└── main.dart          # 앱 진입점
```

## 시작하기

1. Flutter 개발 환경 설정
   ```bash
   flutter pub get
   ```

2. 코드 생성 실행 (Drift 데이터베이스 관련)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. 앱 실행
   ```bash
   flutter run -d macos  # macOS에서 실행
   flutter run -d windows  # Windows에서 실행
   flutter run -d linux  # Linux에서 실행
   ```

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.
