#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  ufw \
  fail2ban \
  unattended-upgrades \
  apt-listchanges

dpkg-reconfigure -f noninteractive unattended-upgrades

ufw --force allow OpenSSH
ufw --force enable

cat >/usr/local/bin/install-hermes-agent <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ -f /etc/default/hermes-agent ]]; then
  # shellcheck source=/dev/null
  . /etc/default/hermes-agent
fi

: "${HERMES_INSTALL_CMD:?Set HERMES_INSTALL_CMD in /etc/default/hermes-agent}"
eval "${HERMES_INSTALL_CMD}"
EOF
chmod +x /usr/local/bin/install-hermes-agent

cat >/etc/systemd/system/hermes-agent.service <<'EOF'
[Unit]
Description=Hermes Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=-/etc/default/hermes-agent
ExecStart=/bin/bash -lc '${HERMES_RUN_CMD:-/usr/local/bin/hermes-agent run}'
Restart=always
RestartSec=5
User=root
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fail2ban
systemctl restart fail2ban

echo "Bootstrap complete."
echo "Next steps:"
echo "  1) Create /etc/default/hermes-agent with HERMES_INSTALL_CMD and HERMES_RUN_CMD."
echo "  2) Run: /usr/local/bin/install-hermes-agent"
echo "  3) Run: systemctl enable --now hermes-agent"
