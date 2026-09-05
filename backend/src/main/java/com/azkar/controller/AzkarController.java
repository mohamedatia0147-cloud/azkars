package com.azkar.controller;

import com.azkar.dto.ApiResponse;
import com.azkar.model.Zikr;
import com.azkar.service.AzkarService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/azkar")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AzkarController {

    private final AzkarService azkarService;

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<ApiResponse<List<Zikr>>> getAzkarByCategoryId(@PathVariable Long categoryId) {
        List<Zikr> list = azkarService.getAzkarByCategoryId(categoryId);
        return ResponseEntity.ok(ApiResponse.ok("تم استرجاع أذكار القسم بنجاح", list));
    }

    @GetMapping("/code/{code}")
    public ResponseEntity<ApiResponse<List<Zikr>>> getAzkarByCategoryCode(@PathVariable String code) {
        List<Zikr> list = azkarService.getAzkarByCategoryCode(code);
        return ResponseEntity.ok(ApiResponse.ok("تم استرجاع أذكار القسم بنجاح", list));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Zikr>>> searchAzkar(@RequestParam("q") String query) {
        List<Zikr> list = azkarService.searchAzkar(query);
        return ResponseEntity.ok(ApiResponse.ok("نتائج البحث", list));
    }

    @GetMapping("/favorites")
    public ResponseEntity<ApiResponse<List<Zikr>>> getFavorites() {
        List<Zikr> list = azkarService.getFavoriteAzkar();
        return ResponseEntity.ok(ApiResponse.ok("الأذكار المفضلة", list));
    }

    @PostMapping("/{id}/favorite")
    public ResponseEntity<ApiResponse<Zikr>> toggleFavorite(@PathVariable Long id) {
        return azkarService.toggleFavorite(id)
                .map(z -> ResponseEntity.ok(ApiResponse.ok("تم تحديث حالة التفضيل بنجاح", z)))
                .orElseGet(() -> ResponseEntity.status(404).body(ApiResponse.error("الذكر غير موجود")));
    }
}
