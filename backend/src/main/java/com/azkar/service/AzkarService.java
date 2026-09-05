package com.azkar.service;

import com.azkar.model.Category;
import com.azkar.model.TasbeehPreset;
import com.azkar.model.Zikr;
import com.azkar.repository.CategoryRepository;
import com.azkar.repository.TasbeehPresetRepository;
import com.azkar.repository.ZikrRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AzkarService {

    private final CategoryRepository categoryRepository;
    private final ZikrRepository zikrRepository;
    private final TasbeehPresetRepository tasbeehPresetRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAllByOrderByOrderIndexAsc();
    }

    public Optional<Category> getCategoryById(Long id) {
        return categoryRepository.findById(id);
    }

    public Optional<Category> getCategoryByCode(String code) {
        return categoryRepository.findByCode(code);
    }

    public List<Zikr> getAzkarByCategoryId(Long categoryId) {
        return zikrRepository.findByCategoryIdOrderByItemOrderAsc(categoryId);
    }

    public List<Zikr> getAzkarByCategoryCode(String code) {
        return zikrRepository.findByCategoryCodeOrderByItemOrderAsc(code);
    }

    public List<Zikr> searchAzkar(String query) {
        if (query == null || query.trim().isEmpty()) {
            return List.of();
        }
        return zikrRepository.searchAzkar(query.trim());
    }

    public List<Zikr> getFavoriteAzkar() {
        return zikrRepository.findByIsFavoriteTrueOrderByItemOrderAsc();
    }

    @Transactional
    public Optional<Zikr> toggleFavorite(Long zikrId) {
        return zikrRepository.findById(zikrId).map(zikr -> {
            boolean current = zikr.getIsFavorite() != null && zikr.getIsFavorite();
            zikr.setIsFavorite(!current);
            return zikrRepository.save(zikr);
        });
    }

    public List<TasbeehPreset> getAllTasbeehPresets() {
        return tasbeehPresetRepository.findAllByOrderByOrderIndexAsc();
    }
}
