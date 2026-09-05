package com.azkar.controller;

import com.azkar.dto.ApiResponse;
import com.azkar.model.TasbeehPreset;
import com.azkar.service.AzkarService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasbeeh")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TasbeehController {

    private final AzkarService azkarService;

    @GetMapping("/presets")
    public ResponseEntity<ApiResponse<List<TasbeehPreset>>> getPresets() {
        List<TasbeehPreset> presets = azkarService.getAllTasbeehPresets();
        return ResponseEntity.ok(ApiResponse.ok("تم استرجاع أوراد ومسبحات السبحة بنجاح", presets));
    }
}
