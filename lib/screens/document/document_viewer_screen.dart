import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart'; // 이미 설치된 패키지 활용
import 'dart:io';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  String? _filePath;
  String? _fileName;
  String? _fileSize;

  // 지원하는 확장자 목록
  final List<String> _allowedExtensions = [
    'hwp', 'hwpx', // 한글
    'doc', 'docx', // 워드
    'xls', 'xlsx', // 엑셀
    'ppt', 'pptx', // 파워포인트
    'txt'          // 텍스트
  ];

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();
        
        setState(() {
          _filePath = result.files.single.path;
          _fileName = result.files.single.name;
          _fileSize = (sizeInBytes / 1024).toStringAsFixed(2) + " KB";
        });
      }
    } catch (e) {
      debugPrint("파일 선택 오류: $e");
    }
  }

  // 외부 앱으로 파일 열기 (핵심 기능)
  Future<void> _openFileExternal() async {
    if (_filePath == null) return;

    final result = await OpenFile.open(_filePath!);

    if (result.type != ResultType.done) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "파일을 열 수 없습니다.\n해당 파일을 볼 수 있는 앱(한컴, Office 등)이 설치되어 있는지 확인해주세요.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // 아이콘 가져오기 도우미
  IconData _getFileIcon(String extension) {
    if (extension.contains('hwp')) return Icons.description; // 한글 느낌
    if (extension.contains('doc')) return Icons.article; // 워드
    if (extension.contains('xls')) return Icons.table_chart; // 엑셀
    if (extension.contains('ppt')) return Icons.slideshow; // PPT
    return Icons.insert_drive_file;
  }

  // 확장자에 따른 색상
  Color _getFileColor(String extension) {
    if (extension.contains('hwp')) return Colors.blue;
    if (extension.contains('doc')) return Colors.blueAccent;
    if (extension.contains('xls')) return Colors.green;
    if (extension.contains('ppt')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final extension = _fileName?.split('.').last.toLowerCase() ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Office & HWP Viewer"),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 파일이 없을 때
              if (_filePath == null) ...[
                const Icon(Icons.folder_copy_outlined, size: 80, color: Colors.white24),
                const SizedBox(height: 20),
                const Text(
                  "문서 파일을 선택해주세요.",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "지원 형식: HWP, Word, Excel, PPT",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text("문서 찾아보기", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ]
              // 2. 파일이 선택되었을 때
              else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getFileIcon(extension),
                        size: 60,
                        color: _getFileColor(extension),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _fileName ?? "Unknown",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fileSize ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // 파일 열기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _openFileExternal,
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: const Text(
                      "뷰어로 열기", 
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getFileColor(extension),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _pickDocument,
                  child: const Text("다른 파일 선택", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}