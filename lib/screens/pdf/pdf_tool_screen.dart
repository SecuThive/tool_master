import 'package:flutter/material.dart';
import 'pdf_merge_screen.dart'; // 기존 병합 스크린

// [새로 만든 스크린 import]
import 'pdf_viewer_screen.dart';
import 'image_to_pdf_screen.dart';
import 'pdf_to_image_screen.dart';

class PdfToolScreen extends StatelessWidget {
  const PdfToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("PDF Tools"),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Function",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "PDF 관련 작업을 선택하세요.",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // 1. PDF 병합
                  _buildToolCard(
                    context,
                    title: "PDF 병합",
                    icon: Icons.merge_type,
                    color: Colors.redAccent,
                    description: "여러 PDF를 하나로 합치기",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const PdfMergeScreen()));
                    },
                  ),

                  // 2. PDF 뷰어 (연결됨!)
                  _buildToolCard(
                    context,
                    title: "PDF 뷰어",
                    icon: Icons.picture_as_pdf,
                    color: Colors.orangeAccent,
                    description: "PDF 파일 열기 및 보기",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const PdfViewerScreen()));
                    },
                  ),

                  // 3. 이미지 -> PDF (연결됨!)
                  _buildToolCard(
                    context,
                    title: "이미지 to PDF",
                    icon: Icons.image,
                    color: Colors.blueAccent,
                    description: "사진을 PDF로 변환",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const ImageToPdfScreen()));
                    },
                  ),

                  // 4. PDF -> 이미지 (연결됨!)
                  _buildToolCard(
                    context,
                    title: "PDF to 이미지",
                    icon: Icons.photo_library,
                    color: Colors.purpleAccent,
                    description: "PDF를 사진으로 저장",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const PdfToImageScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}