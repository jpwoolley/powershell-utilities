function New-WindowsForm ($formName, $formElements) {
  <#
  .SYNOPSIS
    Creates a Windows Form and gets input from the user, before returning the input.
  .DESCRIPTION
    Creates a Windows Form and gets input from the user, before returning the input. The function takes in a string containging the name of the Form and an array of objects describing the Form elements. Use the ShowDialog() method on the returned object to view the form.
  .EXAMPLE
    $myForm = New-WindowsForm -formName "My form" -formElements @(
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
    $myForm.Colour # Retrieves the answer to "What your favourite colour?"
    $myForm.DOB # Retrieves the answer to "When's your birthday?"
    
    Explanation of the keys in the element object:
    type = tells the function what type of input element you want to add to the form. Options are: 'TextBox', 'TextBoxSecure' (same as TextBox but secure), 'ComboBox' (a dropdown menu), 'DatePicker' or 'Alert' (not input from user, just a message)
    name = the name used to access the answer for that particular element after the form has been used
    question = the string of text which appears above the input
    answer = only required when using 'ComboBox' type. An array of options for the user to choose from.
  #>

  function newFormTextBox ($question, $verticalOffset) {
      
    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $question
    $verticalOffset = $verticalOffset + 20

    $formTextBoxObject = New-Object System.Windows.Forms.TextBox
    $formTextBoxObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formTextBoxObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $verticalOffset = $verticalOffset + 30
      
    Return @($FormLabelObject, $formTextBoxObject, $verticalOffset)

  }

  function newFormTextBoxSecure ($question, $verticalOffset) {

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $question
    $verticalOffset = $verticalOffset + 20

    $formTextBoxBoxSecureObject = New-Object System.Windows.Forms.TextBox
    $formTextBoxBoxSecureObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formTextBoxBoxSecureObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formTextBoxBoxSecureObject.UseSystemPasswordChar = $true
    $verticalOffset = $verticalOffset + 30

    Return @($FormLabelObject, $formTextBoxBoxSecureObject, $verticalOffset)

  }

  function newComboBox ($question, $options, $verticalOffset) {

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formLabelObject.Size = New-Object System.Drawing.Size($elementLength, 20)
    $formLabelObject.AutoSize = $true
    $formLabelObject.Text = $question
    $verticalOffset = $verticalOffset + 20
  
    $formComboBoxObject = New-Object System.Windows.Forms.Combobox
    $formComboBoxObject.Items.AddRange($options);
    $formComboBoxObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset);
    $formComboBoxObject.Size = New-Object System.Drawing.Size($elementLength, ($options.Count * 5));
    $formComboBoxObject.TabIndex = 0;
    $verticalOffset = $verticalOffset + 30

    Return @($formLabelObject, $formComboBoxObject, $verticalOffset)
  }

  function newDatePicker ($question, $verticalOffset) {

    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $question
    $verticalOffset = $verticalOffset + 20

    $formDatePickerObject = New-Object System.Windows.Forms.DateTimePicker
    $formDatePickerObject.CustomFormat = "dd MMMM yyyy"
    $formDatePickerObject.Format = "Custom"
      
    $formDatePickerObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formDatePickerObject.AutoSize = $true
    $verticalOffset = $verticalOffset + 30

    Return @($formLabelObject, $formDatePickerObject, $verticalOffset)
  }

  function newButton ($label, $type, $verticalOffset) {

    $newButton = New-Object System.Windows.Forms.Button
    $newButton.Location = New-Object System.Drawing.Point($buttonHorizontalOffset, ($currentVerticalOffset + 10))
    $newButton.Size = New-Object System.Drawing.Size($buttonLength, $buttonHeight)
    $newButton.Text = $label
    $newButton.DialogResult = [System.Windows.Forms.DialogResult]::$type
    $verticalOffset = $verticalOffset + 85

    Return @($newButton, $newButton_VerticalOffset)
  }

  function newAlert ($question, $verticalOffset) {
      
    $formLabelObject = New-Object System.Windows.Forms.Label
    $formLabelObject.Location = New-Object System.Drawing.Point($elementHorizontalOffset, $verticalOffset)
    $formLabelObject.AutoSize = $true;
    $formLabelObject.Text = $question
    $verticalOffset = $verticalOffset + 20
      
    Return @($FormLabelObject, $verticalOffset)

  }

  # Dimensions
  $elementLength = 360
  $elementHorizontalOffset = 10
  $buttonLength = 75
  $buttonHeight = 25
  $buttonHorizontalOffset = (($elementHorizontalOffset + $elementLength) - $buttonLength)
  $currentVerticalOffset = 10

  # Create form object
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $formName
  $form.StartPosition = 'CenterScreen'
  $form.Padding = 10
  $form.Padding.All = 5

  # Populate form with elements
  ForEach ($element in $formElements) {

    switch ( $element.type ) {
      "TextBox" {
        $functionResult = newFormTextBox -Question $element.question -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formTextBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formTextBox$($element.name)").Value )
      }
      "TextBoxSecure" {
        $functionResult = newFormTextBoxSecure -Question $element.question -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formTextBoxSecure$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formTextBoxSecure$($element.name)").Value )
      }
      "ComboBox" {
        $functionResult = newComboBox -Question $element.question -Options $element.answer -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formComboBox$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formComboBox$($element.name)").Value )            
      }
      "DatePicker" {
        $functionResult = newDatePicker -Question $element.question -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        Set-Variable -Name "formDatePicker$($element.name)" -Value ( $functionResult[1] )
        $currentVerticalOffset = $functionResult[2]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
        $form.Controls.Add( (Get-Variable "formDatePicker$($element.name)").Value )
      }
      "Alert" {
        $functionResult = newAlert -Question $element.question -VerticalOffset $currentVerticalOffset
        Set-Variable -Name "formLabel$($element.name)" -Value ( $functionResult[0] )
        $currentVerticalOffset = $functionResult[1]

        $form.Controls.Add( (Get-Variable "formLabel$($element.name)").Value )
      }

    }

  }

  # Submit button
  $submitButton, $currentVerticalOffset = newButton -label "Submit" -type "OK" -verticalOffset $currentVerticalOffset
  $form.AcceptButton = $submitButton
  $form.Controls.Add($submitButton)

  # Set form height
  $form.AutoSize = $true;
  $form.AutoSizeMode = "GrowAndShrink"

  # Display the form and get input
  $form.ShowDialog()

  # Construct return value
  $resultObject = @{}
  ForEach ($element in $formElements) {
    $resultObject.Add($element.name, (Get-Variable -Name "form$($element.type)$($element.name)").Value.Text)
  }

  # Return
  Return $resultObject

}