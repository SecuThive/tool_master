import 'dart:io';
import 'dart:ui' as ui; // 추가
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw; 
import 'package:pdf/pdf.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdfrx/pdfrx.dart'; 

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  List<File> _selectedFiles = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  // ⭐️ 실제 동작하는 PDF 병합 로직
Future<void> _mergePDFs() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("병합하려면 최소 2개 이상의 파일을 선택하세요.")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final mergedPdf = pw.Document();

      for (var file in _selectedFiles) {
        final doc = await PdfDocument.openFile(file.path);
        
        for (var page in doc.pages) {
          final pageImage = await page.render(fullWidth: 2000); 
          
          if (pageImage != null) {
            final uiImage = await pageImage.createImage();
            final bytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);
            
            if (bytes != null) {
              final image = pw.MemoryImage(bytes.buffer.asUint8List());
              
              mergedPdf.addPage(
                pw.Page(
                  // 1. 여백을 완전히 제거 (0) ⭐️
                  margin: const pw.EdgeInsets.all(0),
                  // 2. 원본 PDF 페이지의 실제 크기를 포인트(pt) 단위로 정확히 설정
                  pageFormat: p.PdfPageFormat(page.width, page.height),
                  build: (pw.Context context) {
                    // 3. 짓눌림 방지를 위해 BoxFit.fill 대신 BoxFit.contain 또는 BoxFit.cover 사용
                    // 여기서는 원본 비율을 유지하며 꽉 채우는 pw.SizedBox.expand를 활용합니다.
                    return pw.SizedBox.expand(
                      child: pw.Image(
                        image, 
                        fit: pw.BoxFit.fill, // 페이지 포맷이 원본과 같으므로 fill을 써도 비율이 유지됩니다.
                      ),
                    );
                  },
                ),
              );
            }
            pageImage.dispose(); 
          }
        }
        await doc.dispose();
      }

      final output = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile = File("${output.path}/merged_$timestamp.pdf");
      
      await outputFile.writeAsBytes(await mergedPdf.save());

      await Share.shareXFiles(
        [XFile(outputFile.path)],
        text: 'Tool Master에서 병합 완료!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("병합 성공! 저장 위치를 선택하세요.")),
      );
      
      setState(() => _selectedFiles = []);
    } catch (e) {
      debugPrint("Merge Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류가 발생했습니다: $e")),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 부분은 기존과 동일하므로 생략하거나 기존 코드를 그대로 사용하세요.
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(title: const Text("PDF Merge"), backgroundColor: const Color(0xFF1E1E1E)),
      body: Column(
        children: [
          Expanded(
            child: _selectedFiles.isEmpty
                ? const Center(child: Text("선택된 파일이 없습니다.", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        title: Text(_selectedFiles[index].path.split('/').last, style: const TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white38),
                          onPressed: () => setState(() => _selectedFiles.removeAt(index)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.add),
                    label: const Text("파일 추가"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _mergePDFs,
                    icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.merge_type),
                    label: const Text("PDF 병합"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}