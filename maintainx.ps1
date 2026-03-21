Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = "Bakım"
$form.Size = New-Object System.Drawing.Size(520,640)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#181818"

# BAŞLIK
$title = New-Object System.Windows.Forms.Label
$title.Text = "Windows Bakım"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = "White"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(150,15)
$form.Controls.Add($title)

# ALT METİN
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Yapmak istediğin işlemleri seç ve başlat."
$subtitle.Font = New-Object System.Drawing.Font("Segoe UI",9)
$subtitle.ForeColor = "Gray"
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(120,50)
$form.Controls.Add($subtitle)

# PANEL (checkbox alanı)
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(460,360)
$panel.Location = New-Object System.Drawing.Point(30,90)
$panel.BackColor = "#202020"
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

foreach ($i in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.ForeColor = "White"
    $cb.BackColor = "#202020"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI",9)
    $cb.Location = New-Object System.Drawing.Point(20,$y)
    $cb.AutoSize = $true
    $panel.Controls.Add($cb)
    $boxes += $cb
    $y += 32
}

# BAŞLAT BUTON
$run = New-Object System.Windows.Forms.Button
$run.Text = "Başlat"
$run.Size = New-Object System.Drawing.Size(140,40)
$run.Location = New-Object System.Drawing.Point(180,470)
$run.BackColor = "#0A84FF"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# STATUS BOX
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.Size = New-Object System.Drawing.Size(460,90)
$statusBox.Location = New-Object System.Drawing.Point(30,520)
$statusBox.BackColor = "#111111"
$statusBox.ForeColor = "LightGray"
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# STARTUP SEÇİM
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }

    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Başlangıç Programları"
    $f.Size = New-Object System.Drawing.Size(380,380)
    $f.BackColor = "#202020"

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

    foreach ($b in $boxes) {
        if ($b.Checked) {

            $statusBox.AppendText("→ $($b.Text)`r`n")

            switch ($b.Text) {

                "Sistem dosyalarını onar" {
                    DISM /Online /Cleanup-Image /RestoreHealth
                    sfc /scannow
                }

                "Disk hatalarını kontrol et" {
                    Get-PSDrive -PSProvider FileSystem | % { chkdsk $_.Name /f /r /x }
                }

                "Virüs taraması yap" {
                    Start-MpScan -ScanType FullScan
                }

                "Geçici dosyaları temizle" {
                    $p=@("$env:TEMP","C:\Windows\Temp","$env:SystemRoot\Prefetch","$env:USERPROFILE\Recent")
                    foreach($x in $p){Remove-Item "$x\*" -Recurse -Force -ErrorAction SilentlyContinue}
                }

                "Disk temizleme" {
                    cleanmgr /sagerun:1
                }

                "Diski optimize et" {
                    Get-PSDrive -PSProvider FileSystem | % { Optimize-Volume -DriveLetter $_.Name -ReTrim }
                }

                "Başlangıç programlarını düzenle" {
                    $sec = StartupSec
                    foreach ($s in $sec) {
                        Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance
                    }
                }

                "DNS önbelleğini temizle" {
                    ipconfig /flushdns
                }

                "İnternet ayarlarını sıfırla" {
                    netsh winsock reset
                    netsh int ip reset
                }

                "Güncellemeleri kontrol et" {
                    Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                    Import-Module PSWindowsUpdate
                    Get-WindowsUpdate -AcceptAll -Install
                }
            }
        }
    }

    $statusBox.AppendText("`r`nBitti. Yeniden başlat önerilir.")
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı.")
})

[void]$form.ShowDialog()
