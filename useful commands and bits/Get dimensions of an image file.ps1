$PathToImage = ""

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$Image = [System.Drawing.Image]::FromFile($PathToImage) 

$width = $Image.Width
$height = $Image.Height