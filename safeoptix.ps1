Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==================== FORM ====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "SafeOptix - Windows Bakım"
$form.Size = New-Object System.Drawing.Size(650,900)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = "#121212"

# ==================== LOG FUNCTION ====================
function Log($text,$type="info") {
    switch ($type) {
        "info" { $statusBox.SelectionColor = [System.Drawing.Color]::White }
        "success" { $statusBox.SelectionColor = [System.Drawing.Color]::Lime }
        "error" { $statusBox.SelectionColor = [System.Drawing.Color]::Red }
    }
    $statusBox.AppendText($text + "`r`n")
    $statusBox.SelectionStart = $statusBox.Text.Length
    $statusBox.ScrollToCaret()
}

# ==================== TITLE ====================
$title = New-Object System.Windows.Forms.Label
$title.Text = "SafeOptix"
$title.Font = New-Object System.Drawing.Font("Segoe UI",24,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = "#0A84FF"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(220,15)
$form.Controls.Add($title)

# ==================== PANEL ====================
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(580,540)
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

# ==================== BAŞLAT BUTONU ====================
$run = New-Object System.Windows.Forms.Button
$run.Text="Başlat"
$run.Size=New-Object System.Drawing.Size(200,50)
$run.Location=New-Object System.Drawing.Point(220,650)
$run.BackColor="#0A84FF"
$run.ForeColor="White"
$run.FlatStyle="Flat"
$run.Font=New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($run)

# ==================== STATUS BOX ====================
$statusBox=New-Object System.Windows.Forms.RichTextBox
$statusBox.Size=New-Object System.Drawing.Size(580,200)
$statusBox.Location=New-Object System.Drawing.Point(30,720)
$statusBox.BackColor="#111111"
$statusBox.ForeColor="LightGray"
$statusBox.ReadOnly=$true
$statusBox.ScrollBars="Vertical"
$statusBox.WordWrap=$true
$form.Controls.Add($statusBox)

# ==================== STARTUP SEC ====================
function StartupSec {
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object {$_.User -eq "$env:USERNAME"}
    if ($apps.Count -eq 0) { return @() }
