import 'package:drift/drift.dart';

// 중요도 상수 정의
class TaskPriority {
  static const String high = '높음';
  static const String medium = '중간';
  static const String low = '낮음';
  static const String none = '선택안함';
  
  // 모든 중요도 값 목록
  static const List<String> values = [high, medium, low, none];
  
  // 기본 중요도
  static const String defaultValue = none;
}

// 메모 색상 상수 정의
class StickyNoteColor {
  static const String yellow = 'yellow';
  static const String pink = 'pink';
  static const String blue = 'blue';
  static const String green = 'green';
  static const String purple = 'purple';
  
  // 모든 색상 값 목록
  static const List<String> values = [yellow, pink, blue, green, purple];
  
  // 기본 색상
  static const String defaultValue = yellow;
}

// 할 일 테이블 정의
class Tasks extends Table {
  // 기본 키 (자동 증가)
  IntColumn get id => integer().autoIncrement()();
  
  // 제목 (필수)
  TextColumn get title => text().withLength(min: 1, max: 255)();
  
  // 설명 (선택)
  TextColumn get description => text().nullable()();
  
  // 생성 일시
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 마감 일시 (선택)
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  // 완료 여부
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  
  // 고정 여부
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  
  // 카테고리 (사용하지 않지만 호환성을 위해 유지)
  TextColumn get category => text().nullable()();
  
  // 우선순위 (높음, 중간, 낮음, 선택안함)
  TextColumn get priority => text().nullable()();
  
  // 인덱스 설정
  @override
  List<String> get customConstraints => [
    'UNIQUE (id)'
  ];
  
  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {id},
  ];
  
  @override
  List<Set<Column<Object>>>? get indexes => [
    {title},
    {createdAt},
    {isCompleted},
    {isPinned},
  ];
}

// 스티커 메모 테이블 정의
class StickyNotes extends Table {
  // 기본 키 (자동 증가)
  IntColumn get id => integer().autoIncrement()();
  
  // 제목 (필수)
  TextColumn get title => text().withLength(min: 1, max: 100)();
  
  // 내용 (필수)
  TextColumn get content => text()();
  
  // 색상 (yellow, pink, blue, green, purple)
  TextColumn get color => text().withDefault(const Constant(StickyNoteColor.defaultValue))();
  
  // 생성 일시
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 마지막 수정 일시
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 인덱스 설정
  @override
  List<String> get customConstraints => [
    'UNIQUE (id)'
  ];
  
  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {id},
  ];
  
  @override
  List<Set<Column<Object>>>? get indexes => [
    {title},
    {createdAt},
    {updatedAt},
  ];
}

// 뽀모도로 설정 테이블 정의
class PomodoroSettings extends Table {
  // 기본 키 (자동 증가)
  IntColumn get id => integer().autoIncrement()();
  
  // 집중 시간 (분)
  IntColumn get focusMinutes => integer().withDefault(const Constant(25))();
  
  // 휴식 시간 (분)
  IntColumn get restMinutes => integer().withDefault(const Constant(5))();
  
  // 긴 휴식 시간 (분)
  IntColumn get longRestMinutes => integer().withDefault(const Constant(15))();
  
  // 긴 휴식 간격 (몇 번의 집중 후 긴 휴식으로 전환되는지)
  IntColumn get longRestInterval => integer().withDefault(const Constant(4))();
  
  // 자동 시작 여부 (한 세션이 끝나면 다음 세션 자동 시작)
  BoolColumn get autoStartNextSession => boolean().withDefault(const Constant(false))();
  
  // 알림 사운드 재생 여부
  BoolColumn get playSound => boolean().withDefault(const Constant(true))();
  
  // 테마 색상 (16진수 색상 코드)
  TextColumn get focusColorHex => text().withDefault(const Constant('FFC8C8'))();
  TextColumn get restColorHex => text().withDefault(const Constant('D1EAC8'))();
  
  // 생성 시간
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 마지막 수정 시간
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 인덱스 설정
  @override
  List<String> get customConstraints => [
    'UNIQUE (id)'
  ];
  
  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {id},
  ];
}

// 계산기 히스토리 테이블 정의
class CalculatorHistory extends Table {
  // 기본 키 (자동 증가)
  IntColumn get id => integer().autoIncrement()();
  
  // 계산 수식
  TextColumn get expression => text()();
  
  // 계산 결과
  TextColumn get result => text()();
  
  // 생성 일시
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  
  // 인덱스 설정
  @override
  List<String> get customConstraints => [
    'UNIQUE (id)'
  ];
  
  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {id},
  ];
  
  @override
  List<Set<Column<Object>>>? get indexes => [
    {createdAt},
  ];
} 