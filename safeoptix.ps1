#Requires -RunAsAdministrator
#Requires -Version 5.1

<#
.SYNOPSIS
    SafeOptix Ultra v3.0 - Windows Sistem Optimizasyon Aracı
.DESCRIPTION
    Sistem onarımı, disk temizliği, güvenlik taraması ve optimizasyon işlemleri
.NOTES
    Yönetici hakları gerektirir
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==================== ASSEMBLY YÜKLEMELERİ ====================
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Error "Gerekli assembly'ler yüklenemedi: $_"
    exit 1
}

# ==================== GLOBAL DEĞİŞKENLER ====================
$script:FormClosed = $false
$script:OperationRunning = $false

# ==================== RENK TANIMLARI ====================
$Colors = @{
    Background      = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
    PanelDark       = [System.Drawing.ColorTranslator]::FromHtml("#333337")
    StatusBg        = [System.Drawing.ColorTranslator]::FromHtml("#1E1E1E")
    Primary         = [System.Drawing.ColorTranslator]::FromHtml("#00A2FF")
    TextLight       = [System.Drawing.ColorTranslator]::FromHtml("#D1D1D1")
    TextMuted       = [System.Drawing.ColorTranslator]::FromHtml("#AAAAAA")
    ButtonBg        = [System.Drawing.ColorTranslator]::FromHtml("#3F3F46")
    Success         = [System.Drawing.ColorTranslator]::FromHtml("#00FF41")
    Warning         = [System.Drawing.ColorTranslator]::FromHtml("#FFD700")
    Error           = [System.Drawing.ColorTranslator]::FromHtml("#FF6B6B")
}

# ==================== ANA FORM ====================
$form = New-Object System.Windows.Forms.Form -Property @{
    Text            = "SafeOptix Ultra v3.0"
    Size            = New-Object System.Drawing.Size(550, 880)
    StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterScreen
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    MaximizeBox     = $false
    MinimizeBox     = $true
    BackColor       = $Colors.Background
    Font            = New-Object System.Drawing.Font("Segoe UI", 9)
}

# Form kapanırken temizlik
$form.Add_FormClosing({
    param($sender, $e)
    if ($script:OperationRunning) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "İşlem devam ediyor. Çıkmak istediğinize emin misiniz?",
            "Uyarı",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($result -eq [System.Windows.Forms.DialogResult]::No) {
            $e.Cancel = $true
            return
        }
    }
    $script:FormClosed = $true
})

# ==================== LOG FONKSİYONU ====================
function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    if ($script:FormClosed) { return }
    
    $color = switch ($Level) {
        'Success' { $Colors.Success }
        'Warning' { $Colors.Warning }
        'Error'   { $Colors.Error }
        default   { $Colors.TextMuted }
    }
    
    $prefix = switch ($Level) {
        'Success' { "✓" }
        'Warning' { "⚠" }
        'Error'   { "✗" }
        default   { "»" }
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = $color
    $statusBox.AppendText("[$timestamp] $prefix $Message`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== PROGRESS GÜNCELLEME ====================
function Update-Progress {
    param(
        [int]$Value,
        [int]$Maximum = 100
    )
    
    if ($script:FormClosed) { return }
    
    $percent = [math]::Min(100, [math]::Max(0, [int](($Value / $Maximum) * 100)))
    $progressBar.Value = $percent
    $pctLabel.Text = "%$percent"
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== HEADER PANEL ====================
$headerLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "SAFEOPTIX"
    Font      = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
    ForeColor = $Colors.Primary
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Size      = New-Object System.Drawing.Size(550, 50)
    Location  = New-Object System.Drawing.Point(0, 15)
}
$form.Controls.Add($headerLabel)

$subHeaderLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "SYSTEM OPTIMIZER | BUILD 2026"
    Font      = New-Object System.Drawing.Font("Consolas", 8)
    ForeColor = $Colors.TextMuted
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Size      = New-Object System.Drawing.Size(550, 20)
    Location  = New-Object System.Drawing.Point(0, 60)
}
$form.Controls.Add($subHeaderLabel)

# ==================== TÜMÜNÜ SEÇ BUTONU ====================
$selectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Tümünü Seç / Kaldır"
    Size      = New-Object System.Drawing.Size(150, 28)
    Location  = New-Object System.Drawing.Point(365, 90)
    BackColor = $Colors.ButtonBg
    ForeColor = $Colors.TextLight
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    Cursor    = [System.Windows.Forms.Cursors]::Hand
}
$selectAllButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($selectAllButton)

