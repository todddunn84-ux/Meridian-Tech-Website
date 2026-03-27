# Meridian Tech LLC — Website Deployment Guide

## Prerequisites
- AWS CLI configured with credentials
- Domain `meridian-hq.com` registered
- Route53 hosted zone for `meridian-hq.com`

## Step 1: Create SSL Certificate
The certificate MUST be in `us-east-1` (required for CloudFront).

```bash
aws acm request-certificate \
    --domain-name meridian-hq.com \
    --subject-alternative-names "*.meridian-hq.com" \
    --validation-method DNS \
    --region us-east-1
```

Add the DNS validation records to Route53, then wait for validation.

## Step 2: Deploy CloudFormation Stack

```bash
aws cloudformation deploy \
    --template-file cloudformation.yml \
    --stack-name meridian-tech-website \
    --parameter-overrides \
        DomainName=meridian-hq.com \
        CertificateArn=arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID \
    --region us-east-1
```

## Step 3: Get Stack Outputs

```bash
aws cloudformation describe-stacks \
    --stack-name meridian-tech-website \
    --query "Stacks[0].Outputs" \
    --region us-east-1
```

Copy the `CloudFrontDistributionId` and update `deploy.sh`.

## Step 4: Upload Website Files

```bash
chmod +x deploy.sh
./deploy.sh
```

## Step 5: Verify
Visit https://meridian-hq.com — should be live within a few minutes.

## Updating the Site
Just run `./deploy.sh` again after making changes. It syncs files and invalidates the CloudFront cache.
