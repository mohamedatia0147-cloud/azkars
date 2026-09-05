package com.azkar.service;

import com.azkar.dto.QiblaDto;
import org.springframework.stereotype.Service;

@Service
public class QiblaService {

    // الإحداثيات الجغرافية للكعبة المشرفة في مكة المكرمة
    private static final double KAABA_LATITUDE = 21.422487;
    private static final double KAABA_LONGITUDE = 39.826206;
    private static final double EARTH_RADIUS_KM = 6371.0;

    public QiblaDto calculateQibla(double userLat, double userLng) {
        double phiK = Math.toRadians(KAABA_LATITUDE);
        double lambdaK = Math.toRadians(KAABA_LONGITUDE);
        double phi = Math.toRadians(userLat);
        double lambda = Math.toRadians(userLng);

        // حساب زاوية الاتجاه الكروية (Spherical Forward Azimuth)
        double deltaLambda = lambdaK - lambda;
        double y = Math.sin(deltaLambda);
        double x = Math.cos(phi) * Math.tan(phiK) - Math.sin(phi) * Math.cos(deltaLambda);

        double qiblaAngle = Math.toDegrees(Math.atan2(y, x));
        // تحويل النتيجة لمجال [0, 360)
        qiblaAngle = (qiblaAngle + 360.0) % 360.0;
        qiblaAngle = Math.round(qiblaAngle * 100.0) / 100.0;

        // حساب المسافة بالكيلومتر باستخدام قانون هافرسين (Haversine Formula)
        double dLat = phiK - phi;
        double dLng = lambdaK - lambda;
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(phi) * Math.cos(phiK) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distanceKm = Math.round(EARTH_RADIUS_KM * c * 10.0) / 10.0;

        String cardinal = getCardinalDirection(qiblaAngle);

        return QiblaDto.builder()
                .userLatitude(userLat)
                .userLongitude(userLng)
                .kaabaLatitude(KAABA_LATITUDE)
                .kaabaLongitude(KAABA_LONGITUDE)
                .bearingDegrees(qiblaAngle)
                .distanceKilometers(distanceKm)
                .compassDirection(cardinal)
                .build();
    }

    private String getCardinalDirection(double degrees) {
        String[] directions = {"شمال", "شمال شرق", "شرق", "جنوب شرق", "جنوب", "جنوب غرب", "غرب", "شمال غرب"};
        int index = (int) Math.round(((degrees % 360) / 45)) % 8;
        return directions[index];
    }
}
