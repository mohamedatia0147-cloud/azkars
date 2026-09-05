package com.azkar.controller;

import com.azkar.dto.ApiResponse;
import com.azkar.dto.PrayerTimesDto;
import com.azkar.service.PrayerTimesService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/prayer-times")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PrayerTimesController {

    private final PrayerTimesService prayerTimesService;

    @GetMapping
    public ResponseEntity<ApiResponse<PrayerTimesDto>> getPrayerTimes(
            @RequestParam(name = "lat", defaultValue = "30.0444") double latitude, // الافتراضي: القاهرة
            @RequestParam(name = "lng", defaultValue = "31.2357") double longitude,
            @RequestParam(name = "date", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(name = "method", defaultValue = "MUSLIM_WORLD_LEAGUE") String method
    ) {
        if (date == null) {
            date = LocalDate.now();
        }
        PrayerTimesDto times = prayerTimesService.calculatePrayerTimes(latitude, longitude, date, method);
        return ResponseEntity.ok(ApiResponse.ok("تم حساب مواقيت الصلاة بنجاح", times));
    }
}
