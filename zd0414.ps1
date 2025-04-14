#author：zhangran
#describe：找到jmx元素，动态赋值
param (
    [string]$inputFile,
    [string]$paramName,
    [string]$newValue
)

$xml = New-Object System.Xml.XmlDocument
$xml.PreserveWhitespace = $true  # 保留空白字符
$xml.Load($inputFile)

# 找到所有的 Argument 元素
$nodes = $xml.SelectNodes("//stringProp[@name='Argument.name']")
foreach ($node in $nodes) {
    $parentNode = $node.ParentNode
    $valueNode = $parentNode.SelectSingleNode("stringProp[@name='Argument.value']")

    if ($node.InnerText -eq $paramName -and $valueNode) {
        $valueNode.InnerText = $newValue
    }
}

$xml.Save($inputFile)