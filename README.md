# Linux System Initialization Ansible Playbook

This playbook is designed to automate the initial configuration, optimization, and management of Linux systems (Ubuntu, Debian, Oracle Linux). It provides a comprehensive set of roles to quickly prepare systems for production use, improve security, and optimize performance.

## Compatibility

The playbook is compatible with:
- **Ubuntu** 20.04, 22.04, 24.04
- **Debian** 11, 12
- **Oracle Linux** 9, 10

Tested on both BIOS and UEFI boot configurations.

## Quickstart

### Prerequisites

- Ansible 2.9+ installed
- SSH access to target hosts
- Python 3 on target hosts

### Clone the Repository

```bash
git clone git@github.com:yokozu777/init-roles.git
cd init_roles
```

### Configure Variables

1. **Edit group variables** (applies to all hosts):
   ```bash
   vi group_vars/all.yml
   ```

2. **Configure host-specific variables**:
   ```bash
   cp host_vars/192.168.1.130.yml host_vars/<your_host_ip>.yml
   vi host_vars/<your_host_ip>.yml
   ```

### Required Variables for Connection

To ensure a successful connection, configure the following variables in `group_vars/all.yml`:

#### Users Configuration

```yaml
ansible_user: localuser  # SSH connection user
initial_user: localuser  # Initial user for the system
initial_password: "YourPassword123!"  # Initial user's password
```

#### Using SSH Keys for Authentication

1. **Set the SSH key path** - The `run.sh` script automatically sets both `SSH_KEY` and `ANSIBLE_PRIVATE_KEY_FILE`:
   ```bash
   export SSH_KEY="$HOME/mxhash_keys/id_rsa"
   # Or override ANSIBLE_PRIVATE_KEY_FILE directly:
   export ANSIBLE_PRIVATE_KEY_FILE="/path/to/your/key"
   ```
   
   **Note:** The playbook works **with or without** an Ansible config file. If no config is present, Ansible uses `ANSIBLE_PRIVATE_KEY_FILE` environment variable automatically.

2. **Configure key authentication** in `group_vars/all.yml`:
   ```yaml
   init_ssh_connect: key  # Use 'key' or 'password'
   initial_key_file: ""   # Empty = use SSH_KEY/ANSIBLE_PRIVATE_KEY_FILE from environment
   ```

3. **Add public keys to users**:
   - Create a `pub_keys/` folder in the project root
   - Place your `.pub` SSH keys in `pub_keys/`
   - Set `pub_keys_folder: pub_keys/` in `group_vars/all.yml`
   - Keys will be automatically added to the user specified in `system_user`

### Add Hosts to Inventory

Update `inventory.yml` with your host(s):

```yaml
all:
  children:
    your_group:
      hosts:
        192.168.1.100:
          vars_file: host_vars/192.168.1.100.yml
        192.168.1.101:
          vars_file: host_vars/192.168.1.101.yml
```

### Run the Playbook

**Using the provided script:**
```bash
./run.sh
```

**Or manually:**
```bash
ansible-playbook -i inventory.yml init-roles.yaml
```

**Run specific roles:**
```bash
ansible-playbook -i inventory.yml init-roles.yaml --tags "00_init,02_init_sshd,03_configure_users"
```

## Description

This repository contains an advanced Ansible playbook for automating the initial configuration, optimization, and management of Linux systems. It provides a structured approach to system initialization with 18 specialized roles covering everything from SSH configuration to kernel optimization.

## Key Features

### System Initialization
- **00_init**: Initial system connection and OS detection
- **01_backup_etc**: Create backups of `/etc` directory before configuration
- **17_update_reboot**: System updates and optional reboot after configuration

### SSH Configuration
- **02_init_sshd**: Configure SSH daemon settings
  - Change SSH port
  - Disable/enable root login
  - Configure password authentication
  - Manage SSH access policies

