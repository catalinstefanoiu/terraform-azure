# Azure Resource Deployment with Terraform

This project automates the deployment of various Azure resources using Terraform. It includes the creation of a resource group, public IP addresses, virtual networks, virtual machines, a container registry, and the necessary configurations for network interfaces and virtual machines.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- Azure CLI installed and authenticated.
- SSH keys generated for accessing the virtual machines.

## Project Structure

- `provider.tf`: Defines the required providers and their versions.
- `group.tf`: Creates an Azure Resource Group.
- `network_interface.tf`: Defines the network interface resource.
- `public_ip.tf`: Creates public IP addresses for the virtual machines.
- `random_password.tf`: Generates random passwords for the virtual machines.
- `virtual_network.tf`: Defines the virtual network resource.
- `virtual_machine.tf`: Creates Linux virtual machines.
- `ping_test.tf`: Tests connectivity between virtual machines.
- `acr.tf`: Creates an Azure Container Registry.
- `customdata.tpl`: Script to install Docker and run an Nginx container on the virtual machines.

## Configuration

### Variables

The following variables should be defined to customize the deployment:

- `var.vm_count`: Number of virtual machines to create.
- `var.vm_size`: Size of the virtual machines.
- `var.vm_image`: Image SKU of the virtual machines.
- `var.host_os`: Host operating system (used in commented-out provisioner script).

### SSH Keys

Ensure you have SSH keys generated and available at `~/.ssh/mtcazureke` and `~/.ssh/mtcazureke.pub`.

## Deployment

1. **Initialize Terraform:**
    ```sh
    terraform init
    ```

2. **Plan the deployment:**
    ```sh
    terraform plan -var 'vm_count=1' -var 'vm_size=Standard_B1s' -var 'vm_image=18.04-LTS'
    ```

3. **Apply the deployment:**
    ```sh
    terraform apply -var 'vm_count=1' -var 'vm_size=Standard_B1s' -var 'vm_image=18.04-LTS'
    ```

Using the created infrastructure, I made a script in Terraform using `null_resource` to ping from one virtual machine to another. For example: Virtual machine 1 pings the IP address of Virtual machine 2 when `vm_count=2`.

### Deployment Outputs

1. **Changes to Outputs:**
   ![2](https://github.com/user-attachments/assets/a2a5aea6-3f25-48e7-b9ee-89ea145acb2e)

2. **SSH Connection:**
   ![3](https://github.com/user-attachments/assets/ff51abba-e193-4b33-9948-6cae7e19b401)

3. **Ping Test:**
   ![4](https://github.com/user-attachments/assets/84cb7aeb-e98a-4ba5-aef4-996b229d8c10)


## Resources Created

- **Resource Group:** `mtc-resources`
- **Public IP Addresses:** Dynamic public IPs for VMs.
- **Virtual Network:** `mtc-network` with an address space of `10.123.0.0/16`.
- **Virtual Machines:** Linux VMs with generated passwords and SSH key access.
- **Azure Container Registry:** `devacr20240724`
- **Ping Test:** Validates network connectivity between VMs.

## Custom Data Script

The `customdata.tpl` script is used to:

1. Update the package list.
2. Install Docker.
3. Login to the Azure Container Registry.
4. Pull and run an Nginx container.

```bash
#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker adminuser
sudo docker login -u "devacr20240724" -p "5GceqB05Gxl/tJCcCPAvJL2KY9rZzsZe/YywGSHt3A+ACRBT485I" devacr20240724.azurecr.io
sudo docker pull devacr20240724.azurecr.io/nginx:latest
sudo docker run --name nginx-container -d -p 8080:80 nginx
