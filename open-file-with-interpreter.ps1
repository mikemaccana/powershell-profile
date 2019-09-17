Param(
  [string]$fileName
)

echo "Woo I opened $fileName"

$firstLine = (Get-Content $fileName -First 1)

echo $firstLine

if ( $firstLine.startsWith('#!') ) {
  echo 'Woo this is interpreted'
  $firstCommand = $firstLine | Select-String -Pattern '#![a-z/]*' -AllMatches -List | % { $_.Matches } | % { $_.Value }
  echo $firstCommand
  $binary = $firstCommand.split('/')[-1]
  echo "Binary is ${binary}"
  if ( $binary -eq 'env' ) {
    echo "env, running rest of line as command"
  } else {
    echo "not env, cut off folder then run rest of command"
  }
} else {
  echo 'Not an interpreted file'
}