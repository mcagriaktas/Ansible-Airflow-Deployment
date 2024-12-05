# Airflow Deployment with Ansible

This repository contains Ansible playbooks and configuration files for deploying and managing Apache Airflow in a distributed environment.

In this deployment, I used 3 empty Ubuntu containers to simulate a real deployment environment like we would use with VM instances. The `ansible-admin` container is used to install and manage our other containers. Our `server1` and `server2` containers are empty Ubuntu 24.04 containers. There's a `Dockerfile` in the root folder where you can check the configuration.

In the containers folder, you'll see 3 folders that are mounted as volumes in the containers, so you can easily manage your container scripts and other resources.

<img width="958" alt="image" src="https://github.com/user-attachments/assets/10861f4f-0a13-46a5-ba38-e3a0f5789710">

## IP Addresses
- ansible-admin => 172.80.0.10
- server1 - (airflow webserver) => 172.80.0.11
- server2 - (airflow scheduler) => 172.80.0.12

## Prerequisites

Before starting the deployment, ensure you have the following tools installed:
- Java
- Python
- Ansible

Our Dockerfile includes all these requirements. You can verify your installations with:
```bash
java --version
python --version
ansible --version
```

## Project Structure
```
.
├── Dockerfile
├── containers
│   ├── ansible-admin
│   │   └── playbooks
│   │       ├── airflow-init.yml
│   │       ├── airflow-install.yml
│   │       ├── airflow-scheduler-restart.yml
│   │       ├── airflow-start.yml
│   │       ├── airflow-stop.yml
│   │       ├── hosts.yml
│   │       └── roles
│   │           └── airflow
│   │               ├── tasks
│   │               │   └── main.yml
│   │               ├── templates
│   │               │   ├── airflow.env.j2
│   │               │   ├── scheduler.cfg.j2
│   │               │   ├── webserver.cfg.j2
│   │               │   └── webserver_config.py.j2
│   │               └── vars
│   │                   └── main.yml
│   ├── server1
│   └── server2
├── docker-compose.yml
└── readme.md
```

### Configuration Files
- **hosts.yml**: Ansible inventory file that defines target servers (IPs, usernames, roles) for deployment
- **tasks/**: Contains the actual commands and actions that roles will execute
- **templates/**: Holds configuration files with variables using .j2 extension (Jinja2 format)
- **vars/**: Stores role-specific variables with high priority

### Additional Useful Directories

These aren't used in our current setup but are valuable for larger deployments:

- **files/**: Contains static files to copy without variable processing
- **handlers/**: Manages service operations (restart/reload triggers)
- **group_vars/**: Stores variables applied to groups of servers
- **defaults/**: Contains default variables with lowest priority
- **meta/**: Defines role metadata and dependencies on other roles
  
## Setup Instructions

### 1. Configure SSH Access
**Note**: You need to run all your Ansible files in the `ansible-admin` container:
```bash
docker exec -it ansible-admin bash
cd /mnt/ansible/playbooks
```

Add the host fingerprints to your known hosts file:
```bash
ssh-keyscan -H 172.80.0.11 >> ~/.ssh/known_hosts
ssh-keyscan -H 172.80.0.12 >> ~/.ssh/known_hosts
```

### 2. Configure Ansible Environment

Set the Ansible inventory path:
```bash
export ANSIBLE_INVENTORY=/mnt/ansible/playbooks/hosts.yml
```

### 3. Verify Connectivity

Test SSH connectivity to all hosts:
```bash
ansible all -m ping
```

## Deployment Steps

### 1. Install Airflow
```bash
ansible-playbook -i hosts.yml airflow-install.yml
```

### 2. Initialize Airflow
```bash
ansible-playbook -i hosts.yml airflow-init.yml
```

### 3. Start Airflow Services
```bash
ansible-playbook -i hosts.yml airflow-start.yml
```

## Important Notes

- **First-time Start**: When starting Airflow for the first time, you need to restart the scheduler:
```bash
ansible-playbook -i hosts.yml airflow-scheduler-restart.yml
```

- **Container Restart**: If your container restarts, you must restart the scheduler using the same command.

## Management Commands

### Restart Scheduler
```bash
ansible-playbook -i hosts.yml airflow-scheduler-restart.yml
```

### Stop Airflow
```bash
ansible-playbook -i hosts.yml airflow-stop.yml
```
