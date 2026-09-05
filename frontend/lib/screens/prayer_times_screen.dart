import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/azkar_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String _selectedCity = 'القاهرة';

  final Map<String, Map<String, double>> _cities = {
    'القاهرة': {'lat': 30.0444, 'lng': 31.2357},
    'مكة المكرمة': {'lat': 21.4225, 'lng': 39.8262},
    'المدينة المنورة': {'lat': 24.4672, 'lng': 39.6111},
    'الرياض': {'lat': 24.7136, 'lng': 46.6753},
    'القدس الشريف': {'lat': 31.7683, 'lng': 35.2137},
    'دبي': {'lat': 25.2048, 'lng': 55.2708},
  };

  @override
  Widget build(BuildContext context) {
    final azkarService = Provider.of<AzkarService>(context);
    final pt = azkarService.prayerTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. منتقي المدينة
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primaryEmerald),
                        SizedBox(width: 8),
                        Text('المدينة:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _selectedCity,
                      underline: const SizedBox(),
                      items: _cities.keys.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (newCity) {
                        if (newCity != null) {
                          setState(() => _selectedCity = newCity);
                          final coords = _cities[newCity]!;
                          azkarService.calculatePrayerTimes(coords['lat']!, coords['lng']!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. بطاقة المؤقت التنازلي البارزة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryEmerald],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    pt?.hijriDate ?? '١٨ ربيع الأول ١٤٤٨ هـ',
                    style: const TextStyle(color: AppColors.accentGoldLight, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'الوقت المتبقي حتى أذان ${pt?.nextPrayer ?? "العصر"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pt?.timeRemaining ?? '01:35',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. جدول الصلوات الست
            _buildPrayerTile('الفجر', pt?.fajr ?? '04:18', Icons.wb_twilight, pt?.nextPrayer == 'الفجر'),
            _buildPrayerTile('الشروق', pt?.sunrise ?? '05:44', Icons.wb_sunny_outlined, pt?.nextPrayer == 'الشروق'),
            _buildPrayerTile('الظهر', pt?.dhuhr ?? '11:58', Icons.wb_sunny, pt?.nextPrayer == 'الظهر'),
            _buildPrayerTile('العصر', pt?.asr ?? '15:28', Icons.brightness_6, pt?.nextPrayer == 'العصر'),
            _buildPrayerTile('المغرب', pt?.maghrib ?? '18:14', Icons.nights_stay_outlined, pt?.nextPrayer == 'المغرب'),
            _buildPrayerTile('العشاء', pt?.isha ?? '19:33', Icons.bedtime, pt?.nextPrayer == 'العشاء'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTile(String name, String time, IconData icon, bool isNext) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isNext ? AppColors.primaryEmerald.withOpacity(0.08) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isNext ? AppColors.primaryEmerald : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: isNext ? AppColors.primaryEmerald : Colors.grey.shade600, size: 22),
                const SizedBox(width: 14),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? AppColors.primaryEmerald : AppColors.primaryDark,
                  ),
                ),
                if (isNext)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'القادمة',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isNext ? AppColors.primaryEmerald : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
