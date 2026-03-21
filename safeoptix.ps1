Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM (Modern Dark Tasarım) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix - Premium Sistem Bakımı"
$form.Size = New-Object System.Drawing.Size(650, 950)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#0F0F13" # Hafif mavimsi çok koyu gri (Premium Dark)

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "LightGray"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== BAŞLIK VE ALT BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SAFEOPTIX"
$title.Font = New-Object System.Drawing.Font("Segoe UI Black", 32, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.TextAlign = "BottomCenter"
$title.Size = New-Object System.Drawing.Size(650, 60)
$title.Location = New-Object System.Drawing.Point(0, 5)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "PROFESYONEL SİSTEM OPTİMİZASYON ARACI"
$subtitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$subtitle.ForeColor = "#888888"
$subtitle.TextAlign = "TopCenter"
$subtitle.Size = New-Object System.Drawing.Size(650, 20)
$subtitle.Location = New-Object System.Drawing.Point(0, 65)
$form.Controls.Add($subtitle)

# ==================== SEÇENEK PANELİ (Hafif Aydınlık Katman) ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(580, 500)
$panel.Location = New-Object System.Drawing.Point(30, 100)
$panel.BackColor = "#18181C" # Formdan bir tık açık
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# ==================== CHECKBOX OLUŞTURUCU (Flat Stil) ====================
$y = 20
function Add-ModernCheck ($text, $isBold = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "  " + $text # Metinle kutu arası boşluk
    $cb.ForeColor = "#E0E0E0"
    $cb.FlatStyle = "Flat" # Modern, düz kutu tasarımı
    $cb.FlatAppearance.CheckedBackColor = "#0A84FF"
    if($isBold) { 
        $cb.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10) 
        $cb.ForeColor = "#0A84FF" # Önerilen ayarı renklendir
    } else {
        $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    }
    $cb.Location = New-Object System.Drawing.Point(25, $script:y)
    $cb.Size = New-Object System.Drawing.Size(530, 32)
    $panel.Controls.Add($cb)
    $script:y += 38
    return $cb
}

$cbRestore = Add-ModernCheck "Geri Yükleme Noktası Oluştur (Şiddetle Önerilir)" $true

$items = @(
    "Sistem dosyalarını onar (SFC & DISM)",
    "Disk hatalarını kontrol et (Chkdsk)",
    "Virüs taraması yap (Tam Tarama)",
    "Geçici dosyaları temizle (Temp, Prefetch)",
    "Disk temizleme (Sistem Atıkları)",
    "Diski optimize et (Trim)",
    "Başlangıç programlarını düzenle",
    "DNS önbelleğini temizle",
    "İnternet ayarlarını sıfırla",
    "Güncellemeleri kontrol et"
)

$boxes = @()
foreach($i in $items){ $boxes += Add-ModernCheck $i }

# ==================== PROGRESS BAR & YÜZDE ====================
$lblPercent = New-Object System.Windows.Forms.Label
$lblPercent.Text = "%0"
$lblPercent.ForeColor = "#0A84FF"
$lblPercent.Font = New-Object System.Drawing.Font("Segoe UI Black", 14, [System.Drawing.FontStyle]::Bold)
$lblPercent.TextAlign = "MiddleRight"
$lblPercent.Size = New-Object System.Drawing.Size(100, 30)
$lblPercent.Location = New-Object System.Drawing.Point(510, 610)
$form.Controls.Add($lblPercent)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(580, 15)
$progressBar.Location = New-Object System.Drawing.Point(30, 645)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU (Hover Efektli) ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "SİSTEMİ OPTİMİZE ET"
$run.Size = New-Object System.Drawing.Size(260, 55)
$run.Location = New-Object System.Drawing.Point(195, 675)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# Hover Efektleri
$run.Add_MouseEnter({ $run.BackColor = "#0066CC" }) # Üstüne gelince koyulaşır
$run.Add_MouseLeave({ $run.BackColor = "#0A84FF" }) # Gidince eski haline döner

# ==================== CONSOLE LOG (Matris Vibe) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(580, 150)
$statusBox.Location = New-Object System.Drawing.Point(30, 745)
$statusBox.BackColor = "#050505" # Tam siyah
$statusBox.ForeColor = "#00FF00"
$statusBox.ReadOnly = $true
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($statusBox)

# ==================== STARTUP SEC (Orijinal Fonksiyon) ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }
    
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"
    $f.Size = New-Object System.Drawing.Size(450, 400)
    $f.StartPosition = "CenterScreen"
    $f.BackColor = "#18181C"
    $f.FormBorderStyle = 'FixedDialog'

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Size = New-Object System.Drawing.Size(400, 250)
    $list.Location = New-Object System.Drawing.Point(20, 20)
    $list.BackColor = "#050505"
    $list.ForeColor = "White"
    $list.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    foreach($a in $apps){ $list.Items.Add($a.Name) | Out-Null }
    $f.Controls.Add($list)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Seçilenleri Kapat"
    $ok.Size = New-Object System.Drawing.Size(150, 40)
    $ok.Location = New-Object System.Drawing.Point(140, 290)
    $ok.BackColor = "#0A84FF"
    $ok.ForeColor = "White"
    $ok.FlatStyle = "Flat"
    $ok.FlatAppearance.BorderSize = 0
    $f.Controls.Add($ok)

    $sec = @()
    $ok.Add_Click({
        foreach($i in $list.CheckedItems){ $sec += $i }
        $f.Close()
    })
    $f.ShowDialog() | Out-Null
    return $sec
}

