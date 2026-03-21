# ==================== YÖNETİCİ KONTROLÜ ====================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("Kanka sağ tıklayıp 'Yönetici Olarak Çalıştır' de lütfen!", "Hata")
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== ANA FORM (Modern Gri) ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix Ultra v6.0"
$form.Size = New-Object System.Drawing.Size(500, 800)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48) # Koyu Gri

# ==================== BAŞLIK ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::SkyBlue
$title.TextAlign = "MiddleCenter"
$title.Size = New-Object System.Drawing.Size(500, 60)
$title.Location = New-Object System.Drawing.Point(0, 20)
$form.Controls.Add($title)

# ==================== SEÇENEK PANELİ ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(420, 360)
$panel.Location = New-Object System.Drawing.Point(40, 90)
$panel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Controls.Add($panel)

$y = 15
function New-ItemCB($text, $isBlue = $false) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "  " + $text
    $cb.ForeColor = [System.Drawing.Color]::White
    $cb.FlatStyle = "Flat"
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if($isBlue) { $cb.ForeColor = [System.Drawing.Color]::SkyBlue; $cb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) }
    $cb.Location = New-Object System.Drawing.Point(20, $script:y)
    $cb.Size = New-Object System.Drawing.Size(380, 30)
    $panel.Controls.Add($cb)
    $script:y += 33
    return $cb
}

$cbRestore = New-ItemCB "Geri Yükleme Noktası Oluştur (Önerilir)" $true
$items = @(
    "Sistem dosyalarını onar (SFC & DISM)", "Disk hatalarını kontrol et (Chkdsk)",
    "Virüs taraması yap (Windows Defender)", "Geçici dosyaları temizle (Temp/Prefetch)",
    "Disk temizleme (Sistem Dosyaları)", "Diski optimize et (Defrag/Trim)",
    "Başlangıç programlarını düzenle", "DNS önbelleğini temizle",
    "İnternet ayarlarını sıfırla", "Güncellemeleri kontrol et"
)
$boxes = foreach($i in $items) { New-ItemCB $i }

# ==================== PROGRESS & YÜZDE ====================
$pctLabel = New-Object System.Windows.Forms.Label
$pctLabel.Text = "%0"
$pctLabel.ForeColor = [System.Drawing.Color]::SkyBlue
$pctLabel.Font = New-Object System.Drawing.Font("Segoe UI Black", 20)
$pctLabel.TextAlign = "MiddleCenter"
$pctLabel.Size = New-Object System.Drawing.Size(500, 40)
$pctLabel.Location = New-Object System.Drawing.Point(0, 470)
$form.Controls.Add($pctLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(420, 15)
$progressBar.Location = New-Object System.Drawing.Point(40, 520)
$form.Controls.Add($progressBar)

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text = "BAKIMI BAŞLAT"
$run.Size = New-Object System.Drawing.Size(240, 50)
$run.Location = New-Object System.Drawing.Point(130, 560)
$run.BackColor = [System.Drawing.Color]::SkyBlue
$run.ForeColor = [System.Drawing.Color]::Black
$run.FlatStyle = "Flat"
$run.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== LOG BOX ====================
$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Size = New-Object System.Drawing.Size(420, 120)
$statusBox.Location = New-Object System.Drawing.Point(40, 630)
$statusBox.BackColor = [System.Drawing.Color]::Black
$statusBox.ForeColor = [System.Drawing.Color]::Lime
$statusBox.BorderStyle = "None"
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# ==================== MOTOR ====================
$run.Add_Click({
    $sel = @()
    if($cbRestore.Checked) { $sel += "Restore" }
    foreach($b in $boxes) { if($b.Checked) { $sel += $b.Text.Trim() } }

    if($sel.Count -eq 0) { [void][System.Windows.Forms.MessageBox]::Show("Bir şeyler seç kanka!"); return }

    # SIFIRLAMA
    $cbRestore.Checked = $false
    foreach($b in $boxes) { $b.Checked = $false }
    $run.Enabled = $false
    $statusBox.Clear()

    $total = $sel.Count
    for($i=1; $i -le $total; $i++) {
        $target = [int](($i / $total) * 100)
        
        # Animasyonlu dolum
        while($progressBar.Value -lt $target) {
            $progressBar.Value += 1
            $pctLabel.Text = "%$($progressBar.Value)"
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 10
        }

        $task = $sel[$i-1]
        $statusBox.AppendText("> İşlem: $task yapılıyor...`n")
        $statusBox.ScrollToCaret()

        # Komutları buraya ekleyebilirsin (Dism / SFC vs)
        Start-Sleep -Seconds 1 # Simülasyon
    }

    [void][System.Windows.Forms.MessageBox]::Show("İşlem bitti!", "SafeOptix")
    $progressBar.Value = 0
    $pctLabel.Text = "%0"
    $run.Enabled = $true
})

[void]$form.ShowDialog()
