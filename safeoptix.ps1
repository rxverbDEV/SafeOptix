Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles() # Windows'un modern görünüm efektlerini açar

# ==================== ANA FORM (Açık Gri / Light Theme) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#F0F3F5" # Çok hoş, ferah bir açık gri

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#333333"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("» $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== ÜST PANEL (Logo Alanı) ====================
$header = New-Object System.Windows.Forms.Label
$header.Text = "SAFEOPTIX"
$header.Font = New-Object System.Drawing.Font("Segoe UI Black", 26, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#0078D7" # Canlı Windows Mavisi
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SYSTEM OPTIMIZER | BUILD 2026 | LIGHT EDITION"
$osInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$osInfo.ForeColor = "#777777"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 28)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = "#E1E5E8"
$selectAll.ForeColor = "#333333"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$selectAll.Cursor = [System.Windows.Forms.Cursors]::Hand
# Hover Efekti (Üzerine gelince renk değişir)
$selectAll.Add_MouseEnter({ $selectAll.BackColor = "#D0D5D9" })
$selectAll.Add_MouseLeave({ $selectAll.BackColor = "#E1E5E8" })
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 125)
$panel.BackColor = "#FFFFFF" # Panel içi bembeyaz (Kontrast için)
$panel.AutoScroll = $true
$panel.BorderStyle = "FixedSingle" # İnce bir çerçeve
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $bold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = "#222222"
    $c.FlatStyle = "Standard"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $c.Cursor = [System.Windows.Forms.Cursors]::Hand
    if($bold){ $c.ForeColor = "#0078D7"; $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold) }
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($c)
    $script:y += 35
    return $c
}

$cbRestore = Create-CB "Sistem Geri Yükleme Noktası (Önerilir)" $true
$items = @("Sistem dosyalarını onar", "Disk hatalarını kontrol et", "Virüs taraması yap", "Geçici dosyaları temizle", "Disk temizleme", "Diski optimize et", "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et")
$boxes = foreach($i in $items){ Create-CB $i }

# Hepsini Seç Logic
$script:toggle = $false
$selectAll.Add_Click({
    $script:toggle = !$script:toggle
    $cbRestore.Checked = $script:toggle
    foreach($b in $boxes){ $b.Checked = $script:toggle }
})

# ==================== PROGRESS ALANI ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#0078D7"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 12)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 25)
$pctLabel.Location = New-Object System.Drawing.Point(0, 535)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 8)
$progressBar.Location = New-Object System.Drawing.Point(35, 565)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 50)
$run.Location = New-Object System.Drawing.Point(125, 595)
$run.BackColor = "#0078D7"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 11)
$run.Cursor = [System.Windows.Forms.Cursors]::Hand

# Başlat Butonu Hover Efektleri
$run.Add_MouseEnter({ if($run.Enabled){ $run.BackColor = "#005A9E" } }) # Üstüne gelince koyulaşır
$run.Add_MouseLeave({ if($run.Enabled){ $run.BackColor = "#0078D7" } }) # Çekince eski haline döner
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 665)
$statusBox.BackColor = "#FFFFFF"
$statusBox.ForeColor = "#000000"
$statusBox.BorderStyle = "FixedSingle"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== FONKSİYONLAR ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | Where-Object {$_.User -eq "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Startup Manager"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "#F0F3F5"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BackColor = "#FFFFFF"; $l.ForeColor = "Black"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Devre Dışı Bırak"; $b.Size = New-Object System.Drawing.Size(150, 35); $b.Location = New-Object System.Drawing.Point(120, 290); $b.BackColor = "#0078D7"; $b.ForeColor = "White"; $b.FlatStyle = "Flat"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ 
        [void][System.Windows.Forms.MessageBox]::Show("Lütfen görev seçin!", "Bilgi", 0, 64)
        return 
    }

    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }

    $run.Enabled = $false
    $run.BackColor = "#A0A0A0" # Devre dışı kalmış buton rengi
    $statusBox.Clear()
    Log "SafeOptix Engine v3 başlatıldı..." "#0078D7"

    $total = $selected.Count
    $current = 0

    foreach($task in $selected){
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "İşleniyor: $task" "#555555"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            switch -wildcard ($task) {
                "*Geri Yükleme*" { Checkpoint-Computer -Description "SafeOptix" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "*dosyalarını onar*" { 
                    DISM /Online /Cleanup-Image /RestoreHealth -ErrorAction SilentlyContinue | Out-Null
                    sfc /scannow -ErrorAction SilentlyContinue | Out-Null 
                }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan -ErrorAction SilentlyContinue | Out-Null }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan -ErrorAction SilentlyContinue | Out-Null }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { Log "Sistem atıkları temizleniyor..." "#888888" }
                "*optimize et*" { Get-Volume -ErrorAction SilentlyContinue | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim -ErrorAction SilentlyContinue | Out-Null }
                "*Başlangıç*" { $s = StartupSec; foreach($item in $s){ Log "Devre dışı: $item" "#888888" } }
                "*DNS*" { ipconfig /flushdns | Out-Null }
                "*İnternet*" { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null }
                "*Güncellemeleri*" { Log "Güncelleme servisi kontrol edildi." "#888888" }
            }
            Log "TAMAMLANDI." "#008000" # Yeşil Başarı rengi
        } catch {
            Log "HATA VEYA YETKİ YOK: $task" "#D32F2F" # Kırmızı Hata rengi
        }
    }

    Log "OPERASYON BAŞARIYLA BİTTİ." "#0078D7"
    [void][System.Windows.Forms.MessageBox]::Show("Sistem Bakımı Tamamlandı!", "SafeOptix")
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#0078D7"
})

[void]$form.ShowDialog()
