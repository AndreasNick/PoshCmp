class NewClass
{
  # private 
  hidden [int]$IncrementFactor
  # public Property
  [int]$Index
   
  # Constructor
  NewClass()
  {
    # Constructor Code
    $this.Index = 1
    $this.IncrementFactor = 1
      
  }
   
  [string] test(){
    
      Write-Output "Test"
    
  }
   
   # Method
   [void] Increment() {
      $this.Index += $this.IncrementFactor
      }
      
      [void] SetIncrementFactor([int]$NewFactor)
      {
         $this.IncrementFactor = $NewFactor
      }
      
      [int] GetIncrementFactor()
      {
         return $this.IncrementFactor
      }
}

# instantiate class
$myClass = [NewClass]::new()
$myClass.test()


<#
    # use properties and methods
    $myClass.Index

    $myClass.Increment()
    $myClass.Index

    $myClass.SetIncrementFactor(15)
    $myClass.GetIncrementFactor()
    $myClass.Index
    $myClass.Increment()
    $myClass.Index
#>