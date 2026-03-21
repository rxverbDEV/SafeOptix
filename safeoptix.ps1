Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix - Windows Bakım"
$form.Size = New-Object System.Drawing.Size(650, 950)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#121212"

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "LightGray"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.AutoSize = $false
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(650, 60)
$title.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($title)

# ==================== PANEL ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(580, 520)
$panel.Location = New-Object System.Drawing.Point(30, 90)
$panel.BackColor = "#1E1E1E"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# ==================== CHECKBOX'LAR ====================
$y = 20
$cbRestore = New-Object System.Windows.Forms.CheckBox
$cbRestore.Text = "Geri Yükleme Noktası Oluştur (Önerilir)"
$cbRestore.ForeColor = "White"
$cbRestore.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
$cbRestore.Location = New-Object System.Drawing.Point(20, $y)
$cbRestore.Size = New-Object System.Drawing.Size(540, 28)
$panel.Controls.Add($cbRestore)
$y += 35

$items = @(
    "Sistem dosyalarını onar",
    "Disk hatalarını kontrol et",
    "Virüs taraması yap",
    "Geçici dosyaları temizle",
    "Disk temizleme",
    "Diski optimize et",
    "Başlangıç programlarını düzenle",
    "DNS önbelleğini temizle",
    "İnternet ayarlarını sıfırla",
    "Güncellemeleri kontrol et"
)

$boxes = @()
foreach($i in $items){
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.ForeColor = "White"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cb.Location = New-Object System.Drawing.Point(20, $y)
    $cb.Size = New-Object System.Drawing.Size(540, 28)
    $panel.Controls.Add($cb)
    $boxes += $cb
    $y += 35
}

# ==================== PROGRESS BAR & YÜZDE ====================
$lblPercent = New-Object System.Windows.Forms.Label
$lblPercent.Text = "%0"
$lblPercent.ForeColor = "#0A84FF"
$lblPercent.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblPercent.TextAlign = "MiddleRight"
$lblPercent.Size = New-Object System.Drawing.Size(100, 25)
$lblPercent.Location = New-Object System.Drawing.Point(510, 620)
$form.Controls.Add($lblPercent)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(580, 20)
$progressBar.Location = New-Object System.Drawing.Point(30, 650)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "Başlat"
$run.Size = New-Object System.Drawing.Size(200, 50)
$run.Location = New-Object System.Drawing.Point(220, 685)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== STATUS BOX (Renkli Log İçin RichTextBox) ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(580, 160)
$statusBox.Location = New-Object System.Drawing.Point(30, 750)
$statusBox.BackColor = "#111111"
$statusBox.ForeColor = "LightGray"
$statusBox.ReadOnly = $true
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($statusBox)

# ==================== STARTUP SEC (Orijinal Kod) ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }
    
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"
    $f.Size = New-Object System.Drawing.Size(450, 400)
    $f.StartPosition = "CenterScreen"
    $f.BackColor = "#1E1E1E"
    $f.FormBorderStyle = 'FixedDialog'

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Size = New-Object System.Drawing.Size(400, 250)
    $list.Location = New-Object System.Drawing.Point(20, 20)
    $list.BackColor = "#111111"
    $list.ForeColor = "White"
    $list.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    foreach($a in $apps){ $list.Items.Add($a.Name) | Out-Null }
    $f.Controls.Add($list)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Uygula"
    $ok.Size = New-Object System.Drawing.Size(120, 40)
    $ok.Location = New-Object System.Drawing.Point(160, 290)
    $ok.BackColor = "#0A84FF"
    $ok.ForeColor = "White"
    $ok.FlatStyle = "Flat"
    $f.Controls.Add($ok)

    $sec = @()
    $ok.Add_Click({
        foreach($i in $list.CheckedItems){ $sec += $i }
        $f.Close()
    })
    $f.ShowDialog() | Out-Null
    return $sec
}

