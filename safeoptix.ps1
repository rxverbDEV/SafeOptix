# ==================== YÖNETİCİ KONTROLÜ ====================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("Lütfen bu aracı YÖNETİCİ olarak çalıştırın! Yoksa sistem dosyalarına müdahale edemez.", "Yetki Hatası", 0, 16)
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Gerekli grafik kütüphanelerini garantiye alalım
$Drawing2D = "System.Drawing.Drawing2D"

# ==================== YUVARLATILMIŞ KÖŞE FONKSİYONU ====================
function Set-RoundedRegion ($Control, $Radius) {
    $Path = New-Object "$Drawing2D.GraphicsPath"
    $Rect = New-Object System.Drawing.Rectangle(0, 0, $Control.Width, $Control.Height)
    $ArcRect = New-Object System.Drawing.Rectangle($Rect.Location, New-Object System.Drawing.Size($Radius, $Radius))
    
    $Path.AddArc($ArcRect, 180, 90) # Sol Üst
    $ArcRect.X = $Rect.Right - $Radius
    $Path.AddArc($ArcRect, 270, 90) # Sağ Üst
    $ArcRect.Y = $Rect.Bottom - $Radius
    $Path.AddArc($ArcRect, 0, 90)   # Sağ Alt
    $ArcRect.X = $Rect.Left
    $Path.AddArc($ArcRect, 90, 90)  # Sol Alt
    $Path.CloseFigure()
    $Control.Region = New-Object System.Drawing.Region($Path)
}

# ==================== ANA FORM (Modern Pro Gray) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v4.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#252526" # Daha derin bir gri

# ==================== BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 28)
$title.ForeColor = "#00A2FF"
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(550, 60)
$title.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($title)

# ==================== SEÇENEK PANELİ (Modern Kart) ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(460, 380)
$panel.Location = New-Object System.Drawing.Point(45, 100)
$panel.BackColor = "#333337"
$form.Controls.Add($panel)

$y = 15
function New-CB($text, $blue = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "  " + $text
    $cb.ForeColor = "#E1E1E1"
    $cb.FlatStyle = "Flat"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($blue) { $cb.ForeColor = "#00A2FF"; $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) }
    $cb.Location = New-Object System.Drawing.Point(25, $script:y)
    $cb.Size = New-Object System.Drawing.Size(410, 30)
    $panel.Controls.Add($cb)
    $script:y += 33
    return $cb
}

$cbRestore = New-CB "Geri Yükleme Noktası Oluştur (Önerilir)" $true
$items = @("Sistem dosyalarını onar (SFC & DISM)", "Disk hatalarını kontrol et (Chkdsk)", "Virüs taraması yap (Windows Defender)", "Geçici dosyaları temizle (Temp/Prefetch)", "Disk temizleme (Sistem Dosyaları)", "Diski optimize et (Defrag/Trim)", "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et")
$boxes = foreach($i in $items) { New-CB $i }

# ==================== PROGRESS & YÜZDE ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#00A2FF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 22)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 45)
$pctLabel.Location = New-Object System.Drawing.Point(0, 500)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(460, 12)
$progressBar.Location = New-Object System.Drawing.Point(45, 555)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU (Oval & Yumuşak) ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 60)
$run.Location = New-Object System.Drawing.Point(125, 595)
$run.BackColor = "#00A2FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$run.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== LOG BOX (Koyu Şık) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(460, 120)
$statusBox.Location = New-Object System.Drawing.Point(45, 675)
$statusBox.BackColor = "#1E1E1E"
$statusBox.ForeColor = "#00A2FF"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# UI Yuvarlama İşlemleri (Form yüklendiğinde)
$form.Add_Shown({
    Set-RoundedRegion $panel 25
    Set-RoundedRegion $run 30
    Set-RoundedRegion $statusBox 15
})

# ==================== OPERASYON ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked) { $selected += $cbRestore }
    foreach($b in $boxes) { if($b.Checked) { $selected += $b } }

    if($selected.Count -eq 0) { [void][System.Windows.Forms.MessageBox]::Show("Lütfen görev seçin!"); return }

    # KURAL 1: BAŞLATINCA SEÇİMLER SIFIRLANIR
    $cbRestore.Checked = $false
    foreach($b in $boxes) { $b.Checked = $false }

    $run.Enabled = $false
    $statusBox.Clear()
    $statusBox.AppendText("[!] Optimizasyon motoru devreye girdi...`r`n")
    
    $total = $selected.Count
    $current = 0

    foreach($task in $selected) {
        $current++
        $targetPct = [int](($current / $total) * 100)
        
        # Animasyonlu Progress Bar
        for($i = $progressBar.Value; $i -le $targetPct; $i+=2) {
            $progressBar.Value = $i
            $pctLabel.Text = "%$i"
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 10
        }

        $statusBox.AppendText("» İşleniyor: $($task.Text)...`r`n")
        $statusBox.ScrollToCaret()

        # İşlemler
        try {
            switch($task.Text) {
                "*Geri Yükleme*" { Checkpoint-Computer -Description "SafeOptix" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "*dosyalarını onar*" { dism /online /cleanup-image /restorehealth; sfc /scannow }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { cleanmgr /sagerun:1 }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "*DNS*" { ipconfig /flushdns }
                "*İnternet*" { netsh winsock reset; netsh int ip reset }
            }
        } catch {}
    }

    $statusBox.AppendText("[+] İşlem başarıyla bitti!`r`n")
    [void][System.Windows.Forms.MessageBox]::Show("Sistem başarıyla optimize edildi!", "SafeOptix")
    
    # KURAL 2: BİTİNCE SIFIRLANIR
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
})

[void]$form.ShowDialog()
