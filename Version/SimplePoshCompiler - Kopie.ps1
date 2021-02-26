# Simple x86 PowerShell Compiler in PowerShell
#
# Program     | start with line 0
# Declaraion  | $Variable 
# Assignment  | $Variable "=" Expression
# while       | while Expression do
# Statement   | Assignment | while | write-host
# Out         | Write-Host Expression
# Expression  | ["+"|"-"] Factor {("+" |"-"|"-ge"|"-le"|"-eq"|"-lt"|"-gt") Factor}
# Identifer   | $Letter{Letter|Digit}
# Factor      | Identifer | Constant
# Constant    | Digit {Digit}
# Letter      | [a-z|A-Z]
# Digit       | [0-9]
# Comment     | '#'



Class Scanner{
  static [string[]] $Symbols = @('string','while','do','write-host','comma','equal','plus','minus','eof','variable', 'const','curlyBracesOpen','curlyBracesClose','BracketOpen','BracketClose','if','ge','le','eq','lt','gt')
  static [int] $MaxVarLength = 80
  
  Hidden [System.IO.StreamReader] $SourceStream
  [int] $Linecounter = 0
  Hidden [char] $LastCharFromIdent = [char] 255
  [string[]] $varlist = @()
  
  
  Scanner([System.IO.StreamReader] $InputStream){
  
    $this.SourceStream = $InputStream
  }
  
  
  [char] GetChar()
  {
    $c = $null

    if($this.SourceStream.Peek() -ge 0 ){
      [char] $c = [char] $this.SourceStream.Read()
      
      if($c -eq [char] 13 ) {$this.Linecounter++ }
      if($c -eq [char] '#' ) { #Ignor commends
        do{
          [char] $c = [char] $this.SourceStream.Read()
        } while($c -ne [char] 13 )
      }
      return  $c
    }
    
    $this.SourceStream.Close()
    
    return $null
  }
  
  [void] Close(){
     if($this.SourceStream -ne $null){
       $this.SourceStream.Close()
     }
  }
  
  
  [PSCustomObject] GetSymbol(){
  
    [string] $ident = $null
    [char] $c = $null
    [int] $sym = 0
    [int] $sym = 0
    [int] $constant = 0
    
  
    if($this.LastCharFromIdent -eq [char]255){
      $c = $this.GetChar()
    } else {
      $c = $this.LastCharFromIdent
      $this.LastCharFromIdent = [char]255
    }
    
    while (($c -le [int][char] " ") -and ($c -gt [char](0))) #ASCII !!!!
    {
      $c=$this.GetChar()
    } 
    
    if($this.Linecounter -eq 4){

      
    }
  
    switch ($c)
    {
      
      { $_ -eq '$' } { #Variable
        do
        {
          $ident += $c        
          $c = $This.getchar()
        } while (($ident.Length -le [Scanner]::MaxVarLength) -and ($c -match '[a-z|A-Z|0-9]'))
        
        if($ident.Length -lt 1){
          throw $("Unknown symbold in variable in " + $this.Linecounter)
        }
        $sym = [Scanner]::Symbols.IndexOf("variable")
        $ident = $ident.Replace('$','').ToLower() #Remove $
        
        
        if(-not $this.varlist.Contains($ident)){
          $this.varlist+= $ident
        }
        
        
        $this.LastCharFromIdent = $c
      }
      
      
      { $_ -match '[a-z|A-Z]' } { #Keyword
      
        do
        {
          $ident += $c
          $c = $This.getchar()
        } while (($ident.Length -le [Scanner]::MaxVarLength) -and ($c -match '[a-z|A-Z|`-]'))
      
        if([Scanner]::Symbols.Contains($Ident.ToLower())){
          
          $sym = [Scanner]::Symbols.IndexOf($ident.ToLower())
          
        } else { #unknown keyword
        
          throw $("Unknown keyword $ident in line " + $this.Linecounter)
        }
        $this.LastCharFromIdent= $c
        
      }

      {$_ -match '[0-9]'} {
        $constant = 0;
        do
        {
          $constant = 10 * $constant + [int] $c - ([int] [char] "0")
          $c=$this.GetChar() 
        } while ($c -match '[0-9]')

        $sym = [Scanner]::Symbols.IndexOf("const")
        $this.LastCharFromIdent= $c
      }
      
      {$_ -eq '='}{
        $sym = [Scanner]::Symbols.IndexOf("equal") 
        
      }
      {$_ -eq '{'}{
        $sym = [Scanner]::Symbols.IndexOf("curlyBracesOpen") 
        
      }
      {$_ -eq '}'}{
        $sym = [Scanner]::Symbols.IndexOf("curlyBracesClose") 
        
      }
      {$_ -eq '('}{
        $sym = [Scanner]::Symbols.IndexOf("BracketOpen") 
        
      }
      {$_ -eq ')'}{
        $sym = [Scanner]::Symbols.IndexOf("BracketClose") 
        
      }
                  
      
      {$_ -eq '+'}{
        $sym = [Scanner]::Symbols.IndexOf("plus") 
        
      }
      {$_ -eq '-'}{
        $sym = [Scanner]::Symbols.IndexOf("minus") 
        $c = $This.getchar()
        if($c -match '[a-z|A-Z]'){ #mybe le,ge...
          
          do
          {
            $ident += $c
            $c = $This.getchar()
          } while (($ident.Length -le [Scanner]::MaxVarLength) -and ($c -match '[a-z|A-Z]'))
          
          if(@('ge','le','eq','lt','gt').Contains($ident)){
             $sym = [Scanner]::Symbols.IndexOf($ident) 
          } else {
            throw $('Scanner: Unknown switch -' + $ident + ' in ' +  $this.Linecounter)
          }
         
        }
         $this.LastCharFromIdent = $c   

        
      }
      {$_ -eq ','}{
        $sym = [Scanner]::Symbols.IndexOf("comma") 
        
      }
      {$_ -eq '"'} {
        $c = $This.getchar()
        do
        {
          $ident += $c
          $c = $This.getchar()
        } while (($ident.Length -le [Scanner]::MaxVarLength) -and ($c -ne '"'))
        
        $sym = [Scanner]::Symbols.IndexOf("string") 
        
      }    
    
    
      {$_ -eq 0} {$sym = [Scanner]::Symbols.IndexOf("eof")}
  
      default      { throw $('Scanner: Unknown Symbol ' + $c + ' in ' +  $this.Linecounter )}
    }
    
    $Output = "" | Select-Object Ident, Sym, Const
    $Output.Sym = $sym
    $Output.Ident = $Ident.ToLower()
    $Output.Const = $constant
    
  
    return  $Output
 
  }
}


