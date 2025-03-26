import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todotools/database/database.dart';
import 'package:todotools/database/tables.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;

// 선택한 날짜 상태 프로바이더
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 특정 날짜에 대한 작업 목록을 가져오는 Provider
final dayTasksProvider = FutureProvider.autoDispose.family<List<Task>, DateTime>((ref, date) async {
  // taskProvider를 감시하여 작업이 변경될 때 자동으로 갱신
  final _ = ref.watch(taskProvider);
  
  final db = ref.read(databaseProvider);
  // 선택한 날짜의 시작과 끝 시간 계산 (하루 전체)
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
  
  // 시작 시간과 끝 시간 사이에 마감일이 있는 작업만 조회
  return (db.select(db.tasks)
    ..where((t) => t.dueDate.isBetweenValues(startOfDay, endOfDay)))
    .get();
});

// 날짜가 지정되지 않은 작업 목록을 가져오는 Provider
final undatedTasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  // taskProvider를 감시하여 작업이 변경될 때 자동으로 갱신
  final _ = ref.watch(taskProvider);

  final db = ref.read(databaseProvider);
  
  // dueDate가 null인 작업들만 가져오기
  return (db.select(db.tasks)
    ..where((t) => t.dueDate.isNull()))
    .get();
});

// 모든 할일을 날짜별로 그룹화하는 함수 - 달력에 표시할 이벤트 맵 생성
Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
  final Map<DateTime, List<Task>> taskMap = {};
  
  for (final task in tasks) {
    if (task.dueDate != null) {
      // 날짜 부분만 사용하여 시간 정보는 제외 (날짜별 그룹화를 위해)
      final date = DateTime(
        task.dueDate!.year, 
        task.dueDate!.month, 
        task.dueDate!.day
      );
      
      // 해당 날짜의 이벤트 리스트가 없으면 새로 생성
      if (taskMap[date] == null) {
        taskMap[date] = [];
      }
      
      // 해당 날짜에 할일 추가
      taskMap[date]!.add(task);
    }
  }
  
  return taskMap;
}

// 우선순위에 따른 마커 색상을 반환하는 함수
Color _getPriorityColor(String? priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red;
    case TaskPriority.medium:
      return Colors.orange;
    case TaskPriority.low:
      return Colors.blue;
    default:
      return Colors.green;
  }
}

