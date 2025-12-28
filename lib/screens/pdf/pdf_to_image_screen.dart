import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart'; // PDF 렌더링
import 'package:gal/gal.dart'; // 갤러리 저장
import 'dart:io';
import 'dart:ui' as ui; // [중요] 이미지를 PNG로 변환하기 위해 추가
import 'package:path_provider/path_provider.dart';

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  String? _pdfPath;
  PdfDocument? _doc;
  bool _isConverting = false;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _pdfPath = result.files.single.path;
      if (_pdfPath != null) {
        final doc = await PdfDocument.openFile(_pdfPath!);
        setState(() {
          _doc = doc;
        });
      }
    }
  }

  // 특정 페이지를 이미지로 저장 (수정된 로직)
  Future<void> _savePageAsImage(int pageIndex) async {
    if (_doc == null) return;
    try {
      setState(() => _isConverting = true);

      // 1. 페이지 렌더링 (format 파라미터 제거됨)
      final page = await _doc!.getPage(pageIndex + 1);
      
      // render는 PdfPageImage를 반환합니다.
      final pageImage = await page.render(
        width: page.width.toInt() * 2, // 해상도 2배 (고화질)
        height: page.height.toInt() * 2,
      );

      // 2. PdfPageImage를 dart:ui.Image로 변환
      final ui.Image image = await pageImage.createImageDetached();

      // 3. PNG 데이터로 변환
      final checkData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (checkData == null) throw Exception("이미지 변환 실패");
      
      final pngBytes = checkData.buffer.asUint8List();

      // 4. 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      // 파일명 충돌 방지를 위해 시간값 추가
      final fileName = 'page_${pageIndex + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // 5. 갤러리에 저장 (Gal 사용)
      await Gal.putImage(tempFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("페이지 ${pageIndex + 1} 갤러리 저장 완료!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("오류: $e")),
        );
      }
    } finally {
      setState(() => _isConverting = false);
    }
  }

  @override
  void dispose() {
    _doc?.dispose(); // 메모리 해제 필수
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("PDF to Image"),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: _pickPdf),
        ],
      ),
      body: _doc == null
          ? Center(
              child: ElevatedButton(
                onPressed: _pickPdf,
                child: const Text("PDF 파일 선택"),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "총 ${_doc!.pageCount} 페이지 (터치하여 갤러리에 저장)",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _doc!.pageCount,
                    itemBuilder: (context, index) {
                      return Card(
                        color: const Color(0xFF2C2C2C),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: const Icon(Icons.image, color: Colors.purpleAccent),
                          title: Text("Page ${index + 1}", style: const TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.download, color: Colors.white70),
                          onTap: _isConverting ? null : () => _savePageAsImage(index),
                        ),
                      );
                    },
                  ),
                ),
                if (_isConverting)
                  const LinearProgressIndicator(color: Colors.purpleAccent),
              ],
            ),
    );
  }
}