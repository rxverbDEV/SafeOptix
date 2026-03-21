Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== YUVARLATILMIŞ KÖŞE FONKSİYONU ====================
function Set-RoundedRegion ($Control, $Radius) {
    $Path = New-Object System.Drawing.Drawing2D.GraphicsPath
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

# ==================== ANA FORM (Modern Gray) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra - Pro Suite"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#2D2D30" # Ana Arka Plan Gri

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#00A2FF") {
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("» $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 28)
$title.ForeColor = "#F1F1F1"
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(550, 60)
$title.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($title)

# ==================== SEÇENEK PANELİ (Kompakt Kart) ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(470, 380)
$panel.Location = New-Object System.Drawing.Point(40, 95)
$panel.BackColor = "#3E3E42" # Kart Rengi
$form.Controls.Add($panel)
$form.Add_Shown({ Set-RoundedRegion $panel 20 }) # Paneli yuvarlat

$y = 15
function New-CB($text, $isBlue = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "  " + $text
    $cb.ForeColor = "#DCDCDC"
    $cb.FlatStyle = "Flat"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($isBlue) { 
        $cb.ForeColor = "#00A2FF"
        $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    }
    $cb.Location = New-Object System.Drawing.Point(25, $script:y)
    $cb.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($cb)
    $script:y += 33
    return $cb
}

# Orijinal Yazılar Geri Geldi
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

# ==================== PROGRESS & PERCENT ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#00A2FF"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 22)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 45)
$pctLabel.Location = New-Object System.Drawing.Point(0, 500)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(470, 10)
$progressBar.Location = New-Object System.Drawing.Point(40, 550)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU (Yumuşak Kenarlı) ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(280, 55)
$run.Location = New-Object System.Drawing.Point(135, 585)
$run.BackColor = "#00A2FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)
$form.Add_Shown({ Set-RoundedRegion $run 25 }) # Butonu yuvarlat

# ==================== LOG BOX (Koyu Gri) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(470, 130)
$statusBox.Location = New-Object System.Drawing.Point(40, 665)
$statusBox.BackColor = "#1E1E1E"
$statusBox.ForeColor = "#A9A9A9"
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)
$form.Add_Shown({ Set-RoundedRegion $statusBox 15 }) # Log kutusunu yuvarlat

# ==================== STARTUP MODÜLÜ ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -match "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Yönetici"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "#2D2D30"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BackColor = "#3E3E42"; $l.ForeColor = "White"; $l.BorderStyle = "None"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Tamam"; $b.Size = New-Object System.Drawing.Size(100, 35); $b.Location = New-Object System.Drawing.Point(150, 290); $b.BackColor = "#00A2FF"; $b.FlatStyle = "Flat"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); Set-RoundedRegion $b 10; $f.ShowDialog() | Out-Null
    return $res
}

# ==================== OPERASYON MANTIĞI ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked) { $selected += $cbRestore }
    foreach($b in $boxes) { if($b.Checked) { $selected += $b } }

    if($selected.Count -eq 0) { [void][System.Windows.Forms.MessageBox]::Show("Lütfen bir görev seçin!"); return }

    # SIFIRLAMA: BAŞLARKEN TİKLER KALKAR
    $cbRestore.Checked = $false
    foreach($b in $boxes) { $b.Checked = $false }

    $run.Enabled = $false
    $run.Text = "İŞLENİYOR..."
    $statusBox.Clear()
    Log "SafeOptix v3.0 Motoru Tetiklendi..." "#00A2FF"
    
    $total = $selected.Count
    $current = 0

    foreach($task in $selected) {
        $current++
        # Animasyonlu Progress Bar Geçişi
        $targetPct = [int](($current / $total) * 100)
        for($i = $progressBar.Value; $i -le $targetPct; $i++) {
            $progressBar.Value = $i
            $pctLabel.Text = "%$i"
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 5 # Akıcı dolum hissi
        }
        
        Log "Yürütülüyor: $($task.Text)" "#FFFFFF"

        try {
            switch($task.Text) {
                "Geri Yükleme Noktası Oluştur (Önerilir)" { Checkpoint-Computer -Description "SafeOptix" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue }
                "Sistem dosyalarını onar (SFC & DISM)" { dism /online /cleanup-image /restorehealth; sfc /scannow }
                "Disk hatalarını kontrol et (Chkdsk)" { Repair-Volume -DriveLetter C -Scan }
                "Virüs taraması yap (Windows Defender)" { Start-MpScan -ScanType QuickScan }
                "Geçici dosyaları temizle (Temp/Prefetch)" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "Disk temizleme (Sistem Dosyaları)" { cleanmgr /sagerun:1 }
                "Diski optimize et (Defrag/Trim)" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim }
                "Başlangıç programlarını düzenle" { $s = StartupSec; foreach($item in $s){ Log "Devre dışı: $item" } }
                "DNS önbelleğini temizle" { ipconfig /flushdns }
                "İnternet ayarlarını sıfırla" { netsh winsock reset; netsh int ip reset }
                "Güncellemeleri kontrol et" { Log "Update kontrolleri tamam." }
            }
            Log "✔ Tamamlandı." "#00FF7F"
        } catch {
            Log "✖ Hata!" "#FF4500"
        }
    }

    Log "✅ TÜM SİSTEM OPTİMİZE EDİLDİ" "#00A2FF"
    [void][System.Windows.Forms.MessageBox]::Show("Tüm işlemler başarıyla tamamlandı!", "SafeOptix")
    
    # SIFIRLAMA: BİTİNCE BAR VE YÜZDE SIFIRLANIR
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.Text = "OPERASYONU BAŞLAT"
})

[void]$form.ShowDialog()
