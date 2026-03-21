Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = "MaintainX"
$form.Size = New-Object System.Drawing.Size(560,720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#121212"

# LOG
function Log($text) {
    $statusBox.AppendText($text + "`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
    $statusBox.Refresh()
}

function Run-Cmd($cmd) {
    Start-Process cmd -ArgumentList "/c $cmd" -Wait -NoNewWindow
}

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "MaintainX"
$title.Font = New-Object System.Drawing.Font("Segoe UI",22,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(200,15)
$form.Controls.Add($title)

# SUBTITLE
$sub = New-Object System.Windows.Forms.Label
$sub.Text = "Windows bakım aracın"
$sub.Font = New-Object System.Drawing.Font("Segoe UI",10)
$sub.ForeColor = "Gray"
$sub.AutoSize = $true
$sub.Location = New-Object System.Drawing.Point(205,60)
$form.Controls.Add($sub)

# PANEL
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(500,440)
$panel.Location = New-Object System.Drawing.Point(25,100)
$panel.BackColor = "#1E1E1E"
$panel.BorderStyle = "FixedSingle"
$form.Controls.Add($panel)

# RESTORE
$cbRestore = New-Object System.Windows.Forms.CheckBox
$cbRestore.Text = "Geri Yükleme Noktası Oluştur (Önerilir)"
$cbRestore.ForeColor = "White"
$cbRestore.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$cbRestore.Location = New-Object System.Drawing.Point(20,20)
$panel.Controls.Add($cbRestore)

# ITEMS
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

$boxes=@()
$y=60
foreach($i in $items){
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.ForeColor="White"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI",10)
    $cb.Location = New-Object System.Drawing.Point(20,$y)
    $cb.AutoSize = $true
    $panel.Controls.Add($cb)
    $boxes+=$cb
    $y+=34
}

# BUTTON
$run = New-Object System.Windows.Forms.Button
$run.Text="Başlat"
$run.Size=New-Object System.Drawing.Size(200,50)
$run.Location=New-Object System.Drawing.Point(180,560)
$run.BackColor="#0A84FF"
$run.ForeColor="White"
$run.FlatStyle="Flat"
$run.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# STATUS
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline=$true
$statusBox.Size=New-Object System.Drawing.Size(500,120)
$statusBox.Location=New-Object System.Drawing.Point(25,620)
$statusBox.BackColor="#0F0F0F"
$statusBox.ForeColor="LightGray"
$statusBox.ScrollBars="Vertical"
$statusBox.ReadOnly=$true
$statusBox.Font = New-Object System.Drawing.Font("Consolas",9)
$form.Controls.Add($statusBox)

# STARTUP
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name}
    if(!$apps){ return @() }

    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"
    $f.Size = New-Object System.Drawing.Size(420,420)
    $f.BackColor="#1E1E1E"

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Dock="Fill"
    $list.BackColor="#111"
    $list.ForeColor="White"

    foreach($a in $apps){ $list.Items.Add($a.Name) }

    $f.Controls.Add($list)
    $f.ShowDialog()

    return $list.CheckedItems
}

# RUN
$run.Add_Click({

    $statusBox.Clear()
    Log "Başlatıldı"

    if($cbRestore.Checked){
        try{
            Log "Geri yükleme noktası oluşturuluyor..."
            Checkpoint-Computer -Description "MaintainX" -RestorePointType "MODIFY_SETTINGS"
            Log "✔ Geri yükleme tamamlandı"
        }catch{
            Log "❌ Geri yükleme başarısız"
        }
    }

    foreach($b in $boxes){
        if($b.Checked){

            Log ""
            Log "▶ $($b.Text)"

            try{

                switch($b.Text){

                    "Sistem dosyalarını onar"{
                        Run-Cmd "DISM /Online /Cleanup-Image /RestoreHealth"
                        Run-Cmd "sfc /scannow"
                    }

                    "Disk hatalarını kontrol et"{
                        foreach($d in Get-Volume | Where-Object {$_.DriveLetter -ne $null -and $_.DriveType -eq 'Fixed'}){
                            Run-Cmd "chkdsk $($d.DriveLetter) /f /r /x"
                        }
                    }

                    "Virüs taraması yap"{
                        Start-MpScan -ScanType FullScan
                    }

                    "Geçici dosyaları temizle"{
                        $paths=@("$env:TEMP","C:\Windows\Temp")
                        foreach($p in $paths){
                            try{ Remove-Item "$p\*" -Recurse -Force -ErrorAction Stop }catch{}
                        }
                    }

                    "Disk temizleme"{
                        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait
                    }

                    "Diski optimize et"{
                        foreach($d in Get-Volume | Where-Object {$_.DriveLetter -ne $null -and $_.DriveType -eq 'Fixed'}){
                            try{ Optimize-Volume -DriveLetter $d.DriveLetter -ErrorAction Stop }catch{}
                        }
                    }

                    "Başlangıç programlarını düzenle"{
                        $sec = StartupSec
                        foreach($s in $sec){
                            try{
                                Get-CimInstance Win32_StartupCommand |
                                Where-Object {$_.Name -eq $s} |
                                Disable-CimInstance
                            }catch{}
                        }
                    }

                    "DNS önbelleğini temizle"{
                        Run-Cmd "ipconfig /flushdns"
                    }

                    "İnternet ayarlarını sıfırla"{
                        Run-Cmd "netsh winsock reset"
                        Run-Cmd "netsh int ip reset"
                    }

                    "Güncellemeleri kontrol et"{
                        try{
                            Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                            Import-Module PSWindowsUpdate
                            Get-WindowsUpdate -AcceptAll -Install
                        }catch{
                            Log "❌ Update hatası"
                        }
                    }
                }

                Log "✔ Tamamlandı"

            }catch{
                Log "❌ Hata oluştu"
            }
        }
    }

    Log ""
    Log "TÜM İŞLEMLER BİTTİ"
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı")
})

[void]$form.ShowDialog()
