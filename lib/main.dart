import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// [화면 파일 import]
import 'screens/image/image_editor_screen.dart'; 
import 'screens/pdf/pdf_tool_screen.dart'; 
import 'screens/document/document_viewer_screen.dart';
import 'screens/settings/settings_screen.dart'; 
import 'screens/image/image_info_screen.dart';

// 테마 리모컨
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  // 초기화 보장
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ToolMasterApp());
}

class ToolMasterApp extends StatelessWidget {
  const ToolMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Tool Master',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, 

          // ☀️ 라이트 모드
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            primaryColor: Colors.blueAccent,
            cardColor: Colors.white,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F5F7),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),

          // 🌙 다크 모드
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            primaryColor: Colors.blueAccent,
            cardColor: const Color(0xFF2C2C2C),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // [핵심] 다시 SplashScreen을 시작점으로 설정하여 디자인을 보여줍니다.
          home: const SplashScreen(), 
        );
      },
    );
  }
}

// 1️⃣ 스플래시 스크린 (디자인 업그레이드 Ver.)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // 페이드인 애니메이션 효과 추가 (부드럽게 나타나기)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // 2.5초 뒤에 메인 화면으로 이동
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainCategoryScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 테마 감지
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition( // 전체적으로 부드럽게 등장
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 로고 아이콘
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
                child: Image.asset(
                  "assets/icon/icon.png", // 아까 만든 아이콘 파일 사용
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 30),
              
              // 2. 앱 이름 (TOOL MASTER)
              Text(
                "TOOL MASTER",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 4.0, // 자간을 넓혀서 고급스럽게
                ),
              ),
              const SizedBox(height: 10),
              
              // 3. 슬로건 (Premium Creative Studio)
              Text(
                "Premium Creative Studio",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                  letterSpacing: 1.2,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // 4. 로딩 인디케이터
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white30 : Colors.black26,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2️⃣ 메인 카테고리 화면
class MainCategoryScreen extends StatelessWidget {
  const MainCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (이 아래는 기존 코드와 동일) ...
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text("Tool Master"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }, 
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategoryTile(
            context,
            title: "이미지 도구 (Image Tools)",
            icon: Icons.image,
            color: Colors.blueAccent,
            children: [
              _buildActionItem(
                context,
                title: "이미지 편집기 실행",
                subtitle: "자르기, 필터, 회전 등",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImageEditorScreen()),
                  );
                },
              ),
              _buildActionItem(
                context,
                title: "이미지 정보 보기",
                subtitle: "해상도 및 파일 정보 확인",
                onTap: () {
                  // 👈 기존의 _showPreparingMessage 대신 화면 이동 코드로 교체!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImageInfoScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: "PDF 도구 (PDF Tools)",
            icon: Icons.picture_as_pdf,
            color: Colors.redAccent,
            children: [
              _buildActionItem(
                context,
                title: "PDF 도구 모음",
                subtitle: "PDF 병합, 변환, 뷰어 등",
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const PdfToolScreen())
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: "오피스 뷰어 (Office & HWP)",
            icon: Icons.snippet_folder, 
            color: Colors.greenAccent,   
            children: [
              _buildActionItem(
                context,
                title: "문서 열기",
                subtitle: "HWP, Word, Excel, PPT 지원",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentViewerScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryTile(
            context,
            title: "AI & 실험실 (Labs)",
            icon: Icons.auto_awesome,
            color: Colors.purpleAccent,
            children: [
              _buildActionItem(
                context,
                title: "AI 이미지 생성",
                subtitle: "텍스트로 이미지 만들기 (준비중)",
                onTap: () => _showPreparingMessage(context),
              ),
              _buildActionItem(
                context,
                title: "동영상 편집",
                subtitle: "간단한 컷 편집 (준비중)",
                onTap: () => _showPreparingMessage(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPreparingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("이 기능은 곧 업데이트됩니다!"), duration: Duration(seconds: 1)),
    );
  }

  Widget _buildCategoryTile(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: children,
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white70 : Colors.black87;
    final subColor = isDark ? Colors.white38 : Colors.black54;

    return ListTile(
      title: Text(title, style: TextStyle(color: titleColor, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subColor),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    );
  }
}