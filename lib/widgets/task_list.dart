import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/database.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:todotools/widgets/edit_task_dialog.dart';

// 할 일 목록을 보여주는 위젯
class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 프로바이더에서 필요한 데이터 가져오기
    final tasksAsync = ref.watch(taskProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final showTodayOnly = ref.watch(showTodayOnlyProvider);
    final showPinned = ref.watch(showPinnedOnlyProvider);

    // FutureProvider 결과 처리
    return tasksAsync.when(
      data: (tasks) => _buildTaskList(context, ref, tasks, searchQuery, showTodayOnly, showPinned),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // 오류 발생 시 사용자 친화적인 메시지 표시
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 할 일 목록 또는 빈 상태 UI 생성
  Widget _buildTaskList(
    BuildContext context, 
    WidgetRef ref, 
    List<Task> tasks, 
    String searchQuery, 
    bool showTodayOnly, 
    bool showPinned
  ) {
    // 할 일이 없을 때 표시할 메시지
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off
                  : showTodayOnly
                      ? Icons.calendar_today
                      : showPinned
                          ? Icons.push_pin_outlined
                          : Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? '검색 결과가 없습니다'
                  : showTodayOnly
                      ? '오늘 할 일이 없습니다'
                      : showPinned
                          ? '고정된 할 일이 없습니다'
                          : '할 일이 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 할 일을 추가해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // 할 일 목록 표시
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                final actions = ref.read(taskActionsProvider);
                actions.toggleTaskCompletion(task);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty) ...[
                  Text(
                    task.description!,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    // 고정 토글 버튼
                    IconButton(
                      icon: Icon(
                        task.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: task.isPinned ? Colors.blue.shade700 : null,
                      ),
                      onPressed: () {
                        final actions = ref.read(taskActionsProvider);
                        actions.toggleTaskPinned(task);
                      },
                      tooltip: '고정됨',
                    ),
                    // 중요도 표시
                    if (task.priority != null && task.priority != '선택안함')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.priority!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // 수정 버튼
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditTaskDialog(task: task),
                        );
                      },
                      tooltip: '수정',
                    ),
                    // 삭제 버튼
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('할 일 삭제'),
                            content: const Text('이 할 일을 삭제하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final actions = ref.read(taskActionsProvider);
                                  actions.deleteTask(task.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: '삭제',
                    ),
                    const Spacer(),
                    // 마감일 표시
                    if (task.dueDate != null)
                      Text(
                        '마감일: ${task.dueDate!.year}년 ${task.dueDate!.month}월 ${task.dueDate!.day}일',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 중요도에 따른 배경색 반환
  Color _getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;
    
    switch (priority) {
      case '높음':
        return Color(0xFFFF8080); // 파스텔 빨강
      case '중간':
        return Color(0xFFFFB366); // 파스텔 주황
      case '낮음':
        return Color(0xFF66B3FF); // 파스텔 파랑
      default:
        return Colors.grey;
    }
  }
} 