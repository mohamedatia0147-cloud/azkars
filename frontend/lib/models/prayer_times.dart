class PrayerTimesModel {
  final String date;
  final String hijriDate;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String currentPrayer;
  final String nextPrayer;
  final String nextPrayerTime;
  final String timeRemaining;
  final double qiblaAngle;

  PrayerTimesModel({
    required this.date,
    required this.hijriDate,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.timeRemaining,
    required this.qiblaAngle,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final nextP = json['nextPrayer'] ?? 'الفجر';
    final fajrVal = json['fajr'] ?? '04:18';
    final dhuhrVal = json['dhuhr'] ?? '11:58';
    final asrVal = json['asr'] ?? '15:28';
    final maghribVal = json['maghrib'] ?? '18:14';
    final ishaVal = json['isha'] ?? '19:33';
    final sunriseVal = json['sunrise'] ?? '05:44';

    String computedNextTime = fajrVal;
    if (nextP == 'الفجر') computedNextTime = fajrVal;
    else if (nextP == 'الشروق') computedNextTime = sunriseVal;
    else if (nextP == 'الظهر') computedNextTime = dhuhrVal;
    else if (nextP == 'العصر') computedNextTime = asrVal;
    else if (nextP == 'المغرب') computedNextTime = maghribVal;
    else if (nextP == 'العشاء') computedNextTime = ishaVal;

    return PrayerTimesModel(
      date: json['date']?.toString() ?? '',
      hijriDate: json['hijriDate'] ?? json['hijri_date'] ?? '٢٣ ربيع الأول ١٤٤٨ هـ',
      fajr: fajrVal,
      sunrise: sunriseVal,
      dhuhr: dhuhrVal,
      asr: asrVal,
      maghrib: maghribVal,
      isha: ishaVal,
      currentPrayer: json['currentPrayer'] ?? 'الظهر',
      nextPrayer: nextP,
      nextPrayerTime: json['nextPrayerTime'] ?? computedNextTime,
      timeRemaining: json['timeRemaining'] ?? '01:45:00',
      qiblaAngle: (json['qiblaAngle'] as num?)?.toDouble() ?? 136.5,
    );
  }
}