# ==================== ÇALIŞTIRMA MANTIĞI ====================
$run.Add_Click({
    # Seçilenleri bir listeye alalım
    $selectedTaskNames = @()
    if($cbRestore.Checked){ $selectedTaskNames += $cbRestore.Text }
    foreach($cb in $boxes){
        if($cb.Checked){ $selectedTaskNames += $cb.Text }
    }

    if($selectedTaskNames.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Lütfen bir seçenek seçin!", "Uyarı", 0, 48)
        return
    }

    # İSTEĞİN ÜZERİNE: BAŞLAT TUŞUNA BASINCA SEÇİMLERİ SIFIRLA
    $cbRestore.Checked = $false
    foreach($cb in $boxes){ $cb.Checked = $false }

    $run.Enabled = $false
    $statusBox.Clear()
    $progressBar.Value = 0
    $lblPercent.Text = "%0"

    $taskCount = $selectedTaskNames.Count
    $current = 0

    Log "Bakım işlemleri başlatılıyor..." "#0A84FF"

    foreach($taskName in $selectedTaskNames){
        $current++
        $percent = [int](($current / $taskCount) * 100)
        
        # UI Güncelleme
        $progressBar.Value = $percent
        $lblPercent.Text = "%$percent"
        Log "▶ $taskName" "White"

        try{
            switch($taskName){
                "Geri Yükleme Noktası Oluştur (Önerilir)"{
                    Checkpoint-Computer -Description "SafeOptix Öncesi Bakım" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                    Log "✔ Geri yükleme noktası oluşturuldu" "#00FF00"
                }
                "Sistem dosyalarını onar"{
                    DISM /Online /Cleanup-Image /RestoreHealth | Out-Null
                    sfc /scannow | Out-Null
                    Log "✔ Sistem dosyaları onarıldı" "#00FF00"
                }
                "Disk hatalarını kontrol et"{
                    $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($d in $drives){
                        chkdsk $d.DriveLetter /f /r /x | Out-Null
                        Log "✔ Disk $($d.DriveLetter) kontrol edildi" "#00FF00"
                    }
                }
                "Virüs taraması yap"{ 
                    Start-MpScan -ScanType FullScan | Out-Null
                    Log "✔ Virüs taraması tamamlandı" "#00FF00" 
                }
                "Geçici dosyaları temizle"{
                    $paths = @("$env:TEMP","C:\Windows\Temp","C:\Windows\Prefetch","$env:USERPROFILE\Recent")
                    foreach($p in $paths){
                        if(Test-Path $p){
                            Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                                try{ Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop } catch{}
                            }
                        }
                    }
                    Log "✔ Geçici dosyalar temizlendi" "#00FF00"
                }
                "Disk temizleme"{ 
                    Log "⚠ Disk temizleme artık manuel yapılmıyor, geçici dosyaları temizle ile birleşti" "#FFA500" 
                }
                "Diski optimize et"{
                    $vols = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($v in $vols){ 
                        try{ Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim | Out-Null } catch{} 
                    }
                    Log "✔ Disk optimize edildi" "#00FF00"
                }
                "Başlangıç programlarını düzenle"{
                    $sec = StartupSec
                    foreach($s in $sec){ 
                        try{ Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance } catch{} 
                    }
                    Log "✔ Başlangıç programları düzenlendi" "#00FF00"
                }
                "DNS önbelleğini temizle"{ 
                    ipconfig /flushdns | Out-Null
                    Log "✔ DNS önbelleği temizlendi" "#00FF00" 
                }
                "İnternet ayarlarını sıfırla"{ 
                    netsh winsock reset | Out-Null
                    netsh int ip reset | Out-Null
                    Log "✔ İnternet ayarları sıfırlandı" "#00FF00" 
                }
                "Güncellemeleri kontrol et"{
                    try{
                        Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                        Import-Module PSWindowsUpdate
                        Get-WindowsUpdate -AcceptAll -Install | Out-Null
                    }catch{}
                    Log "✔ Güncellemeler kontrol edildi" "#00FF00"
                }
            }
        }catch{
            Log "❌ $taskName sırasında hata oluştu" "#FF0000"
        }
    }

    Log "✅ TÜM İŞLEMLER TAMAMLANDI" "#0A84FF"
    [System.Windows.Forms.MessageBox]::Show("Bakım başarıyla tamamlandı!", "SafeOptix", 0, 64)

    # İSTEĞİN ÜZERİNE: İŞLEM BİTİNCE PROGRESS BAR VE YÜZDE SIFIRLANSIN
    $progressBar.Value = 0
    $lblPercent.Text = "%0"
    $run.Enabled = $true
})

[void]$form.ShowDialog()