# ==================== SEÇENEK PANELİ ====================
$optionsPanel = New-Object System.Windows.Forms.Panel -Property @{
    Size       = New-Object System.Drawing.Size(480, 420)
    Location   = New-Object System.Drawing.Point(35, 125)
    BackColor  = $Colors.PanelDark
    AutoScroll = $true
}
$form.Controls.Add($optionsPanel)

# ==================== CHECKBOX OLUŞTURMA ====================
$script:checkBoxes = @{}
$script:yPosition = 15

function New-OptionCheckBox {
    param(
        [Parameter(Mandatory)]
        [string]$Key,
        
        [Parameter(Mandatory)]
        [string]$Text,
        
        [string]$Tooltip = "",
        [bool]$Highlighted = $false
    )
    
    $checkBox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text      = " $Text"
        ForeColor = if ($Highlighted) { $Colors.Primary } else { $Colors.TextLight }
        FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        Font      = New-Object System.Drawing.Font("Segoe UI", 9, $(if ($Highlighted) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }))
        Location  = New-Object System.Drawing.Point(20, $script:yPosition)
        Size      = New-Object System.Drawing.Size(420, 32)
        Cursor    = [System.Windows.Forms.Cursors]::Hand
    }
    
    if ($Tooltip) {
        $toolTip = New-Object System.Windows.Forms.ToolTip
        $toolTip.SetToolTip($checkBox, $Tooltip)
    }
    
    $optionsPanel.Controls.Add($checkBox)
    $script:checkBoxes[$Key] = $checkBox
    $script:yPosition += 38
    
    return $checkBox
}

# Seçenekleri oluştur
New-OptionCheckBox -Key "RestorePoint" -Text "Sistem Geri Yükleme Noktası (Önerilir)" -Tooltip "İşlemlerden önce güvenlik noktası oluşturur" -Highlighted $true
New-OptionCheckBox -Key "SFC" -Text "Sistem dosyalarını onar (SFC)" -Tooltip "System File Checker ile bozuk dosyaları tarar"
New-OptionCheckBox -Key "DISM" -Text "Windows imajını onar (DISM)" -Tooltip "Deployment Image Service ile sistem imajını onarır"
New-OptionCheckBox -Key "CHKDSK" -Text "Disk hatalarını kontrol et" -Tooltip "Disk sektör hatalarını tarar (yeniden başlatma gerekebilir)"
New-OptionCheckBox -Key "Defender" -Text "Windows Defender taraması" -Tooltip "Hızlı virüs taraması başlatır"
New-OptionCheckBox -Key "TempFiles" -Text "Geçici dosyaları temizle" -Tooltip "Temp, Prefetch ve önbellek dosyalarını siler"
New-OptionCheckBox -Key "DiskCleanup" -Text "Disk temizleme (Cleanmgr)" -Tooltip "Windows Disk Temizleme aracını çalıştırır"
New-OptionCheckBox -Key "Defrag" -Text "Diski optimize et" -Tooltip "HDD için defrag, SSD için TRIM uygular"
New-OptionCheckBox -Key "Startup" -Text "Başlangıç programlarını düzenle" -Tooltip "Otomatik başlayan programları yönetir"
New-OptionCheckBox -Key "DNSFlush" -Text "DNS önbelleğini temizle" -Tooltip "DNS cache'i sıfırlar"
New-OptionCheckBox -Key "NetworkReset" -Text "Ağ ayarlarını sıfırla" -Tooltip "Winsock ve TCP/IP yığınını sıfırlar"
New-OptionCheckBox -Key "WindowsUpdate" -Text "Güncellemeleri kontrol et" -Tooltip "Windows Update'i başlatır"

# Tümünü Seç/Kaldır mantığı
$script:allSelected = $false
$selectAllButton.Add_Click({
    $script:allSelected = -not $script:allSelected
    foreach ($cb in $script:checkBoxes.Values) {
        $cb.Checked = $script:allSelected
    }
})

# ==================== PROGRESS ALANI ====================
$pctLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "%0"
    ForeColor = $Colors.Primary
    Font      = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Size      = New-Object System.Drawing.Size(550, 25)
    Location  = New-Object System.Drawing.Point(0, 560)
}
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Size     = New-Object System.Drawing.Size(480, 10)
    Location = New-Object System.Drawing.Point(35, 590)
    Style    = [System.Windows.Forms.ProgressBarStyle]::Continuous
    Minimum  = 0
    Maximum  = 100
    Value    = 0
}
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$runButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "▶  OPERASYONU BAŞLAT"
    Size      = New-Object System.Drawing.Size(320, 55)
    Location  = New-Object System.Drawing.Point(115, 615)
    BackColor = $Colors.Primary
    ForeColor = [System.Drawing.Color]::White
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    Font      = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    Cursor    = [System.Windows.Forms.Cursors]::Hand
}
$runButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($runButton)

