package com.azkar.controller;

import com.azkar.dto.ApiResponse;
import com.azkar.model.Category;
import com.azkar.service.AzkarService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CategoryController {

    private final AzkarService azkarService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Category>>> getAllCategories() {
        List<Category> categories = azkarService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.ok("تم استرجاع الأقسام بنجاح", categories));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Category>> getCategoryById(@PathVariable Long id) {
        return azkarService.getCategoryById(id)
                .map(cat -> ResponseEntity.ok(ApiResponse.ok("تم استرجاع القسم بنجاح", cat)))
                .orElseGet(() -> ResponseEntity.status(404).body(ApiResponse.error("القسم غير موجود")));
    }
}