### User Management
- **03_configure_users**: User and authentication management
  - Create and configure system users
  - Change root password
  - Manage SSH public keys
  - Configure user passwords

### System Configuration
- **04_configure_hostname**: Set system hostname
- **05_configure_sysctl_limits**: Optimize system limits and sysctl parameters
  - File descriptor limits
  - Process limits
  - Network tuning
  - Memory management
- **06_configure_kernel**: Kernel parameter configuration
  - GRUB/EFI boot parameters
  - CPU P-State settings (AMD/Intel)
  - SMT (Simultaneous Multi-Threading) configuration
  - IPv6 disable option
  - IOMMU parameters
- **07_remove_unwanted_services**: Remove unnecessary services
  - Remove cloud-init
  - Remove snap (Ubuntu)
  - Disable systemd-resolved

### Security Configuration
- **08_configure_security**: Security hardening
  - Disable SELinux (Oracle Linux)
  - Disable AppArmor
  - Security policy configuration

### Locale and Timezone
- **09_configure_locales**: System locale configuration
  - Generate additional locales
  - Set default system locale
- **12_date_timezone**: Time and timezone management
  - Set system timezone (IANA format)
  - Configure NTP servers
  - Time synchronization

### Network Configuration
- **16_configure_network**: Network interface management
  - Configure static/dynamic IP addresses
  - Set DNS servers
  - Network interface configuration (Ubuntu/Debian/Oracle Linux)

### Certificate Management
- **11_certificates**: Certificate installation and management
  - Download CA certificates from URL
  - Install custom certificates from directory
  - Automatic certificate installation for Ubuntu/Debian/Oracle Linux
  - Update CA certificate stores

### Repository and Package Management
- **13_configure_repo**: Repository configuration
  - Clean existing repositories
  - Configure OS-specific repositories
  - Add custom repositories
- **14_install_software**: Package management
  - Install additional packages
  - Remove unwanted packages

### Service Management
- **10_manage_services**: Service enable/disable management
  - Configure service states
  - Manage system services

### Shell Configuration
- **15_configure_bash**: Bash shell customization
  - Custom prompt configuration
  - History size configuration
  - Shell environment setup

## Role Execution Order

The playbook executes roles in the following order to ensure proper dependencies:

1. **00_init** - System initialization and connection
2. **01_backup_etc** - Backup before changes
3. **02_init_sshd** - SSH configuration
4. **03_configure_users** - User management
5. **04_configure_hostname** - Hostname setup
6. **05_configure_sysctl_limits** - System limits
7. **06_configure_kernel** - Kernel parameters
8. **07_remove_unwanted_services** - Service cleanup
9. **08_configure_security** - Security hardening
10. **09_configure_locales** - Locale configuration
11. **10_manage_services** - Service management
12. **11_certificates** - Certificate installation
13. **12_date_timezone** - Time/timezone setup
14. **13_configure_repo** - Repository configuration
15. **14_install_software** - Package installation
16. **15_configure_bash** - Shell configuration
17. **16_configure_network** - Network setup
18. **17_update_reboot** - Updates and reboot (final step)

## Configuration Examples

### Basic Configuration

```yaml
# group_vars/all.yml
ansible_user: localuser
initial_user: localuser
init_ssh_connect: key
system_user: localuser
timezone: Europe/Moscow
ntp_servers:
  - 192.168.1.1
```

### Advanced Configuration

```yaml
# group_vars/all.yml
# SSH Configuration
disable_root_login: true
disable_password_auth: true
change_default_ssh_port: true
new_ssh_port: 2222

# Kernel Optimization
configure_kernel_params: true
pstate_performance: true
amd_pstate: "active"
disable_ipv6: true

# System Limits
configure_system_limits: true
copy_system_files: true

# Certificates
certificates_configure: true
ca_certificate_url: "https://ca.example.com/roots.pem"
ca_certificate_name: "company-ca.crt"
custom_certs_dir: "files/certs"

# Software
install_packages: "jq nano vim htop"
uninstall_packages: "snapd"

# Updates
update_now: false
system_update_scheduler: true
update_schedule_time: "03:00"
reboot_system: false
```

