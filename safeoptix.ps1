Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== FORM ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeCare - Windows Bakım"
$form.Size = New-Object System.Drawing.Size(650,820)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#121212"

# ==================== LOG FUNCTION ====================
function Log($text) {
    $statusBox.AppendText($text + "`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
}

# ==================== TITLE ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeCare"
$title.Font = New-Object System.Drawing.Font("Segoe UI",24,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(220,15)
$form.Controls.Add($title)

# ==================== PANEL ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(580,450)
$panel.Location = New-Object System.Drawing.Point(30,90)
$panel.BackColor = "#1E1E1E"
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# ==================== CHECKBOXES ====================
$y=20

# Geri Yükleme Noktası
$cbRestore = New-Object System.Windows.Forms.CheckBox
$cbRestore.Text = "Geri Yükleme Noktası Oluştur (Önerilir)"
$cbRestore.ForeColor = "White"
$cbRestore.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$cbRestore.Location = New-Object System.Drawing.Point(20,$y)
$cbRestore.Size = New-Object System.Drawing.Size(540,28)
$cbRestore.AutoSize = $false
$panel.Controls.Add($cbRestore)
$y+=32

$items=@(
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
foreach($i in $items){
    $cb=New-Object System.Windows.Forms.CheckBox
    $cb.Text=$i
    $cb.ForeColor="White"
    $cb.Font=New-Object System.Drawing.Font("Segoe UI",10)
    $cb.Location=New-Object System.Drawing.Point(20,$y)
    $cb.Size=New-Object System.Drawing.Size(540,28)
    $cb.AutoSize=$false
    $panel.Controls.Add($cb)
    $boxes+=$cb
    $y+=32
}

# ==================== PROGRESS BAR ====================
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(580,25)
$progressBar.Location = New-Object System.Drawing.Point(30,560)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# ==================== STATUS BOX ====================
$statusBox=New-Object System.Windows.Forms.TextBox
$statusBox.Multiline=$true
$statusBox.Size=New-Object System.Drawing.Size(580,180)
$statusBox.Location=New-Object System.Drawing.Point(30,600)
$statusBox.BackColor="#111111"
$statusBox.ForeColor="LightGray"
$statusBox.ReadOnly=$true
$statusBox.ScrollBars="Vertical"
$statusBox.WordWrap=$true
$form.Controls.Add($statusBox)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text="Başlat"
$run.Size=New-Object System.Drawing.Size(200,50)
$run.Location=New-Object System.Drawing.Point(220,790)
$run.BackColor="#0A84FF"
$run.ForeColor="White"
$run.FlatStyle="Flat"
$run.Font=New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== STARTUP SEC ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }
    $f=New-Object System.Windows.Forms.Form
    $f.Text="Başlangıç Programları"
    $f.Size=New-Object System.Drawing.Size(450,400)
    $f.StartPosition="CenterScreen"
    $f.BackColor="#1E1E1E"

    $list=New-Object System.Windows.Forms.CheckedListBox
    $list.Size=New-Object System.Drawing.Size(400,250)
    $list.Location=New-Object System.Drawing.Point(20,20)
    $list.BackColor="#111111"
    $list.ForeColor="White"
    foreach($a in $apps){$list.Items.Add($a.Name)}
    $f.Controls.Add($list)

    $ok=New-Object System.Windows.Forms.Button
    $ok.Text="Uygula"
    $ok.Location=New-Object System.Drawing.Point(160,290)
    $ok.BackColor="#0A84FF"
    $ok.ForeColor="White"
    $ok.FlatStyle="Flat"
    $f.Controls.Add($ok)

    $sec=@()
    $ok.Add_Click({
        foreach($i in $list.CheckedItems){$sec+=$i}
        $f.Close()
    })
    $f.ShowDialog()
    return $sec
}

# ==================== ÇALIŞTIR ====================
$run.Add_Click({
    $run.Enabled = $false
    $statusBox.Clear()
    $progressBar.Value = 0

    # Seçili öğeleri al
    $allTasks = @()
    if($cbRestore.Checked){$allTasks+=$cbRestore}
    $allTasks += $boxes | Where-Object {$_.Checked}

    if($allTasks.Count -eq 0){
        [System.Windows.Forms.MessageBox]::Show("Lütfen bir işlem seçin!")
        $run.Enabled = $true
        return
    }

    $taskCount = $allTasks.Count
    $current = 0

    foreach($task in $allTasks){
        $current++
        $percent = [int](($current / $taskCount) * 100)
        $progressBar.Value = $percent
        Log("[$percent%] ▶ $($task.Text)")

        try{
            switch($task.Text){
                "Geri Yükleme Noktası Oluştur (Önerilir)"{
                    Checkpoint-Computer -Description "SafeCare Öncesi Bakım" -RestorePointType "MODIFY_SETTINGS"
                    Log("✔ Geri yükleme noktası oluşturuldu")
                }
                "Sistem dosyalarını onar"{
                    DISM /Online /Cleanup-Image /RestoreHealth
                    sfc /scannow
                    Log("✔ Sistem dosyaları onarıldı")
                }
                "Disk hatalarını kontrol et"{
                    $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($d in $drives){
                        chkdsk $d.DriveLetter /f /r /x
                        Log("✔ Disk $($d.DriveLetter) kontrol edildi")
                    }
                }
                "Virüs taraması yap"{ Start-MpScan -ScanType FullScan; Log("✔ Virüs taraması tamamlandı") }
                "Geçici dosyaları temizle"{
                    $paths=@("$env:TEMP","C:\Windows\Temp","C:\Windows\Prefetch","$env:USERPROFILE\Recent")
                    foreach($p in $paths){
                        if(Test-Path $p){
                            Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                                try{ Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop } catch{}
                            }
                        }
                    }
                    Log("✔ Geçici dosyalar temizlendi")
                }
                "Disk temizleme"{ Log("⚠ Disk temizleme artık manuel yapılmıyor, geçici dosyaları temizle ile birleşti") }
                "Diski optimize et"{
                    $vols=Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($v in $vols){ try{ Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim } catch{} }
                    Log("✔ Disk optimize edildi")
                }
                "Başlangıç programlarını düzenle"{
                    $sec=StartupSec
                    foreach($s in $sec){ try{ Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance } catch{} }
                    Log("✔ Başlangıç programları düzenlendi")
                }
                "DNS önbelleğini temizle"{ ipconfig /flushdns; Log("✔ DNS önbelleği temizlendi") }
                "İnternet ayarlarını sıfırla"{ netsh winsock reset; netsh int ip reset; Log("✔ İnternet ayarları sıfırlandı") }
                "Güncellemeleri kontrol et"{
                    try{
                        Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                        Import-Module PSWindowsUpdate
                        Get-WindowsUpdate -AcceptAll -Install
                    }catch{}
                    Log("✔ Güncellemeler kontrol edildi")
                }
            }
        }catch{
            Log("❌ $($task.Text) sırasında hata oluştu")
        }
    }

    # Tamamlandıktan sonra progress bar ve checkbox reset
    $progressBar.Value = 100
    Log("")
    Log("✅ TÜM İŞLEMLER TAMAMLANDI")
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı")
    
    # Checkboxları sıfırla
    foreach($c in $boxes){$c.Checked=$false}
    $cbRestore.Checked = $false
    $progressBar.Value = 0
    $run.Enabled = $true
})

[void]$form.ShowDialog()
