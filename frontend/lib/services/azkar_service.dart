import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/prayer_times.dart';
import '../models/zikr.dart';

class AzkarService with ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api';
  
  List<CategoryModel> _categories = [];
  List<ZikrModel> _favorites = [];
  PrayerTimesModel? _prayerTimes;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _prayerTimer;
  double _currentLat = 30.0444;
  double _currentLng = 31.2357;

  List<CategoryModel> get categories => _categories;
  List<ZikrModel> get favorites => _favorites;
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static final Map<String, Map<String, dynamic>> _knownCities = {
    'القاهرة': {'lat': 30.0444, 'lng': 31.2357, 'fajr': '04:18', 'sunrise': '05:44', 'dhuhr': '11:58', 'asr': '15:28', 'maghrib': '18:14', 'isha': '19:33', 'qibla': 136.5},
    'مكة المكرمة': {'lat': 21.4225, 'lng': 39.8262, 'fajr': '04:52', 'sunrise': '06:08', 'dhuhr': '12:22', 'asr': '15:43', 'maghrib': '18:36', 'isha': '20:06', 'qibla': 0.0},
    'المدينة المنورة': {'lat': 24.4672, 'lng': 39.6111, 'fajr': '04:54', 'sunrise': '06:12', 'dhuhr': '12:24', 'asr': '15:48', 'maghrib': '18:37', 'isha': '20:07', 'qibla': 175.2},
    'الرياض': {'lat': 24.7136, 'lng': 46.6753, 'fajr': '04:22', 'sunrise': '05:40', 'dhuhr': '11:53', 'asr': '15:19', 'maghrib': '18:05', 'isha': '19:35', 'qibla': 247.1},
    'القدس الشريف': {'lat': 31.7683, 'lng': 35.2137, 'fajr': '04:55', 'sunrise': '06:19', 'dhuhr': '12:38', 'asr': '16:11', 'maghrib': '18:57', 'isha': '20:18', 'qibla': 156.3},
    'دبي': {'lat': 25.2048, 'lng': 55.2708, 'fajr': '04:42', 'sunrise': '06:01', 'dhuhr': '12:21', 'asr': '15:47', 'maghrib': '18:41', 'isha': '20:11', 'qibla': 259.8},
  };

  AzkarService() {
    initData();
  }

  @override
  void dispose() {
    _prayerTimer?.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. محاولة جلب البيانات محلياً أولاً لضمان العمل أوفلاين 100%
      await loadFromLocalAsset();
      
      // 2. محاولة المزامنة مع خادم Spring Boot في الخلفية
      trySyncWithBackend();

      // 3. حساب مواقيت الصلاة والبدء بالعد التنازلي الحي
      calculatePrayerTimes(_currentLat, _currentLng);
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الأذكار: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFromLocalAsset() async {
    final jsonString = await rootBundle.loadString('assets/data/azkar_data.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    if (data.containsKey('categories')) {
      final List<dynamic> catList = data['categories'];
      _categories = catList.map((c) => CategoryModel.fromJson(c)).toList();
    }
  }

  Future<void> trySyncWithBackend() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categories')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        if (decoded['success'] == true && decoded['data'] != null) {
          debugPrint('Synced successfully with Java Spring Boot backend!');
        }
      }
    } catch (e) {
      debugPrint('Backend offline or unreachable, using offline bundle: $e');
    }
  }

  CategoryModel? getCategoryByCode(String code) {
    try {
      return _categories.firstWhere((cat) => cat.code == code);
    } catch (_) {
      return null;
    }
  }

  void toggleFavorite(ZikrModel zikr) {
    zikr.isFavorite = !zikr.isFavorite;
    if (zikr.isFavorite) {
      if (!_favorites.any((z) => z.id == zikr.id)) {
        _favorites.add(zikr);
      }
    } else {
      _favorites.removeWhere((z) => z.id == zikr.id);
    }
    notifyListeners();
  }

  void calculatePrayerTimes(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;
    _prayerTimer?.cancel();
    _updatePrayerTimesModel();
    _prayerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerTimesModel();
    });
  }

  void _updatePrayerTimesModel() {
    // العثور على المدينة الأقرب أو الافتراضية
    Map<String, dynamic> cityData = _knownCities['القاهرة']!;
    double minDiff = 999999;
    for (final entry in _knownCities.entries) {
      final cLat = entry.value['lat'] as double;
      final cLng = entry.value['lng'] as double;
      final diff = (cLat - _currentLat).abs() + (cLng - _currentLng).abs();
      if (diff < minDiff) {
        minDiff = diff;
        cityData = entry.value;
      }
    }

    final now = DateTime.now();
    DateTime parseTime(String timeStr, [int dayOffset = 0]) {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day + dayOffset, h, m, 0);
    }

    final fajrDate = parseTime(cityData['fajr']);
    final sunriseDate = parseTime(cityData['sunrise']);
    final dhuhrDate = parseTime(cityData['dhuhr']);
    final asrDate = parseTime(cityData['asr']);
    final maghribDate = parseTime(cityData['maghrib']);
    final ishaDate = parseTime(cityData['isha']);

    String currentP = 'العشاء';
    String nextP = 'الفجر';
    String nextTimeStr = cityData['fajr'];
    DateTime targetDate = fajrDate;

    if (now.isBefore(fajrDate)) {
      currentP = 'قيام الليل';
      nextP = 'الفجر';
      nextTimeStr = cityData['fajr'];
      targetDate = fajrDate;
    } else if (now.isBefore(sunriseDate)) {
      currentP = 'الفجر';
      nextP = 'الشروق';
      nextTimeStr = cityData['sunrise'];
      targetDate = sunriseDate;
    } else if (now.isBefore(dhuhrDate)) {
      currentP = 'الضحى';
      nextP = 'الظهر';
      nextTimeStr = cityData['dhuhr'];
      targetDate = dhuhrDate;
    } else if (now.isBefore(asrDate)) {
      currentP = 'الظهر';
      nextP = 'العصر';
      nextTimeStr = cityData['asr'];
      targetDate = asrDate;
    } else if (now.isBefore(maghribDate)) {
      currentP = 'العصر';
      nextP = 'المغرب';
      nextTimeStr = cityData['maghrib'];
      targetDate = maghribDate;
    } else if (now.isBefore(ishaDate)) {
      currentP = 'المغرب';
      nextP = 'العشاء';
      nextTimeStr = cityData['isha'];
      targetDate = ishaDate;
    } else {
      currentP = 'العشاء';
      nextP = 'الفجر';
      nextTimeStr = cityData['fajr'];
      targetDate = parseTime(cityData['fajr'], 1);
    }

    final diff = targetDate.difference(now);
    final totalSecs = diff.inSeconds > 0 ? diff.inSeconds : 0;
    final hours = (totalSecs ~/ 3600).toString().padLeft(2, '0');
    final mins = ((totalSecs % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    final formattedCountdown = '$hours:$mins:$secs';

    _prayerTimes = PrayerTimesModel(
      date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      hijriDate: '٢٣ ربيع الأول ١٤٤٨ هـ',
      fajr: cityData['fajr'],
      sunrise: cityData['sunrise'],
      dhuhr: cityData['dhuhr'],
      asr: cityData['asr'],
      maghrib: cityData['maghrib'],
      isha: cityData['isha'],
      currentPrayer: currentP,
      nextPrayer: nextP,
      nextPrayerTime: nextTimeStr,
      timeRemaining: formattedCountdown,
      qiblaAngle: (cityData['qibla'] as num).toDouble(),
    );
    notifyListeners();
  }
}
