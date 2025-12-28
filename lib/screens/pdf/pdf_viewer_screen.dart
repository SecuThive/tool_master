import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart'; // pdfrx 패키지
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _filePath;

  // PDF 파일 선택 함수
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _filePath = result.files.single.path;
        });
      }
    } catch (e) {
      debugPrint("파일 선택 오류: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _pickPdfFile(); // 시작하자마자 파일 선택
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 다크 모드 배경
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickPdfFile,
          ),
        ],
      ),
      body: _filePath == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  const Text(
                    "PDF 파일을 선택해주세요.",
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickPdfFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text("파일 열기", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          // [수정] 복잡한 레이아웃 코드를 제거하고 기본값 사용
          : PdfViewer.file(
              _filePath!,
              // 기본 설정만으로도 훌륭하게 동작합니다.
              params: PdfViewerParams(
                backgroundColor: const Color(0xFF1E1E1E), // 뷰어 배경색
                onViewerReady: (document, controller) {
                  // 파일이 열리면 하단에 페이지 수 안내
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("총 ${document.pages.length} 페이지 로드됨"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                errorBannerBuilder: (context, error, stackTrace, documentRef) {
                  return Center(
                    child: Text(
                      "PDF를 불러올 수 없습니다.\n$error",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                },
              ),
            ),
    );
  }
}