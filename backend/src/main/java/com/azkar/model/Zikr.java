package com.azkar.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "azkar")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Zikr {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    @JsonBackReference
    private Category category;

    @Column(name = "item_order")
    private Integer itemOrder;

    @Column(name = "text_ar", nullable = false, columnDefinition = "TEXT")
    private String textAr;

    @Column(name = "translation_en", columnDefinition = "TEXT")
    private String translationEn;

    @Column(name = "target_count")
    private Integer targetCount;

    @Column(name = "fadl_virtue", columnDefinition = "TEXT")
    private String fadlVirtue;

    @Column(name = "reference_sanad")
    private String referenceSanad;

    @Column(name = "audio_url")
    private String audioUrl;

    @Column(name = "is_favorite")
    private Boolean isFavorite;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (targetCount == null) {
            targetCount = 1;
        }
        if (isFavorite == null) {
            isFavorite = false;
        }
    }
}