Class CodeGenerator{

  static hidden [int] $Jumpmark = 0

  static Declaration([String[]] $varlist){
    # section '.bss' readable writeable
    # I dd ?

    #Write-Host '    ccall   [getchar]'
    Write-Host '    stdcall [ExitProcess],0'
    Write-Host ';===================================='
    Write-Host "section '.bss' readable writeable"
    Write-Host ';===================================='
    
    foreach($i in $varlist){
      Write-Host $("     $i dd " + '?')
    }

  }
  
  static MoveVarEAX([string] $variable){
    # Copy a Variable in CPU Register EAX
    # mov eax,[I]
    Write-Host $("     mov eax, " + '[' +$variable +']')
  }
  
  static MoveEAXVar([string] $variable){
    # Copy a Variable in CPU Register EAX
    # mov eax,[I]
    Write-Host $("     mov [" +$variable +'], eax')
  }    
  
  static MoveVarECX([string] $variable){
    # Copy a Variable in CPU Register ECX
    # mov eax,[I]
    Write-Host $("     mov ecx, " + '[' +$variable +']')

  }  
  
  static MoveEAXECX(){
    Write-Host $("     mov ecx, eax")

  } 
  
  static MoveConstEAX([string] $constant){
    # Copy a constant in the CPU register EAX
    Write-Host $("     mov eax, " + $constant )
  }

  static NegEAX(){
    # negate EAX
    Write-Host $("     neg eax" )
  }
  
  static AddEAXECX(){
    # EAX = EAX+ECX
    Write-Host $("     add eax, ecx" )
  }

  
  static Jumplabel([string] $label){
    Write-Host $('.LABEL' + $label +':')
  }
  
  static CMPEAX([String] $Op2){
    #Operation: Op2-EAX
    Write-Host "     CMP EAX, $Op2"
  }
  
  static JBE([String] $Label){
    
    Write-Host $('     JBE .LABEL'+$Label)
  }
  
  static JMP([String] $Label){
    
    Write-Host $('     JMP .LABEL'+$Label)
  }
  
  static [void] WriteHost([String] $Label, [String] $Variable ){
  
    Write-Host $('     ccall   [printf], '+$Label+', ['+$Variable+']')

  }
  static [void] WriteHost([String] $Label ){
  
    WWrite-Host $('     ccall   [printf], '+$Label)

  }
    
  
  static StartBlock(){
    Write-Host ';===================================='
    Write-Host ';Minimalistic PowerShell to '
    Write-Host ';Machinecode (Assembler) Compiler'
    Write-Host ';Andreas Nick 2019'
    Write-Host ';===================================='
    Write-Host 
    Write-Host 'format PE Console'
    Write-Host 'entry start'
    Write-Host "Include '%include%\win32a.inc'"
  }

   static DataBlock(){

    Write-Host ';============ Constants ==============='
    Write-Host "section '.data' data readable writeable"
    Write-Host ';======================================'
    Write-Host 
    Write-Host 'printfempty  db 10,0'
    Write-Host 'printfint    db "%lu",10,0'
  }
  
  
  static [void] AddDataEntries([hashtable] $entries){
    foreach($item in $entries.Keys){
      Write-Host  $($item+'         db "'+$entries[$item]+'", 10, 0')
    }
    Write-Host 
  }
  
  
  static [void] StartCode(){
    Write-Host ';======================================='
    Write-Host "section '.code' code readable executable"
    Write-Host ";======================================="

    Write-Host "start:"
  }
  
  
  static Refblock(){
  
    Write-Host ';===================================='
    Write-Host "section '.idata' import data readable"
    Write-Host ';===================================='
    Write-Host ''
    Write-Host "library kernel,'kernel32.dll',`\"
    Write-Host "        msvcrt,'msvcrt.dll'"

    Write-Host ''
    Write-Host 'import  kernel,\'
    Write-Host "        ExitProcess,'ExitProcess',\"
    Write-Host "        AllocConsole,'AllocConsole'"
    Write-Host ''
    Write-Host 'import  msvcrt,\'
    Write-Host "        printf,'printf',\"
    Write-Host "        getchar,'_fgetchar'"
  }
  
  
  static [int] GetJumpmark(){
    [CodeGenerator]::Jumpmark++
    return [CodeGenerator]::Jumpmark
    
  }
  
}


