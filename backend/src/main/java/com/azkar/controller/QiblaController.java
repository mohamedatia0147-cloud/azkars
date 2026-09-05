package com.azkar.controller;

import com.azkar.dto.ApiResponse;
import com.azkar.dto.QiblaDto;
import com.azkar.service.QiblaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/qibla")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class QiblaController {

    private final QiblaService qiblaService;

    @GetMapping
    public ResponseEntity<ApiResponse<QiblaDto>> getQiblaDirection(
            @RequestParam(name = "lat") double latitude,
            @RequestParam(name = "lng") double longitude
    ) {
        QiblaDto qibla = qiblaService.calculateQibla(latitude, longitude);
        return ResponseEntity.ok(ApiResponse.ok("تم حساب اتجاه القبلة بنجاح", qibla));
    }
}
