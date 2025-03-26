import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/tables.dart';
import 'package:todotools/providers/sticky_note_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:todotools/widgets/add_sticky_note_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

// 스티커 메모 카드 위젯
class StickyNoteCard extends ConsumerWidget {
  final dynamic note;
  final VoidCallback onTap;

  const StickyNoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color noteColor = _getColorFromString(note.color);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: noteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 및 삭제 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _confirmDelete(context, ref),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 내용 (마크다운 지원)
              Expanded(
                child: Scrollbar(
                  thickness: 3.0,
                  radius: const Radius.circular(2.0),
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Markdown(
                      data: note.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 14),
                        h1: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                        h2: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                        h3: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                        code: TextStyle(
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        a: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      onTapLink: (text, href, title) {
                        _launchURL(href);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 날짜
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(note.updatedAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('정말 이 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(stickyNoteActionsProvider).deleteStickyNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  // 문자열 색상값을 Color 객체로 변환
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case StickyNoteColor.yellow:
        return Colors.amber.shade100;
      case StickyNoteColor.pink:
        return Colors.pink.shade100;
      case StickyNoteColor.blue:
        return Colors.blue.shade100;
      case StickyNoteColor.green:
        return Colors.green.shade100;
      case StickyNoteColor.purple:
        return Colors.purple.shade100;
      default:
        return Colors.amber.shade100; // 기본값 노란색
    }
  }

  // URL 실행 함수
  void _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // 링크를 열 수 없을 때는 조용히 실패
      }
    } catch (e) {
      // URL 파싱 오류도 조용히 처리
    }
  }
} 