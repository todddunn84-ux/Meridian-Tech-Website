#!/bin/bash
# Meridian Tech LLC - Website Deployment Script
# Usage: ./deploy.sh

set -e

BUCKET_NAME="meridian-hq.com-website"
DISTRIBUTION_ID=""  # Fill in after CloudFormation stack is created
REGION="us-east-1"

echo "=== Meridian Tech LLC - Website Deploy ==="

# Step 1: Sync files to S3
echo "Uploading files to S3..."
aws s3 sync . s3://$BUCKET_NAME \
    --exclude "*.sh" \
    --exclude "cloudformation.yml" \
    --exclude "DEPLOYMENT.md" \
    --delete \
    --region $REGION

# Step 2: Set correct content types
aws s3 cp s3://$BUCKET_NAME/index.html s3://$BUCKET_NAME/index.html \
    --content-type "text/html" \
    --metadata-directive REPLACE \
    --region $REGION

aws s3 cp s3://$BUCKET_NAME/styles.css s3://$BUCKET_NAME/styles.css \
    --content-type "text/css" \
    --metadata-directive REPLACE \
    --region $REGION

# Step 3: Invalidate CloudFront cache
if [ -n "$DISTRIBUTION_ID" ]; then
    echo "Invalidating CloudFront cache..."
    aws cloudfront create-invalidation \
        --distribution-id $DISTRIBUTION_ID \
        --paths "/*"
    echo "Cache invalidation started."
else
    echo "WARNING: No DISTRIBUTION_ID set. Skipping cache invalidation."
    echo "Update DISTRIBUTION_ID in this script after stack creation."
fi

echo "=== Deploy complete ==="