# ==================== DURUM KUTUSU ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Size        = New-Object System.Drawing.Size(480, 150)
    Location    = New-Object System.Drawing.Point(35, 685)
    BackColor   = $Colors.StatusBg
    ForeColor   = $Colors.Success
    BorderStyle = [System.Windows.Forms.BorderStyle]::None
    Font        = New-Object System.Drawing.Font("Consolas", 9)
    ReadOnly    = $true
    ScrollBars  = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
}
$form.Controls.Add($statusBox)

# ==================== YARDIMCI FONKSİYONLAR ====================

function New-RestorePoint {
    param([string]$Description = "SafeOptix Otomatik Yedek")
    
    try {
        Write-Log "Geri yükleme noktası oluşturuluyor..." -Level Info
        
        # Sistem koruması etkin mi kontrol et
        $protection = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description $Description -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        
        Write-Log "Geri yükleme noktası oluşturuldu" -Level Success
        return $true
    } catch {
        Write-Log "Geri yükleme noktası oluşturulamadı: $($_.Exception.Message)" -Level Warning
        return $false
    }
}

function Invoke-SystemFileChecker {
    try {
        Write-Log "Sistem dosyaları taranıyor (SFC)..." -Level Info
        
        $process = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -WindowStyle Hidden -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "SFC tamamlandı - Sorun bulunamadı veya onarıldı" -Level Success
        } else {
            Write-Log "SFC tamamlandı - Bazı dosyalar onarılamadı (Kod: $($process.ExitCode))" -Level Warning
        }
        return $true
    } catch {
        Write-Log "SFC hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Invoke-DISM {
    try {
        Write-Log "Windows imajı onarılıyor (DISM)..." -Level Info
        
        $process = Start-Process -FilePath "DISM.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -WindowStyle Hidden -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "DISM tamamlandı" -Level Success
        } else {
            Write-Log "DISM tamamlandı (Kod: $($process.ExitCode))" -Level Warning
        }
        return $true
    } catch {
        Write-Log "DISM hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Invoke-DiskCheck {
    try {
        Write-Log "Disk kontrol planlanıyor..." -Level Info
        
        $result = & chkdsk $env:SystemDrive 2>&1
        Write-Log "Disk durumu kontrol edildi" -Level Success
        
        $scheduleResult = [System.Windows.Forms.MessageBox]::Show(
            "Tam disk kontrolü için yeniden başlatma gerekiyor. Bir sonraki açılışta kontrol yapılsın mı?",
            "Disk Kontrolü",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($scheduleResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            & fsutil dirty set $env:SystemDrive
            Write-Log "Disk kontrolü planlandı (sonraki başlatmada)" -Level Info
        }
        return $true
    } catch {
        Write-Log "Disk kontrol hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Invoke-DefenderScan {
    try {
        Write-Log "Windows Defender taraması başlatılıyor..." -Level Info
        
        $defenderPath = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
        
        if (Test-Path $defenderPath) {
            Start-Process -FilePath $defenderPath -ArgumentList "-Scan", "-ScanType", "1" -WindowStyle Hidden -Wait
            Write-Log "Defender hızlı taraması tamamlandı" -Level Success
        } else {
            Write-Log "Windows Defender bulunamadı" -Level Warning
        }
        return $true
    } catch {
        Write-Log "Defender hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Clear-TempFiles {
    try {
        Write-Log "Geçici dosyalar temizleniyor..." -Level Info
        
        $paths = @(
            "$env:TEMP",
            "$env:SystemRoot\Temp",
            "$env:SystemRoot\Prefetch",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
        )
        
        $totalCleared = 0
        
        foreach ($path in $paths) {
            if (Test-Path $path) {
                try {
                    $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    $size = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    $totalCleared += $size
                    
                    Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                } catch {
                    # Kullanımda olan dosyaları atla
                }
            }
        }
        
        $clearedMB = [math]::Round($totalCleared / 1MB, 2)
        Write-Log "Geçici dosyalar temizlendi (~$clearedMB MB)" -Level Success
        return $true
    } catch {
        Write-Log "Temp temizleme hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Invoke-DiskCleanup {
    try {
        Write-Log "Disk temizleme başlatılıyor..." -Level Info
        
        # Önceden ayarlanmış temizlik profili
        $cleanupKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
        
        if (Test-Path $cleanupKey) {
            $subKeys = Get-ChildItem -Path $cleanupKey -ErrorAction SilentlyContinue
            foreach ($key in $subKeys) {
                Set-ItemProperty -Path $key.PSPath -Name "StateFlags0100" -Value 2 -Type DWord -ErrorAction SilentlyContinue
            }
        }
        
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:100" -Wait -WindowStyle Hidden
        
        Write-Log "Disk temizleme tamamlandı" -Level Success
        return $true
    } catch {
        Write-Log "Disk temizleme hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Optimize-Disk {
    try {
        Write-Log "Disk optimize ediliyor..." -Level Info
        
        $volume = Get-Volume -DriveLetter ($env:SystemDrive -replace ':', '') -ErrorAction Stop
        
        if ($volume.DriveType -eq 'Fixed') {
            Optimize-Volume -DriveLetter ($env:SystemDrive -replace ':', '') -ErrorAction Stop
            Write-Log "Disk optimizasyonu tamamlandı" -Level Success
        } else {
            Write-Log "Bu sürücü türü optimize edilemez" -Level Warning
        }
        return $true
    } catch {
        Write-Log "Disk optimizasyon hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Show-StartupManager {
    try {
        Write-Log "Başlangıç programları alınıyor..." -Level Info
        
        $startupItems = Get-CimInstance -ClassName Win32_StartupCommand -ErrorAction Stop | 
            Where-Object { $_.User -like "*$env:USERNAME*" -or $_.User -eq "Public" }
        
        if (-not $startupItems) {
            Write-Log "Başlangıç öğesi bulunamadı" -Level Info
            return $true
        }
        
        # Başlangıç yöneticisi formu
        $startupForm = New-Object System.Windows.Forms.Form -Property @{
            Text            = "Başlangıç Programları"
            Size            = New-Object System.Drawing.Size(500, 500)
            StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterParent
            BackColor       = $Colors.Background
            FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
            MaximizeBox     = $false
        }
        
        $listLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "Devre dışı bırakmak istediğiniz programları seçin:"
            ForeColor = $Colors.TextLight
            Location  = New-Object System.Drawing.Point(20, 15)
            Size      = New-Object System.Drawing.Size(450, 25)
        }
        $startupForm.Controls.Add($listLabel)
        
        $checkedList = New-Object System.Windows.Forms.CheckedListBox -Property @{
            Size        = New-Object System.Drawing.Size(440, 340)
            Location    = New-Object System.Drawing.Point(20, 45)
            BackColor   = $Colors.StatusBg
            ForeColor   = [System.Drawing.Color]::White
            BorderStyle = [System.Windows.Forms.BorderStyle]::None
        }
        
        foreach ($item in $startupItems) {
            [void]$checkedList.Items.Add("$($item.Name) - $($item.Location)")
        }
        $startupForm.Controls.Add($checkedList)
        
        $applyButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Seçilenleri Devre Dışı Bırak"
            Size      = New-Object System.Drawing.Size(200, 40)
            Location  = New-Object System.Drawing.Point(140, 400)
            BackColor = $Colors.Primary
            ForeColor = [System.Drawing.Color]::White
            FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        }
        $applyButton.FlatAppearance.BorderSize = 0
        
        $applyButton.Add_Click({
            $selectedItems = $checkedList.CheckedItems
            if ($selectedItems.Count -gt 0) {
                Write-Log "$($selectedItems.Count) başlangıç öğesi işaretlendi" -Level Info
            }
            $startupForm.Close()
        })
        $startupForm.Controls.Add($applyButton)
        
        $startupForm.ShowDialog($form) | Out-Null
        
        Write-Log "Başlangıç yöneticisi kapatıldı" -Level Info
        return $true
    } catch {
        Write-Log "Başlangıç yöneticisi hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Clear-DNSCache {
    try {
        Write-Log "DNS önbelleği temizleniyor..." -Level Info
        
        Clear-DnsClientCache -ErrorAction Stop
        
        Write-Log "DNS önbelleği temizlendi" -Level Success
        return $true
    } catch {
        Write-Log "DNS temizleme hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Reset-NetworkSettings {
    try {
        Write-Log "Ağ ayarları sıfırlanıyor..." -Level Info
        
        # Winsock sıfırla
        & netsh winsock reset 2>&1 | Out-Null
        
        # IP yapılandırmasını sıfırla
        & netsh int ip reset 2>&1 | Out-Null
        
        # DNS önbelleğini temizle
        & ipconfig /flushdns 2>&1 | Out-Null
        
        Write-Log "Ağ ayarları sıfırlandı (yeniden başlatma önerilir)" -Level Success
        return $true
    } catch {
        Write-Log "Ağ sıfırlama hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Start-WindowsUpdate {
    try {
        Write-Log "Windows Update başlatılıyor..." -Level Info
        
        Start-Process "ms-settings:windowsupdate" -ErrorAction Stop
        
        Write-Log "Windows Update açıldı" -Level Success
        return $true
    } catch {
        Write-Log "Windows Update hatası: $($_.Exception.Message)" -Level Error
        return $false
    }
}

# ==================== ANA OPERASYON MOTORU ====================
$runButton.Add_Click({
    # Seçim kontrolü
    $selectedOperations = $script:checkBoxes.GetEnumerator() | Where-Object { $_.Value.Checked }
    
    if (-not $selectedOperations) {
        [System.Windows.Forms.MessageBox]::Show(
            "Lütfen en az bir işlem seçin.",
            "Uyarı",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }
    
    # Onay al
    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        "Seçilen $(@($selectedOperations).Count) işlem başlatılacak. Devam edilsin mi?",
        "Onay",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }
    
    # UI'ı kilitle
    $script:OperationRunning = $true
    $runButton.Enabled = $false
    $runButton.Text = "⏳ İŞLEM DEVAM EDİYOR..."
    $selectAllButton.Enabled = $false
    foreach ($cb in $script:checkBoxes.Values) { $cb.Enabled = $false }
    
    $statusBox.Clear()
    Write-Log "SafeOptix Ultra v3.0 başlatıldı" -Level Info
    Write-Log "=" * 45 -Level Info
    
    # İşlem haritası
    $operations = [ordered]@{
        "RestorePoint"   = { New-RestorePoint }
        "SFC"            = { Invoke-SystemFileChecker }
        "DISM"           = { Invoke-DISM }
        "CHKDSK"         = { Invoke-DiskCheck }
        "Defender"       = { Invoke-DefenderScan }
        "TempFiles"      = { Clear-TempFiles }
        "DiskCleanup"    = { Invoke-DiskCleanup }
        "Defrag"         = { Optimize-Disk }
        "Startup"        = { Show-StartupManager }
        "DNSFlush"       = { Clear-DNSCache }
        "NetworkReset"   = { Reset-NetworkSettings }
        "WindowsUpdate"  = { Start-WindowsUpdate }
    }
    
    $totalOps = @($selectedOperations).Count
    $currentOp = 0
    $successCount = 0
    $failCount = 0
    
    foreach ($op in $selectedOperations) {
        if ($script:FormClosed) { break }
        
        $currentOp++
        Update-Progress -Value $currentOp -Maximum $totalOps
        
        $key = $op.Key
        if ($operations.ContainsKey($key)) {
            try {
                $result = & $operations[$key]
                if ($result) { $successCount++ } else { $failCount++ }
            } catch {
                Write-Log "Beklenmeyen hata ($key): $($_.Exception.Message)" -Level Error
                $failCount++
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    # Sonuç özeti
    Write-Log "=" * 45 -Level Info
    Write-Log "Tamamlandı: $successCount başarılı, $failCount başarısız" -Level $(if ($failCount -eq 0) { 'Success' } else { 'Warning' })
    
    Update-Progress -Value 100 -Maximum 100
    
    # UI'ı aç
    $script:OperationRunning = $false
    $runButton.Enabled = $true
    $runButton.Text = "▶  OPERASYONU BAŞLAT"
    $selectAllButton.Enabled = $true
    foreach ($cb in $script:checkBoxes.Values) { $cb.Enabled = $true }
    
    [System.Windows.Forms.MessageBox]::Show(
        "İşlemler tamamlandı.`n`nBaşarılı: $successCount`nBaşarısız: $failCount",
        "SafeOptix",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
})

# ==================== FORM BAŞLAT ====================
Write-Log "SafeOptix Ultra v3.0 hazır" -Level Success
Write-Log "İşlem seçin ve başlatın" -Level Info

[void]$form.ShowDialog()

# Temizlik
$form.Dispose()
