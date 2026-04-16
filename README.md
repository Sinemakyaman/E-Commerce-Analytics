# Olist E-Ticaret Veri Analizi ve Pipeline Projesi

Bu proje, Brezilya merkezli Olist e-ticaret verilerini kullanarak uçtan uca bir veri analizi ve veri  mühendisliği süreci sunar.

## 📁 Proje Yapısı
- **data/**: Ham veri dosyaları.
- **notebooks/**: Veri keşfi (EDA) ve SQL analizleri.
- **src/**: Veri işleme (ETL) süreçleri için Python kodları.
- **outputs/**: Temizlenmiş veri ve analiz çıktıları.

## 🛠️ Kullanılan Teknolojiler
- **Python** (Pandas, Matplotlib, Seaborn)
- **PostgreSQL** (SQLAlchemy ile entegrasyon)
- **PySpark** (Gelecek aşama)

## 🚀 Analiz Özeti
- Siparişlerin teslimat süreleri (`delivery_time`) ve gecikme oranları (`delay`) analiz edildi.
- Eyalet bazlı lojistik performans raporları oluşturuldu.
- Müşteri memnuniyeti ile teslimat hızı arasındaki korelasyon incelendi.
-Aylık Gelir Trendi ve Büyüme Analizi,zaman içindeki satış trendine bakıldı.
-Kargo ücretlerinin teslimat sürelerine etkisi olup olmadığı sorgulandı.
