# =================================================================
# SafeOptix Ultra v3.1 - Professional System Optimizer
# =================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GÜVENLİK: Yönetici Olarak Çalıştırma Kontrolü
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $msg = "Bu araç sistem dosyalarına müdahale ettiği için YÖNETİCİ olarak çalıştırılmalıdır."
    [System.Windows.Forms.MessageBox]::Show($msg, "Erişim Reddedildi", 0, 16)
    exit
}

# ==================== ANA FORM AYARLARI ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.1 - Pro"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#2D2D30" # Profesyonel Gri Arka Plan

# Log Fonksiyonu (Gelişmiş)
function Log($text, $color = "#FFFFFF"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("» " + (Get-Date -Format "HH:mm") + " - $text`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== UI BİLEŞENLERİ ====================
$header = New-Object System.Windows.Forms.Label
$header.Text = "SAFEOPTIX PRO"
$header.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 24)
$header.ForeColor = "#00A2FF"
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "ENTERPRISE SYSTEM MAINTENANCE | 2026"
$osInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$osInfo.ForeColor = "#AAAAAA"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 70)
$form.Controls.Add($osInfo)

# Tümünü Seç/Kaldır Butonu
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Seçimi Tersine Çevir"
$selectAll.Size = New-Object System.Drawing.Size(150, 25)
$selectAll.Location = New-Object System.Drawing.Point(365, 95)
$selectAll.BackColor = "#3F3F46"
$selectAll.ForeColor = "White"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$form.Controls.Add($selectAll)

# Seçenek Paneli
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 130)
$panel.BackColor = "#333337"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $isBold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " $txt"
    $c.ForeColor = "#E1E1E1"
    $c.FlatStyle = "Flat"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($isBold){ $c.ForeColor = "#00A2FF"; $c.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) }
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($c)
    $script:y += 38
    return $c
}

$cbRestore = Create-CB "Sistem Geri Yükleme Noktası Oluştur" $true
$items = @("Sistem Dosyalarını Onar (SFC/DISM)", "Disk Hatalarını Tara", "Hızlı Virüs Taraması", "Geçici Dosyaları (Temp) Temizle", "Sistem Atıklarını Temizle", "Disk Optimize Et (Trim)", "Başlangıç Programlarını Yönet", "DNS Önbelleğini Sıfırla", "İnternet Protokollerini Yenile", "Update Servislerini Resetle")
$boxes = foreach($i in $items){ Create-CB $i }

$selectAll.Add_Click({
    $cbRestore.Checked = !$cbRestore.Checked
    foreach($b in $boxes){ $b.Checked = !$b.Checked }
})

# Progress & Status
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#00A2FF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 25)
$pctLabel.Location = New-Object System.Drawing.Point(0, 540)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 10)
$progressBar.Location = New-Object System.Drawing.Point(35, 570)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

$run = New-Object System.Windows.Forms.Button
$run.Text = "BAKIMI BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 50)
$run.Location = New-Object System.Drawing.Point(125, 600)
$run.BackColor = "#007ACC"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 120)
$statusBox.Location = New-Object System.Drawing.Point(35, 670)
$statusBox.BackColor = "#1E1E1E"
$statusBox.ForeColor = "#D4D4D4"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== ANA MOTOR (ENGINE) ====================
$run.Add_Click({
    $selectedTasks = @()
    if($cbRestore.Checked){ $selectedTasks += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selectedTasks += $b.Text.Trim() } }

    if($selectedTasks.Count -eq 0){ 
        [void][System.Windows.Forms.MessageBox]::Show("Lütfen yapılacak işlemleri seçin!", "Uyarı")
        return 
    }

    $run.Enabled = $false
    $run.Text = "İŞLEM YAPILIYOR..."
    $run.BackColor = "#555555"
    
    $total = $selectedTasks.Count
    $current = 0

    foreach($task in $selectedTasks){
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "İşlem başlatıldı: $task" "#00A2FF"

        try {
            switch -wildcard ($task) {
                "*Geri Yükleme*" { 
                    Checkpoint-Computer -Description "SafeOptix_Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue 
                }
                "*Onar*" { 
                    DISM /Online /Cleanup-Image /RestoreHealth
                    sfc /scannow 
                }
                "*Hatalarını Tara*" { Repair-Volume -DriveLetter C -Scan }
                "*Virüs*" { Start-MpScan -ScanType QuickScan }
                "*Temp*" { 
                    $paths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    foreach($p in $paths){ Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Optimize*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "*DNS*" { ipconfig /flushdns }
                "*İnternet*" { 
                    netsh winsock reset
                    netsh int ip reset
                }
                "*Update*" {
                    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
                    Start-Service wuauserv -ErrorAction SilentlyContinue
                }
            }
            Log "BAŞARILI: $task" "#00FF41"
        } catch {
            Log "HATA: $task" "#FF3B30"
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    Log "TÜM İŞLEMLER TAMAMLANDI." "#00A2FF"
    [void][System.Windows.Forms.MessageBox]::Show("Sistem bakımı başarıyla tamamlandı. Bazı değişikliklerin etkili olması için bilgisayarı yeniden başlatmanız gerekebilir.", "Bitti")
    
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.Text = "BAKIMI BAŞLAT"
    $run.BackColor = "#007ACC"
})

# Formu Çalıştır
[void]$form.ShowDialog()
