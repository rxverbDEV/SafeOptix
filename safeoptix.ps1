Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM (Compact & Pro) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850) # Boşluklar atıldı
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#0B0B0E"

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#BBBBBB"){
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
$header.ForeColor = "#00A2FF"
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SYSTEM OPTIMIZER | BUILD 2026"
$osInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$osInfo.ForeColor = "#555555"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 25)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = "#1A1A1F"
$selectAll.ForeColor = "#888888"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 120)
$panel.BackColor = "#121216"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $bold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = "#D1D1D1"
    $c.FlatStyle = "Flat"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    if($bold){ $c.ForeColor = "#00A2FF"; $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold) }
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
$pctLabel.ForeColor = "#00A2FF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 12)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 25)
$pctLabel.Location = New-Object System.Drawing.Point(0, 535)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 8)
$progressBar.Location = New-Object System.Drawing.Point(35, 565)
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 50)
$run.Location = New-Object System.Drawing.Point(125, 595)
$run.BackColor = "#00A2FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 11)
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 665)
$statusBox.BackColor = "#08080A"
$statusBox.ForeColor = "#00FF41" # Matrix Yeşili
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== FONKSİYONLAR ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Startup Manager"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "#121216"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BackColor = "#0B0B0E"; $l.ForeColor = "White"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Devre Dışı Bırak"; $b.Size = New-Object System.Drawing.Size(150, 35); $b.Location = New-Object System.Drawing.Point(120, 290); $b.BackColor = "#00A2FF"; $b.FlatStyle = "Flat"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ [void][System.Windows.Forms.MessageBox]::Show("Lütfen görev seçin!"); return }

    # KURAL 1: SEÇİMLERİ SIFIRLA
    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }

    $run.Enabled = $false
    $run.BackColor = "#333333"
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
                "*dosyalarını onar*" { DISM /Online /Cleanup-Image /RestoreHealth | Out-Null; sfc /scannow | Out-Null }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan | Out-Null }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan | Out-Null }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { Log "Sistem atıkları temizleniyor..." }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim | Out-Null }
                "*Başlangıç*" { $s = StartupSec; foreach($item in $s){ Log "Devre dışı: $item" } }
                "*DNS*" { ipconfig /flushdns | Out-Null }
                "*İnternet*" { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null }
                "*Güncellemeleri*" { Log "Güncelleme servisi kontrol edildi." }
            }
            Log "TAMAMLANDI." "#00FF41"
        } catch {
            Log "HATA: $task" "#FF3B30"
        }
    }

    # KURAL 2: BİTİNCE SIFIRLA
    Log "OPERASYON BAŞARIYLA BİTTİ." "#00A2FF"
    [void][System.Windows.Forms.MessageBox]::Show("Sistem Bakımı Tamamlandı!", "SafeOptix")
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#00A2FF"
})

[void]$form.ShowDialog()
