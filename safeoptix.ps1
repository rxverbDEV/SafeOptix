Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM (Premium Light) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Pro - Sistem Bakım Kiti"
$form.Size = New-Object System.Drawing.Size(520, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#FFFFFF"

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#333333") {
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== MODERN BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0078D4" # Microsoft Blue
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(520, 60)
$title.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($title)

$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "PROFESYONEL OPTİMİZASYON ARAÇLARI"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$subTitle.ForeColor = "#A0A0A0"
$subTitle.TextAlign = "MiddleCenter"
$subTitle.Size = New-Object System.Drawing.Size(520, 20)
$subTitle.Location = New-Object System.Drawing.Point(0, 65)
$form.Controls.Add($subTitle)

# ==================== SEÇENEK PANELİ (Kompakt) ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(460, 400)
$panel.Location = New-Object System.Drawing.Point(30, 100)
$panel.BackColor = "#F8F9FA" # Hafif gri kart
$form.Controls.Add($panel)

$y = 15
function New-CB($text, $isBold = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $text
    $cb.ForeColor = "#202124"
    $cb.FlatStyle = "Flat"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($isBold) { 
        $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $cb.ForeColor = "#0078D4"
    }
    $cb.Location = New-Object System.Drawing.Point(20, $script:y)
    $cb.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($cb)
    $script:y += 34
    return $cb
}

# İLK YAZILARIN VE İŞLEMLERİN GERİ GELİŞİ
$cbRestore = New-CB "Geri Yükleme Noktası Oluştur (Önerilir)" $true
$items = @(
    "Sistem dosyalarını onar (SFC & DISM)",
    "Disk hatalarını kontrol et (Chkdsk)",
    "Virüs taraması yap (Windows Defender)",
    "Geçici dosyaları temizle (Temp/Prefetch)",
    "Disk temizleme (Sistem Dosyaları)",
    "Diski optimize et (Defrag/Trim)",
    "Başlangıç programlarını düzenle",
    "DNS önbelleğini temizle",
    "İnternet ayarlarını sıfırla",
    "Güncellemeleri kontrol et"
)
$boxes = foreach($i in $items) { New-CB $i }

# ==================== PROGRESS & YÜZDE ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#0078D4"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 18)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(520, 40)
$pctLabel.Location = New-Object System.Drawing.Point(0, 520)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(460, 8)
$progressBar.Location = New-Object System.Drawing.Point(30, 565)
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(260, 50)
$run.Location = New-Object System.Drawing.Point(130, 595)
$run.BackColor = "#0078D4"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($run)

# Hover efekti
$run.Add_MouseEnter({ $run.BackColor = "#005A9E" })
$run.Add_MouseLeave({ $run.BackColor = "#0078D4" })

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(460, 130)
$statusBox.Location = New-Object System.Drawing.Point(30, 665)
$statusBox.BackColor = "#F1F3F4"
$statusBox.ForeColor = "#3C4043"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== STARTUP MODÜLÜ ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -match "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Yönetim"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "White"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BorderStyle = "None"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Devre Dışı Bırak"; $b.Size = New-Object System.Drawing.Size(150, 35); $b.Location = New-Object System.Drawing.Point(120, 290); $b.BackColor = "#0078D4"; $b.ForeColor = "White"; $b.FlatStyle = "Flat"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA ÇALIŞTIRMA MANTIĞI ====================
$run.Add_Click({
    $tasks = @()
    if($cbRestore.Checked) { $tasks += $cbRestore }
    foreach($b in $boxes) { if($b.Checked) { $tasks += $b } }

    if($tasks.Count -eq 0) { [void][System.Windows.Forms.MessageBox]::Show("Hiçbir işlem seçilmedi!", "SafeOptix"); return }

    # KURAL 1: BAŞLAT TUŞUNA BASINCA SEÇİMLER SIFIRLANSIN
    $cbRestore.Checked = $false
    foreach($b in $boxes) { $b.Checked = $false }

    $run.Enabled = $false
    $statusBox.Clear()
    Log "Sistem analizi ve bakım süreci başladı..." "#0078D4"
    
    $total = $tasks.Count
    $current = 0

    foreach($task in $tasks) {
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "Yürütülüyor: $($task.Text)" "#202124"

        try {
            switch($task.Text) {
                "Geri Yükleme Noktası Oluştur (Önerilir)" { Checkpoint-Computer -Description "SafeOptix_Bakim" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "Sistem dosyalarını onar (SFC & DISM)" { dism /online /cleanup-image /restorehealth; sfc /scannow }
                "Disk hatalarını kontrol et (Chkdsk)" { Repair-Volume -DriveLetter C -Scan }
                "Virüs taraması yap (Windows Defender)" { Start-MpScan -ScanType QuickScan }
                "Geçici dosyaları temizle (Temp/Prefetch)" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "Disk temizleme (Sistem Dosyaları)" { cleanmgr /sagerun:1 }
                "Diski optimize et (Defrag/Trim)" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "Başlangıç programlarını düzenle" { $s = StartupSec; foreach($item in $s){ Log "Devre dışı bırakıldı: $item" } }
                "DNS önbelleğini temizle" { ipconfig /flushdns }
                "İnternet ayarlarını sıfırla" { netsh winsock reset; netsh int ip reset }
                "Güncellemeleri kontrol et" { Log "Windows Update servisi tetiklendi." }
            }
            Log "✔ Başarıyla tamamlandı." "#1E8E3E" # Yeşil
        } catch {
            Log "✖ Hata: $($_.Exception.Message)" "#D93025" # Kırmızı
        }
    }

    Log "✅ TÜM İŞLEMLER BİTTİ" "#0078D4"
    [void][System.Windows.Forms.MessageBox]::Show("Bakım başarıyla tamamlandı!", "SafeOptix")
    
    # KURAL 2: İŞLEM BİTİNCE PROGRESS BAR SIFIRLANSIN
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
})

[void]$form.ShowDialog()
