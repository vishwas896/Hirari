# Hirari

High intelligent reverse auto review integrated

## 24/7 Ubuntu VPS + Hermes Agent Setup

Use this on a fresh Ubuntu 22.04/24.04 VPS to keep Hermes running continuously with secure remote control.

### 1) Run the bootstrap script

```bash
git clone https://github.com/vishwas896/Hirari.git
cd Hirari
chmod +x /home/runner/work/Hirari/Hirari/scripts/setup_hermes_vps.sh
sudo /home/runner/work/Hirari/Hirari/scripts/setup_hermes_vps.sh
```

### 2) Provide Hermes env values

Create `/etc/default/hermes-agent`:

```bash
sudo tee /etc/default/hermes-agent >/dev/null <<'EOF'
HERMES_INSTALL_CMD='curl -fsSL https://YOUR-HERMES-INSTALLER | bash'
HERMES_RUN_CMD='/usr/local/bin/hermes-agent run'
EOF
```

Then install and start:

```bash
sudo /usr/local/bin/install-hermes-agent
sudo systemctl daemon-reload
sudo systemctl enable --now hermes-agent
sudo systemctl status hermes-agent --no-pager
```

### 3) Full-control checklist

- SSH key auth only (password login disabled)
- UFW enabled (OpenSSH allowed)
- Fail2ban installed and running
- Automatic security updates enabled
- Hermes managed by `systemd` with `Restart=always`
- Logs available via `journalctl -u hermes-agent -f`
