import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/database.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:todotools/database/tables.dart';

// 기존 할 일을 수정하는 다이얼로그
class EditTaskDialog extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskDialog({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  // 입력 필드 컨트롤러
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  // 상태 변수
  late DateTime? _dueDate;
  late bool _isPinned;
  late String _priority;

  @override
  void initState() {
    super.initState();
    // 기존 할 일 데이터로 초기화
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _isPinned = widget.task.isPinned;
    _priority = widget.task.priority ?? TaskPriority.defaultValue;
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('할 일 수정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '할 일의 제목을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            // 설명 입력 필드
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '할 일에 대한 설명을 입력하세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // 마감일 선택 필드
            ListTile(
              title: const Text('마감일'),
              subtitle: Text(
                _dueDate != null
                    ? '${_dueDate!.year}년 ${_dueDate!.month}월 ${_dueDate!.day}일'
                    : '선택하지 않음',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // 현재 날짜 가져오기
                final now = DateTime.now();
                // dueDate가 과거 날짜인 경우 현재 날짜로 설정
                final initialDate = _dueDate != null && _dueDate!.isAfter(now) 
                    ? _dueDate! 
                    : now;
                    
                final date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: now,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            // 중요도 선택 드롭다운
            ListTile(
              title: const Text('중요도'),
              trailing: DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
                items: TaskPriority.values.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // 고정된 할 일 체크박스
            CheckboxListTile(
              title: const Text('고정됨'),
              value: _isPinned,
              onChanged: (value) {
                setState(() {
                  _isPinned = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        // 저장 버튼
        FilledButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              // Task를 TasksCompanion으로 변환
              final companionData = TasksCompanion(
                id: Value(widget.task.id),
                title: Value(_titleController.text),
                description: Value(_descriptionController.text.isEmpty ? null : _descriptionController.text),
                dueDate: Value(_dueDate),
                isCompleted: Value(widget.task.isCompleted),
                isPinned: Value(_isPinned),
                createdAt: Value(widget.task.createdAt),
                category: Value(widget.task.category),
                priority: Value(_priority),
              );
              
              // 데이터베이스에 저장
              final actions = ref.read(taskActionsProvider);
              actions.updateTask(companionData);
              Navigator.of(context).pop();
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
} 