#author:zhangran
#describe:动态修改参数

param (
    [string]$inputFile,
    [string]$paramName,
    [string]$newValue,
    [string]$portValue = "",
    [string]$httpValue
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
    if ($node.InnerText -eq "server_port" -and $valueNode) {
        $valueNode.InnerText = $portValue
    }
    if ($node.InnerText -eq "server_http" -and $valueNode) {
        $valueNode.InnerText = $httpValue
    }
}

$xml.Save($inputFile)