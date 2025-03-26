import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:todotools/database/database.dart';

// 스티커 메모 검색어를 위한 프로바이더
final stickyNoteSearchProvider = StateProvider<String>((ref) => '');

// 데이터베이스 액세스를 위한 프로바이더
final stickyNoteDbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// 모든 스티커 메모를 가져오는 프로바이더
final stickyNotesProvider = FutureProvider<List<StickyNote>>((ref) async {
  final db = ref.watch(stickyNoteDbProvider);
  final searchQuery = ref.watch(stickyNoteSearchProvider);
  
  if (searchQuery.isEmpty) {
    return db.getAllStickyNotes();
  } else {
    return db.searchStickyNotes(searchQuery);
  }
});

// 스티커 메모 액션을 위한 프로바이더
final stickyNoteActionsProvider = Provider<StickyNoteActions>((ref) {
  return StickyNoteActions(ref);
});

// 스티커 메모 액션 클래스
class StickyNoteActions {
  final ProviderRef ref;
  
  StickyNoteActions(this.ref);
  
  // 스티커 메모 추가
  Future<int> addStickyNote(String title, String content, String color) async {
    final db = ref.read(stickyNoteDbProvider);
    
    final note = StickyNotesCompanion(
      title: Value(title),
      content: Value(content),
      color: Value(color),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    
    final id = await db.saveStickyNote(note);
    
    // 프로바이더 새로고침
    ref.refresh(stickyNotesProvider);
    
    return id;
  }
  
  // 스티커 메모 업데이트
  Future<int> updateStickyNote(int id, String title, String content, String color) async {
    final db = ref.read(stickyNoteDbProvider);
    
    final note = StickyNotesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      color: Value(color),
      updatedAt: Value(DateTime.now()),
    );
    
    final result = await db.saveStickyNote(note);
    
    // 프로바이더 새로고침
    ref.refresh(stickyNotesProvider);
    
    return result;
  }
  
  // 스티커 메모 삭제
  Future<int> deleteStickyNote(int id) async {
    final db = ref.read(stickyNoteDbProvider);
    final result = await db.deleteStickyNote(id);
    
    // 프로바이더 새로고침
    ref.refresh(stickyNotesProvider);
    
    return result;
  }
  
  // 검색어 설정
  void setSearchQuery(String query) {
    ref.read(stickyNoteSearchProvider.notifier).state = query;
  }
} 