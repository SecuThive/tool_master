import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img; // 이미지 처리 라이브러리
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Uint8List? _imageData;
  final _cropController = CropController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final data = await pickedFile.readAsBytes();
      setState(() => _imageData = data);
    } else {
      if (mounted && _imageData == null) Navigator.pop(context);
    }
  }

  // --- [신규 기능 1] 이미지 회전/반전/필터 처리 ---
  Future<void> _processImage(String action) async {
    if (_imageData == null) return;
    setState(() => _isLoading = true);

    // 1. 바이트 데이터를 이미지 객체로 변환 (무거운 작업)
    img.Image? decodedImage = img.decodeImage(_imageData!);
    if (decodedImage == null) return;

    // 2. 각 기능 수행
    img.Image processed;
    switch (action) {
      case 'rotate_left':
        processed = img.copyRotate(decodedImage, angle: -90);
        break;
      case 'rotate_right':
        processed = img.copyRotate(decodedImage, angle: 90);
        break;
      case 'flip_horizontal':
        processed = img.copyFlip(decodedImage, direction: img.FlipDirection.horizontal);
        break;
      case 'grayscale':
        processed = img.grayscale(decodedImage);
        break;
      default:
        processed = decodedImage;
    }

    // 3. 다시 화면에 보여주기 위해 바이트로 변환 (JPG 형식)
    // (이 과정이 약간 느릴 수 있어 로딩바가 필요합니다)
    final newBytes = Uint8List.fromList(img.encodeJpg(processed));

    setState(() {
      _imageData = newBytes;
      _isLoading = false;
    });
  }

  Future<void> _cropAndSave() async {
    setState(() => _isLoading = true);
    _cropController.crop();
  }

  Future<void> _onCropped(Uint8List croppedData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      // 파일명을 현재 시간으로 해서 중복 방지
      final fileName = 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(croppedData);

      await Gal.putImage(file.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리에 저장되었습니다!')),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 편집기'),
        actions: [
          IconButton(onPressed: _pickImage, icon: const Icon(Icons.add_photo_alternate)),
          TextButton(
             onPressed: _cropAndSave,
             child: const Text("저장", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: _imageData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    // 메인 편집 영역
                    Expanded(
                      child: Crop(
                        image: _imageData!,
                        controller: _cropController,
                        onCropped: _onCropped,
                        baseColor: Colors.grey[900]!,
                        maskColor: Colors.black.withOpacity(0.5),
                        // 인자 하나를 더 받도록 (_, ) 추가
                        initialRectBuilder: (rect, _) => rect,
                      ),
                    ),
                    // 하단 툴바
                    _buildToolbar(),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _toolBtn(Icons.rotate_left, "좌회전", () => _processImage('rotate_left')),
          _toolBtn(Icons.rotate_right, "우회전", () => _processImage('rotate_right')),
          _toolBtn(Icons.flip, "좌우반전", () => _processImage('flip_horizontal')),
          _toolBtn(Icons.filter_b_and_w, "흑백", () => _processImage('grayscale')),
          const VerticalDivider(width: 30), // 구분선
          _toolBtn(Icons.crop_square, "1:1", () => _cropController.aspectRatio = 1),
          _toolBtn(Icons.crop_free, "자유", () => _cropController.aspectRatio = null),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}