# bash-scripts

🐚 Bash Scripts

A curated collection of practical Bash scripts I've written for automation, system maintenance, network diagnostics, and general Linux productivity. These scripts are tools I use in real-world environments — either in my homelab, client systems, or cybersecurity research.

📁 Structure

Scripts are organized by purpose, with descriptive filenames and comments inside each script. Some examples:

    backup_home.sh – backs up a user's home directory to a remote NAS

    network_diag.sh – checks connectivity, DNS, and captures interface info

    sys_update.sh – automates package updates with logging

    usb_kill.sh – instantly disables all USB ports (great for locking down physical access)

    firewall_rules.sh – applies a secure UFW or iptables profile

🚀 Getting Started

Clone the repo:

    git clone https://github.com/yourusername/Bash-Scripts.git
    cd Bash-Scripts

Make a script executable:

    chmod +x your_script.sh

Run it:

    ./your_script.sh

    ⚠️ Note: These scripts assume a Linux environment and may require root privileges depending on the task.

🛠️ Dependencies

Some scripts may rely on common CLI tools like:

    curl, wget

    jq

    ufw or iptables

    rsync

    net-tools / iproute2

At some point in time I'll add a note to the top of each script for a reference on dependencies.


📜 License

Because... why not. 

This repo is licensed under the MIT License. You're free to use, modify, and share — just don't sell it as-is.
