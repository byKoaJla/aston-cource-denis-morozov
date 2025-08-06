#!/bin/bash

URL=$1

if [ "$URL" == "" ]; then
    echo "URL address is required!"
    exit 1
fi

if [[ $URL =~ ^https?://([^/]+) ]]; then
    URL="$1"
else
    echo "Invalid URL address!"
    exit 1
fi

error=$(curl -o /dev/null -k -s -w "%{http_code}" "$URL" 2>&1)
curl_exec_code=$?

if [ $curl_exec_code -ne 0 ]; then
    echo "Error to connection $URL"
    echo "$error"
    exit 1
else 
    echo "The website with url $URL is available. HTTP status: $error"
fi
