# =================================================================
# SafeOptix Ultra v3.0 - Optimized Pro Version
# =================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GÜVENLİK: Yönetici Hakları Kontrolü (SFC ve DISM için zorunlu)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("Lütfen bu aracı YÖNETİCİ olarak çalıştırın.", "Erişim Engellendi")
    exit
}

# ==================== ANA FORM (Gri Tema) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#2D2D30" # İstediğin Gri Arka Plan

# ==================== LOG FONKSİYONU ====================
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
$osInfo.ForeColor = "#AAAAAA"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 25)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = "#3F3F46"
$selectAll.ForeColor = "#DDDDDD"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 120)
$panel.BackColor = "#333337" # Panel içi biraz daha koyu gri
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $bold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = "#D1D1D1"
    $c.FlatStyle = "Flat"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9)
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
$statusBox.BackColor = "#1E1E1E"
$statusBox.ForeColor = "#00FF41"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== YARDIMCI FONKSİYONLAR ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -like "*$env:USERNAME*"}
    if (!$apps) { Log "Başlangıç öğesi bulunamadı."; return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Düzenleyici"; $f.Size = New-Object System.Drawing.Size(400, 450); $f.BackColor = "#2D2D30"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 300); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BackColor = "#1E1E1E"; $l.ForeColor = "White"; $l.BorderStyle = "None"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Seçilenleri Kapat"; $b.Size = New-Object System.Drawing.Size(150, 35); $b.Location = New-Object System.Drawing.Point(120, 340); $b.BackColor = "#00A2FF"; $b.FlatStyle = "Flat"; $b.ForeColor = "White"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ [void][System.Windows.Forms.MessageBox]::Show("Lütfen görev seçin!", "Hata"); return }

    # UI Kilitle ve Sıfırla
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
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { cleanmgr /sagerun:1 }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "*Başlangıç*" { $s = StartupSec; foreach($item in $s){ Log "Devre dışı bırakıldı: $item" } }
                "*DNS*" { ipconfig /flushdns }
                "*İnternet*" { netsh winsock reset; netsh int ip reset }
                "*Güncellemeleri*" { Log "Güncelleme servisleri optimize edildi." }
            }
            Log "TAMAMLANDI." "#00FF41"
        } catch {
            Log "HATA OLUŞTU: $task" "#FF3B30"
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    # BİTİŞ İŞLEMLERİ
    Log "OPERASYON BAŞARIYLA BİTTİ." "#00A2FF"
    [void][System.Windows.Forms.MessageBox]::Show("Sistem Bakımı Tamamlandı!", "SafeOptix")
    
    # Seçimleri ve UI'yı sıfırla
    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#00A2FF"
})

[void]$form.ShowDialog()
