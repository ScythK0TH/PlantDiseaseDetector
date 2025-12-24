# PlantDiseaseDetector

**PlantDiseaseDetector** คือแอปพลิเคชันบนมือถือที่พัฒนาด้วย **Flutter** สำหรับตรวจจับและวินิจฉัยโรคพืชผ่านการประมวลผลภาพ (Image Processing) และ Machine Learning ช่วยให้เกษตรกรหรือผู้สนใจสามารถระบุโรคของพืชได้เบื้องต้นผ่านกล้องมือถือหรือรูปภาพในอัลบั้ม

## คุณสมบัติ (Features)

* **ถ่ายภาพ/เลือกรูปภาพ:** รองรับการนำเข้าภาพจากการถ่ายสดผ่านกล้อง หรือเลือกจากแกลเลอรีในเครื่อง
* **ระบบตรวจจับโรค:** วิเคราะห์ภาพใบพืชเพื่อระบุชนิดของโรค (หรือความปกติ) โดยใช้โมเดล Machine Learning (TensorFlow Lite)
* **แสดงผลลัพธ์:** แสดงชื่อโรคและความน่าจะเป็น (Confidence Score) ของผลลัพธ์ที่ได้
* **Multi-Device Support:** รองรับการทำงานบนอุปกรณ์ Android ที่หลากหลาย ครอบคลุมทั้งหน้าจอขนาดเล็กและหน้าจอขนาดใหญ่ (Tablets)

## เทคโนโลยีที่ใช้ (Tech Stack)

* **Language:** Dart
* **Framework:** Flutter
* **Machine Learning:** TensorFlow Lite
* **Architecture:** MVC หรือ MVVM

## การติดตั้ง (Installation)

1.  **Clone โปรเจกต์นี้**
    ```bash
    git clone https://github.com/ScythK0TH/PlantDiseaseDetector.git
    cd PlantDiseaseDetector
    ```

2.  **ติดตั้ง Dependencies**
    ```bash
    flutter pub get
    ```

3.  **รันแอปพลิเคชัน**
    เชื่อมต่ออุปกรณ์มือถือ หรือเปิด Emulator แล้วใช้คำสั่ง:
    ```bash
    flutter run
    ```

## วิธีการใช้งาน (Usage)

1.  เปิดแอปพลิเคชันขึ้นมา
2.  กดปุ่ม **ถ่ายภาพ** หรือ **เลือกรูปภาพ** เพื่อนำรูปใบพืชที่ต้องการตรวจสอบเข้ามา
3.  รอให้ระบบประมวลผลสักครู่
4.  อ่านผลลัพธ์การวินิจฉัยที่หน้าจอ

## ผู้จัดทำ (Contributors)

ขอขอบคุณผู้มีส่วนร่วมในการพัฒนาโปรเจกต์นี้:

* [@ScythK0TH](https://github.com/ScythK0TH)
* [@yanapatt](https://github.com/yanapatt)
* [@ThunwaratK](https://github.com/ThunwaratK)

## ใบอนุญาต (License)

โปรเจกต์นี้ได้รับอนุญาตให้ใช้งานภายใต้ **MIT License** - อ่านรายละเอียดเพิ่มเติมได้ที่ไฟล์ [LICENSE](LICENSE)

---
*หมายเหตุ: โปรเจกต์นี้เป็นส่วนหนึ่งของการศึกษา/พัฒนา*
