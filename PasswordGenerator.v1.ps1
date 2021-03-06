<#

    SCRIPT : PasswordGenerator.v1.ps1
    
    DESCRIPTION : Ce script permet de générer un mot de passe selon les critères
                  définis par l'utilisateur.
                  
    AUTEUR : Johann BARON
    
    VERSIONS :
    - 24/01/2021, v1.0
    
#>


#region CHARGEMENT DES ASSEMBLY

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()

#endregion


#region CREATION DES FONCTIONS

# ================================
# Fonction pour masquer la console
# ================================

# Link : https://stackoverflow.com/questions/40617800/opening-powershell-script-and-hide-command-prompt-but-not-the-gui


Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

Function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

Hide-Console


# =======================================================
# Fonction pour vérifier la configuration du mot de passe
# =======================================================

Function Check-PasswordConfiguration {

    if (!$upperCheckBox.Checked -and
        !$lowerCheckBox.Checked -and
        !$digitCheckBox.Checked -and
        !$specialCharsCheckBox.Checked) {
        
        $msgConfigError = "Aucun type de caractères n'a été sélectionné.`n"
        $msgConfigError += "Veuillez cocher la/les case(s) des caractères à utiliser."
        
        [System.Windows.Forms.MessageBox]::Show($msgConfigError, "Configuration incorrecte", 0, 16)

        Return
    }
    elseif ($numberOfCharNumericUpDown.Value -eq "0") {
        
        $msgConfigError = "Le nombre de caractères est égal à 0.`n "
        $msgConfigError += "Veuillez modifier ce paramètre."

        [System.Windows.Forms.MessageBox]::Show($msgConfigError, "Configuration incorrecte", 0, 16)
        
        Return
    }
    
    $nbSelectedCheckBox = 0
    $charTypes = ''
    
    if ($upperCheckBox.Checked) {
        $nbSelectedCheckBox++
        $charTypes += "`t- " + (($upperCheckBox.Text) -replace " .*") + "`n"
    }
    
    if ($lowerCheckBox.Checked) {
        $nbSelectedCheckBox++
        $charTypes += "`t- " + (($lowerCheckBox.Text) -replace " .*") + "`n"    
    }
    
    if ($digitCheckBox.Checked) {
        $nbSelectedCheckBox++
        $charTypes += "`t- " + (($digitCheckBox.Text) -replace " .*") + "`n"
    }
    
    if ($specialCharsCheckBox.Checked) {
        $nbSelectedCheckBox++
        $charTypes += "`t- Caractères " + ((($specialCharsCheckBox.Text).ToLower()) -replace " .*") + "`n"
    }
    
    if ($nbSelectedCheckBox -gt $numberOfCharNumericUpDown.Value) {
    
        $msgWrongLength = "Il y a une incohérence entre le nombre de caractères et les caractères à utiliser.`n"
        $msgWrongLength += "Vous avez séléctionner $nbSelectedCheckBox types de caractères pour une longueur de "
        
        if ($numberOfCharNumericUpDown.Value -eq '1') {
            $msgWrongLength += "$($numberOfCharNumericUpDown.Value) caractère.`n"
        } else {
            $msgWrongLength += "$($numberOfCharNumericUpDown.Value) caractères.`n"
        }
        
        $msgWrongLength += "Votre configuration :`n"
        $msgWrongLength += "`t- Longueur du mot de passe : $($numberOfCharNumericUpDown.Value)`n"
        $msgWrongLength += "$charTypes`n"
        $msgWrongLength += "`nVeuillez modifier la configuration de votre mot de passe."
        
        [System.Windows.Forms.MessageBox]::Show($msgWrongLength, "Petite erreur de calcul ?", 0, 16)
        
        Return
    } else {
        Generate-Password
    }
}


# =====================================
# Fonction pour générer un mot de passe
# =====================================

