$startFolder = "C:\Users\yassin.eltahir\Documents"

$colItems = (Get-ChildItem $startFolder | Measure-Object -property length -sum)
"$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

$colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
foreach ($i in $colItems)
    {
        $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
        $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
    }
$colItems = (Get-ChildItem C:\Users\yassin.eltahir\ -recurse | Measure-Object -property length -sum)
"{0:N2}" -f ($colItems.sum / 1MB) + " MB"

