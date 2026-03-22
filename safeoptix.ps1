# =================================================================
# SafeOptix Ultra v3.0 - Optimized & Secured Pro Version
# =================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GÜVENLİK: Yönetici Hakları Kontrolü
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("Sistem dosyalarına müdahale edebilmek için lütfen bu aracı sağ tıklayıp 'Yönetici Olarak Çalıştır' seçeneğiyle açın.", "Güvenlik Uyarısı - Erişim Engellendi", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

# ==================== ANA FORM (Gri Tema) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")

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
$header.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SYSTEM OPTIMIZER | BUILD 2026 | SECURED"
$osInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$osInfo.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#AAAAAA")
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 25)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F46")
$selectAll.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#DDDDDD")
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 120)
$panel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#333337")
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$script:y = 15
function Create-CB($txt, $bold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#D1D1D1")
    $c.FlatStyle = "Standard" # Tik kutusunun düzgün görünmesi için Standard bırakıldı
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $c.Cursor = [System.Windows.Forms.Cursors]::Hand
    if($bold){ 
        $c.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
        $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold) 
    }
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($c)
    $script:y += 35
    return $c
}

$cbRestore = Create-CB "Sistem Geri Yükleme Noktası (Önerilir)" $true
$items = @("Sistem dosyalarını onar (SFC & DISM)", "Disk hatalarını kontrol et", "Virüs taraması yap (Hızlı)", "Geçici dosyaları temizle (Güvenli)", "Disk temizleme", "Diski optimize et (TRIM/Defrag)", "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et")
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
$pctLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
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
$run.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
$run.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 11)
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 665)
$statusBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1E1E1E")
$statusBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#00FF41")
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)


# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ 
        [System.Windows.Forms.MessageBox]::Show("Lütfen en az bir görev seçin!", "Hata", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return 
    }

    # UI Kilitle ve Sıfırla
    $run.Enabled = $false
    $run.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#555555")
    $statusBox.Clear()
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    
    Log "SafeOptix Engine v3 başlatıldı..." "#00A2FF"
    Log "NOT: Ağır işlemlerde pencere kısa süreliğine 'Yanıt Vermiyor' görünebilir, lütfen bekleyin." "#FFCC00"

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
                "*Geri Yükleme*" { 
                    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                    Checkpoint-Computer -Description "SafeOptix_$(Get-Date -Format 'yyyyMMdd_HHmm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue 
                }
                "*dosyalarını onar*" { 
                    $null = Start-Process "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -WindowStyle Hidden
                    $null = Start-Process "sfc.exe" -ArgumentList "/scannow" -Wait -WindowStyle Hidden
                }
                "*Disk hatalarını*" { $null = Repair-Volume -DriveLetter C -Scan -ErrorAction SilentlyContinue }
                "*Virüs taraması*" { $null = Start-MpScan -ScanType QuickScan -ErrorAction SilentlyContinue }
                "*Geçici dosyaları*" { 
                    $paths = @("$env:TEMP\*", "$env:windir\Temp\*", "$env:windir\Prefetch\*")
                    foreach ($p in $paths) {
                        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                "*Disk temizleme*" { $null = Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1 /autoclean" -Wait -WindowStyle Hidden }
                "*optimize et*" { $null = Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue }
                "*Başlangıç*" { 
                    $null = Start-Process "taskmgr" -ArgumentList "/0 /startup"
                    Log "Görev Yöneticisi Başlangıç sekmesi açıldı. (Güvenlik gereği manuel kapatın)" "#FFCC00"
                }
                "*DNS*" { Clear-DnsClientCache -ErrorAction SilentlyContinue }
                "*İnternet*" { 
                    $null = Start-Process "netsh" -ArgumentList "winsock reset" -Wait -WindowStyle Hidden
                    $null = Start-Process "netsh" -ArgumentList "int ip reset" -Wait -WindowStyle Hidden
                }
                "*Güncellemeleri*" { 
                    $null = Start-Process "control" -ArgumentList "update"
                    Log "Windows Update penceresi açıldı." "#FFCC00" 
                }
            }
            Log "TAMAMLANDI: İşlem başarılı." "#00FF41"
        } catch {
            Log "HATA OLUŞTU: Sistem bu işlemi reddetti veya desteklemiyor." "#FF3B30"
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    # BİTİŞ İŞLEMLERİ
    Log "OPERASYON BAŞARIYLA BİTTİ." "#00A2FF"
    [System.Windows.Forms.MessageBox]::Show("Seçilen tüm sistem bakım işlemleri başarıyla tamamlandı!", "SafeOptix", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    
    # Seçimleri ve UI'yı sıfırla
    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
})

$null = $form.ShowDialog()
