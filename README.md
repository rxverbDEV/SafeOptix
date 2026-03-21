# MaintainX

**MaintainX**, Windows için geliştirilmiş açık kaynaklı bir bakım aracıdır.  
Kullanıcıların kendi seçimine göre sistem dosyalarını onarma, disk hatalarını kontrol etme, geçici dosyaları temizleme, başlangıç programlarını yönetme ve daha fazlasını yapmasını sağlar.  
Tamamen **Türkçe** ve **kullanıcı kontrolünde** bir araçtır.

---

## Özellikler

- Sistem dosyalarını onarma (DISM + SFC)  
- Disk hatalarını kontrol etme (CHKDSK)  
- Windows Defender ile tam tarama  
- Geçici dosyaları ve önbelleği temizleme  
- Disk temizleme ve optimize etme  
- Başlangıç uygulamalarını yönetme  
- DNS önbelleğini temizleme  
- Ağ ayarlarını sıfırlama (Winsock, IP reset)  
- Windows güncellemelerini kontrol etme ve yükleme  

---

## Kullanım

1. **PowerShell’i Yönetici olarak açın**  
2. Execution Policy’yi ayarlayın (gerekirse):  

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

3. MaintainX script’ini çalıştırmak için URL kullanın:



irm "https://raw.githubusercontent.com/rxverbDEV/maintainx/main/maintainx.ps1" | iex

4. Açılan GUI’de yapmak istediğiniz işlemleri tikleyin


5. “Başlat” butonuna basın ve işlemlerin tamamlanmasını bekleyin



> ⚠ Not: Bazı işlemler (DISM, CHKDSK, Optimize) admin yetkisi gerektirir.
İşlem tamamlandıktan sonra bilgisayarı yeniden başlatmanız önerilir.




---

Lisans

Bu proje MIT License altında yayınlanmıştır.
Kodunuzu kopyalayabilir, değiştirebilir ve dağıtabilirsiniz.
Orijinal yazarı belirtmeyi unutmayın.


---

Katkıda Bulunma

Kod geliştirme, hata düzeltme veya yeni özellikler eklemek isterseniz Pull Request gönderebilirsiniz.

Tüm katkılar için teşekkür ederiz!



---

Notlar

Proje tamamen açık kaynak ve güvenlidir

Fikir ve yöntemler yaygın olup, kodun tamamı özgün olarak geliştirilmiştir

Türkçe kullanıcı dostu arayüz ile kolay kullanım sağlar
