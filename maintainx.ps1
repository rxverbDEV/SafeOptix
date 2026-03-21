Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = "MaintainX - Windows Bakım"
$form.Size = New-Object System.Drawing.Size(520,660)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#1E1E1E"

# BAŞLIK
$title = New-Object System.Windows.Forms.Label
$title.Text = "Windows Bakım Aracı"
$title.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(100,15)
$form.Controls.Add($title)

# ALT METİN
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Yapmak istediğin işlemleri seç ve başlat."
$subtitle.Font = New-Object System.Drawing.Font("Segoe UI",10)
$subtitle.ForeColor = "Gray"
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(120,55)
$form.Controls.Add($subtitle)

# PANEL (checkbox alanı)
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(460,400)
$panel.Location = New-Object System.Drawing.Point(30,90)
$panel.BackColor = "#282828"
$panel.BorderStyle = "FixedSingle"
$form.Controls.Add($panel)

# SEÇENEKLER
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
$y = 20

# EK: Geri Yükleme Noktası
$cbRestore = New-Object System.Windows.Forms.CheckBox
$cbRestore.Text = "Geri Yükleme Noktası Oluştur (Önerilir)"
$cbRestore.ForeColor = "White"
$cbRestore.BackColor = "#282828"
$cbRestore.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$cbRestore.Location = New-Object System.Drawing.Point(20, $y)
$cbRestore.AutoSize = $true
$panel.Controls.Add($cbRestore)
$y += 32

foreach ($i in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.ForeColor = "White"
    $cb.BackColor = "#282828"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI",10)
    $cb.Location = New-Object System.Drawing.Point(20,$y)
    $cb.AutoSize = $true
    $panel.Controls.Add($cb)
    $boxes += $cb
    $y += 32
}

# BAŞLAT BUTON
$run = New-Object System.Windows.Forms.Button
$run.Text = "Başlat"
$run.Size = New-Object System.Drawing.Size(150,45)
$run.Location = New-Object System.Drawing.Point(180,510)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# STATUS BOX
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.Size = New-Object System.Drawing.Size(460,100)
$statusBox.Location = New-Object System.Drawing.Point(30,570)
$statusBox.BackColor = "#111111"
$statusBox.ForeColor = "LightGray"
$statusBox.ReadOnly = $true
$statusBox.ScrollBars = "Vertical"
$form.Controls.Add($statusBox)

# STARTUP SEÇİM
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }

    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"
    $f.Size = New-Object System.Drawing.Size(380,380)
    $f.BackColor = "#282828"
    $f.StartPosition = "CenterScreen"

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Size = New-Object System.Drawing.Size(320,250)
    $list.Location = New-Object System.Drawing.Point(20,20)
    $list.BackColor = "#111111"
    $list.ForeColor = "White"

    foreach ($a in $apps) { $list.Items.Add($a.Name) }
    $f.Controls.Add($list)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Uygula"
    $ok.Location = New-Object System.Drawing.Point(130,290)
    $ok.BackColor = "#0A84FF"
    $ok.ForeColor = "White"
    $ok.FlatStyle = "Flat"
    $f.Controls.Add($ok)

    $sec = @()
    $ok.Add_Click({
        foreach ($i in $list.CheckedItems) { $sec += $i }
        $f.Close()
    })

    $f.ShowDialog()
    return $sec
}

# ÇALIŞTIR
$run.Add_Click({
    $statusBox.Clear()
    $statusBox.AppendText("Başlatılıyor...`r`n")

    # Tek seferlik geri yükleme noktası
    if ($cbRestore.Checked) {
        try {
            $statusBox.AppendText("→ Geri yükleme noktası oluşturuluyor...`r`n")
            Checkpoint-Computer -Description "MaintainX Öncesi Bakım" -RestorePointType "MODIFY_SETTINGS"
            $statusBox.AppendText("→ Geri yükleme noktası oluşturuldu.`r`n")
        } catch { $statusBox.AppendText("→ Geri yükleme noktası oluşturulamadı.`r`n") }
    }

    foreach ($b in $boxes) {
        if ($b.Checked) {
            $statusBox.AppendText("→ $($b.Text)`r`n")
            try {
                switch ($b.Text) {
                    "Sistem dosyalarını onar" {
                        $statusBox.AppendText("Sistem dosyaları kontrol ediliyor...`r`n")
                        DISM /Online /Cleanup-Image /RestoreHealth
                        sfc /scannow
                    }
                    "Disk hatalarını kontrol et" {
                        foreach ($drv in Get-PSDrive -PSProvider FileSystem) {
                            $statusBox.AppendText("→ Disk $($drv.Name) kontrol ediliyor...`r`n")
                            chkdsk $drv.Name /f /r /x
                        }
                    }
                    "Virüs taraması yap" { Start-MpScan -ScanType FullScan }
                    "Geçici dosyaları temizle" {
                        $paths=@("$env:TEMP","C:\Windows\Temp","$env:SystemRoot\Prefetch","$env:USERPROFILE\Recent")
                        foreach($p in $paths){ try { Remove-Item "$p\*" -Recurse -ErrorAction SilentlyContinue } catch { $statusBox.AppendText("→ $p temizlenemedi.`r`n") } }
                    }
                    "Disk temizleme" { cleanmgr /sagerun:1 }
                    "Diski optimize et" {
                        foreach ($drv in Get-PSDrive -PSProvider FileSystem) { try { Optimize-Volume -DriveLetter $drv.Name -ReTrim } catch { $statusBox.AppendText("→ $($drv.Name) optimize edilemedi.`r`n") } }
                    }
                    "Başlangıç programlarını düzenle" {
                        $sec = StartupSec
                        foreach ($s in $sec) { try { Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance } catch { $statusBox.AppendText("→ $s devre dışı bırakılamadı.`r`n") } }
                    }
                    "DNS önbelleğini temizle" { ipconfig /flushdns }
                    "İnternet ayarlarını sıfırla" { netsh winsock reset; netsh int ip reset }
                    "Güncellemeleri kontrol et" {
                        try { Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue; Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -Install } catch { $statusBox.AppendText("→ Güncellemeler yüklenemedi.`r`n") }
                    }
                }
            } catch { $statusBox.AppendText("→ $($b.Text) sırasında hata oluştu.`r`n") }
        }
    }

    $statusBox.AppendText("`r`nBitti. Yeniden başlatmanız önerilir.")
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı.")
})

[void]$form.ShowDialog()
