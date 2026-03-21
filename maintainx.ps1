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

# LOG FONKSİYONU
function Log($text) {
    $statusBox.AppendText($text + "`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
}

# CMD ÇALIŞTIR
function Run-Cmd($cmd) {
    Start-Process cmd -ArgumentList "/c $cmd" -Wait -NoNewWindow
}

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

# PANEL
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(460,400)
$panel.Location = New-Object System.Drawing.Point(30,90)
$panel.BackColor = "#282828"
$form.Controls.Add($panel)

# GERİ YÜKLEME
$cbRestore = New-Object System.Windows.Forms.CheckBox
$cbRestore.Text = "Geri Yükleme Noktası Oluştur (Önerilir)"
$cbRestore.ForeColor = "White"
$cbRestore.BackColor = "#282828"
$cbRestore.Location = New-Object System.Drawing.Point(20,20)
$panel.Controls.Add($cbRestore)

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
$y = 60
foreach ($i in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.ForeColor = "White"
    $cb.BackColor = "#282828"
    $cb.Location = New-Object System.Drawing.Point(20,$y)
    $panel.Controls.Add($cb)
    $boxes += $cb
    $y += 30
}

# BUTTON
$run = New-Object System.Windows.Forms.Button
$run.Text = "Başlat"
$run.Size = New-Object System.Drawing.Size(150,45)
$run.Location = New-Object System.Drawing.Point(180,510)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$form.Controls.Add($run)

# STATUS
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.Size = New-Object System.Drawing.Size(460,100)
$statusBox.Location = New-Object System.Drawing.Point(30,560)
$statusBox.BackColor = "#111"
$statusBox.ForeColor = "White"
$statusBox.ScrollBars = "Vertical"
$form.Controls.Add($statusBox)

# STARTUP
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Dock = "Fill"

    foreach ($a in $apps) { $list.Items.Add($a.Name) }
    $f.Controls.Add($list)

    $f.ShowDialog()
    return $list.CheckedItems
}

# RUN
$run.Add_Click({

    Log "Başlatılıyor..."

    if ($cbRestore.Checked) {
        try {
            Log "Geri yükleme noktası oluşturuluyor..."
            Checkpoint-Computer -Description "MaintainX" -RestorePointType "MODIFY_SETTINGS"
        } catch { Log "Geri yükleme başarısız" }
    }

    foreach ($b in $boxes) {
        if ($b.Checked) {

            try {

                switch ($b.Text) {

                    "Sistem dosyalarını onar" {
                        Log "SFC/DISM çalışıyor..."
                        Run-Cmd "DISM /Online /Cleanup-Image /RestoreHealth"
                        Run-Cmd "sfc /scannow"
                    }

                    "Disk hatalarını kontrol et" {
                        foreach ($d in Get-Volume | Where DriveLetter) {
                            Log "Disk $($d.DriveLetter) kontrol ediliyor..."
                            Run-Cmd "chkdsk $($d.DriveLetter) /f /r /x"
                        }
                    }

                    "Virüs taraması yap" {
                        Log "Virüs taraması..."
                        Start-MpScan -ScanType FullScan
                    }

                    "Geçici dosyaları temizle" {
                        Log "Temp temizleniyor..."
                        $paths=@("$env:TEMP","C:\Windows\Temp")
                        foreach($p in $paths){
                            try { Remove-Item "$p\*" -Recurse -Force -ErrorAction Stop }
                            catch { Log "$p temizlenemedi" }
                        }
                    }

                    "Disk temizleme" {
                        Log "Disk temizleme..."
                        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait
                    }

                    "Diski optimize et" {
                        foreach ($d in Get-Volume | Where DriveLetter) {
                            try {
                                Log "Disk $($d.DriveLetter) optimize ediliyor..."
                                Optimize-Volume -DriveLetter $d.DriveLetter -ErrorAction Stop
                            } catch {
                                Log "$($d.DriveLetter) optimize edilemedi"
                            }
                        }
                    }

                    "DNS önbelleğini temizle" {
                        Run-Cmd "ipconfig /flushdns"
                    }

                    "İnternet ayarlarını sıfırla" {
                        Run-Cmd "netsh winsock reset"
                        Run-Cmd "netsh int ip reset"
                    }

                    "Güncellemeleri kontrol et" {
                        try {
                            Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                            Import-Module PSWindowsUpdate
                            Get-WindowsUpdate -AcceptAll -Install
                        } catch { Log "Update hatası" }
                    }
                }

            } catch {
                Log "$($b.Text) hata verdi"
            }
        }
    }

    Log ""
    Log "Bitti. Yeniden başlat önerilir."
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı.")
})

[void]$form.ShowDialog()
