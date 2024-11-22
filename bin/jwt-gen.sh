#!/bin/bash

# JWT Generator v0.1
# A shell script that generates JWT with Ed25519 algorithm for QWeather API authentication
# Copyright QWeather Dev (https://dev.qweather.com)
# MIT license

# Set required parameters: `kid`, `sub` and `private_key_path`
# If you prefer not to enter the required parameters every time you run this script
# uncomment the following and replace with your values:
# kid=ABC1234DEF
# sub=DEF5678ABC
# private_key_path=/path/to/ed25519-private.pem

# If the above required parameters are not saved
# you will be asked to enter them when this script is run
if [ -z "$kid" ]; then
    read -p "Enter your Credential ID (kid): " kid
fi
if [ -z "$sub" ]; then
    read -p "Enter your Project ID (sub): " sub
fi
if [ -z "$private_key_path" ]; then
    read -p "Enter the path of your Ed25519 private key: " private_key_path
fi

# Check if the private key exists
if [ ! -f "$private_key_path" ]; then
  echo "❌ Private key does not exist, please try again"
  exit 1
fi

# Set `iat` and `exp`
# `iat` defaults to the current time -10 seconds
# `exp` defaults to `iat` +24 hours
# you can overwrite them below
#iat=$(( $(date +%s) - 10 ))
iat=1731409200
exp=$((iat + 86400))

# Make $exp human-readable for later display
if [[ "$OSTYPE" == "darwin"* ]]; then
  exp_iso=$(date -r $exp -Iminutes)
else
  exp_iso=$(date -d @$exp -Iminutes)
fi

# Create base64url encoded header and payload
# and putting them togather
header_base64=$(printf '{"alg":"EdDSA","kid":"%s"}' "$kid" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
echo "header_base64 ${header_base64}"
payload_base64=$(printf '{"sub":"%s","iat":%d,"exp":%d}' "$sub" "$iat" "$exp" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
echo "payload_base64 ${payload_base64}"
header_payload="${header_base64}.${payload_base64}"

# Save $header_payload as a temporary file for Ed25519 signature
tmp_file=$(mktemp)
echo -n "$header_payload" > "$tmp_file"
cat $tmp_file
# Sign with Ed25519
signature=$(openssl pkeyutl -sign -inkey "$private_key_path" -rawin -in "$tmp_file" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
echo "signature ${signature}"
# Check if the signature is ok
if [[ $? -ne 0 || -z "$signature" ]]; then
  echo "❌ Unable to sign, check your private key"
  rm -f "$tmp_file"
  exit 1
fi

# Delete temporary file
rm -f "$tmp_file"

# Generate the final Token
jwt="${header_payload}.${signature}"

# Print Token
echo "🔑 Token (expire at $exp_iso):"
echo -e "\033[32m${jwt}\033[0m"