class Parser
{
  # private 
  hidden [System.IO.StreamReader] $Source
  hidden [PSCustomObject] $Token 
  hidden [Scanner] $Scanner
  
  hidden [String[]] $VarList = @() # a list with every variable found in the parsing process
  hidden [hashtable] $DataList = @{} # Entries for the Data Section Hashtable Key = Label!
   
  # Constructor
  Parser([System.IO.StreamReader] $InStream)
  {
    $this.Source =  $InStream;
    $This.Scanner = New-Object Scanner $this.Source
  }
   
  # Methods

      
  [void] Factor() {
    #$this.Token = $This.Scanner.GetSymbol()  
    switch ([scanner]::Symbols[$this.Token.Sym])
    {
      {$_ -eq 'variable'}  {  
        [CodeGenerator]::MoveVarEAX($this.token.Ident)
        $this.Token = $This.Scanner.GetSymbol()
      }
      {$_ -eq 'const'}  {  
        [CodeGenerator]::MoveConstEAX($this.token.const)
        $this.Token = $This.Scanner.GetSymbol()
      }                 
      default      { 
        throw  'expected factor'
      } 
    }
        
  }
  
  #[+|-] Factor +- Factor
  
  [void] Expression(){
    #is an negative value?
    [bool] $neg=$false
    
    if( @('plus','minus').Contains([Scanner]::Symbols[$this.Token.Sym])){
      $neg = [Scanner]::Symbols[$this.Token.Sym] -eq "minus"
      $this.Token = $This.Scanner.GetSymbol()
    }
    $this.Factor()
     
    if($neg){
      [CodeGenerator]::NegEAX()
    }
    
    while( @('plus','minus').Contains([Scanner]::Symbols[$this.Token.Sym])){
      $neg = [Scanner]::Symbols[$this.Token.Sym] -eq "minus"
      $this.Token = $This.Scanner.GetSymbol()
      [CodeGenerator]::MoveEAXECX()
      $this.Factor()
      if($neg){
        [CodeGenerator]::NegEAX()
      }
      [CodeGenerator]::AddEAXECX()
    }
  }
  
  
  
  
  
