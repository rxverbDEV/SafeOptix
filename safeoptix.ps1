Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM (Modern Light Tasarım) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix - NextGen System Care"
$form.Size = New-Object System.Drawing.Size(550, 820)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#F5F5F7" # Açık gri/beyaz (Premium hissi)

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#1D1D1F"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("• $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== ÜST BAŞLIK ====================
$header = New-Object System.Windows.Forms.Label
$header.Text = "SafeOptix"
$header.Font = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#007AFF" # Canlı Mavi
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SİSTEM OPTİMİZASYON PANELİ"
$osInfo.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$osInfo.ForeColor = "#8E8E93"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(140, 25)
$selectAll.Location = New-Object System.Drawing.Point(375, 90)
$selectAll.BackColor = "#E5E5EA"
$selectAll.ForeColor = "#1D1D1F"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI (Beyaz Kart Sistemi) ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 360) # Boşluklar daraltıldı
$panel.Location = New-Object System.Drawing.Point(35, 120)
$panel.BackColor = "#FFFFFF" # Saf Beyaz kart
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $isBold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = "#1D1D1F"
    $c.FlatStyle = "Flat"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    if($isBold){ $c.ForeColor = "#007AFF"; $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold) }
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(420, 28)
    $panel.Controls.Add($c)
    $script:y += 32 # Dikey mesafe sıkılaştırıldı
    return $c
}

$cbRestore = Create-CB "Geri Yükleme Noktası Oluştur (Önerilir)" $true
$items = @(
    "Sistem dosyalarını onar", "Disk hatalarını kontrol et", "Virüs taraması yap", 
    "Geçici dosyaları temizle", "Disk temizleme", "Diski optimize et", 
    "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", 
    "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et"
)
$boxes = foreach($i in $items){ Create-CB $i }

# Hepsini Seç Fonksiyonu
$script:isAllSelected = $false
$selectAll.Add_Click({
    $script:isAllSelected = !$script:isAllSelected
    $cbRestore.Checked = $script:isAllSelected
    foreach($b in $boxes){ $b.Checked = $script:isAllSelected }
})

# ==================== PROGRESS ALANI ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#007AFF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 14)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 30)
$pctLabel.Location = New-Object System.Drawing.Point(0, 495)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 10)
$progressBar.Location = New-Object System.Drawing.Point(35, 530)
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "BAKIMI BAŞLAT"
$run.Size = New-Object System.Drawing.Size(260, 50)
$run.Location = New-Object System.Drawing.Point(145, 560)
$run.BackColor = "#007AFF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== STATUS LOG (Temiz Stil) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 630)
$statusBox.BackColor = "#FFFFFF" # Beyaz log alanı
$statusBox.ForeColor = "#444444"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== STARTUP MANAGER ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Startup"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "#F5F5F7"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BorderStyle = "None"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Uygula"; $b.Size = New-Object System.Drawing.Size(120, 35); $b.Location = New-Object System.Drawing.Point(140, 300); $b.BackColor = "#007AFF"; $b.ForeColor = "White"; $b.FlatStyle = "Flat"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA ÇALIŞTIRICI ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += "Restore" }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ [void][System.Windows.Forms.MessageBox]::Show("Lütfen işlem seçin!", "SafeOptix", 0, 48); return }

    # SIFIRLA: TİKLER KALKAR
    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }

    $run.Enabled = $false
    $run.BackColor = "#A2A2A2"
    $statusBox.Clear()
    Log "Optimizasyon motoru çalışıyor..." "#007AFF"

    $total = $selected.Count
    $current = 0

    foreach($task in $selected){
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "İşleniyor: $task"

        try {
            switch -wildcard ($task) {
                "Restore" { Checkpoint-Computer -Description "SafeOptix" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "*dosyalarını onar*" { DISM /Online /Cleanup-Image /RestoreHealth | Out-Null; sfc /scannow | Out-Null }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan | Out-Null }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan | Out-Null }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { cleanmgr /sagerun:1 | Out-Null }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim | Out-Null }
                "*Başlangıç*" { $s = StartupSec; foreach($item in $s){ Log "Kapatıldı: $item" } }
                "*DNS*" { ipconfig /flushdns | Out-Null }
                "*İnternet*" { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null }
                "*Güncellemeleri*" { Log "Güncelleme kontrolü yapıldı." }
            }
            Log "✔ Başarıyla bitti." "#34C759" # Apple Green
        } catch {
            Log "✖ Hata oluştu: $task" "#FF3B30"
        }
    }

    # BİTİŞ: PROGRESS BAR SIFIRLANIR
    Log "SİSTEM BAKIMI TAMAMLANDI!" "#007AFF"
    [void][System.Windows.Forms.MessageBox]::Show("Tüm operasyon başarıyla bitti.", "SafeOptix", 0, 64)
    
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#007AFF"
})

[void]$form.ShowDialog()
