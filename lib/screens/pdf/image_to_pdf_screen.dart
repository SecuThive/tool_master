import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart'; // 공유 및 미리보기용
import 'dart:io';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isGenerating = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isGenerating = true);

    final pdf = pw.Document();

    for (var imageFile in _selectedImages) {
      final imageBytes = await File(imageFile.path).readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    // PDF 미리보기 및 공유 (Printing 패키지 기능 활용)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Image to PDF"),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _pickImages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImages.isEmpty
                ? const Center(
                    child: Text("이미지를 선택해주세요 (+ 버튼)", 
                    style: TextStyle(color: Colors.white54)))
                : ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _selectedImages.removeAt(oldIndex);
                        _selectedImages.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int i = 0; i < _selectedImages.length; i++)
                        ListTile(
                          key: ValueKey(_selectedImages[i]),
                          leading: Image.file(File(_selectedImages[i].path), width: 50, height: 50, fit: BoxFit.cover),
                          title: Text("Page ${i + 1}", style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(i);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isGenerating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(_isGenerating ? "생성 중..." : "PDF 생성 및 공유"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: _selectedImages.isEmpty || _isGenerating ? null : _generatePdf,
              ),
            ),
          ),
        ],
      ),
    );
  }
}