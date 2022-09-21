# Wait for connection to host
do{$connection = Test-Connection -ComputerName "server" -Quiet}  until ($connection)