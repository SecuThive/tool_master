import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // [필수] 패키지 import
import '../../main.dart'; // 테마 리모컨(themeNotifier) 사용

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationOn = true;

  // 📧 [핵심 기능] 이메일 앱 띄우기 함수
  Future<void> _sendEmail() async {
    final String email = 'thive8564@gmail.com';
    final String subject = '[Tool Master] 앱 문의 및 제안';
    final String body = '안녕하세요,\n앱 사용 중 문의사항이 있어 메일 드립니다.\n\n내용:\n';

    // 이메일 URL 생성 (mailto 스킴 사용)
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // 이메일 앱이 없는 경우 안내
        throw 'Could not launch email';
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("알림"),
            content: SelectableText("이메일 앱을 열 수 없습니다.\n아래 주소로 직접 문의해주세요.\n\n$email"), // 복사 가능하도록 SelectableText 사용
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인")),
            ],
          ),
        );
      }
    }
  }

  // 특수문자나 띄어쓰기 인코딩용 함수
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    // 현재 테마 상태 확인
    final isDark = themeNotifier.value == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          _buildSectionHeader("General", context),
          _buildSwitchTile(
            context,
            title: "알림 수신",
            subtitle: "앱의 중요 알림을 받습니다.",
            value: _isNotificationOn,
            onChanged: (value) {
              setState(() => _isNotificationOn = value);
            },
          ),

          // 다크 모드 스위치
          SwitchListTile(
            activeColor: Colors.blueAccent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text("다크 모드", style: TextStyle(color: textColor)),
            subtitle: Text(
              isDark ? "현재 다크 모드 사용 중" : "현재 라이트 모드 사용 중", 
              style: TextStyle(color: subTextColor, fontSize: 12)
            ),
            value: isDark,
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode, 
              color: isDark ? Colors.purpleAccent : Colors.orangeAccent
            ),
            onChanged: (value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 40),

          _buildSectionHeader("About & Support", context),
          
          _buildListTile(
            context,
            title: "버전 정보",
            trailingText: "v1.0.0",
            onTap: () {},
          ),
          _buildListTile(
            context,
            title: "오픈소스 라이선스",
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: "TOOL MASTER",
                applicationVersion: "1.0.0",
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.design_services_outlined, size: 48, color: textColor),
                ),
              );
            },
          ),
          
          // [수정됨] 이메일 보내기 기능 연결
          _buildListTile(
            context,
            title: "개발자 문의",
            trailingIcon: Icons.mail_outline,
            onTap: _sendEmail, // 👈 여기서 함수 호출!
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Made by Creator",
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // (아래는 이전과 동일한 위젯들)
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    return SwitchListTile(
      activeColor: Colors.blueAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(BuildContext context, {
    required String title,
    String? trailingText,
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: subTextColor, fontSize: 14)),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 16, color: subTextColor),
        ],
      ),
    );
  }
}