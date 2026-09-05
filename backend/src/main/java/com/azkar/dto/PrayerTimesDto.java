package com.azkar.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PrayerTimesDto {
    private LocalDate date;
    private String hijriDate;
    private double latitude;
    private double longitude;
    private String timezone;
    private String calculationMethod;

    private String fajr;
    private String sunrise;
    private String dhuhr;
    private String asr;
    private String maghrib;
    private String isha;

    private String currentPrayer;
    private String nextPrayer;
    private String timeRemaining;
    private double qiblaAngle;
    private Map<String, String> rawTimes;
}
