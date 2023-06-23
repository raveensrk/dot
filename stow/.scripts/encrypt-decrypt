#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 [encrypt/decrypt] [file_or_directory] [passphrase]"
    exit 1
fi

operation="$1"
file_or_directory="$2"
passphrase="$3"
tar_file="archive.tar"
compressed_file="$tar_file.gz"
encrypted_file="$compressed_file.enc"

if [[ "$operation" == "encrypt" ]]; then
    # Create a tar archive of the file or directory
    tar -hcvf "$tar_file" "$file_or_directory"

    # Compress the tar archive with maximum compression
    gzip -9 "$tar_file"

    # Encrypt the compressed file with the given passphrase
    openssl enc -aes-256-cbc -salt -pass "pass:$passphrase" -in "$compressed_file" -out "$encrypted_file"

    echo "Encrypted file $encrypted_file created."
elif [[ "$operation" == "decrypt" ]]; then
    # Decrypt the encrypted file with the given passphrase
    openssl enc -d -aes-256-cbc -pass "pass:$passphrase" -in "$encrypted_file" -out "$compressed_file"

    # Decompress the compressed file
    gzip -d "$compressed_file"

    # Extract the files from the tar archive
    tar -xvf "$tar_file"
    
    echo "File or directory extracted from $encrypted_file."
else
    echo "Invalid operation. Usage: $0 [encrypt/decrypt] [file_or_directory] [passphrase]"
    exit 1
fi

