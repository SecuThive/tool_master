import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class UpscaleScreen extends StatefulWidget {
  const UpscaleScreen({super.key});

  @override
  State<UpscaleScreen> createState() => _UpscaleScreenState();
}

class _UpscaleScreenState extends State<UpscaleScreen> {
  File? _inputImage;
  File? _outputImage;
  bool _isProcessing = false;
  tfl.Interpreter? _interpreter;
  double _comparisonSliderValue = 0.5;

  // ⭐️ 고사양 설정 (256x256 -> 1024x1024)
  final int inputSize = 256; 
  final int upscaleFactor = 4; 

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      var options = tfl.InterpreterOptions();
      if (Platform.isAndroid) {
        options.addDelegate(tfl.XNNPackDelegate()); 
      } else if (Platform.isIOS) {
        options.addDelegate(tfl.GpuDelegate()); 
      }

      _interpreter = await tfl.Interpreter.fromAsset(
        'assets/models/upscaler.tflite',
        options: options,
      );
      debugPrint("256x256 고성능 모델 로드 완료");
    } catch (e) {
      debugPrint("모델 로드 실패: $e");
      _showErrorSnackBar("모델을 불러오지 못했습니다.");
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // 에러 발생 시 사용자에게 팝업 알림
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _processImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && _interpreter != null) {
      setState(() {
        _inputImage = File(pickedFile.path);
        _outputImage = null;
        _isProcessing = true;
      });

      // ⭐️ 메모리 정리를 위해 짧은 대기 (Garbage Collection 유도)
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final imageData = await _inputImage!.readAsBytes();
        img.Image? originalImage = img.decodeImage(imageData);
        if (originalImage == null) {
          throw Exception("이미지를 디코딩할 수 없습니다.");
        }

        // 1. 전처리 (256x256)
        img.Image resized = img.copyResize(originalImage, width: inputSize, height: inputSize);
        
        var input = Uint8List(1 * inputSize * inputSize * 3);
        var buffer = input.buffer.asUint8List();
        int pixelIndex = 0;
        for (var y = 0; y < inputSize; y++) {
          for (var x = 0; x < inputSize; x++) {
            var pixel = resized.getPixel(x, y);
            buffer[pixelIndex++] = pixel.r.toInt();
            buffer[pixelIndex++] = pixel.g.toInt();
            buffer[pixelIndex++] = pixel.b.toInt();
          }
        }

        // 2. 출력 텐서 준비 (1024x1024)
        final int outputSize = inputSize * upscaleFactor; 
        var output = List.filled(1 * outputSize * outputSize * 3, 0.0)
            .reshape([1, outputSize, outputSize, 3]);

        // 3. AI 추론 실행
        _interpreter!.run(input.reshape([1, inputSize, inputSize, 3]), output);

        // 4. 후처리 (픽셀 조립)
        final resultImg = img.Image(width: outputSize, height: outputSize);
        for (var y = 0; y < outputSize; y++) {
          for (var x = 0; x < outputSize; x++) {
            resultImg.setPixelRgb(
              x, y, 
              output[0][y][x][0].clamp(0, 255).toInt(),
              output[0][y][x][1].clamp(0, 255).toInt(),
              output[0][y][x][2].clamp(0, 255).toInt(),
            );
          }
        }

        final directory = await getTemporaryDirectory();
        final outputPath = "${directory.path}/out_${DateTime.now().millisecondsSinceEpoch}.png";
        File(outputPath).writeAsBytesSync(img.encodePng(resultImg));

        if (mounted) {
          setState(() {
            _outputImage = File(outputPath);
          });
        }
      } catch (e) {
        debugPrint("상세 오류: $e");
        
        // ⭐️ 메모리 부족(OOM) 특화 대응
        String errorMessage = "복원 중 예상치 못한 오류가 발생했습니다.";
        String errorTitle = "복원 실패";

        if (e.toString().toLowerCase().contains("memory") || e.toString().contains("oom")) {
          errorMessage = "기기의 메모리가 부족하여 고해상도 복원을 완료할 수 없습니다. 다른 앱을 종료하거나 기기를 재부팅한 후 다시 시도해 주세요.";
          errorTitle = "메모리 부족";
        }
        
        _showErrorDialog(errorTitle, errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_outputImage == null) return;
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();
      await Gal.putImage(_outputImage!.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("갤러리에 저장되었습니다!")));
      }
    } catch (e) {
      _showErrorSnackBar("갤러리 저장에 실패했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI 고해상도 복원"),
        actions: [
          if (_outputImage != null)
            IconButton(icon: const Icon(Icons.download), onPressed: _saveToGallery)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_outputImage != null) ...[
              const Text("슬라이더를 움직여 비포/애프터를 비교하세요", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: 1, 
                  child: Stack(
                    children: [
                      Positioned.fill(child: Image.file(_inputImage!, fit: BoxFit.cover)),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _comparisonSliderValue,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.white, width: 2)),
                              ),
                              child: Image.file(_outputImage!, fit: BoxFit.cover, alignment: Alignment.centerLeft),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Slider(
                value: _comparisonSliderValue,
                activeColor: Colors.blueAccent,
                onChanged: (v) => setState(() => _comparisonSliderValue = v),
              ),
            ] else if (_inputImage != null) ...[
               ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_inputImage!, height: 300, fit: BoxFit.cover),
              ),
            ],
            
            const SizedBox(height: 20),
            if (_isProcessing) 
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("고해상도 변환은 기기 사양에 따라\n최대 10초 이상 소요될 수 있습니다.", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _processImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: Text(_isProcessing ? "AI 분석 중..." : "이미지 선택 및 AI 복원 시작"),
            ),
          ],
        ),
      ),
    );
  }
}