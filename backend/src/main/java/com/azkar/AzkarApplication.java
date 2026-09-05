package com.azkar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AzkarApplication {

    public static void main(String[] args) {
        SpringApplication.run(AzkarApplication.class, args);
        System.out.println("==================================================");
        System.out.println("🕌 تم تشغيل خادم الأذكار والمواقيت الإسلامي بنجاح!");
        System.out.println("📍 REST API Docs & Endpoints: http://localhost:8080/api/categories");
        System.out.println("🗄️ H2 Console: http://localhost:8080/h2-console");
        System.out.println("==================================================");
    }
}
