import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';

class ElectronicTasbeehScreen extends StatefulWidget {
  const ElectronicTasbeehScreen({super.key});

  @override
  State<ElectronicTasbeehScreen> createState() => _ElectronicTasbeehScreenState();
}

class _ElectronicTasbeehScreenState extends State<ElectronicTasbeehScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  int _totalCount = 0;
  int _selectedZikrIndex = 0;
  bool _soundEnabled = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _tasbeehList = [
    {'title': 'سُبْحَانَ اللَّهِ', 'target': 33},
    {'title': 'الْحَمْدُ لِلَّهِ', 'target': 33},
    {'title': 'اللَّهُ أَكْبَرُ', 'target': 34},
    {'title': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 'target': 100},
    {'title': 'لاَ إِلَهَ إِلاَّ اللَّهُ', 'target': 100},
    {'title': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 'target': 100},
    {'title': 'لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ', 'target': 100},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _increment() {
    _animController.forward().then((_) => _animController.reverse());

    setState(() {
      _counter++;
      _totalCount++;
    });

    HapticFeedback.lightImpact();
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    if (_counter >= _target && _target > 0) {
      HapticFeedback.heavyImpact();
      _showTargetDialog();
    }
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('اكتمل الورد!', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        content: Text(
          'أتممت ${_target} تسبيحة بحمد الله.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reset();
            },
            child: const Text('بدء دورة جديدة'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متابعة التسبيح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentZikr = _tasbeehList[_selectedZikrIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('السبحة الإلكترونية'),
        actions: [
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'تصفير العداد',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 1. اختيار الذكر الحالي
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _tasbeehList.length,
                itemBuilder: (context, idx) {
                  final isSelected = idx == _selectedZikrIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_tasbeehList[idx]['title']),
                      selected: isSelected,
                      selectedColor: AppColors.primaryEmerald,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedZikrIndex = idx;
                            _target = _tasbeehList[idx]['target'];
                            _counter = 0;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // 2. بطاقة الذكر ومعدل الإنجاز
            Text(
              currentZikr['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الهدف: $_target | الإجمالي: $_totalCount',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // 3. زر السبحة الدائري التفاعلي الكبير
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: _increment,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF166534),
                        AppColors.primaryEmerald,
                        AppColors.primaryDark,
                      ],
                      center: Alignment(-0.2, -0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.accentGold.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(color: AppColors.accentGold, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_counter',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'انقر هنا',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.accentGoldLight,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 4. أزرار التحكم بالأهداف السريعة (33, 100, حر)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTargetButton('٣٣', 33),
                  _buildTargetButton('١٠٠', 100),
                  _buildTargetButton('مفتوح', 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetButton(String label, int value) {
    final isSelected = _target == value;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryEmerald : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.primaryDark,
        side: BorderSide(
          color: isSelected ? AppColors.primaryEmerald : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          _target = value;
          _counter = 0;
        });
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
