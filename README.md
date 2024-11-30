# Ansible VPS Hardening Playbook

A comprehensive Ansible playbook for configuring and hardening VPS servers with security best practices.

## Features

- System Updates and Maintenance
  - Automated system updates
  - Smart reboot handling
  - Package cleanup
  - OS-specific update mechanisms

- User Management
  - Create secure user with SSH key authentication
  - Configurable sudo access (with or without password)
  - Security reminders for users

- SSH Hardening
  - Disable root login and password authentication
  - Enforce key-based authentication
  - Secure SSH configuration
  - X11 forwarding disabled
  - Maximum authentication attempts limited

- Firewall Configuration
  - UFW (Debian) or firewalld (RedHat) setup
  - Protocol-specific port configuration
  - Default deny policy
  - Stateful packet filtering

- Fail2ban Integration
  - Brute force protection
  - Custom ban times and retry limits
  - Advanced monitoring with geolocation
  - Log rotation and status tracking
  - Real-time jail status monitoring

## Prerequisites

- Ansible 2.9 or higher
- SSH access to target server
- Python 3.x on target server
- SSH key pair for authentication

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
   your-server-ip
   ```

3. Configure variables in `group_vars/vps.yml`:
   ```yaml
   # User settings
   user_settings:
     username: "your-username"
     sudo_group: "wheel"  # or "sudo" for Debian
     sudo_requires_password: true
     ssh_public_key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"

   # Security settings
   security_settings:
     ssh:
       port: 22
       permit_root_login: "no"
       password_authentication: "no"
     firewall:
       allowed_ports:
         - { port: 22, proto: "tcp" }  # SSH
         - { port: 80, proto: "tcp" }  # HTTP
         - { port: 443, proto: "tcp" } # HTTPS
   ```

4. Run the playbook:
   ```bash
   # Full deployment
   ansible-playbook -i inventory.ini playbook.yml -K

   # System updates only
   ansible-playbook -i inventory.ini playbook.yml -K --tags update

   # Security-only tasks
   ansible-playbook -i inventory.ini playbook.yml -K --tags security

   # Verify configuration
   ansible-playbook -i inventory.ini playbook.yml -K --tags verify
   ```

## Role Structure

The playbook is organized into specialized roles:

- `update`: System updates and maintenance
- `common`: Essential packages and configurations
- `user`: User management and SSH key setup
- `security`: SSH hardening and security configurations
- `firewall`: Firewall setup and port management
- `fail2ban`: Intrusion prevention and monitoring

## Monitoring Tools

The playbook includes a comprehensive monitoring system:

- Fail2ban Status Tool (`f2b`):
  ```bash
  # View current status
  sudo f2b

  # Features:
  - Real-time banned IP list
  - Geolocation of attackers
  - Jail status overview
  - Recent attack attempts
  ```

- Log Monitoring:
  ```bash
  # View fail2ban logs
  sudo cat /var/log/fail2ban.log

  # View monitoring status
  sudo cat /var/log/fail2ban-status.log
  ```

## Security Features

- System hardening:
  - Regular system updates
  - Package cleanup
  - Secure default configurations

- Access control:
  - SSH key-based authentication only
  - Sudo access control
  - Firewall port restrictions
  - Fail2ban protection

- Monitoring and logging:
  - Automated log rotation
  - Attack monitoring
  - Geolocation tracking
  - Status reporting

## OS Compatibility

Tested and supported operating systems:
- RedHat/CentOS/Fedora
- Debian/Ubuntu

The playbook automatically detects and applies OS-specific configurations.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - feel free to use and modify as needed.

## Security Notes

- Keep your SSH private key secure
- Regularly update system packages
- Monitor logs for suspicious activity
- Review fail2ban reports regularly
- Maintain secure firewall rules
- Consider enabling additional security features based on your needs
