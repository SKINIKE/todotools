import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/database.dart';
import 'package:drift/drift.dart' show Value;

// 데이터베이스 프로바이더
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.instance;
  ref.onDispose(() {
    // 앱이 종료될 때만 데이터베이스를 닫기 위해 onDispose 로직 제거
    // 싱글톤 인스턴스는 앱 전체에서 공유됨
  });
  return db;
});

// 검색어 프로바이더
final searchQueryProvider = StateProvider<String>((ref) => '');

// 오늘만 표시 프로바이더
final showTodayOnlyProvider = StateProvider<bool>((ref) => false);

// 고정된 항목만 표시 프로바이더 (기존 중요 항목 대체)
final showPinnedOnlyProvider = StateProvider<bool>((ref) => false);

// 작업 목록 프로바이더
final taskProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(databaseProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final showTodayOnly = ref.watch(showTodayOnlyProvider);
  final showPinned = ref.watch(showPinnedOnlyProvider);
  
  // 필터링된 작업 목록 반환
  return db.getFilteredTasks(
    searchQuery: searchQuery.isEmpty ? null : searchQuery,
    todayOnly: showTodayOnly,
    pinnedOnly: showPinned,
  );
});

// 작업 관리 클래스
class TaskActions {
  final AppDatabase _db;
  final Ref _ref;
  
  TaskActions(this._db, this._ref);
  
  // 작업 추가
  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    bool isCompleted = false,
    bool isPinned = false,
    String? priority,
  }) async {
    await _db.saveTask(TasksCompanion.insert(
      title: title,
      description: description == null ? const Value.absent() : Value(description),
      dueDate: dueDate == null ? const Value.absent() : Value(dueDate),
      isCompleted: Value(isCompleted),
      isPinned: Value(isPinned),
      createdAt: Value(DateTime.now()),
      priority: priority == null ? const Value.absent() : Value(priority),
    ));
    
    // 프로바이더 갱신
    _ref.refresh(taskProvider);
  }
  
  // 작업 업데이트
  Future<void> updateTask(TasksCompanion task) async {
    await _db.saveTask(task);
    
    // 프로바이더 갱신
    _ref.refresh(taskProvider);
  }
  
  // 작업 삭제
  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    
    // 프로바이더 갱신
    _ref.refresh(taskProvider);
  }
  
  // 작업 완료 여부 토글
  Future<void> toggleTaskCompletion(Task task) async {
    await _db.toggleTaskCompletion(task);
    
    // 프로바이더 갱신
    _ref.refresh(taskProvider);
  }
  
  // 작업 고정 여부 토글
  Future<void> toggleTaskPinned(Task task) async {
    await _db.toggleTaskPinned(task);
    
    // 프로바이더 갱신
    _ref.refresh(taskProvider);
  }
}

// 작업 액션 프로바이더
final taskActionsProvider = Provider<TaskActions>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskActions(db, ref);
}); 