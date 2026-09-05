import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/category.dart';
import '../services/azkar_service.dart';
import 'azkar_reader_screen.dart';
import 'electronic_tasbeeh_screen.dart';
import 'prayer_times_screen.dart';
import 'qibla_compass_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final azkarService = Provider.of<AzkarService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أذكار المسلم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => azkarService.initData(),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: azkarService.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald))
          : RefreshIndicator(
              onRefresh: () => azkarService.initData(),
              color: AppColors.primaryEmerald,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة الهيدر الإسلامية الملكية مع مواقيت الصلاة والذكر اليومي
                    _buildPrayerBanner(context, azkarService),
                    const SizedBox(height: 16),

                    // 2. شريط الوصول السريع (السبحة، المواقيت، القبلة)
                    _buildQuickActionButtons(context),
                    const SizedBox(height: 20),

                    // 3. عنوان الأقسام
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'أقسام الأذكار والأدعية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          '${azkarService.categories.length} أقسام',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. شبكة الأقسام المتجاوبة
                    _buildCategoriesGrid(context, azkarService.categories),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrayerBanner(BuildContext context, AzkarService service) {
    final pt = service.prayerTimes;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, Color(0xFF0C3D26), AppColors.primaryEmerald],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryEmerald.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // السطر العلوي: المدينة، التاريخ الهجري، والعد التنازلي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.accentGold, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'القاهرة',
                      style: TextStyle(color: AppColors.accentGoldLight, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${pt?.hijriDate ?? "١٨ ربيع الأول ١٤٤٨ هـ"}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.accentGold, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        '${pt?.nextPrayer ?? "الفجر"} ${pt?.timeRemaining ?? "00:00:00"}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // شريط الصلوات الأفقي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPrayerStripItem('الفجر', pt?.fajr ?? '04:18', Icons.wb_twilight, pt?.nextPrayer == 'الفجر'),
                  _buildPrayerStripItem('الشروق', pt?.sunrise ?? '05:44', Icons.wb_sunny_outlined, pt?.nextPrayer == 'الشروق'),
                  _buildPrayerStripItem('الظهر', pt?.dhuhr ?? '11:58', Icons.wb_sunny, pt?.nextPrayer == 'الظهر'),
                  _buildPrayerStripItem('العصر', pt?.asr ?? '15:28', Icons.brightness_6, pt?.nextPrayer == 'العصر'),
                  _buildPrayerStripItem('المغرب', pt?.maghrib ?? '18:14', Icons.nights_stay_outlined, pt?.nextPrayer == 'المغرب'),
                  _buildPrayerStripItem('العشاء', pt?.isha ?? '19:33', Icons.bedtime, pt?.nextPrayer == 'العشاء'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // السطر السفلي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: AppColors.accentGold, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'الأذان القادم: ${pt?.nextPrayer ?? "الفجر"} (${pt?.nextPrayerTime ?? pt?.fajr ?? "04:18"})',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'المواقيت بالتفصيل',
                      style: TextStyle(color: AppColors.accentGoldLight, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: AppColors.accentGoldLight, size: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerStripItem(String name, String time, IconData icon, bool isNext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isNext ? AppColors.accentGold.withOpacity(0.22) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNext ? AppColors.accentGold : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 14,
            color: isNext ? AppColors.accentGoldLight : Colors.white70,
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? AppColors.accentGoldLight : Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (isNext)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'القادمة',
                style: TextStyle(fontSize: 7, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            context,
            icon: Icons.fingerprint,
            title: 'السبحة',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ElectronicTasbeehScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickButton(
            context,
            icon: Icons.access_time_filled,
            title: 'المواقيت',
            color: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickButton(
            context,
            icon: Icons.explore,
            title: 'القبلة',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<CategoryModel> categories) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReaderScreen(category: cat),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.menu_book, color: AppColors.primaryEmerald, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.nameAr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cat.azkar.length} أذكار',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_left, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
