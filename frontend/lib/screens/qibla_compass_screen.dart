import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  double _qiblaAngle = 136.5; // زاوية القبلة من القاهرة
  double _distanceKm = 1290.0;
  String _currentCity = 'القاهرة';

  final Map<String, Map<String, dynamic>> _cities = {
    'القاهرة': {'angle': 136.5, 'dist': 1290.0},
    'الإسكندرية': {'angle': 140.2, 'dist': 1450.0},
    'الرياض': {'angle': 247.1, 'dist': 870.0},
    'القدس الشريف': {'angle': 156.3, 'dist': 1240.0},
    'دبي': {'angle': 259.8, 'dist': 1650.0},
    'إسطنبول': {'angle': 152.4, 'dist': 2410.0},
    'الدار البيضاء': {'angle': 98.6, 'dist': 4800.0},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // 1. تحديد المدينة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryEmerald),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _currentCity,
                    underline: const SizedBox(),
                    items: _cities.keys.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (newCity) {
                      if (newCity != null) {
                        setState(() {
                          _currentCity = newCity;
                          _qiblaAngle = _cities[newCity]!['angle'];
                          _distanceKm = _cities[newCity]!['dist'];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                'الزاوية: ${_qiblaAngle.toStringAsFixed(1)}° | المسافة لمكة: ${_distanceKm.toStringAsFixed(0)} كم',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),

              const Spacer(),

              // 2. بوصلة القبلة المرئية
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.4), width: 3),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // علامات الاتجاهات (N, S, E, W)
                    const Positioned(top: 14, child: Text('ش', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                    const Positioned(bottom: 14, child: Text('ج', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Positioned(right: 14, child: Text('ق', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Positioned(left: 14, child: Text('غ', style: TextStyle(fontWeight: FontWeight.bold))),

                    // سهم مؤشر القبلة الدائري مع الكعبة
                    Transform.rotate(
                      angle: (_qiblaAngle * (math.pi / 180.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryEmerald,
                            ),
                            child: const Icon(Icons.mosque, color: AppColors.accentGold, size: 28),
                          ),
                          Container(
                            width: 4,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    // النقطة المركزية
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 3. تنبيه دقة البوصلة
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryEmerald),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'يرجى توجيه الهاتف أفقياً بعيداً عن المعادن والمجالات المغناطيسية للحصول على أدق قراءة.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
