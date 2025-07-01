# Secure Private Nix Cache Setup

## AWS IAM Setup

**Create IAM Users:**
```bash
# Admin user - read/write access
aws iam create-user --user-name nix-admin

# Developer user - read-only access  
aws iam create-user --user-name nix-dev
```

**S3 Bucket Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AdminAccess",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::ACCOUNT:user/nix-admin"},
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::your-nix-cache", "arn:aws:s3:::your-nix-cache/*"]
    },
    {
      "Sid": "DeveloperAccess", 
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::ACCOUNT:user/nix-dev"},
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::your-nix-cache", "arn:aws:s3:::your-nix-cache/*"]
    }
  ]
}
```

## Admin Machine Setup

**1. Configure AWS Profile:**
```bash
aws configure --profile nix-admin
# Enter admin access key/secret
```

**2. Generate Signing Keys:**
```bash
nix-store --generate-binary-cache-key company-cache ./secret-key ./public-key
```

**3. Admin Nix Configuration:**
```bash
# ~/.config/nix/nix.conf
substituters = https://cache.nixos.org s3://your-nix-cache
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
```

**4. Copy Curated Packages:**
```bash
export AWS_PROFILE=nix-admin
export NIX_CACHE_BUCKET="s3://your-nix-cache"

# Get store paths
ZULU_PATH=$(nix eval --raw nixpkgs#zulu21.outPath)
NODE_PATH=$(nix eval --raw nixpkgs#nodejs_22.outPath)

# Copy with signing
nix copy --to $NIX_CACHE_BUCKET \
  --from https://cache.nixos.org \
  --option secret-key-files ./secret-key \
  $ZULU_PATH $NODE_PATH
```

**5. Verify Upload:**
```bash
nix path-info --store $NIX_CACHE_BUCKET --sigs $ZULU_PATH
```

## Developer Machine Setup

**1. Configure AWS Profile:**
```bash
aws configure --profile nix-dev
# Enter dev access key/secret (read-only)
```

**2. Developer Nix Configuration:**
```bash
# ~/.config/nix/nix.conf
substituters = s3://your-nix-cache
trusted-public-keys = company-cache:CONTENT_OF_PUBLIC_KEY_FILE
```

**3. Set AWS Profile:**
```bash
export AWS_PROFILE=nix-dev
```

**4. Test Package Installation:**
```bash
# Should fetch from private cache only
nix-shell -p zulu21 nodejs_22
```

## Package Curation Workflow

**Admin adds new package:**
```bash
#!/bin/bash
export AWS_PROFILE=nix-admin

add_package() {
    local pkg=$1
    local path=$(nix eval --raw nixpkgs#${pkg}.outPath)
    
    echo "Adding $pkg to curated cache..."
    nix copy --to s3://your-nix-cache \
      --from https://cache.nixos.org \
      --option secret-key-files ./secret-key \
      $path
    
    echo "✓ $pkg available for developers"
}

# Usage
add_package "zulu21"
add_package "nodejs_22"
```

**Developer verification:**
```bash
# List available packages
nix path-info --store s3://your-nix-cache --all
```

## Security Benefits

- **Controlled supply chain**: Only admin-approved packages
- **Least privilege**: Developers can't access cache.nixos.org directly
- **Signed packages**: Cryptographic verification of integrity
- **Audit trail**: All package additions logged via admin actions
- **Air-gapped development**: No direct internet dependency for packages