### Host-Specific Configuration

```yaml
# host_vars/192.168.1.100.yml
hostname: web-server.example.com
```

## Benefits

- **Time-Saving**: Automates routine tasks, significantly speeding up system preparation
- **Consistency**: Ensures uniform configuration across all systems
- **Security**: Implements security best practices and hardening
- **Flexibility**: Wide range of options allows customization for specific needs
- **Reliability**: Reduces human error through automation
- **Performance**: Optimizes system settings for better performance
- **Maintainability**: Centralized configuration management

## Advanced Usage

### Running Specific Roles

```bash
# Only SSH and user configuration
ansible-playbook -i inventory.yml init-roles.yaml --tags "02_init_sshd,03_configure_users"

# Only security hardening
ansible-playbook -i inventory.yml init-roles.yaml --tags "08_configure_security"

# Skip reboot
ansible-playbook -i inventory.yml init-roles.yaml --skip-tags "17_update_reboot"
```

### Using Ansible Vault for Sensitive Data

```bash
# Encrypt passwords
ansible-vault encrypt_string 'MySecurePassword' --name 'initial_password'

# Edit encrypted file
ansible-vault edit group_vars/all.yml
```

### Custom SSH Key

```bash
# Override SSH key path (works with or without config file)
export SSH_KEY="/path/to/your/key"
# Or use ANSIBLE_PRIVATE_KEY_FILE directly (works without config)
export ANSIBLE_PRIVATE_KEY_FILE="/path/to/your/key"
./run.sh

# Or pass via command line
ansible-playbook -i inventory.yml init-roles.yaml --private-key "/path/to/your/key"
```

## Troubleshooting

### Connection Issues

- Ensure SSH key is correctly configured:
  ```bash
  export SSH_KEY="$HOME/mxhash_keys/id_rsa"
  # Or use ANSIBLE_PRIVATE_KEY_FILE (works without config file)
  export ANSIBLE_PRIVATE_KEY_FILE="$HOME/mxhash_keys/id_rsa"
  ```
- Verify `ansible_user` matches the user with SSH access
- Check SSH key permissions: `chmod 600 ~/mxhash_keys/id_rsa`
- Verify public key is in `~/.ssh/authorized_keys` on target hosts
- **Note:** The playbook works without `ansible.cfg` - Ansible uses `ANSIBLE_PRIVATE_KEY_FILE` environment variable automatically

### Permission Issues

- Ensure `become: True` is set in playbook (default)
- Verify user has sudo privileges
- Check `ansible_user` has passwordless sudo or provide password

### Role-Specific Issues

- Check role defaults in `roles/<role_name>/defaults/main.yml`
- Override variables in `group_vars/all.yml` or `host_vars/<host>.yml`
- Review role tasks in `roles/<role_name>/tasks/main.yaml`

## Project Structure

```
init_roles/
├── init-roles.yaml          # Main playbook
├── inventory.yml            # Host inventory
├── group_vars/
│   └── all.yml             # Global variables
├── host_vars/              # Host-specific variables
│   └── <host_ip>.yml
├── roles/                  # Ansible roles
│   ├── 00_init/
│   ├── 01_backup_etc/
│   ├── 02_init_sshd/
│   └── ...
├── pub_keys/               # SSH public keys
├── run.sh                  # Execution script
└── ansible_local_execute.cfg  # Ansible configuration
```

## Contributing

When adding new roles or features:
1. Follow the naming convention: `##_role_name`
2. Add role defaults in `roles/<role>/defaults/main.yml`
3. Document variables in `group_vars/all.yml`
4. Update this README with new features

## Support

For issues and questions, please open an issue in the repository.
