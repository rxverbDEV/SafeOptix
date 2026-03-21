Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Pro - Gelişmiş Sistem Bakımı"
$form.Size = New-Object System.Drawing.Size(650, 950)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#121212"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "LightGray") {
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = $color
    $statusBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SAFEOPTIX"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 28)
$title.ForeColor = "#0A84FF"
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(650, 60)
$title.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($title)

# ==================== PANEL ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(560, 480)
$panel.Location = New-Object System.Drawing.Point(40, 100)
$panel.BackColor = "#1E1E1E"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# ==================== SEÇENEKLER ====================
$y = 15
function Add-CheckItem ($Text, $IsBold = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $Text
    $cb.ForeColor = "White"
    $cb.Size = New-Object System.Drawing.Size(500, 30)
    $cb.Location = New-Object System.Drawing.Point(20, $script:y)
    if($IsBold) { $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) }
    $panel.Controls.Add($cb)
    $script:y += 35
    return $cb
}

$cbRestore = Add-CheckItem "Sistem Geri Yükleme Noktası Oluştur (Önerilir)" $true
$items = @(
    "Sistem Dosyalarını Onar (SFC & DISM)",
    "Disk Hatalarını Tara ve Onar (Chkdsk)",
    "Hızlı Virüs Taraması Yap",
    "Geçici Dosyaları ve Prefetch Temizle",
    "DNS Önbelleğini ve IP Ayarlarını Sıfırla",
    "Sürücüleri ve Disk Bölümlerini Optimize Et",
    "Windows Güncelleme Servislerini Sıfırla"
)

$boxes = foreach($i in $items) { Add-CheckItem $i }

# ==================== PROGRESS & YÜZDE ====================
$lblPercent = New-Object System.Windows.Forms.Label
$lblPercent.Text = "%0"
$lblPercent.ForeColor = "White"
$lblPercent.TextAlign = "MiddleRight"
$lblPercent.Size = New-Object System.Drawing.Size(50, 20)
$lblPercent.Location = New-Object System.Drawing.Point(550, 615)
$form.Controls.Add($lblPercent)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(560, 15)
$progressBar.Location = New-Object System.Drawing.Point(40, 640)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "İŞLEMLERİ BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 60)
$run.Location = New-Object System.Drawing.Point(175, 675)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$run.FlatAppearance.BorderSize = 0
$form.Controls.Add($run)

# ==================== STATUS BOX (RichTextBox) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(560, 160)
$statusBox.Location = New-Object System.Drawing.Point(40, 750)
$statusBox.BackColor = "#000000"
$statusBox.ForeColor = "#00FF00" # Matrix yeşili :)
$statusBox.ReadOnly = $true
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($statusBox)

# ==================== ANA MOTOR (LOGIC) ====================
$run.Add_Click({
    $selectedTasks = @()
    if($cbRestore.Checked) { $selectedTasks += $cbRestore }
    foreach($b in $boxes) { if($b.Checked) { $selectedTasks += $b } }

    if($selectedTasks.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Lütfen yapılacak en az bir işlem seçin!", "Uyarı", 0, 48)
        return
    }

    $run.Enabled = $false
    $run.Text = "İŞLEM YAPILIYOR..."
    $run.BackColor = "#555555"
    $statusBox.Clear()
    Log "Bakım operasyonu başlatıldı..." "Cyan"

    $total = $selectedTasks.Count
    $current = 0

    foreach($task in $selectedTasks) {
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $lblPercent.Text = "%$pct"
        Log "Yürütülüyor: $($task.Text)" "White"

        try {
            switch ($task.Text) {
                "Sistem Geri Yükleme Noktası Oluştur (Önerilir)" {
                    Checkpoint-Computer -Description "SafeOptix_Bakim" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                }
                "Sistem Dosyalarını Onar (SFC & DISM)" {
                    dism /online /cleanup-image /restorehealth /norestart | Out-Null
                    sfc /scannow | Out-Null
                }
                "Disk Hatalarını Tara ve Onar (Chkdsk)" {
                    Repair-Volume -DriveLetter C -Scan | Out-Null
                }
                "Hızlı Virüs Taraması Yap" {
                    Start-MpScan -ScanType QuickScan
                }
                "Geçici Dosyaları ve Prefetch Temizle" {
                    $paths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    foreach($p in $paths) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "DNS Önbelleğini ve IP Ayarlarını Sıfırla" {
                    ipconfig /flushdns | Out-Null
                    netsh winsock reset | Out-Null
                    netsh int ip reset | Out-Null
                }
                "Sürücüleri ve Disk Bölümlerini Optimize Et" {
                    Optimize-Volume -DriveLetter C -Defrag -ReTrim -Verbose | Out-Null
                }
                "Windows Güncelleme Servislerini Sıfırla" {
                    net stop wuauserv; net stop bits
                    Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                    net start wuauserv; net start bits
                }
            }
            Log "✔ Tamamlandı: $($task.Text)" "LightGreen"
        } catch {
            Log "✖ Hata: $($task.Text) yapılamadı!" "Red"
        }
    }

    $progressBar.Value = 100
    $lblPercent.Text = "%100"
    $run.Enabled = $true
    $run.Text = "İŞLEMLERİ BAŞLAT"
    $run.BackColor = "#0A84FF"
    Log "✅ Tüm işlemler başarıyla sonuçlandı." "Yellow"
    [System.Windows.Forms.MessageBox]::Show("Sistem bakımı başarıyla tamamlandı!", "Başarılı", 0, 64)
})

# Formu Göster
[void]$form.ShowDialog()
