$rootpath = split-path $MyInvocation.MyCommand.Path -Parent

#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   MinWidth="200"
   Width ="500"
   SizeToContent="Height"
   Title="Experimental PowerShell to Assembler Compiler"
   Topmost="True">
    <Grid Margin="10,40,10,10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="370"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <StackPanel Orientation="Vertical" Grid.Column="0" Grid.Row="0" Grid.ColumnSpan="3" Margin="5">
            <TextBlock>
    Experimental PoSh Compiler - please download Fasm
    <Hyperlink 
        NavigateUri="https://flatassembler.net/">
       fasm
    </Hyperlink>
            </TextBlock>
            <TextBlock>
    Andreas Nick 2019
    <Hyperlink 
        NavigateUri="https:www.andreasnick.com">
       Blog AndreasNick.com
    </Hyperlink>
            </TextBlock>

        </StackPanel>
        <TextBlock Grid.Column="0" Grid.Row="1" Margin="5">Source</TextBlock>
        <TextBlock Grid.Column="0" Grid.Row="2" Margin="5">Fasm Path</TextBlock>
        <TextBlock Grid.Column="0" Grid.Row="3" Margin="5">Out Path</TextBlock>
        <TextBox Name="TxtName" Grid.Column="1" Grid.Row="1" Margin="5"></TextBox>
        <TextBox Name="TxtFasm" Grid.Column="1" Grid.Row="2" Margin="5"></TextBox>
        <TextBox Name="OutPutPath" Grid.Column="1" Grid.Row="3" Margin="5"></TextBox>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,10,0,0" Grid.Row="4" Grid.ColumnSpan="2">
            <Button Name="ButtonCompile" MinWidth="80" Height="22" Margin="5">Compile</Button>
            <Button Name="ButtonExit" MinWidth="80" Height="22" Margin="5">Exit</Button>
        </StackPanel>
        <Button Content=" ... " Grid.Column="2" Grid.Row="3" Margin="5" Width="20"/>
        <Button Content=" ... " Grid.Column="2" Grid.Row="2" Margin="5" Width="20"/>
        <Button Content=" ... " Grid.Column="2" Grid.Row="1" Margin="5" Width="20"/>
        
    </Grid>
</Window>
'@
#endregion

#region Code Behind
function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $XAML
  )
  
  Add-Type -AssemblyName PresentationFramework
  
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  $reader.Close()
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  while ($reader.Read())
  {
      $name=$reader.GetAttribute('Name')
      if (!$name) { $name=$reader.GetAttribute('x:Name') }
      if($name)
      {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
  }
  $reader.Close()
  $result
}

function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [Windows.Window]
    $Window
  )
  
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}
#endregion Code Behind

#region Convert XAML to Window
$window = Convert-XAMLtoWindow -XAML $xaml 
#endregion

#region Define Event Handlers
# Right-Click XAML Text and choose WPF/Attach Events to
# add more handlers
$window.ButCancel.add_Click(
  {
    $window.DialogResult = $false
  }
)

$window.ButOk.add_Click(
  {
    $window.DialogResult = $true
  }
)
#endregion Event Handlers

#region Manipulate Window Content


#endregion

# Show Window
$result = Show-WPFWindow -Window $window

#region Process results
if ($result -eq $true)
{
  [PSCustomObject]@{
    EmployeeName = $window.TxtName.Text
    EmployeeMail = $window.TxtEmail.Text
  }
}
else
{
  Write-Warning 'User aborted dialog.'
}
#endregion Process results