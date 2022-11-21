function New-WindowsForm ($formName, $formElements) {
  <#
  .SYNOPSIS
    Creates a Windows Form object for getting input from the user.
  .DESCRIPTION
    Creates a Windows Form object for getting input from the user. The function takes in a string containging the name of the Form and an array of objects describing the Form elements. Use the ShowDialog() method on the returned object to interact with the form.

    The keys for the objects in the array $formElements are:
    * Type = tells the function what type of input element you want to add to the form. Options are:
        - 'TextBox' - A single line text field.
        - 'MultilineTextBox' - A multiline text field.
        - 'TextBoxSecure' - same as TextBox but secure.
        - 'ComboBox' - a dropdown menu with predefined answers.
        - 'DatePicker'
        - 'Alert' (not input from user, just a message).
        - 'CheckedListBox' - Similar to Combobox but with checkboxes.
        - 'Button' - A clickable button (note that for a button you'll need to specify an allow type for 'Options'. See here for a list of button types: https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.dialogresult)
    * Name - a variable name which refers to that specific element. Allow you to access the element to retrieve the answer or modify it.
    * Question - the string of text which appears above the section.
    * Answers - Used to pre-select an answer for the user (i.e. fill in the TextBox answer field, or tick boxes for the CheckedListBox answer field.
    * Options - Provide options for elements which have multiple answers to choose from (e.g. Combobox and CheckedListBox)
    * Column - choose a value between 1-5 to place the element in a particular column.
    * Backcolor - the background colour of the element. See here for a list of valid choices: https://learn.microsoft.com/en-us/dotnet/api/system.drawing.color

    .EXAMPLE
    $MyElements = @(
      @{
        "type"="TextBox"
        "name" = "Colour"
        "question"="What's your favourite colour?"
      },
      @{
        "type"="DatePicker"
        "name" = "DOB"
        "question"="When's your birthday?"
      }
    )
    $MyForm = (New-WindowsForm -formName "My form" -formElements $MyElements).ShowDialog()

    # Note the elements exist in an object inside $MyForm called 'Controlls'
    $MyColour = $MyForm.Controlls | Where-Object { $_.Name -eq "Colour" }).Text # Retrieves the answer to "What your favourite colour?"
    $MyDOB = $MyForm.Controlls | Where-Object { $_.Name -eq "DOB" }).Text # Retrieves the answer to "When's your birthday?"
    
  #>

  function newFormTextBox {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter()]
        [String]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [Bool]
        $Disabled
    )
    
    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.AutoSize = $true
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20

    $formTextBoxObject = New-Object System.Windows.Forms.TextBox
    $formTextBoxObject.Name = $Name
    $formTextBoxObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formTextBoxObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formTextBoxObject.TabStop = $true
    $VerticalOffset = $VerticalOffset + 30

    If($null -ne $Answers){
      $formTextBoxObject.Text = $Answers
    }
    If($null -ne $BackColor){
      $formTextBoxObject.BackColor = $BackColor
    }
    If($Disabled){
      $formTextBoxObject.Enabled = $false
    }
      
    Return @($FormLabelObject, $formTextBoxObject, $VerticalOffset)

  }

  function newFormMultilineTextBox {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter()]
        [String]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [Bool]
        $Disabled
    )
    
    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.AutoSize = $true
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20

    $newFormMultilineTextBox = New-Object System.Windows.Forms.TextBox
    $newFormMultilineTextBox.Name = $Name
    $newFormMultilineTextBox.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $newFormMultilineTextBox.Size = New-Object System.Drawing.Size($elementLength, 100)
    $newFormMultilineTextBox.TabStop = $true
    $newFormMultilineTextBox.Multiline = $true
    $newFormMultilineTextBox.ScrollBars = "Both"
    $VerticalOffset = $VerticalOffset + 110

    If($null -ne $Answers){
      $newFormMultilineTextBox.Text = $Answers
    }
    If($null -ne $BackColor){
      $newFormMultilineTextBox.BackColor = $BackColor
    }
    If($Disabled){
      $newFormMultilineTextBox.Enabled = $false
    }
      
    Return @($FormLabelObject, $newFormMultilineTextBox, $VerticalOffset)

  }

  function newFormTextBoxSecure {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter()]
        [String]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20

    $formTextBoxBoxSecureObject = New-Object System.Windows.Forms.TextBox
    $formTextBoxBoxSecureObject.Name = $Name
    $formTextBoxBoxSecureObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formTextBoxBoxSecureObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formTextBoxBoxSecureObject.UseSystemPasswordChar = $true
    $formTextBoxBoxSecureObject.TabStop = $true
    $VerticalOffset = $VerticalOffset + 30

    If($null -ne $Answers){
      $formTextBoxBoxSecureObject.Text = $Answers
    }
    If($null -ne $BackColor){
      $formTextBoxBoxSecureObject.BackColor = $BackColor
    }
    If($Disabled){
      $formTextBoxBoxSecureObject.Enabled = $false
    }

    Return @($FormLabelObject, $formTextBoxBoxSecureObject, $VerticalOffset)

  }

  function newComboBox {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter(Mandatory)]
        [Array]
        $Options,
        [Parameter()]
        [String]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )

    If(($Options.Length * 20) -gt 110){
        $ControlHeight = 110
    } else {
        $ControlHeight = ($Options.Length * 20)
    }

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formLabelObject.AutoSize = $true
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20
  
    $formComboBoxObject = New-Object System.Windows.Forms.Combobox
    $formComboBoxObject.Name = $Name
    $formComboBoxObject.Items.AddRange($Options);
    $formComboBoxObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset);
    $formComboBoxObject.Size = New-Object System.Drawing.Size(360, $ControlHeight)
    $formComboBoxObject.TabIndex = 0;
    $formComboBoxObject.TabStop = $true
    $VerticalOffset = $VerticalOffset + 30

    If($null -ne $Answers){
      $formComboBoxObject.Text = $Answers
    }
    If($null -ne $BackColor){
      $formComboBoxObject.BackColor = $BackColor
    }
    If($Disabled){
      $formComboBoxObject.Enabled = $false
    }

    Return @($formLabelObject, $formComboBoxObject, $VerticalOffset)
  }

  function newDatePicker {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter()]
        [String]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20

    $formDatePickerObject = New-Object System.Windows.Forms.DateTimePicker
    $formDatePickerObject.Name = $Name
    $formDatePickerObject.CustomFormat = "dd MMMM yyyy"
    $formDatePickerObject.Format = "Custom"
    $formDatePickerObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formDatePickerObject.AutoSize = $true
    $formDatePickerObject.TabStop = $true
    $VerticalOffset = $VerticalOffset + 30

    If($null -ne $Answers){
      $formDatePickerObject.Text = $Answers
    }
    If($null -ne $BackColor){
      $formDatePickerObject.BackColor = $BackColor
    }
    If($Disabled){
      $formDatePickerObject.Enabled = $false
    }

    Return @($formLabelObject, $formDatePickerObject, $VerticalOffset)
  }

  function newButton {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Type,
        [Parameter(Mandatory)]
        [String]
        $Options,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )

    $newButton = New-Object System.Windows.Forms.Button
    $newButton.Name = $Name
    $newButton.Location = New-Object System.Drawing.Point($buttonHorizontalOffset, $currentVerticalOffset)
    $newButton.Size = New-Object System.Drawing.Size($buttonLength, 30)
    $newButton.Text = $Options
    $newButton.DialogResult = [System.Windows.Forms.DialogResult]::$Options
    $VerticalOffset = $VerticalOffset + 40

    If($null -ne $BackColor){
      $newButton.BackColor = $BackColor
    }
    If($Disabled){
      $newButton.Enabled = $false
    }

    Return @($newButton, $VerticalOffset)
  }

  function newAlert {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )
      
    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Name = $Name
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20

    If($null -ne $BackColor){
      $formLabelObject.BackColor = $BackColor
    }
    If($Disabled){
      $formLabelObject.Enabled = $false
    }
      
    Return @($FormLabelObject, $VerticalOffset)

  }

  function newCheckedListBox {

    [CmdletBinding()]
    param (
      [Parameter(Mandatory)]
      [String]
      $Name,
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter(Mandatory)]
        [Array]
        $Options,
        [Parameter()]
        [Array]
        $Answers,
        [Parameter(Mandatory)]
        [Int32]
        $VerticalOffset,
        [Parameter()]
        [String]
        $BackColor,
        [Parameter()]
        [bool]
        $Disabled
    )

    If(($Options.Length * 20) -gt 110){
        $ControlHeight = 210
    } else {
        $ControlHeight = ($Options.Length * 20)
    }

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    #$formLabelObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formLabelObject.AutoSize = $true
    $formLabelObject.Text = $Question
    $VerticalOffset = $VerticalOffset + 20
  
    $formCheckedListBox = New-Object System.Windows.Forms.CheckedListBox
    $formCheckedListBox.Name = $Name
    $formCheckedListBox.Items.AddRange($Options);
    $formCheckedListBox.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $VerticalOffset)
    $formCheckedListBox.Size = New-Object System.Drawing.Size($elementLength, $ControlHeight)
    $formCheckedListBox.TabIndex = 0
    $formCheckedListBox.CheckOnClick = $true
    $formCheckedListBox.TabStop = $true
    $VerticalOffset = $VerticalOffset + $ControlHeight + 10

    If($null -ne $Answers){
      For ($i=0; $i -le $formCheckedListBox.Items.Count; $i++) {
        If($Answers -contains $formCheckedListBox.Items[$i]){
          $formCheckedListBox.SetItemChecked($i, $true)
        }
      }
    }
    If($null -ne $BackColor){
      $formCheckedListBox.BackColor = $BackColor
    }
    If($Disabled){
      $formCheckedListBox.Enabled = $false
    }

    Return @($formLabelObject, $formCheckedListBox, $VerticalOffset)
  }

  # Dimensions
  $elementLength = 360
  $elementHorizontalOffset1 = 10
  $elementHorizontalOffset2 = 30 + $elementLength
  $elementHorizontalOffset3 = 50 + ($elementLength * 2)
  $elementHorizontalOffset4 = 70 + ($elementLength * 3)
  $elementHorizontalOffset5 = 90 + ($elementLength * 4)
  $buttonLength = 75
  $buttonHorizontalOffset = 10
  $currentVerticalOffset1 = 10
  $currentVerticalOffset2 = 10
  $currentVerticalOffset3 = 10
  $currentVerticalOffset4 = 10
  $currentVerticalOffset5 = 10

  # Create form object
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $formName
  $form.StartPosition = 'CenterScreen'
  $form.Padding = 10
  $form.Padding.All = 5
  $form.AutoSize = $true
  $form.AutoSizeMode = "GrowAndShrink"
  $form.TopMost = $true

  # Populate form with elements
  ForEach ($element in $formElements) {
    
    switch($element.column){
        1 {
            $currentVerticalOffset = $currentVerticalOffset1
            $elementHorizontalOffset = $elementHorizontalOffset1
        }
        2 {
            $currentVerticalOffset = $currentVerticalOffset2
            $elementHorizontalOffset = $elementHorizontalOffset2
        }
        3 {
            $currentVerticalOffset = $currentVerticalOffset3
            $elementHorizontalOffset = $elementHorizontalOffset3
        }
        4 {
            $currentVerticalOffset = $currentVerticalOffset4
            $elementHorizontalOffset = $elementHorizontalOffset4
        }
        5 {
            $currentVerticalOffset = $currentVerticalOffset5
            $elementHorizontalOffset = $elementHorizontalOffset5
        }
    }

    If($null -eq $element.disabled){
      $element.disabled = $false
    }

    Switch ( $element.type ) {
      "TextBox" {
        $functionResult = newFormTextBox -Name $element.Name -Question $element.question -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formTextBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formTextBox$($element.name)").Value )
      }
      "MultilineTextBox" {
        $functionResult = newFormMultilineTextBox -Name $element.Name -Question $element.question -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formMultilineTextBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formMultilineTextBox$($element.name)").Value )
      }
      "TextBoxSecure" {
        $functionResult = newFormTextBoxSecure -Name $element.Name -Question $element.question -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formTextBoxSecure$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formTextBoxSecure$($element.name)").Value )
      }
      "ComboBox" {
        $functionResult = newComboBox -Name $element.Name -Question $element.question -Options $element.options -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formComboBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formComboBox$($element.name)").Value )            
      }
      "DatePicker" {
        $functionResult = newDatePicker -Name $element.Name -Question $element.question -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formDatePicker$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formDatePicker$($element.name)").Value )
      }
      "Alert" {
        $functionResult = newAlert -Name $element.Name -Question $element.question -BackColor $element.backcolor -Disabled $element.disabled -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        $currentVerticalOffset = $functionResult[1]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
      }
      "CheckedListBox" {
        $functionResult = newCheckedListBox -Name $element.Name -question $element.question -options $element.options -Answers $element.answers -BackColor $element.backcolor -Disabled $element.disabled -verticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formCheckedListBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formCheckedListBox$($element.name)").Value )
      }
      "Button" {
        $functionResult = newButton -Name $element.Name -type $element.type -options $element.options -BackColor $element.backcolor -Disabled $element.disabled -verticalOffset $currentVerticalOffset
        Set-Variable -Name "formButton$($element.name)" -Value ( $functionResult[0] )
        $currentVerticalOffset = $functionResult[1]

        $form.Controls.Add( (Get-Variable "formButton$($element.name)").Value )
      }
    }

    Switch($element.column){
        1 {
            $currentVerticalOffset1 = $currentVerticalOffset
        }
        2 {
            $currentVerticalOffset2 = $currentVerticalOffset
        }
        3 {
            $currentVerticalOffset3 = $currentVerticalOffset
        }
        4 {
            $currentVerticalOffset4 = $currentVerticalOffset
        }
        5 {
            $currentVerticalOffset5 = $currentVerticalOffset
        }
    }

  }

  Return $form

}