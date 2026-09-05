package com.azkar.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QiblaDto {
    private double userLatitude;
    private double userLongitude;
    private double kaabaLatitude;
    private double kaabaLongitude;
    private double bearingDegrees;
    private double distanceKilometers;
    private String compassDirection;
}
