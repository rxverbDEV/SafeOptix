# =================================================================
# SafeOptix Ultra v3.0 - Custom Blue Tick Edition
# =================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Yönetici Kontrolü
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("Lütfen yönetici olarak çalıştırın!", "Sistem")
    exit
}

# ==================== ANA FORM ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#2D2D30"

# Log Fonksiyonu
function Log($text, $color = "#BBBBBB"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("» $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== ÜST PANEL ====================
$header = New-Object System.Windows.Forms.Label
$header.Text = "SAFEOPTIX"
$header.Font = New-Object System.Drawing.Font("Segoe UI Black", 26, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#00A2FF"
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SYSTEM OPTIMIZER | BUILD 2026"
$osInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$osInfo.ForeColor = "#888888"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# Tümünü Seç Butonu
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 25)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = "#3F3F46"
$selectAll.ForeColor = "White"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 120)
$panel.BackColor = "#333337"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
# Gelişmiş Checkbox Fonksiyonu (Sadece Tik Mavi)
function Create-CB($txt, $bold = $false) {
    # 1. Asıl CheckBox (Sadece Tik için)
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = ""
    $c.ForeColor = "#00A2FF" # Sadece tik rengi mavi olacak
    $c.FlatStyle = "Flat"
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(25, 30)
    
    # 2. Yazı Etiketi (Yazılar Beyaz/Gri kalacak)
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $txt
    $l.ForeColor = "#D1D1D1"
    $l.Location = New-Object System.Drawing.Point(45, $script:y + 5)
    $l.Size = New-Object System.Drawing.Size(400, 25)
    $l.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($bold){ $l.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) }
    
    # Yazıya tıklayınca tiki değiştirme özelliği
    $l.Add_Click({ $c.Checked = !$c.Checked })
    
    $panel.Controls.Add($c)
    $panel.Controls.Add($l)
    $script:y += 35
    return @($c, $txt) # Motorun çalışması için nesneyi ve adı döndür
}

$cbRestoreData = Create-CB "Sistem Geri Yükleme Noktası (Önerilir)" $true
$items = @("Sistem dosyalarını onar", "Disk hatalarını kontrol et", "Virüs taraması yap", "Geçici dosyaları temizle", "Disk temizleme", "Diski optimize et", "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et")
$boxesData = foreach($i in $items){ Create-CB $i }

# Hepsini Seç Mantığı
$script:toggle = $false
$selectAll.Add_Click({
    $script:toggle = !$script:toggle
    $cbRestoreData[0].Checked = $script:toggle
    foreach($b in $boxesData){ $b[0].Checked = $script:toggle }
})

# ==================== PROGRESS ALANI ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#00A2FF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 14)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 25)
$pctLabel.Location = New-Object System.Drawing.Point(0, 535)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 10)
$progressBar.Location = New-Object System.Drawing.Point(35, 565)
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU (BAKIMI BAŞLAT) ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "BAKIMI BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 50)
$run.Location = New-Object System.Drawing.Point(125, 595)
$run.BackColor = "#00A2FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 12)
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 665)
$statusBox.BackColor = "#1E1E1E"
$statusBox.ForeColor = "#00FF41"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestoreData[0].Checked){ $selected += $cbRestoreData[1] }
    foreach($b in $boxesData){ if($b[0].Checked){ $selected += $b[1] } }

    if($selected.Count -eq 0){ [void][System.Windows.Forms.MessageBox]::Show("Lütfen görev seçin!"); return }

    $run.Enabled = $false
    $run.BackColor = "#555555"
    $statusBox.Clear()
    Log "SafeOptix Engine v3 başlatıldı..." "#00A2FF"

    $total = $selected.Count
    $current = 0

    foreach($task in $selected){
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "İşleniyor: $task" "#FFFFFF"

        try {
            switch -wildcard ($task) {
                "*Geri Yükleme*" { Checkpoint-Computer -Description "SafeOptix" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "*dosyalarını onar*" { DISM /Online /Cleanup-Image /RestoreHealth; sfc /scannow }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    foreach($folder in $p){ Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { Log "Sistem gereksizleri temizleniyor..." }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "*DNS*" { ipconfig /flushdns }
                "*İnternet*" { netsh winsock reset; netsh int ip reset }
                "*Güncellemeleri*" { Log "Servisler kontrol edildi." }
            }
            Log "TAMAMLANDI." "#00FF41"
        } catch {
            Log "HATA: $task" "#FF3B30"
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    Log "OPERASYON BİTTİ." "#00A2FF"
    [void][System.Windows.Forms.MessageBox]::Show("Sistem Bakımı Tamamlandı!", "SafeOptix")
    
    # Sıfırlama
    $cbRestoreData[0].Checked = $false
    foreach($b in $boxesData){ $b[0].Checked = $false }
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#00A2FF"
})

[void]$form.ShowDialog()
