package com.azkar.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "tasbeeh_presets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TasbeehPreset {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(name = "target_count")
    private Integer targetCount;

    @Column(length = 255)
    private String virtue;

    @Column(name = "order_index")
    private Integer orderIndex;
}
