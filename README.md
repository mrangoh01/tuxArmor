```text
 _____               _                                
|_   _|   ___  __   / \   _ __ _ __ ___   ___  _ __   
  | || | | \ \/ /  / _ \ | '__| '_ ` _ \ / _ \| '__|  
  | || |_| |>  <  / ___ \| |  | | | | | | (_) | |     
  |_| \__,_/_/\_\/_/   \_\_|  |_| |_| |_|\___/|_|
  
```
# TuxArmor 🛡️

**TuxArmor** is a lightweight, modular Linux Security Auditing and Hardening tool written natively in Bash. 
Designed for system administrators, security engineers, and red/blue teamers, TuxArmor conducts comprehensive automated security compliance audits across identity management, file permissions, network stack hardening, SSH configurations, logging subsystems, and kernel parameters.

---

## Key Features

* **Modular Architecture:** Extensible architecture featuring standalone security evaluation modules (`01_user_audit.sh` through `06_kernel_sysctl.sh`).
* **Interactive Terminal UI:** Real-time visual feedback using a subshell-driven Braille spinner and ANSI escape sequence updates.
* **Kernel & System Hardening Checks:** Validates critical sysctl parameters (ASLR, ICMP redirects, RP Filtering, `dmesg_restrict`).
* **OpenSSH Daemon Inspection:** Evaluates root login policies, authentication limits, key enforcement, and X11 forwarding.
* **File System & SUID Auditing:** Scans for non-whitelisted SUID binaries and verifies `/etc/fstab` isolation options (`nodev`, `nosuid`, `noexec`).
* **Structured JSON Reporting:** Generates structured machine-readable logs (`audit_report.json`) for SIEM integration or further programmatic parsing.

---

## Directory Structure

```text
tuxArmor/
├── tuxarmor.sh               # Primary execution pipeline & entrypoint
├── lib/
│   └── logger.sh             # UI handlers, color standards, async spinners & JSON exporter
├── modules/
│   ├── 01_user_audit.sh      # Identity, UID 0, & password policy auditing
│   ├── 02_file_permissions.sh# Critical file perms, SUID scanning, fstab audit
│   ├── 03_network_sec.sh     # Open ports, IP forwarding, SYN cookies, interface binding
│   ├── 04_services_ssh.sh    # OpenSSH daemon hardening evaluation
│   ├── 05_logging_audit.sh   # Auditd, syslog daemons, and sudo logging
│   └── 06_kernel_sysctl.sh   # Kernel parameter & sysctl security verification
└── logs/
    └── audit_report.json     # Generated compliance audit artifact
```

## Quick Start

### Prerequisites

- Linux distribution (Tested on Kali Linux, Debian, Ubuntu, RHEL)
    
- `bash` 4.0+
    
- Root privileges (`sudo`) for full kernel and system file visibility
    

### Installation & Execution

1. Clone the repository:
```bash
git clone [https://github.com/your-username/tuxArmor.git](https://github.com/your-username/tuxArmor.git)
cd tuxArmor
```

2.Make the script executable:
```bash
chmod +x tuxarmor.sh
```

3.Execute the audit pipeline with superuser privileges:
```bash
sudo ./tuxarmor.sh
```

