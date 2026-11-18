# Map Feature (Flutter) — خريطة مجانية بـ OpenStreetMap

## 1) انسخ الفولدر
حط فولدر `map_feature` جوه `lib/` في مشروعك.

## 2) أضف الـ dependencies
```bash
flutter pub add flutter_map latlong2 http geolocator
```

## 3) استخدمها
```dart
import 'map_feature/map_page.dart';

Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
```

## 4) الصلاحيات (للموقع الحالي)

### Android — `android/app/src/main/AndroidManifest.xml` (قبل <application>)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS — `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج موقعك لعرضه على الخريطة</string>
```

### macOS (لو بتشغل عليه) — أضف في Entitlements:
`com.apple.security.network.client` و `com.apple.security.personal-information.location`

## 5) تعديلات لازم تعملها
- `map_page.dart`: غيّر `userAgentPackageName` لـ package name بتاع تطبيقك.
- `osm_map_service.dart`: غيّر `userAgent` لاسم تطبيقك (شرط Nominatim).

## الاستخدام
- اضغط على الخريطة ← تضيف نقطة (مرقّمة).
- اضغط على النقطة ← تتحذف.
- ابحث عن مكان ← اختار نتيجة ← تتضاف كنقطة.
- زر الاتجاهات ← يرسم الطريق بين كل النقاط بالترتيب ويعرض المسافة والزمن.
- المسافة المباشرة (خط مستقيم) بتظهر تلقائيًا لما يبقى فيه نقطتين.

## للإنتاج
سيرفرات Nominatim و OSRM العامة للتجربة فقط. بدّلها بمزوّد بمفتاح
(OpenRouteService / MapTiler / Stadia) أو استضف بنفسك، وكمان بلاطات
OSM الرسمية مش للاستخدام الكثيف. كل اللي تعمله: class جديد
يعمل `implements MapService` وتمرره: `MapPage(service: MyService())`.

## توافق النسخ
الكود مكتوب على flutter_map 7+/8 (`initialCenter`, `child:` في Marker,
`CameraFit.coordinates`). لو عندك نسخة أقدم (6 أو أقل) هتحتاج تعدل
`center/zoom` و `builder:` بدل `child:`.