Function Generate-Password {
    
    $generateButton.Enabled = $false
    $copyLabel.Enabled = $false
    $resultTextBox.Visible = $false
    $resultTextBox.Text = ""
    
    $password = ""
    $upperChars = [char[]]([char]'A'..[char]'Z')
    $lowerChars = [char[]]([char]'a'..[char]'z')
    $digitChars = (0..9)
    $specialChars = @('+','-','.','?','!','_','$','%','@','#')
    
    $selectedChars = @()
    
    if ($upperCheckBox.Checked) {
        $password += ($upperChars | Get-Random)
        $selectedChars += $upperChars
    }
   
    if ($lowerCheckBox.Checked) {
        $password += ($lowerChars | Get-Random)
        $selectedChars += $lowerChars
    }
   
    if ($digitCheckBox.Checked) {
        $password += ($digitChars | Get-Random)
        $selectedChars += $digitChars
    }
   
    if ($specialCharsCheckBox.Checked) {
        $password += ($specialChars | Get-Random)
        $selectedChars += $specialChars
    }
    
    if ($password.Length -lt $numberOfCharNumericUpDown.Value) {
        for ($i, $j = 0, ($numberOfCharNumericUpDown.Value - $password.Length); $i -lt $j; $i++) {
            $password += ($selectedChars | Get-Random)
        }
    }
   
    $resultTextBox.TextAlign = 'Left'
    $resultTextBox.WordWrap = $true
    
    $resultTextBox.Text = (($password.ToCharArray() | Get-Random -Count $password.Length) -join '')
    
    if ((($resultTextBox.GetPositionFromCharIndex(($resultTextBox.TextLength - 1))).Y) -ne 0) {
        $resultTextBox.WordWrap = $false
    } else {
        $resultTextBox.TextAlign = 'Center'
    }
    
    $resultAreaLabel.Visible = $true
    $copyLabel.Enabled = $true
    $generateButton.Enabled = $true
    $resultTextBox.Visible = $true
    
    Return
}

#endregion


#region CREATION DES FORMES

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.StartPosition = 'CenterScreen'
$mainForm.Size = '720,755' #'720,800'
$mainForm.Text = "Générateur de mot de passe"
$mainForm.MaximizeBox = $false
$mainForm.MinimizeBox = $false
$mainForm.FormBorderStyle = 'FixedDialog'
$mainForm.BackColor = '#2A2A2A'
$mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon('.\img\passgen.ico')


$titleLabel = New-Object System.Windows.Forms.PictureBox
$titleLabel.Location = '0,0'
$titleLabel.Size = '720,100'
$titleLabel.Image = [System.Drawing.Image]::FromFile('.\img\passgen.png')
$mainForm.Controls.Add($titleLabel)


$configLabel = New-Object System.Windows.Forms.Label
$configLabel.Text = "Configuration du mot de passe"
$configLabel.TextAlign = 'MiddleLeft'
$configLabel.Font = 'Tahoma, 12pt, style=Bold'
$configLabel.ForeColor = '#32CD32'
$configLabel.Location = '20,120'
$configLabel.Size = '660,20'
$mainForm.Controls.Add($configLabel)


$lengthGroupBox = New-Object System.Windows.Forms.GroupBox
$lengthGroupBox.Text = "Longueur"
$lengthGroupBox.Font = 'Tahoma, 9pt'
$lengthGroupBox.ForeColor = 'White'
$lengthGroupBox.Location = '20,150' #'20,160'
$lengthGroupBox.Size = '660,80'
$mainForm.Controls.Add($lengthGroupBox)


$lengthLabel = New-Object System.Windows.Forms.Label
$lengthLabel.Text = "Nombre de caractères : `n(Minimum recommandé : 8)"
$lengthLabel.TextAlign = 'MiddleLeft'
$lengthLabel.Font = 'Tahoma, 10pt'
$lengthLabel.ForeColor = '#32CD32'
$lengthLabel.Location = '10,25'
$lengthLabel.Size = '180,40'
$lengthGroupBox.Controls.Add($lengthLabel)


$numberOfCharNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$numberOfCharNumericUpDown.Value = '8'
$numberOfCharNumericUpDown.Increment = '1'
$numberOfCharNumericUpDown.Minimum = '0'
$numberOfCharNumericUpDown.Maximum = '80'
$numberOfCharNumericUpDown.ReadOnly = $true
$numberOfCharNumericUpDown.TextAlign = 'Center'
$numberOfCharNumericUpDown.Font = 'Tahoma, 10pt'
$numberOfCharNumericUpDown.ForeColor = '#32CD32'
$numberOfCharNumericUpDown.BackColor = '#2A2A2A'
$numberOfCharNumericUpDown.Location = '200,25'
$numberOfCharNumericUpDown.Size = '60,40'
$numberOfCharNumericUpDown.Cursor = 'Hand'
$lengthGroupBox.Controls.Add($numberOfCharNumericUpDown)


