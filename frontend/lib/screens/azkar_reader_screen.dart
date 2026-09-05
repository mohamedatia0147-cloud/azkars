import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../models/category.dart';
import '../models/zikr.dart';

class AzkarReaderScreen extends StatefulWidget {
  final CategoryModel category;

  const AzkarReaderScreen({super.key, required this.category});

  @override
  State<AzkarReaderScreen> createState() => _AzkarReaderScreenState();
}

class _AzkarReaderScreenState extends State<AzkarReaderScreen> {
  int _currentIndex = 0;
  double _fontSize = 20.0;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    // Reset session counts for current category
    for (var z in widget.category.azkar) {
      z.reset();
    }
  }

  void _onTapZikr(ZikrModel zikr) {
    if (zikr.isCompleted) return;

    setState(() {
      zikr.increment();
      HapticFeedback.lightImpact();
      if (_soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
    });

    if (zikr.isCompleted) {
      HapticFeedback.mediumImpact();
      _showCompletionSnack(zikr);
      // Auto-advance if not last
      if (_currentIndex < widget.category.azkar.length - 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _currentIndex++;
          });
        });
      } else {
        _showFinishedCategoryDialog();
      }
    }
  }

  void _showCompletionSnack(ZikrModel zikr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.accentGold),
            SizedBox(width: 8),
            Text('تم إتمام الذكر، تقبل الله منكم!'),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFinishedCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.military_tech, color: AppColors.accentGold, size: 50),
            SizedBox(height: 10),
            Text(
              'تقبل الله طاعتكم!',
              style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'لقد أتممت بحمد الله جميع ${widget.category.nameAr}. جعلها الله في ميزان حسناتكم وحفظكم بحفظه.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('عودة للرئيسية', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.azkar.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.nameAr)),
        body: const Center(child: Text('لا توجد أذكار في هذا القسم حالياً')),
      );
    }

    final zikr = widget.category.azkar[_currentIndex];
    final totalAzkar = widget.category.azkar.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.nameAr),
        actions: [
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
            tooltip: 'كتم/تشغيل الصوت',
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize == 20.0 ? 24.0 : (_fontSize == 24.0 ? 18.0 : 20.0);
              });
            },
            tooltip: 'تغيير حجم الخط',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. مؤشر التقدم الإجمالي للقسم
            LinearProgressIndicator(
              value: (_currentIndex + 1) / totalAzkar,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              minHeight: 4,
            ),

            // 2. بطاقة عداد التقدم الحالي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الذكر ${_currentIndex + 1} من $totalAzkar',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'التكرار المطلوب: ${zikr.targetCount}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            // 3. مساحة قراءة الذكر التفاعلية
            Expanded(
              child: GestureDetector(
                onTap: () => _onTapZikr(zikr),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: zikr.isCompleted ? AppColors.primaryLight : AppColors.accentGold.withOpacity(0.3),
                      width: zikr.isCompleted ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // نص الذكر القرآني أو النبوي المشكول
                              Text(
                                zikr.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: 2.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // الفضل والسند
                              if (zikr.fadl.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryEmerald.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.stars, size: 16, color: AppColors.warmAmber),
                                          SizedBox(width: 6),
                                          Text(
                                            'الفضل والمصدر:',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        zikr.fadl,
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                      ),
                                      if (zikr.reference.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '• ${zikr.reference}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.primaryEmerald, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // زر العداد الدائري التفاعلي
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: zikr.isCompleted
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [AppColors.primaryEmerald, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryEmerald.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              zikr.isCompleted ? 'تم بحمد الله ✓' : 'انقر للتسبيح',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${zikr.remainingCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. أزرار التنقل (السابق / التالي)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () => setState(() => _currentIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('السابق'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => setState(() => zikr.reset()),
                        tooltip: 'إعادة هذا الذكر',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: zikr.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ الذكر إلى الحافظة')),
                          );
                        },
                        tooltip: 'نسخ الذكر',
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentIndex < totalAzkar - 1
                        ? () => setState(() => _currentIndex++)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('التالي'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
