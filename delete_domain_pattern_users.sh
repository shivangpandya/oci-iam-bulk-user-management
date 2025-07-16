#!/bin/bash

# --- Configuration ---
# Replace with your Identity Domain OCID or URL.
# You can find this in the OCI Console under Identity & Access Management -> Identity Domains.
# Variables
PROFILE_NAME=""
IDENTITY_DOMAIN_URL="" # Example: Replace with your actual URL or OCID
# Or if using OCID directly:

#Optional if adding users in array directly instead of txt file reading it , can uncomment and directly add it here
# EXCLUDE_USERS=(

# )
# TARGET_LIFECYCLE_STATE="INACTIVE"

# Initialize the array
EXCLUDE_USERS=()

# Read each line from the file into the array
while IFS= read -r line || [[ -n "$line" ]]; do
  EXCLUDE_USERS+=("$line")
done < exclude_users.txt

# Verify the array contents
echo "Excluded users:"
for user in "${EXCLUDE_USERS[@]}"; do
  echo "$user"
done


# Convert the array to a grep pattern
EXCLUDE_PATTERN=$(IFS='|'; echo "${EXCLUDE_USERS[*]}")

echo "--- OCI IAM User Deletion Script ---"
echo " "
echo "WARNING: This script will delete users from your OCI tenancy."
echo "         This action is irreversible."
echo " "
echo "Excluding the following users from deletion:"
for user in "${EXCLUDE_USERS[@]}"; do
    echo "  - $user"
done

# --- Functions ---
# --- Script Logic ---


ALL_USERS_JSON=$(oci identity-domains users list --profile "$PROFILE_NAME" --all --endpoint "$IDENTITY_DOMAIN_URL" --query 'data' --raw-output 2>&1)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to list users. Check OCI CLI configuration and permissions for profile '$OCI_CLI_PROFILE'."
    echo "Output: $ALL_USERS_JSON"
    exit 1
fi

if [ -z "$(echo "$ALL_USERS_JSON" | tr -d ' ' | tr -d '\n')" ] || [ "$ALL_USERS_JSON" == "[]" ]; then
    echo "No users found in the tenancy."
    exit 0
fi



# This check ensures it's not empty or malformed before parsing
if [ -z "$(echo "$ALL_USERS_JSON" | tr -d '[:space:]')" ] || [ "$ALL_USERS_JSON" == "[]" ]; then
    echo "No users found in the tenancy or OCI CLI returned an empty response."
    exit 0
fi

# Parse JSON and filter users
# The jq -c '.[]' will correctly unwrap the array of full user objects
#echo "$ALL_USERS_JSON" | jq .
CLEAN_JSON=$(echo "$ALL_USERS_JSON" | jq . 2>/dev/null)


# Check if ALL_USERS_JSON is empty
if [ -z "$ALL_USERS_JSON" ]; then
  echo "Error: ALL_USERS_JSON variable is empty!"
  exit 1
fi


# Loop through each user from the JSON
#The force delete true parameter will delete the user and will force delete it even if it has existing group membership 
#The grep patter checks for pattern matching with exluded users and works on skipping them entirely

echo "$ALL_USERS_JSON" | jq -r '.resources[] | "\(.["user-name"]) \(.ocid)"' 2>/dev/null | while read -r username ocid; do
  echo "Checking user: $username with OCID: $ocid"
  if echo "$username" | grep -qE "$EXCLUDE_PATTERN"; then
    echo "✅ Skipping $username (excluded)"
  else
    echo "🗑️ Deleting user-name: $username, ocid: $ocid"
    yes y | oci identity-domains user delete --profile $PROFILE_NAME --endpoint $IDENTITY_DOMAIN_URL --user-id "$ocid" --force-delete true
  fi
done

