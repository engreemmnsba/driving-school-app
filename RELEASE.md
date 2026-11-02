# RELEASE.md — مفتاح التوقيع، بناء APK، والنشر

> ما انجرّب لسا. الخطوات مكتوبة عشان تنعمل مرة وحدة على جهاز Reem (E: فقط).

## 1. مفتاح التوقيع (مرة وحدة بالعمر — DECISIONS P8)
نفس المفتاح للنسختين (direct و play). ضياعه = ما في تحديثات لنسخة direct.
```powershell
cd E:\driving_school_app\app\android
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore E:\keys\driving_school.jks -keyalg RSA -keysize 2048 -validity 10000 -alias driving_school
```
ملف `android\key.properties` (ما بينرفع لأي مكان):
```
storePassword=...
keyPassword=...
keyAlias=driving_school
storeFile=E:\\keys\\driving_school.jks
```
- نسختين احتياط من `driving_school.jks` و `key.properties` بمكانين آمنين (مثلًا USB + Drive مشفّر).
- لـ Google Play: بتسجيل App Signing، رفع نفس المفتاح (ما نخلي Google يولّد واحد).

## 2. رقم الإصدار
- `app\pubspec.yaml` → `version: 1.1.0+2` (الرقم بعد + لازم يزيد كل مرة).
- `app\lib\core\config\version.dart` → `appVersion = '1.1.0'` و `appBuild = 2` (نفس الأرقام).

## 3. البناء
```powershell
cd E:\driving_school_app\app
flutter build apk --release --flavor direct -t lib/main_direct.dart
flutter build appbundle --release --flavor play -t lib/main_play.dart
flutter build web --release -t lib/main_direct.dart
```
- APK: `build\app\outputs\flutter-apk\app-direct-release.apk`
- Play: `build\app\outputs\bundle\playRelease\app-play-release.aab`

## 4. النشر (Firebase Hosting مجاني بدون Blaze)
1. نسخ `app\build\web\*` إلى `E:\driving_school_app\hosting\` (نسخة المتصفح للآيفون، A7).
2. نسخ الـ APK إلى `hosting\download\app.apk`.
3. تعديل `hosting\download\version.json` (الإصدار، الحجم، التاريخ، اسم المدرسة).
4. `cd E:\driving_school_app ; firebase deploy --only hosting`
5. بالتطبيق (المدير): المزيد ← تحديث التطبيق ← "نشر إصدار جديد": الإصدار، رقم البناء، الرابط `https://your-firebase-project.web.app/download/app.apk`، الجديد.
   كل الجوالات بتشوف "تحديث جديد" مع المزامنة.

صفحة التنزيل: `https://your-firebase-project.web.app/download/`

## 5. قبل أول تشغيل حقيقي (go-live)
- Blaze على حساب فوترة صاحب المدرسة (A10) → `firebase deploy --only functions,firestore`.
- deviceCode من السيرفر (A12).
- نشر `firestore.indexes.json` (فهارس المدرب والطالب).
