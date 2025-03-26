import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todotools/database/tables.dart';
import 'dart:developer' as developer;

part 'database.g.dart';

/// 앱에서 사용할 데이터베이스 클래스
/// 할일, 뽀모도로 설정, 계산기 히스토리, 스티커 메모를 관리합니다.
@DriftDatabase(tables: [Tasks, PomodoroSettings, CalculatorHistory, StickyNotes])
class AppDatabase extends _$AppDatabase {
  // 싱글톤 인스턴스
  static AppDatabase? _instance;
  
  // 싱글톤 인스턴스 가져오기
  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }
  
  // 내부 생성자
  AppDatabase._internal() : super(_openConnection());
  
  // 외부에서 접근 가능한 팩토리 생성자 (기존 코드와의 호환성 유지)
  factory AppDatabase() => instance;

  /// 데이터베이스 버전 (마이그레이션에 사용)
  @override
  int get schemaVersion => 4;

  /// 마이그레이션 전략
  /// 데이터베이스 생성 및 업그레이드 로직을 정의합니다.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 스키마 업그레이드를 위한 마이그레이션 로직
        if (from == 1) {
          // 1 -> 2 마이그레이션: isImportant(중요)에서 isPinned(고정됨)으로 변경
          
          // 트랜잭션으로 마이그레이션 처리
          await transaction(() async {
            try {
              // 기존 테이블 백업 및 초기화
              await customStatement('''
                DROP TABLE IF EXISTS tasks_temp;
                DROP TABLE IF EXISTS tasks_backup;
              ''');
              
              // 현재 스키마 확인
              final result = await customSelect('PRAGMA table_info(tasks)').get();
              final columnNames = result.map((row) => row.data['name'] as String).toList();
              
              // 스키마 유형에 따른 마이그레이션 처리
              if (columnNames.contains('is_important')) {
                // 이전 스키마: is_important -> is_pinned 마이그레이션
                
                // 임시 테이블 생성 및 데이터 복사
                await customStatement('''
                  -- 임시 테이블 생성
                  CREATE TABLE tasks_temp (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    due_date DATETIME,
                    is_completed INTEGER NOT NULL DEFAULT 0,
                    is_pinned INTEGER NOT NULL DEFAULT 0,
                    category TEXT,
                    priority TEXT
                  );
                  
                  -- 데이터 복사 (is_important -> is_pinned)
                  INSERT INTO tasks_temp(id, title, description, created_at, due_date, is_completed, is_pinned, category, priority)
                  SELECT id, title, description, created_at, due_date, is_completed, is_important, category, priority FROM tasks;
                  
                  -- 테이블 교체
                  DROP TABLE tasks;
                  ALTER TABLE tasks_temp RENAME TO tasks;
                ''');
              } else {
                // 이미 최신 스키마이거나 기존 스키마가 손상된 경우
                
                // 데이터 백업 시도
                try {
                  await customStatement('CREATE TABLE tasks_backup AS SELECT * FROM tasks;');
                } catch (e) {
                  // 백업 실패 시 무시하고 계속 진행
                }
                
                // 새 테이블 구조 생성
                await customStatement('''
                  DROP TABLE IF EXISTS tasks;
                  CREATE TABLE tasks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    due_date DATETIME,
                    is_completed INTEGER NOT NULL DEFAULT 0,
                    is_pinned INTEGER NOT NULL DEFAULT 0,
                    category TEXT,
                    priority TEXT
                  );
                ''');
                
                // 데이터 복원 시도
                if (columnNames.isNotEmpty) {
                  try {
                    // 존재하는 컬럼만 복원
                    final columnsToCopy = [
                      'id', 'title', 'description', 'created_at', 'due_date', 
                      'is_completed', 'category', 'priority'
                    ].where((col) => columnNames.contains(col)).join(', ');
                    
                    if (columnsToCopy.isNotEmpty) {
                      await customStatement(
                        'INSERT INTO tasks(${columnsToCopy}) SELECT ${columnsToCopy} FROM tasks_backup;'
                      );
                    }
                  } catch (e) {
                    // 복원 실패 시 무시하고 계속 진행
                  }
                }
              }
              
              // 인덱스 생성 (공통)
              await customStatement('''
                CREATE INDEX IF NOT EXISTS tasks_title ON tasks (title);
                CREATE INDEX IF NOT EXISTS tasks_created_at ON tasks (created_at);
                CREATE INDEX IF NOT EXISTS tasks_is_completed ON tasks (is_completed);
                CREATE INDEX IF NOT EXISTS tasks_is_pinned ON tasks (is_pinned);
              ''');
            } catch (e) {
              // 마이그레이션 오류 시 무시하고 계속 진행
            }
          });
        }
        
        if (from <= 2) {
          // 2 -> 3 마이그레이션: CalculatorHistory 테이블 추가
          try {
            await m.createTable(calculatorHistory);
          } catch (e) {
            // 테이블 생성 실패 시 무시하고 계속 진행
          }
        }
        
        if (from <= 3) {
          // 3 -> 4 마이그레이션: StickyNotes 테이블 추가
          try {
            await m.createTable(stickyNotes);
          } catch (e) {
            // 테이블 생성 실패 시 무시하고 계속 진행
          }
        }
      },
      beforeOpen: (details) async {
        // 데이터베이스 오픈 전 검증 로직
        await customStatement('PRAGMA foreign_keys = ON');
        
        // 첫 실행 시 기본 뽀모도로 설정 생성
        if (details.wasCreated) {
          // 기본 뽀모도로 설정 생성
          await into(pomodoroSettings).insert(PomodoroSettingsCompanion.insert(
            focusMinutes: const Value(25),
            restMinutes: const Value(5),
            longRestMinutes: const Value(15),
            longRestInterval: const Value(4),
            autoStartNextSession: const Value(false),
            playSound: const Value(true),
            focusColorHex: const Value('FFC8C8'),
            restColorHex: const Value('D1EAC8'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ));
        }
      },
    );
  }

  // 작업(Task) 관련 메서드들
  // 모든 작업 가져오기
  Future<List<Task>> getAllTasks() => select(tasks).get();
  
  // 특정 조건으로 필터링된 작업 가져오기 (검색어, 오늘만, 고정만)
  Future<List<Task>> getFilteredTasks({
    String? searchQuery,
    bool? todayOnly,
    bool? pinnedOnly,
  }) {
    return (select(tasks)
      ..where((t) {
        Expression<bool> expression = const Constant(true);
        
        // 검색어 필터링
        if (searchQuery != null && searchQuery.isNotEmpty) {
          expression = expression & (t.title.like('%$searchQuery%') | t.description.like('%$searchQuery%'));
        }
        
        // 오늘 할 일만 필터링
        if (todayOnly == true) {
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
          
          expression = expression & t.dueDate.isBetweenValues(startOfDay, endOfDay);
        }
        
        // 고정된 할 일만 필터링
        if (pinnedOnly == true) {
          expression = expression & t.isPinned.equals(true);
        }
        
        return expression;
      })).get();
  }
  
  // 작업 저장 (새로 추가하거나 업데이트)
  Future<int> saveTask(TasksCompanion task) => into(tasks).insert(
    task,
    mode: InsertMode.insertOrReplace,
  );
  
  // 작업 삭제
  Future<int> deleteTask(int id) => 
    (delete(tasks)..where((t) => t.id.equals(id))).go();
  
  // 작업 완료 여부 토글
  Future<void> toggleTaskCompletion(Task task) async {
    await update(tasks).replace(
      task.copyWith(isCompleted: !task.isCompleted),
    );
  }
  
  // 작업 고정 여부 토글
  Future<void> toggleTaskPinned(Task task) async {
    await update(tasks).replace(
      task.copyWith(isPinned: !task.isPinned),
    );
  }
  
  // 뽀모도로 설정 관련 메서드들
  // 현재 설정 가져오기
  Future<PomodoroSetting?> getPomodoroSettings() => 
    (select(pomodoroSettings)..limit(1)).getSingleOrNull();
  
  // 설정 업데이트
  Future<bool> updatePomodoroSettings(PomodoroSettingsCompanion settings) async {
    // 첫 번째 설정 항목 ID 가져오기
    final firstSettings = await getPomodoroSettings();
    if (firstSettings == null) {
      // 설정이 없으면 새로 생성
      await into(pomodoroSettings).insert(settings);
    } else {
      // 있으면 ID 유지하며 업데이트
      await update(pomodoroSettings).replace(
        settings.copyWith(id: Value(firstSettings.id)),
      );
    }
    return true;
  }
  
  // 설정 초기화
  Future<void> resetPomodoroSettings() async {
    final firstSettings = await getPomodoroSettings();
    if (firstSettings != null) {
      await updatePomodoroSettings(PomodoroSettingsCompanion(
        id: Value(firstSettings.id),
        focusMinutes: const Value(25),
        restMinutes: const Value(5),
        longRestMinutes: const Value(15),
        longRestInterval: const Value(4),
        autoStartNextSession: const Value(false),
        playSound: const Value(true),
        focusColorHex: const Value('FFC8C8'),
        restColorHex: const Value('D1EAC8'),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }
  
  // 계산기 히스토리 관련 메소드들
  // 특정 계산기 히스토리 삭제
  Future<int> deleteCalculatorHistory(int id) =>
    (delete(calculatorHistory)..where((h) => h.id.equals(id))).go();
    
  // 모든 계산기 히스토리 초기화
  Future<int> clearAllCalculatorHistory() =>
    delete(calculatorHistory).go();
  
  // 스티커 메모 관련 메서드들
  // 모든 스티커 메모 가져오기
  Future<List<StickyNote>> getAllStickyNotes() async {
    try {
      developer.log('모든 스티커 메모 가져오기 시도', name: 'database');
      final result = await (select(stickyNotes)
        ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
      developer.log('스티커 메모 로드 성공: ${result.length}개', name: 'database');
      return result;
    } catch (e, stack) {
      developer.log('스티커 메모 로드 오류: $e', name: 'database', error: e, stackTrace: stack);
      rethrow;
    }
  }
  
  // 스티커 메모 검색
  Future<List<StickyNote>> searchStickyNotes(String query) async {
    try {
      developer.log('스티커 메모 검색 시도: $query', name: 'database');
      
      if (query.isEmpty) {
        return getAllStickyNotes();
      }
      
      final result = await (select(stickyNotes)
        ..where((note) => note.title.like('%$query%') | note.content.like('%$query%'))
        ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
      ).get();
      
      developer.log('스티커 메모 검색 성공: ${result.length}개 결과', name: 'database');
      return result;
    } catch (e, stack) {
      developer.log('스티커 메모 검색 오류: $e', name: 'database', error: e, stackTrace: stack);
      rethrow;
    }
  }
  
  // 스티커 메모 저장 (새로 추가하거나 업데이트)
  Future<int> saveStickyNote(StickyNotesCompanion note) async {
    try {
      developer.log('스티커 메모 저장 시도', name: 'database');
      final result = await into(stickyNotes).insert(
        note,
        mode: InsertMode.insertOrReplace,
      );
      developer.log('스티커 메모 저장 성공: ID=$result', name: 'database');
      return result;
    } catch (e, stack) {
      developer.log('스티커 메모 저장 오류: $e', name: 'database', error: e, stackTrace: stack);
      rethrow;
    }
  }
  
  // 스티커 메모 삭제
  Future<int> deleteStickyNote(int id) async {
    try {
      developer.log('스티커 메모 삭제 시도: ID=$id', name: 'database');
      final result = await (delete(stickyNotes)..where((t) => t.id.equals(id))).go();
      developer.log('스티커 메모 삭제 성공: $result개 항목 삭제됨', name: 'database');
      return result;
    } catch (e, stack) {
      developer.log('스티커 메모 삭제 오류: $e', name: 'database', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

// 데이터베이스 연결 설정
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      // 앱 문서 디렉토리 가져오기
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'todotools.db'));
      
      developer.log('데이터베이스 연결 시도: ${file.path}', name: 'database');
      
      // 경로 디렉토리가 존재하는지 확인하고 없으면 생성
      if (!await Directory(dbFolder.path).exists()) {
        await Directory(dbFolder.path).create(recursive: true);
        developer.log('데이터베이스 디렉토리 생성: ${dbFolder.path}', name: 'database');
      }
      
      // 데이터베이스 연결 반환
      final db = NativeDatabase(file);
      developer.log('데이터베이스 연결 성공', name: 'database');
      return db;
    } catch (e, stack) {
      developer.log('데이터베이스 연결 오류: $e', name: 'database', error: e, stackTrace: stack);
      rethrow;
    }
  });
} 