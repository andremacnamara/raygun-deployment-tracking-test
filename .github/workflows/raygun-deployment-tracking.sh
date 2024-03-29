#!/bin/bash

RAYGUN_PAT_TOKEN=""
RAYGUN_API_KEY=""
DEPLOYMENT_VERSION=""
DEPLOYMENT_OWNER_NAME=""
DEPLOYMENT_OWNER_EMAIL=""
DEPLOYMENT_NOTES=""
DEPLOYMENT_SCM_IDENTIFIER=""
DEPLOYMENT_SCM_TYPE=""
DEPLOYMENT_TIME=""

while getopts ":t:a:v:o:e:n:i:s:d:" opt; do
  case $opt in
    t) RAYGUN_PAT_TOKEN="$OPTARG" ;;
    a) RAYGUN_API_KEY="$OPTARG" ;;
    v) DEPLOYMENT_VERSION="$OPTARG" ;;
    o) DEPLOYMENT_OWNER_NAME="$OPTARG" ;;
    e) DEPLOYMENT_OWNER_EMAIL="$OPTARG" ;;
    n) DEPLOYMENT_NOTES="$OPTARG" ;;
    i) DEPLOYMENT_SCM_IDENTIFIER="$OPTARG" ;;
    s) DEPLOYMENT_SCM_TYPE="$OPTARG" ;;
    d) DEPLOYMENT_TIME="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [ -z "$RAYGUN_PAT_TOKEN" ] || [ -z "$RAYGUN_API_KEY" ] || [ -z "$DEPLOYMENT_VERSION" ]; then
  echo @"Usage: $0 -t raygun_token -a apiKey -v version 
                  [-o owner_name] [-e email] [-n notes] [-i scm_identifier] 
                  [-s scm_type] [-d deployed_at]"
  exit 1
fi

echo "Registering deployment with Raygun"

# Some older API keys may contain URL reserved characters. 
# These API keys will need to be encoded before being included in the URL.
# Here are a couple examples of how you could do URL encoding.
# encodedApiKey=$(python -c "import urllib.parse; print(urllib.parse.quote('$RAYGUN_API_KEY'))")
# or
# encodedApiKey=$(echo "$RAYGUN_API_KEY" | jq -R @uri)

url="https://api.raygun.com/v3/applications/api-key/$RAYGUN_API_KEY/deployments"

json_properties=("\"version\": \"$DEPLOYMENT_VERSION\"")

if [ -n "$DEPLOYMENT_OWNER_NAME" ]; then
        json_properties+=("\"ownerName\": \"$DEPLOYMENT_OWNER_NAME\"")
fi

if [ -n "$DEPLOYMENT_OWNER_EMAIL" ]; then
        json_properties+=("\"emailAddress\": \"$DEPLOYMENT_OWNER_EMAIL\"")
fi

if [ -n "$DEPLOYMENT_NOTES" ]; then
        json_properties+=("\"comment\": \"$DEPLOYMENT_NOTES\"")
fi

if [ -n "$DEPLOYMENT_SCM_IDENTIFIER" ]; then
        json_properties+=("\"scmIdentifier\": \"$DEPLOYMENT_SCM_IDENTIFIER\"")
fi

if [ -n "$DEPLOYMENT_SCM_TYPE" ]; then
        json_properties+=("\"scmType\": \"$DEPLOYMENT_SCM_TYPE\"")
fi

if [ -n "$DEPLOYMENT_TIME" ]; then
        json_properties+=("\"deployedAt\": \"$DEPLOYMENT_TIME\"")
fi

arrayString=$(IFS=$',' ; echo "${json_properties[*]}")

json_string="{$arrayString}"

response=$(curl -s -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RAYGUN_PAT_TOKEN" \
  -d "$json_string" \
  "$url")

body=${response::-3}
status_code=$(printf "%s" "$response" | tail -c 3)

if [ "$status_code" -eq "201" ]; 
then
  echo "Deployment registered with Raygun"
else
  echo "Failed to register deployment with raygun"
fi

echo "$body"