$compositionGroupBox = New-Object System.Windows.Forms.GroupBox
$compositionGroupBox.Text = "Composition"
$compositionGroupBox.Font = 'Tahoma, 9pt'
$compositionGroupBox.ForeColor = 'White'
$compositionGroupBox.Location = '20,250' #'20,260'
$compositionGroupBox.Size = '660,160'
$mainForm.Controls.Add($compositionGroupBox)


$compositionLabel = New-Object System.Windows.Forms.Label
$compositionLabel.Text = "Caractères à  utiliser : `n(Recommandé : tous)"
$compositionLabel.TextAlign = 'MiddleLeft'
$compositionLabel.Font = 'Tahoma, 10pt'
$compositionLabel.ForeColor = '#32CD32'
$compositionLabel.Location = '10,25'
$compositionLabel.Size = '180,40'
$compositionGroupBox.Controls.Add($compositionLabel)


$upperCheckBox = New-Object System.Windows.Forms.CheckBox
$upperCheckBox.Text = "Majuscules (A...Z)"
$upperCheckBox.TextAlign = 'MiddleLeft'
$upperCheckBox.Font = 'Tahoma, 10pt'
$upperCheckBox.ForeColor = '#32CD32'
$upperCheckBox.Location = '10,85'
$upperCheckBox.AutoSize = $true
$upperCheckBox.Cursor = 'Hand'
$upperCheckBox.Checked = $true
$upperCheckBox.Add_Click({
    if($upperCheckBox.Checked) {
        $unselectAllCheckBox.Checked = $false
    } else {
        $selectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($upperCheckBox)


$lowerCheckBox = New-Object System.Windows.Forms.CheckBox
$lowerCheckBox.Text = "Minuscules (a...z)"
$lowerCheckBox.TextAlign = 'MiddleLeft'
$lowerCheckBox.Font = 'Tahoma, 10pt'
$lowerCheckBox.ForeColor = '#32CD32'
$lowerCheckBox.Location = '10,125'
$lowerCheckBox.AutoSize = $true
$lowerCheckBox.Cursor = 'Hand'
$lowerCheckBox.Checked = $true
$lowerCheckBox.Add_Click({
    if($lowerCheckBox.Checked) {
        $unselectAllCheckBox.Checked = $false
    } else {
        $selectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($lowerCheckBox)


$digitCheckBox = New-Object System.Windows.Forms.CheckBox
$digitCheckBox.Text = "Chiffres (0...9)"
$digitCheckBox.TextAlign = 'MiddleLeft'
$digitCheckBox.Font = 'Tahoma, 10pt'
$digitCheckBox.ForeColor = '#32CD32'
$digitCheckBox.Location = '230,85'
$digitCheckBox.AutoSize = $true
$digitCheckBox.Cursor = 'Hand'
$digitCheckBox.Checked = $true
$digitCheckBox.Add_Click({
    if($digitCheckBox.Checked) {
        $unselectAllCheckBox.Checked = $false
    } else {
        $selectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($digitCheckBox)


$specialCharsCheckBox = New-Object System.Windows.Forms.CheckBox
$specialCharsCheckBox.Text = "Spéciaux (+-.?!_$%@)"
$specialCharsCheckBox.TextAlign = 'MiddleLeft'
$specialCharsCheckBox.Font = 'Tahoma, 10pt'
$specialCharsCheckBox.ForeColor = '#32CD32'
$specialCharsCheckBox.Location = '230,125'
$specialCharsCheckBox.AutoSize = $true
$specialCharsCheckBox.Cursor = 'Hand'
$specialCharsCheckBox.Checked = $true
$specialCharsCheckBox.Add_Click({
    if($specialCharsCheckBox.Checked) {
        $unselectAllCheckBox.Checked = $false
    } else {
        $selectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($specialCharsCheckBox)


$selectAllCheckBox = New-Object System.Windows.Forms.CheckBox
$selectAllCheckBox.Text = "Sélectionner tout"
$selectAllCheckBox.TextAlign = 'MiddleLeft'
$selectAllCheckBox.Font = 'Tahoma, 10pt'
$selectAllCheckBox.ForeColor = '#32CD32'
$selectAllCheckBox.Location = '450,85'
$selectAllCheckBox.AutoSize = $true
$selectAllCheckBox.Cursor = 'Hand'
$selectAllCheckBox.Checked = $true
$selectAllCheckBox.Add_Click({
    if($selectAllCheckBox.Checked) {
        $upperCheckBox.Checked = $true
        $lowerCheckBox.Checked = $true
        $digitCheckBox.Checked = $true
        $specialCharsCheckBox.Checked = $true
        $unselectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($selectAllCheckBox)


$unselectAllCheckBox = New-Object System.Windows.Forms.CheckBox
$unselectAllCheckBox.Text = "Désélectionner tout"
$unselectAllCheckBox.TextAlign = 'MiddleLeft'
$unselectAllCheckBox.Font = 'Tahoma, 10pt'
$unselectAllCheckBox.ForeColor = '#32CD32'
$unselectAllCheckBox.Location = '450,125'
$unselectAllCheckBox.AutoSize = $true
$unselectAllCheckBox.Cursor = 'Hand'
$unselectAllCheckBox.Add_Click({
    if($unselectAllCheckBox.Checked) {
        $upperCheckBox.Checked = $false
        $lowerCheckBox.Checked = $false
        $digitCheckBox.Checked = $false
        $specialCharsCheckBox.Checked = $false
        $selectAllCheckBox.Checked = $false
    }
})
$compositionGroupBox.Controls.Add($unselectAllCheckBox)


$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Text = ("générer").ToUpper()
$generateButton.TextAlign = 'MiddleCenter'
$generateButton.Font = 'Tahoma, 16pt, style=Bold'
$generateButton.ForeColor = '#191919'
$generateButton.BackColor = '#32CD32'
$generateButton.Location = '280,440' #'280,460'
$generateButton.Size = '160,60'
$generateButton.Cursor = 'Hand'
$generateButton.FlatStyle = 'Flat'
$generateButton.Add_Click({
    Check-PasswordConfiguration
})
$mainForm.Controls.Add($generateButton)


$resultAreaLabel = New-Object System.Windows.Forms.Label
$resultAreaLabel.BackColor = '#191919'
$resultAreaLabel.Location = '10,530' #'10,560'
$resultAreaLabel.Size = '695,115'
$resultAreaLabel.Visible = $false
$mainForm.Controls.Add($resultAreaLabel)


$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Text = "Mot de passe :"
$resultLabel.TextAlign = 'MiddleLeft'
$resultLabel.Font = 'Tahoma, 11pt'
$resultLabel.ForeColor = '#32CD32'
$resultLabel.BackColor = '#191919'
$resultLabel.Location = '5,25'
$resultLabel.Size = '110,40'
$resultAreaLabel.Controls.Add($resultLabel)


$resultTextBox = New-Object System.Windows.Forms.TextBox
$resultTextBox.ReadOnly = $true
$resultTextBox.Multiline = $true
$resultTextBox.ScrollBars = 'Horizontal'
$resultTextBox.Font = 'Tahoma, 34pt'
$resultTextBox.ForeColor = '#32CD32'
$resultTextBox.BackColor = '#191919'
$resultTextBox.Location = '120,15'
$resultTextBox.Size = '460,85'
$resultTextBox.BorderStyle = 'None'
$resultAreaLabel.Controls.Add($resultTextBox)


$copyLabel = New-Object System.Windows.Forms.Label
$copyLabel.Text = "Copier"
$copyLabel.TextAlign = 'MiddleCenter'
$copyLabel.Font = 'Tahoma, 11pt, style=Bold'
$copyLabel.ForeColor = '#32CD32'
$copyLabel.BackColor = '#191919'
$copyLabel.Location = '585,25'
$copyLabel.Size = '105,40'
$copyLabel.Cursor = 'Hand'
$copyLabel.Add_Click({
    $resultTextBox.Text | Clip
})
$resultAreaLabel.Controls.Add($copyLabel)


$copyToolTip = New-Object System.Windows.Forms.ToolTip
$copyToolTip.SetToolTip($copyLabel,"Cliquer ici pour copier le mot de passe")


$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.BackColor = '#32CD32'
$footerLabel.Location = '0,655' #'0,700'
$footerLabel.Size = '720,100'
$mainForm.Controls.Add($footerLabel)


$quitButton = New-Object System.Windows.Forms.Button
$quitButton.Text = "QUITTER"
$quitButton.TextAlign = 'MiddleCenter'
$quitButton.Font = 'Tahoma, 11pt'
$quitButton.ForeColor = '#32CD32'
$quitButton.BackColor = '#191919'
$quitButton.Location = '310,25'
$quitButton.Size = '100,30'
$quitButton.Cursor = 'Hand'
$quitButton.FlatStyle = 'Flat'
$quitButton.Add_Click({
    $mainForm.Close()
})
$footerLabel.Controls.Add($quitButton)

#endregion


# Affichage de la forme

$mainForm.ShowDialog()