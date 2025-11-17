# XMRig No-Donate - Monero Miner

Docker image for XMRig cryptocurrency miner compiled from source with **0% donation** hardcoded.

## Features

- ✅ **0% Donation** - Fully removed from source code
- ✅ **Latest XMRig** - Version 6.23.0
- ✅ **Optimized Build** - Compiled with CPU optimizations
- ✅ **RandomX Support** - Full support for Monero (XMR)
- ✅ **Auto-restart** - Container restarts automatically
- ✅ **Docker Compose** - Easy deployment
- ✅ **GitHub Actions** - Automated builds

## Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/networktoday/xmrig-no-donate.git
cd xmrig-no-donate
```

### 2. Configure your miner

```bash
cp config.json.example config.json
nano config.json
```

Edit these values:
- `url`: Your mining pool address
- `user`: Your Monero wallet address
- `pass`: Your worker name/password

### 3. Start mining

```bash
docker-compose up -d
```

### 4. Check logs

```bash
docker-compose logs -f
```

## One-Line Deploy (Alternative)

```bash
curl -sSL https://raw.githubusercontent.com/networktoday/xmrig-no-donate/main/deploy.sh | bash
```

## Using Pre-Built Image

Edit `docker-compose.yml` and uncomment:

```yaml
image: ghcr.io/networktoday/xmrig-no-donate:latest
```

Then comment out the `build: .` line.

## Configuration

### CPU Usage Control

Edit `config.json` and adjust:

```json
"max-threads-hint": 100,  // Use 100% of CPU cores
```

Reduce to limit CPU usage:
- `75` = 75% of cores
- `50` = 50% of cores
- `25` = 25% of cores

### Pool Configuration

Popular Monero pools:
- `pool.supportxmr.com:443` (TLS)
- `pool.hashvault.pro:443` (TLS)
- `xmr.2miners.com:2222` (No TLS)

### Example Configurations

**Low CPU usage (25%)**:
```json
"max-threads-hint": 25
```

**Medium CPU usage (50%)**:
```json
"max-threads-hint": 50
```

**Maximum performance (100%)**:
```json
"max-threads-hint": 100
```

## Monitoring

### View real-time logs
```bash
docker logs -f xmrig-miner
```

### Check CPU usage
```bash
docker stats xmrig-miner
```

### View container status
```bash
docker ps
```

## Management Commands

### Start miner
```bash
docker-compose up -d
```

### Stop miner
```bash
docker-compose down
```

### Restart miner
```bash
docker-compose restart
```

### Update image
```bash
docker-compose pull
docker-compose up -d
```

## Build from Source

If you want to build locally:

```bash
docker build -t xmrig-no-donate:local .
```

Then edit `docker-compose.yml`:
```yaml
image: xmrig-no-donate:local
```

## Verify 0% Donation

Check the logs after starting:

```bash
docker logs xmrig-miner | grep DONATE
```

You should see:
```
* DONATE       0%
```

## Security Notes

- Container runs as non-root user (`mining`)
- Config file is mounted read-only
- No network ports exposed by default
- Minimal attack surface

## Performance Tips

1. **Enable huge pages** (on host):
   ```bash
   echo "vm.nr_hugepages=1280" | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

2. **Disable MSR warnings** - This is normal in VM environments

3. **Monitor temperature** - Ensure adequate cooling

## Troubleshooting

### Container keeps restarting

Check logs:
```bash
docker logs xmrig-miner
```

### Low hashrate

1. Check CPU usage: `docker stats xmrig-miner`
2. Verify pool connection in logs
3. Increase `max-threads-hint` in config
4. Enable huge pages (see Performance Tips)

### Pool connection failed

1. Verify pool URL is correct
2. Check if TLS is enabled/required
3. Test pool connectivity: `telnet pool.example.com 443`

## Contributing

Contributions are welcome! Please open an issue or pull request.

## Disclaimer

This software is for educational purposes only. Mining cryptocurrency may:
- Consume significant electricity
- Generate heat
- Wear hardware
- Violate cloud provider terms of service

Use responsibly and at your own risk.

## License

This project uses XMRig source code, which is licensed under GPL-3.0.

## Credits

- [XMRig](https://github.com/xmrig/xmrig) - High performance Monero (XMR) miner

## Support

If you find this useful, consider:
- Starring this repository
- Contributing improvements
- Sharing with others

**Happy Mining!**
