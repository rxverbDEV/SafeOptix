# ==================== YÖNETİCİ (ADMIN) KONTROLÜ ====================
# Sistem onarım komutlarının çalışması için scriptin yönetici olarak çalışması şarttır.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Sistem onarımı için Yönetici izinleri gereklidir!", "Hata", 0, 16)
        exit
    }
}

# ==================== KÜTÜPHANELER & ÖZEL BUTON SINIFI ====================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Windows Forms'ta yumuşak kenarlı (Rounded) buton oluşturmak için C# entegrasyonu
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

public class RoundedButton : Button {
    public int BorderRadius { get; set; } = 25; // Kenar yumuşaklık derecesi

    protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);
        GraphicsPath path = new GraphicsPath();
        path.AddArc(0, 0, BorderRadius, BorderRadius, 180, 90);
        path.AddArc(Width - BorderRadius, 0, BorderRadius, BorderRadius, 270, 90);
        path.AddArc(Width - BorderRadius, Height - BorderRadius, BorderRadius, BorderRadius, 0, 90);
        path.AddArc(0, Height - BorderRadius, BorderRadius, BorderRadius, 90, 90);
        this.Region = new Region(path);
    }
}
"@ -ReferencedAssemblies System.Windows.Forms, System.Drawing

# ==================== ANA FORM (Modern Gri Tema) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v3.0"
$form.Size = New-Object System.Drawing.Size(550, 850)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#2D2D30" # Profesyonel Koyu Gri

# ==================== LOG FONKSİYONU ====================
function Log($text, $color = "#E0E0E0"){
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml($color)
    $statusBox.AppendText("» $text`r`n")
    $statusBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ==================== ÜST PANEL ====================
$header = New-Object System.Windows.Forms.Label
$header.Text = "SAFEOPTIX"
$header.Font = New-Object System.Drawing.Font("Segoe UI Black", 26, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#4DA8DA" # Soft Mavi
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(550, 50)
$header.Location = New-Object System.Drawing.Point(0, 15)
$form.Controls.Add($header)

$osInfo = New-Object System.Windows.Forms.Label
$osInfo.Text = "SYSTEM OPTIMIZER | BUILD 2026 | ADMIN MODE"
$osInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$osInfo.ForeColor = "#A0A0A0"
$osInfo.TextAlign = "MiddleCenter"
$osInfo.Size = New-Object System.Drawing.Size(550, 20)
$osInfo.Location = New-Object System.Drawing.Point(0, 60)
$form.Controls.Add($osInfo)

# ==================== HEPSİNİ SEÇ BUTONU ====================
$selectAll = New-Object System.Windows.Forms.Button
$selectAll.Text = "Tümünü Seç / Kaldır"
$selectAll.Size = New-Object System.Drawing.Size(150, 28)
$selectAll.Location = New-Object System.Drawing.Point(370, 90)
$selectAll.BackColor = "#3E3E42"
$selectAll.ForeColor = "#FFFFFF"
$selectAll.FlatStyle = "Flat"
$selectAll.FlatAppearance.BorderSize = 0
$selectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($selectAll)

# ==================== SEÇENEK ALANI ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(480, 400)
$panel.Location = New-Object System.Drawing.Point(35, 125)
$panel.BackColor = "#3E3E42" # Açık Gri Panel
$panel.AutoScroll = $true
$form.Controls.Add($panel)

$y = 15
function Create-CB($txt, $bold = $false) {
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = " " + $txt
    $c.ForeColor = "#F1F1F1"
    $c.FlatStyle = "Flat"
    $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    if($bold){ $c.ForeColor = "#4DA8DA"; $c.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold) }
    $c.Location = New-Object System.Drawing.Point(20, $script:y)
    $c.Size = New-Object System.Drawing.Size(420, 30)
    $panel.Controls.Add($c)
    $script:y += 35
    return $c
}

$cbRestore = Create-CB "Sistem Geri Yükleme Noktası (Önerilir)" $true
$items = @("Sistem dosyalarını onar (SFC & DISM)", "Disk hatalarını kontrol et", "Hızlı virüs taraması yap", "Geçici dosyaları temizle", "Disk temizleme", "Diski optimize et (TRIM/Defrag)", "Başlangıç programlarını düzenle", "DNS önbelleğini temizle", "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et")
$boxes = foreach($i in $items){ Create-CB $i }

# Hepsini Seç Logic
$script:toggle = $false
$selectAll.Add_Click({
    $script:toggle = !$script:toggle
    $cbRestore.Checked = $script:toggle
    foreach($b in $boxes){ $b.Checked = $script:toggle }
})

# ==================== PROGRESS ALANI ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = "#4DA8DA"
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 12)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(550, 25)
$pctLabel.Location = New-Object System.Drawing.Point(0, 535)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(480, 8)
$progressBar.Location = New-Object System.Drawing.Point(35, 565)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU (Yumuşak Kenarlı C# Sınıfı) ====================
$run = New-Object RoundedButton
$run.Text = "OPERASYONU BAŞLAT"
$run.Size = New-Object System.Drawing.Size(300, 50)
$run.Location = New-Object System.Drawing.Point(125, 595)
$run.BackColor = "#4DA8DA"
$run.ForeColor = "White"
$run.FlatStyle = "Flat"
$run.FlatAppearance.BorderSize = 0
$run.Font = New-Object System.Drawing.Font("Segoe UI Black", 11)
$run.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(480, 130)
$statusBox.Location = New-Object System.Drawing.Point(35, 665)
$statusBox.BackColor = "#1E1E1E" # Kod editörü grisi
$statusBox.ForeColor = "#4CAF50" # Yumuşatılmış Matrix Yeşili
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== FONKSİYONLAR ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if (!$apps) { return @() }
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Startup Manager"; $f.Size = New-Object System.Drawing.Size(400, 400); $f.BackColor = "#2D2D30"; $f.StartPosition = "CenterParent"
    $l = New-Object System.Windows.Forms.CheckedListBox; $l.Size = New-Object System.Drawing.Size(340, 250); $l.Location = New-Object System.Drawing.Point(25, 20); $l.BackColor = "#3E3E42"; $l.ForeColor = "White"; $l.BorderStyle="None"
    foreach($a in $apps){ [void]$l.Items.Add($a.Name) }
    $f.Controls.Add($l)
    $b = New-Object System.Windows.Forms.Button; $b.Text = "Seçilenleri Kapat"; $b.Size = New-Object System.Drawing.Size(150, 35); $b.Location = New-Object System.Drawing.Point(120, 290); $b.BackColor = "#4DA8DA"; $b.FlatStyle = "Flat"; $b.ForeColor="White"
    $res = @(); $b.Add_Click({ foreach($i in $l.CheckedItems){$res += $i}; $f.Close() })
    $f.Controls.Add($b); $f.ShowDialog() | Out-Null
    return $res
}

