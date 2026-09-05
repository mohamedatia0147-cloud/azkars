-- =======================================================
-- تطبيق الأذكار والأدعية الإسلامي - مخطط قاعدة البيانات
-- Islamic Azkar & Duas Application - Database Schema
-- Compatible with: PostgreSQL, MySQL, H2, SQLite
-- =======================================================

-- 1. جدول تصنيفات وأقسام الأذكار
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description VARCHAR(255),
    icon VARCHAR(50) DEFAULT 'bookmark',
    color_hex VARCHAR(20) DEFAULT '#0A5C36',
    order_index INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. جدول الأذكار والأدعية
CREATE TABLE IF NOT EXISTS azkar (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    item_order INT DEFAULT 0,
    text_ar TEXT NOT NULL,
    translation_en TEXT,
    target_count INT DEFAULT 1,
    fadl_virtue TEXT,
    reference_sanad VARCHAR(255),
    audio_url VARCHAR(255),
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_azkar_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- 3. جدول إحصائيات وأوراد السبحة الإلكترونية
CREATE TABLE IF NOT EXISTS tasbeeh_presets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    target_count INT DEFAULT 33,
    virtue VARCHAR(255),
    order_index INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tasbeeh_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    preset_id BIGINT,
    count_performed INT NOT NULL DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tasbeeh_preset FOREIGN KEY (preset_id) REFERENCES tasbeeh_presets(id) ON DELETE SET NULL
);

-- إنشاء الفهارس لتحسين سرعة الاستعلام والبحث
CREATE INDEX IF NOT EXISTS idx_azkar_category ON azkar(category_id);
CREATE INDEX IF NOT EXISTS idx_azkar_order ON azkar(item_order);
CREATE INDEX IF NOT EXISTS idx_categories_code ON categories(code);
