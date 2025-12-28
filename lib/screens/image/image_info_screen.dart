import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';

class ImageInfoScreen extends StatefulWidget {
  const ImageInfoScreen({super.key});

  @override
  State<ImageInfoScreen> createState() => _ImageInfoScreenState();
}

class _ImageInfoScreenState extends State<ImageInfoScreen> {
  Map<String, String> _exifData = {};
  File? _selectedImage;
  bool _isLoading = false;
  String _fileSize = "";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _exifData = {};
      });
      
      final file = File(pickedFile.path);
      
      // 파일 크기 계산 (KB, MB 단위)
      final bytesLength = await file.length();
      _fileSize = (bytesLength / (1024 * 1024)).toStringAsFixed(2) + " MB";
      
      final bytes = await file.readAsBytes();
      final data = await readExifFromBytes(bytes);

      setState(() {
        _selectedImage = file;
        // 핵심 정보를 상단으로 올리기 위해 가공
        _exifData = data.map((key, value) => MapEntry(key, value.toString()));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("이미지 상세 정보")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  // [수정됨] Colors.black10 -> Colors.black12 (에러 해결)
                  color: isDark ? Colors.white10 : Colors.black12, 
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  image: _selectedImage != null 
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : null,
                ),
                child: _selectedImage == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.blueAccent),
                        SizedBox(height: 8),
                        Text("이미지 선택", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                      ],
                    )
                  : null,
              ),
            ),
          ),
          
          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            Text("파일 크기: $_fileSize", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ],

          const SizedBox(height: 20),
          if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator())),
          
          if (_exifData.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _exifData.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                itemBuilder: (context, index) {
                  String key = _exifData.keys.elementAt(index);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    subtitle: Text(_exifData[key]!, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                  );
                },
              ),
            )
          else if (!_isLoading)
            const Expanded(child: Center(child: Text("이미지를 선택하여 정보를 확인하세요.", style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }
}