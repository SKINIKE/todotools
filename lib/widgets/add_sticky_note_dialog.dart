import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/tables.dart';
import 'package:todotools/providers/sticky_note_provider.dart';

// 스티커 메모 추가/수정 다이얼로그
class AddStickyNoteDialog extends ConsumerStatefulWidget {
  final dynamic note;
  
  const AddStickyNoteDialog({super.key, this.note});

  @override
  ConsumerState<AddStickyNoteDialog> createState() => _AddStickyNoteDialogState();
}

class _AddStickyNoteDialogState extends ConsumerState<AddStickyNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late String _selectedColor;
  final _formKey = GlobalKey<FormState>();
  bool _isMarkdownGuideVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    // 수정 모드인 경우 기존 데이터 로드
    if (widget.note != null) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
      _selectedColor = widget.note.color;
    } else {
      // 새 메모인 경우 기본값 설정
      _selectedColor = StickyNoteColor.defaultValue;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.note == null ? '새 메모 추가' : '메모 수정'),
          IconButton(
            icon: Icon(
              _isMarkdownGuideVisible 
                ? Icons.help : Icons.help_outline,
              size: 20,
            ),
            tooltip: '마크다운 도움말',
            onPressed: () {
              setState(() {
                _isMarkdownGuideVisible = !_isMarkdownGuideVisible;
              });
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 마크다운 가이드
              if (_isMarkdownGuideVisible)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('마크다운 사용법:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('# 제목 1\n## 제목 2\n### 제목 3'),
                      Text('**굵게** 또는 __굵게__'),
                      Text('*기울임* 또는 _기울임_'),
                      Text('- 목록 항목\n1. 숫자 목록'),
                      Text('`코드 인라인`'),
                      Text('```\n여러 줄 코드 블록\n```'),
                      Text('> 인용문'),
                      Text('[링크 텍스트](https://www.example.com)'),
                    ],
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목 입력 필드
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 내용 입력 필드
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '내용 (마크다운 지원)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '내용을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 색상 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('색상:'),
                        Row(
                          children: [
                            _buildColorOption(StickyNoteColor.yellow, Colors.amber.shade100),
                            _buildColorOption(StickyNoteColor.pink, Colors.pink.shade100),
                            _buildColorOption(StickyNoteColor.blue, Colors.blue.shade100),
                            _buildColorOption(StickyNoteColor.green, Colors.green.shade100),
                            _buildColorOption(StickyNoteColor.purple, Colors.purple.shade100),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveNote,
          child: Text(widget.note == null ? '추가' : '수정'),
        ),
      ],
    );
  }
  
  // 색상 선택 옵션 위젯
  Widget _buildColorOption(String colorName, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorName;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == colorName ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
  
  // 메모 저장
  void _saveNote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final actions = ref.read(stickyNoteActionsProvider);
    
    if (widget.note == null) {
      // 새 메모 추가
      actions.addStickyNote(
        _titleController.text,
        _contentController.text,
        _selectedColor,
      );
    } else {
      // 기존 메모 수정
      actions.updateStickyNote(
        widget.note.id,
        _titleController.text,
        _contentController.text,
        _selectedColor,
      );
    }
    
    Navigator.pop(context);
  }
} 