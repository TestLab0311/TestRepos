#!/bin/bash

API_URL="https://api.github.com"
USERNAME=$username
TOKEN=$token
REPO_OWNER=$1
REPO_NAME=$2

function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    collaborators_raw="$(github_api_get "$endpoint")"

    # Check if there was an error in the API response
    if echo "$collaborators_raw" | jq -e '.message' > /dev/null; then
        echo "Error: $(echo "$collaborators_raw" | jq -r '.message')"
        exit 1
    fi

    collaborators="$(echo "$collaborators_raw" | jq -r '.[] | select(.permissions.pull == true) | .login')"
    
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
