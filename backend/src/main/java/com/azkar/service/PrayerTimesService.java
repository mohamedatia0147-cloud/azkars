package com.azkar.service;

import com.azkar.dto.PrayerTimesDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.chrono.HijrahDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PrayerTimesService {

    private final QiblaService qiblaService;

    public enum CalculationMethod {
        EGYPTIAN(19.5, 17.5),
        UMM_AL_QURA(18.5, 0.0), // Isha is 90 mins after Maghrib
        MUSLIM_WORLD_LEAGUE(18.0, 17.0),
        ISNA(15.0, 15.0),
        KARACHI(18.0, 18.0);

        public final double fajrAngle;
        public final double ishaAngle;

        CalculationMethod(double fajrAngle, double ishaAngle) {
            this.fajrAngle = fajrAngle;
            this.ishaAngle = ishaAngle;
        }
    }

    public PrayerTimesDto calculatePrayerTimes(double latitude, double longitude, LocalDate date, String methodName) {
        if (date == null) {
            date = LocalDate.now();
        }

        CalculationMethod method = CalculationMethod.MUSLIM_WORLD_LEAGUE;
        if (methodName != null) {
            try {
                method = CalculationMethod.valueOf(methodName.toUpperCase());
            } catch (Exception ignored) {}
        }

        // Calculate Day of Year (Julian day approximation)
        int dayOfYear = date.getDayOfYear();
        double d = dayOfYear + ((12.0 - (longitude / 15.0)) / 24.0);

        // Sun's mean anomaly
        double M = Math.toRadians((357.529 + 0.98560028 * d) % 360.0);
        // Sun's mean longitude
        double L = Math.toRadians((280.459 + 0.98564736 * d) % 360.0);
        // Sun's apparent longitude
        double lambda = L + Math.toRadians(1.915 * Math.sin(M) + 0.020 * Math.sin(2 * M));
        // Obliquity of the ecliptic
        double epsilon = Math.toRadians(23.439 - 0.00000036 * d);

        // Sun's declination
        double sinDelta = Math.sin(epsilon) * Math.sin(lambda);
        double delta = Math.asin(sinDelta);

        // Equation of time in minutes
        double y = Math.tan(epsilon / 2) * Math.tan(epsilon / 2);
        double eot = 4.0 * Math.toDegrees(y * Math.sin(2 * L) - 2 * 0.0167 * Math.sin(M) + 4 * 0.0167 * y * Math.sin(M) * Math.cos(2 * L) - 0.5 * y * y * Math.sin(4 * L) - 1.25 * 0.0167 * 0.0167 * Math.sin(2 * M));

        // Solar Noon (Dhuhr) in local solar hours
        double timezoneOffset = Math.round(longitude / 15.0);
        double solarNoonHours = 12.0 + timezoneOffset - (longitude / 15.0) - (eot / 60.0);

        double phi = Math.toRadians(latitude);

        // Helper to calculate hour angle
        double fajrHourAngle = calculateHourAngle(-Math.toRadians(method.fajrAngle), phi, delta);
        double sunriseHourAngle = calculateHourAngle(-Math.toRadians(0.833), phi, delta);
        double asrHourAngle = calculateAsrHourAngle(1.0, phi, delta); // Standard Shafi'i/Hanbali/Maliki
        double ishaHourAngle = calculateHourAngle(-Math.toRadians(method.ishaAngle > 0 ? method.ishaAngle : 18.0), phi, delta);

        double fajrTime = solarNoonHours - (fajrHourAngle / 15.0);
        double sunriseTime = solarNoonHours - (sunriseHourAngle / 15.0);
        double dhuhrTime = solarNoonHours + (2.0 / 60.0); // +2 mins safety after zenith
        double asrTime = solarNoonHours + (asrHourAngle / 15.0);
        double maghribTime = solarNoonHours + (sunriseHourAngle / 15.0) + (2.0 / 60.0);
        double ishaTime = (method == CalculationMethod.UMM_AL_QURA) 
                ? maghribTime + 1.5 
                : solarNoonHours + (ishaHourAngle / 15.0);

        String fajrStr = formatHoursToTime(fajrTime);
        String sunriseStr = formatHoursToTime(sunriseTime);
        String dhuhrStr = formatHoursToTime(dhuhrTime);
        String asrStr = formatHoursToTime(asrTime);
        String maghribStr = formatHoursToTime(maghribTime);
        String ishaStr = formatHoursToTime(ishaTime);

        // Hijri date conversion
        String hijriDateStr = "";
        try {
            HijrahDate hijrahDate = HijrahDate.from(date);
            DateTimeFormatter hijriFormatter = DateTimeFormatter.ofPattern("dd MMMM yyyy", new Locale("ar"));
            hijriDateStr = hijrahDate.format(hijriFormatter) + " هـ";
        } catch (Exception e) {
            hijriDateStr = "1448 هـ";
        }

        // Qibla angle
        double qiblaAngle = qiblaService.calculateQibla(latitude, longitude).getBearingDegrees();

        // Calculate next prayer & remaining time
        LocalTime now = LocalTime.now();
        LocalTime tFajr = parseTime(fajrStr);
        LocalTime tSunrise = parseTime(sunriseStr);
        LocalTime tDhuhr = parseTime(dhuhrStr);
        LocalTime tAsr = parseTime(asrStr);
        LocalTime tMaghrib = parseTime(maghribStr);
        LocalTime tIsha = parseTime(ishaStr);

        String currentPrayer = "العشاء";
        String nextPrayer = "الفجر";
        LocalTime targetTime = tFajr;

        if (now.isBefore(tFajr)) {
            currentPrayer = "قيام الليل";
            nextPrayer = "الفجر";
            targetTime = tFajr;
        } else if (now.isBefore(tSunrise)) {
            currentPrayer = "الفجر";
            nextPrayer = "الشروق";
            targetTime = tSunrise;
        } else if (now.isBefore(tDhuhr)) {
            currentPrayer = "الضحى";
            nextPrayer = "الظهر";
            targetTime = tDhuhr;
        } else if (now.isBefore(tAsr)) {
            currentPrayer = "الظهر";
            nextPrayer = "العصر";
            targetTime = tAsr;
        } else if (now.isBefore(tMaghrib)) {
            currentPrayer = "العصر";
            nextPrayer = "المغرب";
            targetTime = tMaghrib;
        } else if (now.isBefore(tIsha)) {
            currentPrayer = "المغرب";
            nextPrayer = "العشاء";
            targetTime = tIsha;
        }

        long diffMinutes = java.time.Duration.between(now, targetTime).toMinutes();
        if (diffMinutes < 0) {
            diffMinutes += 24 * 60;
        }
        long hours = diffMinutes / 60;
        long minutes = diffMinutes % 60;
        String remainingStr = String.format("%02d:%02d", hours, minutes);

        Map<String, String> rawTimes = new HashMap<>();
        rawTimes.put("Fajr", fajrStr);
        rawTimes.put("Sunrise", sunriseStr);
        rawTimes.put("Dhuhr", dhuhrStr);
        rawTimes.put("Asr", asrStr);
        rawTimes.put("Maghrib", maghribStr);
        rawTimes.put("Isha", ishaStr);

        return PrayerTimesDto.builder()
                .date(date)
                .hijriDate(hijriDateStr)
                .latitude(latitude)
                .longitude(longitude)
                .timezone("UTC+" + (int)timezoneOffset)
                .calculationMethod(method.name())
                .fajr(fajrStr)
                .sunrise(sunriseStr)
                .dhuhr(dhuhrStr)
                .asr(asrStr)
                .maghrib(maghribStr)
                .isha(ishaStr)
                .currentPrayer(currentPrayer)
                .nextPrayer(nextPrayer)
                .timeRemaining(remainingStr)
                .qiblaAngle(qiblaAngle)
                .rawTimes(rawTimes)
                .build();
    }

    private double calculateHourAngle(double alpha, double phi, double delta) {
        double cosOmega = (Math.sin(alpha) - Math.sin(phi) * Math.sin(delta)) / (Math.cos(phi) * Math.cos(delta));
        if (cosOmega > 1.0) cosOmega = 1.0;
        if (cosOmega < -1.0) cosOmega = -1.0;
        return Math.toDegrees(Math.acos(cosOmega));
    }

    private double calculateAsrHourAngle(double shadowFactor, double phi, double delta) {
        double alpha = -Math.atan(1.0 / (shadowFactor + Math.tan(Math.abs(phi - delta))));
        return calculateHourAngle(alpha, phi, delta);
    }

    private String formatHoursToTime(double decimalHours) {
        decimalHours = (decimalHours % 24 + 24) % 24;
        int hours = (int) decimalHours;
        int minutes = (int) Math.round((decimalHours - hours) * 60);
        if (minutes == 60) {
            hours = (hours + 1) % 24;
            minutes = 0;
        }
        return String.format(Locale.US, "%02d:%02d", hours, minutes);
    }

    private LocalTime parseTime(String timeStr) {
        try {
            return LocalTime.parse(timeStr);
        } catch (Exception e) {
            return LocalTime.of(12, 0);
        }
    }
}
