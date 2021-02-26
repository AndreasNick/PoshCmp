$max = 100
$i = 1
$n = 0
$l = 0
$m = 0
$r = 0

while($i -lt $max){

  if($i -eq 1) {
    Write-Output $i
    $i = $i +1
    
  }
  
  if($i -eq 2) {
    Write-Output $i
    $i = $i +1
  }
  
  $n = $i % 2 
  if($n -eq 0){
    $i = $i +1
  }

  $n = $i / 2
  $l = 3
  $m = 1

  while($l -le $n){
    $r = $i % $l
    
    if($r -eq 0){
      $m = 0
      #break
    }
    $l = $l + 2
  }

  if($m){ 
    Write-Output $i
  }
  
  $i = $i +1
  
}