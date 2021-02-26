# Andreas Nick 2019
# Test for PoSh Compiler

$I = 1
$J = 0
$K = 10


# if($I -eq 0){ }


  While ($K) {
    Write-Host "fibu " $I
    $I = $i + $J
    $J = $I - $J
    $K = $K - 1
   
  }


