# Ansible VPS Hardening Playbook

A comprehensive Ansible playbook for configuring and hardening VPS servers with security best practices.

## Features

- User Management
  - Create secure user with SSH key authentication
  - Configurable sudo access (with or without password)
  - Security reminders for users

- SSH Hardening
  - Disable root login and password authentication
  - Custom SSH port configuration
  - Secure SFTP configuration

- Firewall Configuration
  - UFW (Debian) or firewalld (RedHat) setup
  - Configurable allowed ports
  - OS-specific configurations

- Fail2ban Integration
  - Brute force protection
  - Custom ban times and retry limits
  - Advanced monitoring with geolocation
  - Log rotation and status tracking

## Prerequisites

- Ansible 2.9 or higher
- SSH access to target server
- Python 3.x on target server

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ansible-vps.git
   cd ansible-vps
   ```

2. Update inventory file:
   ```ini
   # inventory.ini
   [vps]
   your-server-ip ansible_user=your-user ansible_ssh_private_key_file=~/.ssh/your-key
   ```

3. Configure variables in `group_vars/vps.yml`:
   - Adjust SSH port if needed
   - Configure firewall ports
   - Set fail2ban parameters
   - Customize monitoring settings

4. Run the playbook:
   ```bash
   # Full deployment
   ansible-playbook -i inventory.ini playbook.yml -K

   # Security-only tasks
   ansible-playbook -i inventory.ini playbook.yml -K --tags security

   # Verify configuration
   ansible-playbook -i inventory.ini playbook.yml -K --tags verify
   ```

## Security Features

- SSH key-based authentication
- Fail2ban brute force protection
- Firewall configuration
- Regular security status monitoring
- Automated log rotation
- Geolocation tracking of attacks

## Monitoring

The playbook includes a comprehensive monitoring system:

- Real-time fail2ban status tracking
- Geolocation of banned IPs
- Daily log rotation
- Attack attempt summaries

Access monitoring:
```bash
# Quick status
sudo f2b

# View logs
cat /var/log/fail2ban-status.log
```

## OS Compatibility

- RedHat/CentOS/Fedora
- Debian/Ubuntu
- Automated OS-specific configurations

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - feel free to use and modify as needed.

## Security Notes

- Default configuration requires sudo password
- SSH password authentication is disabled by default
- Regular monitoring is recommended
- Keep system and packages updated
- Review logs periodically