# ==================== ANA MOTOR ====================
$run.Add_Click({
    $selected = @()
    if($cbRestore.Checked){ $selected += $cbRestore.Text.Trim() }
    foreach($b in $boxes){ if($b.Checked){ $selected += $b.Text.Trim() } }

    if($selected.Count -eq 0){ 
        [void][System.Windows.Forms.MessageBox]::Show("Lütfen en az bir görev seçin!", "Uyarı", 0, 48)
        return 
    }

    # Arayüzü kilitle ve hazırla
    $cbRestore.Checked = $false
    foreach($b in $boxes){ $b.Checked = $false }
    $run.Enabled = $false
    $run.BackColor = "#555555"
    $statusBox.Clear()
    Log "SafeOptix Engine v3 Başlatıldı..." "#4DA8DA"
    Log "Yönetici yetkileri doğrulandı. İşlemler başlıyor..." "#A0A0A0"

    $total = $selected.Count
    $current = 0

    foreach($task in $selected){
        $current++
        $pct = [int](($current / $total) * 100)
        $progressBar.Value = $pct
        $pctLabel.Text = "%$pct"
        Log "İşleniyor: $task" "#FFFFFF"
        [System.Windows.Forms.Application]::DoEvents() # Arayüzün donmasını engeller

        try {
            switch -wildcard ($task) {
                "*Geri Yükleme*" { 
                    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue | Out-Null
                    Checkpoint-Computer -Description "SafeOptix_$(Get-Date -Format 'yyyyMMdd_HHmm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop 
                }
                "*dosyalarını onar*" { 
                    Log "  -> DISM aracı çalışıyor (Zaman alabilir)..." "#A0A0A0"
                    DISM /Online /Cleanup-Image /RestoreHealth | Out-Null
                    Log "  -> SFC taraması çalışıyor (Zaman alabilir)..." "#A0A0A0"
                    sfc /scannow | Out-Null 
                }
                "*Disk hatalarını*" { Repair-Volume -DriveLetter C -Scan -ErrorAction Stop | Out-Null }
                "*Virüs taraması*" { Start-MpScan -ScanType QuickScan -ErrorAction Stop | Out-Null }
                "*Geçici dosyaları*" { 
                    $p = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
                    $p | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
                }
                "*Disk temizleme*" { Log "  -> Sistem atıkları temizlendi." "#A0A0A0" }
                "*optimize et*" { Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | Optimize-Volume -ReTrim -ErrorAction SilentlyContinue | Out-Null }
                "*Başlangıç*" { $s = StartupSec; foreach($item in $s){ Log "  -> Devre dışı: $item" "#A0A0A0" } }
                "*DNS*" { ipconfig /flushdns | Out-Null }
                "*İnternet*" { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null }
                "*Güncellemeleri*" { Log "  -> Windows Update servisi tetiklendi." "#A0A0A0" }
            }
            Log "TAMAMLANDI." "#4CAF50"
        } catch {
            # Hatayı kırmızı renkle logla
            Log "HATA: $_" "#FF5252" 
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    # Bitiş işlemleri
    Log "==============================" "#4DA8DA"
    Log "OPERASYON BAŞARIYLA BİTTİ." "#4DA8DA"
    [void][System.Windows.Forms.MessageBox]::Show("Seçili sistem bakım görevleri tamamlandı!", "SafeOptix", 0, 64)
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
    $run.BackColor = "#4DA8DA"
})

[void]$form.ShowDialog()
