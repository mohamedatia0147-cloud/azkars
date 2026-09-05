package com.azkar.repository;

import com.azkar.model.TasbeehPreset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TasbeehPresetRepository extends JpaRepository<TasbeehPreset, Long> {
    List<TasbeehPreset> findAllByOrderByOrderIndexAsc();
}
