# 🛠️ Tool Master (툴 마스터)

**Tool Master**는 Flutter를 기반으로 제작된 올인원 PDF 및 이미지 편집 유틸리티 앱입니다. 복잡한 서버 처리 없이도 강력한 편집 기능을 제공하며, 사용자의 프라이버시를 최우선으로 생각하는 온디바이스(On-Device) 처리를 지향합니다.



---

## ✨ 주요 기능 (Current Features)

### 📄 PDF 도구 (PDF Tools)
* **PDF 병합:** 여러 개의 PDF 파일을 선택하여 하나의 고화질 파일로 병합합니다. (비율 유지 및 짓눌림 방지 로직 적용)
* **PDF 뷰어:** 빠르고 안정적인 최신 렌더링 엔진(`pdfrx`)을 사용한 문서 열람 기능.
* **이미지 ↔ PDF 변환:** 사진을 PDF로 만들거나, PDF의 각 페이지를 이미지로 추출합니다.

### 🖼️ 이미지 도구 (Image Tools)
* **이미지 편집기:** 자르기, 회전, 필터 적용 등 직관적인 편집 기능을 제공합니다.
* **EXIF 정보 보기:** 이미지에 숨겨진 메타데이터(카메라 모델, 촬영 시간, 파일 크기 등)를 상세히 분석합니다.

### ⚙️ 사용자 경험 (UX)
* **다크 모드 지원:** 시스템 설정에 맞춘 깔끔한 다크/라이트 테마를 지원합니다.
* **세련된 스플래시 화면:** 앱 실행 시 부드러운 페이드인 애니메이션과 함께 브랜드 로고를 노출합니다.
* **간편한 공유:** 작업 완료 후 시스템 공유창을 통해 즉시 파일을 저장하거나 전송할 수 있습니다.

---

## 🧪 실험실 (Upcoming: On-Device AI)

서버 비용 없이 사용자의 기기 성능을 활용하는 강력한 AI 기능들이 추가될 예정입니다.

* **AI 배경 제거 (Background Removal):** Google MediaPipe를 활용한 온디바이스 인물/물체 누끼 따기.
* **AI 고해상도 복원 (Super Resolution):** 저화질 이미지를 딥러닝 모델로 업스케일링.
* **스타일 변환 (Style Transfer):** 사진을 만화나 유화 화풍으로 실시간 변환.

---

## 🚀 시작하기 (Getting Started)

### 사전 요구 사항
* Flutter SDK: `^3.4.3` 이상
* Android API Level: `21` 이상 (Lollipop)

### 설치 및 빌드
1. 저장소 클론:
   ```bash
   git clone https://github.com/secuthive/tool_master.git
   ```

2. 패키지 설치:
   ```bash
   flutter pub get
   ```

3. 아이콘 및 리소스 생성:
   ```bash
   dart run flutter_launcher_icons
   ```

4. 앱 실행:
   ```bash
   flutter run
   ```
   
## 🛠️ 기술 스택 (Tech Stack)

Language: Dart
Framework: Flutter
Libraries: * pdfrx & pdf: PDF 렌더링 및 생성
exif: 메타데이터 추출
url_launcher: 이메일 문의 및 외부 링크 연결
share_plus: 시스템 파일 공유
