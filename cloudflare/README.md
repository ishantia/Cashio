# Cashio Cloudflare Worker

This directory contains the Cloudflare Worker that acts as the backend for Cashio's privacy-preserving Cloud Backup feature.

## Privacy & Security

* **Zero-Knowledge Architecture:** The Worker never sees the encryption keys.
* **End-to-End Encryption:** Financial data is AES-GCM encrypted on the user's device before upload.
* **No Database:** No structured financial data is stored in the cloud. Backups are stored as opaque blobs in Cloudflare R2.
* **Minimal Scope:** The Worker only provides APIs to upload, download, list, and delete opaque blobs.

## Prerequisites

1. Cloudflare account
2. wrangler CLI (
pm install -g wrangler)
3. Cloudflare R2 enabled

## Setup Instructions

1. **Create an R2 Bucket:**
   `bash
   wrangler r2 bucket create cashio-backups
   `

2. **Configure Authentication:**
   Generate a strong random string to use as your API Token (e.g., using openssl rand -hex 32).
   
   Set it as a secret in Cloudflare:
   `bash
   wrangler secret put API_TOKEN
   `
   (Paste your secret token when prompted)

3. **Deploy the Worker:**
   `bash
   npm run deploy
   `

## Connecting the App

1. Open the Cashio app.
2. Go to **Settings > Cloud Backup > Configure Settings**.
3. Enter your Worker URL (e.g., https://cashio-sync.<your-subdomain>.workers.dev).
4. Enter the API_TOKEN you generated.
5. Enter a secure encryption password (this password encrypts your backups locally and is never sent to the cloud).

## Local Development & Testing

`bash
npm install
npm test
`