  [void] Statement(){
    # while
    # write-host
    # assihnment (=)
    # 

    [int] $start = 0
    [int] $end = 0
    
    [string] $name = $this.Token.Ident
    $symbol = [scanner]::Symbols[$this.Token.Sym]
    switch ($symbol)
    {
      {$_ -eq 'variable'}     { 
        $name = $this.token.Ident
        $this.Token = $This.Scanner.GetSymbol()
        if([scanner]::Symbols[$this.Token.Sym] -ne "equal"){
          throw "expected factor '=' "
        }
        $this.Token = $This.Scanner.GetSymbol()
        $this.Expression()
        [CodeGenerator]::MoveEAXVar($name)
        break

      }
      
      {$_ -eq 'while'}      { 

        $start = [codeGenerator]::GetJumpmark()
        $end = [codeGenerator]::GetJumpmark()
        [CodeGenerator]::Jumplabel($start)
        
        $this.Token = $This.Scanner.GetSymbol()
        if([scanner]::Symbols[$this.Token.Sym] -ne "BracketOpen"){
          throw "expected factor '(' "
        }
        $this.Token = $This.Scanner.GetSymbol()
        $this.Expression()
        
        if([scanner]::Symbols[$this.Token.Sym] -ne "BracketClose"){
          throw "expected factor ')' "
        }   

        [CodeGenerator]::CMPEAX(0)
        [CodeGenerator]::JBE($end)
        
        
        $this.Token = $This.Scanner.GetSymbol()
        
        if([scanner]::Symbols[$this.Token.Sym] -ne "curlyBracesOpen"){
          throw "expected  '{' "
        }
        
        $this.Token = $This.Scanner.GetSymbol()
        while( -not @('curlyBracesClose').Contains([Scanner]::Symbols[$this.Token.Sym])){
          
          $this.Statement()
        }
        
        if([scanner]::Symbols[$this.Token.Sym] -ne "curlyBracesClose"){
          throw "expected  '}' "
        }
        $this.Token = $This.Scanner.GetSymbol()
        [CodeGenerator]::JMP($start)
        [CodeGenerator]::Jumplabel($end)
        
        break
      } 
      
      {$_ -eq 'if'} {
        $this.Token = $This.Scanner.GetSymbol()
        $this.Token = $This.Scanner.GetSymbol()
        $this.Token = $This.Scanner.GetSymbol()
      }
      
      {$_ -eq 'write-host'}  {
        
        $this.Token = $This.Scanner.GetSymbol()
        
        switch ([scanner]::Symbols[$this.Token.sym])
        {
          {$_ -eq 'string'}
                       { 
                        $label= "D" + (Get-Random -Minimum 100 -Maximum 999).ToString()
                        
                        $str = $this.Token.ident
                        $this.Token = $This.Scanner.GetSymbol()
                        if([scanner]::Symbols[$this.Token.sym] -eq "variable"){
                          $str += '%lu'
                          [codeGenerator]::WriteHost($label,$this.Token.ident)
                          #$this.Token = $This.Scanner.GetSymbol()
                          
                        } else {
                          [codeGenerator]::WriteHost($label)
                        
                        }
                        $this.DataList.Add($label, $str)
                        break
                       }
                       
            {$_ -eq 'variable'} 
                        {
                            [codeGenerator]::WriteHost("printfint", $this.Token.ident)  
                            #$this.Token = $This.Scanner.GetSymbol()
                            break
                        }
                       
                       
          default      { 
                        [CodeGenerator]::WriteHost("printfempty")
                        $this.Token = $This.Scanner.GetSymbol()
                        break
                       }
        }
        
        
        
        
        if([scanner]::Symbols[$this.Token.Sym] -ne "variable"){
          throw "expected variable on Write-Host "
        } 
        $this.Token = $This.Scanner.GetSymbol()
          
         
        break
      }
      
    
      default      { throw $('Not expected :' + $Symbol + ' in line ' + $this.Scanner.Linecounter) }
    }
    
  }
  [void] Cmdlet() {
    [int] $start =0
    [CodeGenerator]::StartBlock()
    
    [CodeGenerator]::StartCode()
    
    $this.Token = $This.Scanner.GetSymbol()
    
    while( $this.Token.sym  -ne [Scanner]::Symbols.IndexOf("eof")){
      Write-Host $(';= '+[Scanner]::Symbols[$this.Token.Sym]+" =")
      $this.Statement()
    }
    
    [CodeGenerator]::Declaration($this.Scanner.varlist)
    [CodeGenerator]::DataBlock()
    [CodeGenerator]::AddDataEntries($this.DataList)
    [CodeGenerator]::Refblock()
    
    $this.Scanner.Close()
  }
    
}



# Create the shit

$PoshFile = "$PSScriptRoot\simpleproc.ps1"
#$PoshFile = "C:\Users\Andreas\Desktop\PoshCmp\simpleproc.ps1"

$Filename = $(split-path $PoshFile -leaf).Replace('.ps1','')
$AsmFile = $(split-path $PoshFile -Parent) + '\' + $Filename + '.asm'

#"C:\Users\Andreas\Desktop\PoshCmp\simpleproc.asm" 

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

# Assemble the shit

& "$PSScriptRoot\fasm.exe" $AsmFile   "$PSScriptRoot\simpleproc.exe"


<#

    [Environment]::SetEnvironmentVariable("include", "C:\Users\Andreas\Desktop\PoshCmp\include", "process")

    & "C:\Users\Andreas\Desktop\PoshCmp\fasm.exe" $AsmFile   "C:\Users\Andreas\Desktop\PoshCmp\simpleproc.exe"


    "`nTicks:"



    #(Measure-Command {
    & "C:\Users\Andreas\Desktop\PoshCmp\simpleproc.exe" 
    #}).Ticks


    #(Measure-Command {
    # & "C:\Users\Andreas\Desktop\PoshCmp\simpleproc.ps1" 6> $env:temp\out.tmp
    #}).Ticks

#>