# AST Abstract Syntax Trees example


$AST = [System.Management.Automation.Language.Parser]::ParseFile("$psscriptroot\SimplePoshCompiler.ps1", [ref] $null, [ref] $null)


#$ast

$elements = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true) 

$elements

$Commandlist = @{}
Foreach($item in $elements){

    $Count = 1
    if($Commandlist[$item.CommandElements[0].value] -ne $null){
      $Commandlist[$item.CommandElements[0].value]++
      
    } else{
      $Commandlist.add($item.CommandElements[0].value,1)
    }

} 

$Commandlist

