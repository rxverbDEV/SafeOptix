# MaintainX - Windows Bakım Aracı

![MaintainX Logo](https://via.placeholder.com/300x80?text=MaintainX)

**MaintainX**, Windows için geliştirilmiş **kullanıcı kontrollü bakım aracıdır**.  
Tüm işlemler **seçim ile uygulanır**, maksimum güvenlik ve minimum hata ile tasarlanmıştır.  

---

## 🔹 Öne Çıkan Özellikler
- Sistem dosyalarını onarma (DISM + SFC)  
- Disk hatalarını kontrol etme (CHKDSK)  
- Virüs taraması yapma (Windows Defender)  
- Geçici dosyaları ve önbelleği temizleme  
- Disk temizleme ve optimize etme (TRIM)  
- Başlangıç programlarını yönetme  
- DNS önbelleğini temizleme  
- Internet ayarlarını sıfırlama (Winsock / IP reset)  
- Windows güncellemelerini kontrol etme ve yükleme  

---

## ⚠ Uyarılar ve Güvenlik Önlemleri
1. **Yedekleme Önerisi**  
   - Herhangi bir işlemden önce **sistem geri yükleme noktası** veya önemli dosyalarınızı yedekleyin.  

2. **Admin Yetkisi Gerekliliği**  
   - DISM, SFC, CHKDSK, Optimize-Volume ve güncelleme işlemleri için **PowerShell’i Yönetici olarak çalıştırın**.  

3. **Kullanıcı Kontrolü**  
   - Tüm işlemler **sadece seçilen seçenekler ile çalışır**.  
   - Başlangıç programlarını yalnızca kullanıcı onayı ile değiştirir.  

4. **Hata Yönetimi**  
   - Script tüm işlemleri **try/catch** ile yönetir.  
   - Hatalar **statusBox**’ta gösterilir ve script durmaz.  

5. **Potansiyel Riskler**  
   - CHKDSK uzun sürebilir, işlem sırasında bilgisayarı kapatmamak gerekir.  
   - Disk optimize ve sistem onarım işlemleri nadiren sorun yaratabilir.  
   - Windows Update sırasında internet veya modül hataları olabilir.  

6. **Sorumluluk Reddi**  
   - Bu araç **kullanıcı kendi sorumluluğunda çalıştırır**.  
   - Yanlış kullanım veya sistem hatalarından yazar **sorumlu değildir**.  

---

## 🚀 Kurulum ve Kullanım
1. **PowerShell’i Yönetici olarak açın**  
2. Execution Policy ayarı (gerekirse):

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

3. Scripti çalıştırmak için:



irm "https://raw.githubusercontent.com/<KULLANICI_ADI>/maintainx/main/maintainx.ps1" | iex

4. Açılan GUI’de yapmak istediğiniz işlemleri tikleyin


5. “Başlat” butonuna basın ve işlemlerin tamamlanmasını bekleyin



> 💡 Tüm adımlar GUI üzerinden takip edilebilir, statusBox ilerlemeyi gösterir.




---

🎨 Tasarım ve Kullanıcı Deneyimi

Modern Dark Mode arayüz

Profesyonel ve okunaklı fontlar (Segoe UI)

StatusBox ile gerçek zamanlı işlem bilgisi

Panel ve checkbox düzeni kullanıcı dostu

Mesaj kutuları ile işlem tamamlandığında bilgilendirme



---

📦 Lisans

Bu proje MIT License altında açık kaynak olarak yayınlanmıştır.

Kod üzerinde değişiklik yapabilir, paylaşabilir ve dağıtabilirsiniz.

Orijinal yazarı belirtmeniz yeterlidir.



---

🤝 Katkıda Bulunma

Hata düzeltme, geliştirme veya yeni özellik eklemek için Pull Request gönderebilirsiniz.

Tüm katkılar teşekkürle karşılanır.



---

> ⚡ Not: MaintainX hâlâ geliştirilen bir araçtır. Lütfen tüm işlemleri dikkatle ve kendi sorumluluğunuzda uygulayın.
