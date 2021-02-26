# Introduction to compiler building with a minimalist compiler in PowerShell for PowerShell.
A "learning" compiler for simple PowerShell to assembler

Compiler: Translates one programming language into another
Consists of: 
Scanner - converts source code into symbols
Parser - processes symbols from Scanner and checks syntax
Code generator: Generates code in the new language

Mixing assembler and PowerShell
Understandable mediation, how such a compiler works
Showing that in the end everything is assembler and what runs under the hood
Building your own compiler (larger project)
And.... 
Because I can

#Syntax
```powershell
# Programm | Start mit Zeile 0
# Deklaration | $Variable 
# Zuweisung | $Variable "=" Ausdruck
# while | while (Ausdruck)
# {,} | Block starten, Block schließen
# Anweisung | Zuweisung | while | write-host
# Out | Write-Host Ausdruck
# Ausdruck | ["+"|"-"] Faktor {("+" |"-"|"-ge"|"-le"|"-eq"|"-lt"|"-gt") Faktor}
# Identifer | $Letter{Letter|Digit}
# Faktor | Bezeichner | Konstante
# Konstante | Ziffer {Ziffer}
# Buchstabe | [a-z|A-Z]
# Ziffer | [0-9]
# Kommentar | '#'
```

#Fibonacci numbers formula
The Fibonacci sequence is the infinite sequence of natural numbers that (originally) begins with the number 1 twice. Subsequently, the sum of two consecutive numbers results in the number immediately following: 1,1,2,3,5,8,18

```powershell
$I = 1
$J = 0
$K = 10
   While ($K) {
        Write-Host "fibu " $I
        $I = $i + $J
        $J = $I - $J
        $K = $K - 1
    }
```


#Howto
Everythink is in SimplePoshCompiler.ps1
```powershell
$PoshFile = "$PSScriptRoot\simpleproc.ps1"

$Filename = $(split-path $PoshFile -leaf).Replace('.ps1','')
$AsmFile = $(split-path $PoshFile -Parent) + '\' + $Filename + '.asm'

$inputStream = New-Object System.IO.StreamReader $PoshFile
$p = New-Object Parser $inputStream


$p.Cmdlet()  6>  "$env:TEMP\out.asm"    

$asm = Get-Content "$env:TEMP\out.asm"  
$asm #print it to screen
remove-item "$env:TEMP\out.asm" -Force
#Wrong encoding!

if(Test-Path $AsmFile) {remove-Item $AsmFile}
$asm | Add-Content  $AsmFile -Encoding Ascii 


#Set include
[Environment]::SetEnvironmentVariable("include", "$psscriptroot\include", "process")

# Assemble

& "$PSScriptRoot\fasm.exe" $AsmFile   "$PSScriptRoot\simpleproc.exe"
```