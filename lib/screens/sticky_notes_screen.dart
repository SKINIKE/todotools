import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/tables.dart';
import 'package:todotools/providers/sticky_note_provider.dart';
import 'package:todotools/widgets/sticky_note_card.dart';
import 'package:todotools/widgets/add_sticky_note_dialog.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 스티커 메모 화면
class StickyNotesScreen extends ConsumerStatefulWidget {
  const StickyNotesScreen({super.key});

  @override
  ConsumerState<StickyNotesScreen> createState() => _StickyNotesScreenState();
}

class _StickyNotesScreenState extends ConsumerState<StickyNotesScreen> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _notes = [];
  final GlobalKey _gridViewKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }
  
  // 앱 최초 실행 확인 및 샘플 메모 추가
  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAddedSampleNotes = prefs.getBool('has_added_sample_sticky_notes') ?? false;
    
    if (!hasAddedSampleNotes) {
      // 샘플 메모 추가
      await _addSampleNotes();
      // 완료 표시
      await prefs.setBool('has_added_sample_sticky_notes', true);
    }
  }
  
  // 샘플 스티커 메모 추가
  Future<void> _addSampleNotes() async {
    final actions = ref.read(stickyNoteActionsProvider);
    
    // 마크다운 샘플 메모 추가
    await actions.addStickyNote(
      '마크다운 사용법',
      '''
# 마크다운으로 서식 적용하기

스티커 메모에서 **마크다운**을 사용하여 텍스트 서식을 적용할 수 있습니다.

## 기본 서식
- **굵게**: `**텍스트**` 또는 `__텍스트__`
- *기울임*: `*텍스트*` 또는 `_텍스트_`
- ~~취소선~~: `~~텍스트~~`

## 목록
1. 첫 번째 항목
2. 두 번째 항목
   - 중첩 목록
   - 또 다른 항목

## 코드
인라인 코드: `var x = 10;`

```dart
void main() {
  print('안녕하세요!');
}
```

## 인용문
> 인용문은 이렇게 표시됩니다.
> 여러 줄로 작성할 수 있습니다.

## 링크
[Flutter 웹사이트](https://flutter.dev)
''',
      StickyNoteColor.blue,
    );
    
    // 할 일 목록 샘플 메모
    await actions.addStickyNote(
      '이번 주 할 일',
      '''
# 이번 주 할 일

- [ ] 프로젝트 계획 수립
- [ ] 디자인 완성하기
- [x] 회의 준비
- [ ] 보고서 작성

## 우선순위
1. **높음**: 보고서 작성
2. **중간**: 디자인 완성
3. **낮음**: 계획 수립
''',
      StickyNoteColor.yellow,
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // 스티커 메모 데이터 가져오기
    final notesAsyncValue = ref.watch(stickyNotesProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // 상단 헤더
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  '스티커 메모',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // 검색 필드
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '메모 검색',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    onChanged: (value) {
                      ref.read(stickyNoteActionsProvider).setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // 추가 버튼
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('새 메모'),
                  onPressed: () {
                    _showAddNoteDialog();
                  },
                ),
              ],
            ),
          ),
          
          // 메모 목록
          Expanded(
            child: notesAsyncValue.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text(
                      '메모가 없습니다. 새 메모를 추가하세요.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                
                _notes = List.from(notes);
                
                // 메모 그리드 표시
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDraggableGridView(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      '스티커 메모를 불러오는데 문제가 발생했습니다',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '에러 내용: $error',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '에러 위치: $stack',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(stickyNotesProvider);
                      },
                      child: const Text('다시 시도'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 드래그 가능한 그리드 뷰 생성
  Widget _buildDraggableGridView() {
    return ReorderableBuilder(
      scrollController: _scrollController,
      enableDraggable: true,
      enableLongPress: true,
      enableScrollingWhileDragging: true,
      dragChildBoxDecoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: children,
        );
      },
      children: List.generate(
        _notes.length,
        (index) => StickyNoteCard(
          key: ValueKey(_notes[index].id),
          note: _notes[index],
          onTap: () => _showEditNoteDialog(_notes[index]),
        ),
      ),
      onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
        for (final entity in orderUpdateEntities) {
          final fromIndex = entity.oldIndex;
          final toIndex = entity.newIndex;
          
          if (fromIndex == toIndex) continue;
          
          // 항목 순서 업데이트
          final item = _notes.removeAt(fromIndex);
          _notes.insert(toIndex, item);
        }
        
        setState(() {});
      },
    );
  }
  
  // 메모 추가 다이얼로그 표시
  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddStickyNoteDialog(),
    );
  }
  
  // 메모 수정 다이얼로그 표시
  void _showEditNoteDialog(dynamic note) {
    showDialog(
      context: context,
      builder: (context) => AddStickyNoteDialog(note: note),
    );
  }
} 