# ==================== ÇALIŞTIRMA MANTIĞI ====================
$run.Add_Click({
    # Seçilenleri bir listeye alalım
    $selectedTaskNames = @()
    if($cbRestore.Checked){ $selectedTaskNames += "Geri Yükleme Noktası Oluştur" }
    foreach($cb in $boxes){
        if($cb.Checked){ $selectedTaskNames += $cb.Text.Trim() } # Başındaki boşlukları trim ile alıyoruz
    }

    if($selectedTaskNames.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Lütfen yapılacak en az bir bakım işlemi seçin!", "Uyarı", 0, 48)
        return
    }

    # == KURAL 1: BAŞLAT TUŞUNA BASINCA SEÇİMLER SIFIRLANSIN ==
    $cbRestore.Checked = $false
    foreach($cb in $boxes){ $cb.Checked = $false }

    $run.Enabled = $false
    $run.Text = "İŞLEM YAPILIYOR..."
    $run.BackColor = "#333333" # İşlem sırasında gri olur
    $statusBox.Clear()
    $progressBar.Value = 0
    $lblPercent.Text = "%0"

    $taskCount = $selectedTaskNames.Count
    $current = 0

    Log "SafeOptix Optimizasyon Motoru Başlatıldı..." "#0A84FF"

    foreach($taskName in $selectedTaskNames){
        $current++
        $percent = [int](($current / $taskCount) * 100)
        
        # UI Güncelleme
        $progressBar.Value = $percent
        $lblPercent.Text = "%$percent"
        Log "▶ $taskName" "White"

        try{
            # İsimleri CheckBox textleri ile tam eşleştiriyoruz
            if($taskName -like "*Geri Yükleme*"){
                Checkpoint-Computer -Description "SafeOptix Öncesi Bakım" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                Log "✔ Geri yükleme noktası oluşturuldu" "#00FF00"
            }
            elseif($taskName -like "*Sistem dosyalarını onar*"){
                DISM /Online /Cleanup-Image /RestoreHealth | Out-Null
                sfc /scannow | Out-Null
                Log "✔ Sistem dosyaları onarıldı" "#00FF00"
            }
            elseif($taskName -like "*Disk hatalarını kontrol et*"){
                $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                foreach($d in $drives){
                    chkdsk $d.DriveLetter /f /r /x | Out-Null
                    Log "✔ Disk $($d.DriveLetter) kontrol edildi" "#00FF00"
                }
            }
            elseif($taskName -like "*Virüs taraması yap*"){ 
                Start-MpScan -ScanType FullScan | Out-Null
                Log "✔ Virüs taraması tamamlandı" "#00FF00" 
            }
            elseif($taskName -like "*Geçici dosyaları temizle*"){
                $paths = @("$env:TEMP","C:\Windows\Temp","C:\Windows\Prefetch","$env:USERPROFILE\Recent")
                foreach($p in $paths){
                    if(Test-Path $p){
                        Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                            try{ Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop } catch{}
                        }
                    }
                }
                Log "✔ Geçici dosyalar temizlendi" "#00FF00"
            }
            elseif($taskName -like "*Disk temizleme*"){ 
                Log "⚠ Disk temizleme geçici dosyalar ile birleşik çalışır" "#FFA500" 
            }
            elseif($taskName -like "*Diski optimize et*"){
                $vols = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                foreach($v in $vols){ 
                    try{ Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim | Out-Null } catch{} 
                }
                Log "✔ Disk optimize edildi" "#00FF00"
            }
            elseif($taskName -like "*Başlangıç programlarını düzenle*"){
                $sec = StartupSec
                foreach($s in $sec){ 
                    try{ Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance } catch{} 
                }
                Log "✔ Başlangıç programları düzenlendi" "#00FF00"
            }
            elseif($taskName -like "*DNS önbelleğini temizle*"){ 
                ipconfig /flushdns | Out-Null
                Log "✔ DNS önbelleği temizlendi" "#00FF00" 
            }
            elseif($taskName -like "*İnternet ayarlarını sıfırla*"){ 
                netsh winsock reset | Out-Null
                netsh int ip reset | Out-Null
                Log "✔ İnternet ayarları sıfırlandı" "#00FF00" 
            }
            elseif($taskName -like "*Güncellemeleri kontrol et*"){
                try{
                    Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                    Import-Module PSWindowsUpdate
                    Get-WindowsUpdate -AcceptAll -Install | Out-Null
                }catch{}
                Log "✔ Güncellemeler kontrol edildi" "#00FF00"
            }
        }catch{
            Log "❌ $taskName sırasında hata oluştu" "#FF0000"
        }
    }

    Log "✅ TÜM İŞLEMLER TAMAMLANDI" "#0A84FF"
    [System.Windows.Forms.MessageBox]::Show("Sistem Optimizasyonu Başarıyla Tamamlandı!", "SafeOptix", 0, 64)

    # == KURAL 2: İŞLEM BİTİNCE PROGRESS BAR VE YÜZDE SIFIRLANSIN ==
    $progressBar.Value = 0
    $lblPercent.Text = "%0"
    $run.Text = "SİSTEMİ OPTİMİZE ET"
    $run.BackColor = "#0A84FF"
    $run.Enabled = $true
})

# Formu Çalıştır
[void]$form.ShowDialog()
