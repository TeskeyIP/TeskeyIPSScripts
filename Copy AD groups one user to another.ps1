# Import required modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Copy AD Groups'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Add a label and textbox for the source user
$sourceLabel = New-Object System.Windows.Forms.Label
$sourceLabel.Location = New-Object System.Drawing.Point(10,20)
$sourceLabel.Size = New-Object System.Drawing.Size(120,20)
$sourceLabel.Text = 'Source User:'
$form.Controls.Add($sourceLabel)

$sourceTextBox = New-Object System.Windows.Forms.TextBox
$sourceTextBox.Location = New-Object System.Drawing.Point(140,20)
$sourceTextBox.Size = New-Object System.Drawing.Size(130,20)
$form.Controls.Add($sourceTextBox)

# Add a label and textbox for the target user
$targetLabel = New-Object System.Windows.Forms.Label
$targetLabel.Location = New-Object System.Drawing.Point(10,60)
$targetLabel.Size = New-Object System.Drawing.Size(120,20)
$targetLabel.Text = 'Target User:'
$form.Controls.Add($targetLabel)

$targetTextBox = New-Object System.Windows.Forms.TextBox
$targetTextBox.Location = New-Object System.Drawing.Point(140,60)
$targetTextBox.Size = New-Object System.Drawing.Size(130,20)
$form.Controls.Add($targetTextBox)

# Add a button to initiate the copy
$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Location = New-Object System.Drawing.Point(90,110)
$copyButton.Size = New-Object System.Drawing.Size(100,30)
$copyButton.Text = 'Copy Groups'
$copyButton.Add_Click({
    $copyButton.Enabled = $false

    $sourceUser = $sourceTextBox.Text.Trim()
    $targetUser = $targetTextBox.Text.Trim()

    if (-not $sourceUser -or -not $targetUser) {
        [System.Windows.Forms.MessageBox]::Show("Please enter both source and target usernames.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $copyButton.Enabled = $true
        return
    }

    # Check if users exist
    if (-not (Get-ADUser -Filter {sAMAccountName -eq $sourceUser})) {
        [System.Windows.Forms.MessageBox]::Show("Source user $sourceUser does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $copyButton.Enabled = $true
        return
    }

    if (-not (Get-ADUser -Filter {sAMAccountName -eq $targetUser})) {
        [System.Windows.Forms.MessageBox]::Show("Target user $targetUser does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $copyButton.Enabled = $true
        return
    }

    # Get the list of groups the source user is a member of
    $sourceGroups = Get-ADUser -Identity $sourceUser -Properties memberOf | Select-Object -ExpandProperty memberOf

    # Iterate through each group and add the target user to it
    foreach ($group in $sourceGroups) {
        try {
            # Check if target user is already a member
            $isMember = Get-ADGroupMember -Identity $group | Where-Object {$_.sAMAccountName -eq $targetUser}
            if ($isMember) {
                Write-Host "$targetUser is already a member of $group"
            } else {
                Add-ADGroupMember -Identity $group -Members $targetUser
                Write-Host "Added $targetUser to $group"
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error adding $targetUser to $group: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Group copy completed!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $copyButton.Enabled = $true
})

$form.Controls.Add($copyButton)

# Show the form
$form.ShowDialog()
