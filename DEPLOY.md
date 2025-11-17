# Deployment Guide

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository (e.g., `xmrig-no-donate`)
3. Choose **Public** or **Private**
4. **Do NOT** initialize with README (we already have files)

## Step 2: Upload Files to GitHub

### Option A: Using Git CLI

```bash
cd /root/xmrig-github-repo

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: XMRig No-Donate Docker setup"

# Add remote (replace networktoday)
git remote add origin https://github.com/networktoday/xmrig-no-donate.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Option B: Using GitHub Web UI

1. Create repository on GitHub
2. Upload files manually through the web interface

## Step 3: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **General**
3. Enable **Read and write permissions** for workflows
4. Save

## Step 4: Enable GitHub Container Registry (GHCR)

1. GitHub Actions will automatically build and push to GHCR
2. After first push, the image will be available at:
   ```
   ghcr.io/networktoday/xmrig-no-donate:latest
   ```

## Step 5: Make Package Public (Optional)

1. Go to your GitHub profile → **Packages**
2. Find `xmrig-no-donate` package
3. Click **Package settings**
4. Change visibility to **Public** (optional)

## Step 6: Update Repository URLs

Edit these files and replace `networktoday`:

1. `README.md`:
   - Line 21: Clone URL
   - Line 43: Deploy script URL
   - Line 50: Image URL

2. `deploy.sh`:
   - Line 3: Deploy script URL
   - Line 36: docker-compose.yml URL
   - Line 40: config.json.example URL

3. `docker-compose.yml`:
   - Line 3: Image URL

## Step 7: Test Deploy on New Server

On a new server, run:

```bash
curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/deploy.sh | bash
```

## Automatic Builds

GitHub Actions will automatically build and push new images when you:
- Push to `main` branch
- Create a new tag (e.g., `v1.0.0`)

## Troubleshooting

### Build fails on GitHub Actions

Check:
1. Actions are enabled in Settings
2. Workflow has write permissions
3. Review build logs in Actions tab

### Image not available on GHCR

Wait a few minutes after first push. The build takes 5-10 minutes.

### Deploy script fails

Ensure URLs in `deploy.sh` are updated with your GitHub username.

## Security Notes

### Protecting Sensitive Data

**Never commit**:
- Your wallet address
- Pool credentials
- API tokens

Use `config.json.example` as template and keep `config.json` gitignored.

### Private Repository

If you want to keep the repository private:
1. Create a Personal Access Token (PAT) on GitHub
2. Use it instead of password when pushing
3. Configure deploy script to use authentication

## Support

For issues, open a ticket on your GitHub repository.
