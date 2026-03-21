# ==================== PROGRESS BAR ====================
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(580,25)
$progressBar.Location = New-Object System.Drawing.Point(30, 690)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# ==================== ÇALIŞTIR ====================
$run.Add_Click({
    $run.Enabled = $false
    $allTasks = @()
    if($cbRestore.Checked){$allTasks+=$cbRestore}
    $allTasks += $boxes | Where-Object {$_.Checked}

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
                    Checkpoint-Computer -Description "SafeOptix Öncesi Bakım" -RestorePointType "MODIFY_SETTINGS"
                    Log("✔ Geri yükleme noktası oluşturuldu","success")
                }
                "Sistem dosyalarını onar"{
                    DISM /Online /Cleanup-Image /RestoreHealth
                    sfc /scannow
                    Log("✔ Sistem dosyaları onarıldı","success")
                }
                "Disk hatalarını kontrol et"{
                    $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($d in $drives){
                        chkdsk $d.DriveLetter /f /r /x
                        Log("✔ Disk $($d.DriveLetter) kontrol edildi","success")
                    }
                }
                "Virüs taraması yap"{ Start-MpScan -ScanType FullScan; Log("✔ Virüs taraması tamamlandı","success") }
                "Geçici dosyaları temizle"{
                    $paths=@("$env:TEMP","C:\Windows\Temp","$env:LOCALAPPDATA\Temp")
                    foreach($p in $paths){
                        if(Test-Path $p){
                            Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                                try{ Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop } catch{}
                            }
                        }
                    }
                    Log("✔ Geçici dosyalar temizlendi","success")
                }
                "Disk temizleme"{ cleanmgr /sagerun:1; Log("✔ Disk temizleme tamamlandı","success") }
                "Diski optimize et"{
                    $vols=Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
                    foreach($v in $vols){ try{ Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim } catch{} }
                    Log("✔ Disk optimize edildi","success")
                }
                "Başlangıç programlarını düzenle"{
                    $sec=StartupSec
                    foreach($s in $sec){ try{ Get-CimInstance Win32_StartupCommand | Where-Object {$_.Name -eq $s} | Disable-CimInstance } catch{} }
                    Log("✔ Başlangıç programları düzenlendi","success")
                }
                "DNS önbelleğini temizle"{ ipconfig /flushdns; Log("✔ DNS önbelleği temizlendi","success") }
                "İnternet ayarlarını sıfırla"{ netsh winsock reset; netsh int ip reset; Log("✔ İnternet ayarları sıfırlandı","success") }
                "Güncellemeleri kontrol et"{
                    try{
                        Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
                        Import-Module PSWindowsUpdate
                        Get-WindowsUpdate -AcceptAll -Install
                    }catch{}
                    Log("✔ Güncellemeler kontrol edildi","success")
                }
            }
        }catch{
            Log("❌ $($task.Text) sırasında hata oluştu","error")
        }
    }

    $progressBar.Value = 100
    Log("")
    Log("✅ TÜM İŞLEMLER TAMAMLANDI","success")
    [System.Windows.Forms.MessageBox]::Show("Bakım tamamlandı")
    $run.Enabled=$true
})