// 달력 화면 위젯
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with AutomaticKeepAliveClientMixin {
  // 위젯을 유지하기 위한 상태
  @override
  bool get wantKeepAlive => true;
  
  // 이전 빌드 여부를 추적하는 플래그
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _isFirstBuild = false;
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 첫 빌드가 아닐 때만 데이터 새로고침
    if (!_isFirstBuild) {
      _refreshData();
    }
  }
  
  // 모든 데이터를 새로고침하는 헬퍼 메서드
  void _refreshData() {
    ref.refresh(taskProvider);
    ref.refresh(dayTasksProvider(ref.read(selectedDayProvider)));
    ref.refresh(undatedTasksProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 현재 선택된 날짜 
    final selectedDay = ref.watch(selectedDayProvider);
    
    // 모든 할일 가져오기 (달력에 이벤트 표시용)
    final allTasksAsync = ref.watch(taskProvider);
    
    // 선택한 날짜의 할일 가져오기 (선택한 날짜의 할일 목록 표시용)
    final selectedDayTasksAsync = ref.watch(dayTasksProvider(selectedDay));
    
    // 날짜가 없는 할일 가져오기 (오른쪽 패널에 표시)
    final undatedTasksAsync = ref.watch(undatedTasksProvider);
    
    return allTasksAsync.when(
      data: (allTasks) {
        // 이벤트 맵 생성 - 날짜별로 할일 그룹화
        final eventMap = _groupTasksByDate(allTasks);
        
        return Row(
          children: [
            // 왼쪽: 달력 및 선택한 날짜의 할일
            Expanded(
              flex: 3,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 화면 타이틀
                      Text(
                        '할 일 캘린더',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      // 사용 힌트
                      Text(
                        '수정 버튼을 눌러 할일을 편집할 수 있습니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 달력 위젯 (table_calendar 패키지 사용)
                      TableCalendar(
                        // 달력의 첫 날과 마지막 날 설정 (표시 범위)
                        firstDay: DateTime.utc(2021, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: selectedDay,
                        
                        // 현재 선택된 날짜 표시 설정
                        selectedDayPredicate: (day) {
                          return isSameDay(selectedDay, day);
                        },
                        
                        // 날짜 선택 시 동작
                        onDaySelected: (selected, focused) {
                          // 선택된 날짜 상태 업데이트
                          ref.read(selectedDayProvider.notifier).state = selected;
                        },
                        
                        // 날짜별 이벤트(할일) 로드 함수
                        eventLoader: (day) {
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          return eventMap[normalizedDay] ?? [];
                        },
                        
                        // 달력 스타일 설정
                        calendarStyle: const CalendarStyle(
                          // 날짜에 표시될 마커(이벤트 표시) 설정
                          markersMaxCount: 3,  // 최대 3개까지 표시
                          // 마커 장식 설정은 calendarBuilders에서 커스텀하여 처리
                        ),
                        
                        // 달력 빌더 커스터마이징
                        calendarBuilders: CalendarBuilders(
                          // 마커 빌더 커스터마이징 - 우선순위별 색상 표시
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;
                            
                            return Positioned(
                              bottom: 1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: events.take(3).map((event) {
                                  // event를 Task 타입으로 캐스팅
                                  final task = event as Task;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getPriorityColor(task.priority),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        
                        // 달력 헤더 스타일
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,  // 형식 변경 버튼 숨김
                          titleCentered: true,         // 제목 중앙 정렬
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 선택한 날짜의 일정 목록 제목
                      Text(
                        '${DateFormat('yyyy년 MM월 dd일').format(selectedDay)} 일정',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      
                      // 선택한 날짜의 할일 목록
                      Expanded(
                        child: selectedDayTasksAsync.when(
                          data: (tasks) {
                            if (tasks.isEmpty) {
                              return const Center(
                                child: Text('이 날짜에는 일정이 없습니다.'),
                              );
                            }
                            
                            return ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return TaskListItem(task: task);
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(child: Text('에러: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 오른쪽: 날짜 없는 할일 목록
            Expanded(
              flex: 2,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Text(
                        '날짜가 지정되지 않은 할일',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // 날짜없는 할일 목록
                      Expanded(
                        child: undatedTasksAsync.when(
                          data: (tasks) {
                            if (tasks.isEmpty) {
                              return const Center(
                                child: Text('날짜가 지정되지 않은 할일이 없습니다.'),
                              );
                            }
                            
                            return ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return TaskListItem(task: task);
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(child: Text('에러: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('에러: $e')),
    );
  }
}

// 할일 목록 아이템 위젯 - 개별 할일을 표시하고 관리하는 컴포넌트
class TaskListItem extends ConsumerWidget {
  final Task task;
  
  const TaskListItem({super.key, required this.task});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 할일 관련 동작을 위한 액션 객체
    final taskActions = ref.watch(taskActionsProvider);
    
    // 할일 수정 다이얼로그 표시 함수
    void _showEditTaskDialog() {
      // 제목 컨트롤러 초기화
      final titleController = TextEditingController(text: task.title);
      // 설명 컨트롤러 초기화
      final descriptionController = TextEditingController(text: task.description ?? '');
      
      // 날짜 선택 값 (현재 할일의 마감일로 초기화)
      DateTime? selectedDate = task.dueDate;
      // 우선순위 선택 값 (현재 할일의 우선순위로 초기화)
      String selectedPriority = task.priority ?? TaskPriority.none;
      
      // 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('할일 수정'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력 필드
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: '제목 (필수)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 설명 입력 필드
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: '설명 (선택)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // 날짜 선택 영역
                      Row(
                        children: [
                          const Text('마감일:'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                // 날짜 선택기 표시
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  selectedDate != null 
                                      ? DateFormat('yyyy-MM-dd').format(selectedDate!) 
                                      : '날짜 선택 (선택사항)',
                                ),
                              ),
                            ),
                          ),
                          
                          // 날짜 초기화 버튼
                          if (selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 우선순위 선택 영역
                      const Text('우선순위:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: TaskPriority.values.map((priority) {
                          return ChoiceChip(
                            label: Text(priority),
                            selected: selectedPriority == priority,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedPriority = priority;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // 취소 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('취소'),
                  ),
                  
                  // 삭제 버튼
                  TextButton(
                    onPressed: () async {
                      // 할일 삭제
                      await taskActions.deleteTask(task.id);
                      
                      // 전체 프로바이더 갱신하여 UI 업데이트
                      ref.refresh(taskProvider);
                      ref.refresh(dayTasksProvider(ref.read(selectedDayProvider)));
                      ref.refresh(undatedTasksProvider);
                      
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '삭제',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  
                  // 저장 버튼
                  TextButton(
                    onPressed: () async {
                      // 제목이 비어있으면 처리하지 않음
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('제목을 입력해주세요')),
                        );
                        return;
                      }
                      
                      // 할일 업데이트
                      await taskActions.updateTask(
                        TasksCompanion(
                          id: Value(task.id),
                          title: Value(titleController.text.trim()),
                          description: Value(descriptionController.text.trim().isEmpty 
                              ? null 
                              : descriptionController.text.trim()),
                          dueDate: Value(selectedDate),
                          isCompleted: Value(task.isCompleted),
                          isPinned: Value(task.isPinned),
                          priority: Value(selectedPriority == TaskPriority.none ? null : selectedPriority),
                        ),
                      );
                      
                      // 전체 프로바이더 갱신하여 UI 업데이트
                      ref.refresh(taskProvider);
                      ref.refresh(dayTasksProvider(ref.read(selectedDayProvider)));
                      ref.refresh(undatedTasksProvider);
                      
                      Navigator.pop(context);
                    },
                    child: const Text('저장'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
    
    // 길게 누르면 수정 다이얼로그를 표시하는 GestureDetector로 감싸기
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        // 할일 제목 (완료 상태에 따라 스타일 변경)
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted 
                ? Theme.of(context).disabledColor 
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        
        // 할일 설명 및 날짜 (있는 경우만 표시)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy-MM-dd').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        // 완료 체크박스
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) async {
            await taskActions.toggleTaskCompletion(task);
            // 전체 프로바이더 갱신하여 UI 업데이트
            ref.refresh(taskProvider);
            ref.refresh(dayTasksProvider(ref.read(selectedDayProvider)));
            ref.refresh(undatedTasksProvider);
          },
        ),
        
        // 우측 액션들 (우선순위 표시 및 수정 버튼)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 우선순위 표시 (있는 경우만)
            if (task.priority != null && task.priority!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority!,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            
            // 수정 버튼
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '수정',
              onPressed: _showEditTaskDialog,
            ),
          ],
        ),
      ),
    );
  }
} 