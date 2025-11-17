# 🚀 Come caricare su GitHub

## Passo 1: Crea il repository su GitHub

1. Vai su https://github.com/new
2. **Repository name**: `xmrig-no-donate`
3. **Description**: `XMRig Monero miner with 0% donation - Docker`
4. **Visibility**: Scegli Public o Private
5. ⚠️ **NON** selezionare "Add a README file"
6. Click **Create repository**

## Passo 2: Carica i file

### Metodo A: Git CLI (da questo server)

```bash
cd /root/xmrig-github-repo

# Inizializza git
git init
git add .
git commit -m "Initial commit: XMRig No-Donate Docker setup"

# Collega al repository GitHub
git remote add origin https://github.com/networktoday/xmrig-no-donate.git
git branch -M main

# Push (ti chiederà username e password/token)
git push -u origin main
```

**Note**:
- Username: `networktoday`
- Password: Usa un **Personal Access Token** invece della password
  - Vai su: https://github.com/settings/tokens
  - Generate new token (classic)
  - Seleziona: `repo` (Full control)
  - Copia il token e usalo come password

### Metodo B: Upload manuale (più semplice)

1. Dopo aver creato il repository, clicca **uploading an existing file**
2. Trascina tutti i file dalla cartella `/root/xmrig-github-repo/`
3. Aggiungi commit message: `Initial commit`
4. Click **Commit changes**

## Passo 3: Abilita GitHub Actions

1. Vai su: https://github.com/networktoday/xmrig-no-donate/settings/actions
2. Sezione **Workflow permissions**
3. Seleziona **Read and write permissions**
4. Click **Save**

## Passo 4: Attendi il build

1. Vai su: https://github.com/networktoday/xmrig-no-donate/actions
2. Il primo workflow partirà automaticamente
3. Attendi ~10 minuti per la compilazione

## Passo 5: Immagine Docker pronta!

Dopo il build, l'immagine sarà disponibile su:
```
ghcr.io/networktoday/xmrig-no-donate:latest
```

## Passo 6: Deploy rapido su altri server

Su qualsiasi nuovo server, esegui:

```bash
curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/deploy.sh | bash
```

## Troubleshooting

### Errore: Authentication failed

Usa un Personal Access Token invece della password:
- https://github.com/settings/tokens
- Scope necessario: `repo`

### Build fallito su GitHub Actions

1. Verifica che le GitHub Actions siano abilitate
2. Controlla i permessi (Step 3)
3. Guarda i log nella sezione Actions

### Immagine non disponibile

Aspetta che il primo build finisca (controlla la tab Actions).

## Verifica finale

Dopo l'upload, verifica che questi file siano presenti:
- ✅ README.md
- ✅ Dockerfile
- ✅ docker-compose.yml
- ✅ config.json.example
- ✅ deploy.sh
- ✅ .github/workflows/build.yml

Tutti i file dovrebbero essere visibili su:
https://github.com/networktoday/xmrig-no-donate
