#!/bin/bash

# Usage: ./delete-acr-repositories.sh <resource-group-name>

if [ -z "$1" ]; then
    echo "Error: Resource group name required"
    echo "Usage: $0 <resource-group-name>"
    exit 1
fi

RESOURCE_GROUP=$1

echo "Fetching ACRs in resource group: $RESOURCE_GROUP"
ACRS=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$ACRS" ]; then
    echo "No ACRs found in resource group: $RESOURCE_GROUP"
    exit 0
fi

TOTAL_DELETED=0

echo ""
echo "ACRs found:"
for ACR in $ACRS; do
    echo "  - $ACR"
done
echo ""

for ACR in $ACRS; do
    echo "========================================="
    echo "ACR: $ACR"
    echo "========================================="
    REPOS=$(az acr repository list --name "$ACR" -o tsv 2>/dev/null)
    
    if [ -z "$REPOS" ]; then
        echo "  No repositories found"
        echo ""
        continue
    fi
    
    REPO_COUNT=0
    for REPO in $REPOS; do
        echo "  Deleting: $REPO"
        az acr repository delete --name "$ACR" --repository "$REPO" --yes >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "    ✓ Deleted"
            ((TOTAL_DELETED++))
            ((REPO_COUNT++))
        else
            echo "    ✗ Failed"
        fi
    done
    echo "  Deleted $REPO_COUNT repositories from $ACR"
    echo ""
done

echo "========================================="
echo "SUMMARY"
echo "========================================="
echo "Total repositories deleted: $TOTAL_DELETED"
