# rclone + Syncthing on Docker Compose

Quickly setup a VM to sync files from cloud storage (Google Drive) to all devices including mobiles, tablets, PCs etc.

## Objective
1. **Mount** cloud storage to the VM using rclone.
2. **Sync** the mounted files to mobile devices using Syncthing.
3. **Result:** All data stays in sync across the cloud, the VM, and mobile hardware.

## Deployment Steps

### 1. VM & Network Setup
* Setup a VM with **Docker** and **Docker Compose** installed, and SSH to connect via keys.
* Open the following ports in your firewall:
    * **22**: For SSH access and GUI tunneling.
    * **22000**: For Syncthing file synchronization.

### 2. Prepare Configuration
* Clone this repository to your VM.
* **Rclone Cache:** Copy your local `rclone/cache` folder (containing your `rclone.conf`) to the VM project directory.
You can do it via `scp -i /path/to/private_key.pem -r /local/folder/ user@remote_host:/remote/path/`
* **Environment Variables:** Fill the `.env` file with your specific data variable values 
* Create a folder `$DATA_PATH/sync_service`. (This is the folder, inside which cloud sync will happen)
```bash
# Load variables into your current shell
export $(grep -v '^#' .env | xargs)
#create the folder
mkdir -p $DATA_PATH/sync_service
```
### 3. Build & Launch
Build the Docker Image
`docker build -t my-rclone-mount .`
Run the following command to start the services:
`docker-compose up -d`

Check the rclone mount folder on the VM to ensure the cloud sync has successfully initialized.

### 4. Connect and Configure Syncthing
For security, the Syncthing Web UI port is not opened to the public. Access it via **SSH Tunneling**:

1. Run this command from your local machine:
   `ssh -i /path/to/your/private_key -L 9000:localhost:8384 user@your-vm-ip`
2. Open your web browser and navigate to: **http://localhost:9000**
3. **Setup Password:** Go to **Actions > Settings > GUI** and set a strong username and password.
4. **Network Optimization:** In **Actions > Settings > Connections**, uncheck/disable:
    * Enable NAT traversal
    * Local Discovery
    * Global Discovery
    * Enable Relaying
5. **Static IP Usage:** To ensure devices connect without Discovery services, manually add the VM's address on your mobile/client app under the Device settings:
    * Set the addresses field to: `tcp://[ipAddress]:22000`

---

## Notes to Remember
* **GUI Security:** The Syncthing GUI is turned off for public access and should only be accessed via the SSH tunnel steps provided above.
* **De-provisioning:** To turn off the setup and stop the sync, run **docker-compose down**. 

---

## Operations Guide

### How to build rclone/cache
1. Install rclone on your local machine.
2. Run **rclone config** and follow the prompts to authenticate your cloud provider (e.g., Google Drive).
3. Once finished, locate your `rclone.conf` file (usually in `~/.config/rclone/`).
4. Create a folder named `cache` in your project directory.
5. Copy the `rclone.conf` into that `cache` folder before transferring the folder to the VM.

### How to connect to Syncthing GUI
1. Ensure the Docker container is running on the VM.
2. Open a terminal on your **local computer**.
3. Execute: `ssh -i /path/to/your/private_key -L 9000:localhost:8384 user@your-vm-ip`
4. Keep that terminal open.
5. Open a browser and type **http://localhost:9000**.
6. Set a GUI password immediately upon first login for added security.

## How to Deprovision
To stop the services and clean up using your `.env` variables:
```bash
# Load variables into your current shell
export $(grep -v '^#' .env | xargs)

# Stop and remove services
docker-compose down

# Force removal of specific containers
docker rm -f rclone-drive syncthing

# Unmount and clean up data directory
sudo umount -l $DATA_PATH/<<Foldername>>
rm -rf $DATA_PATH
mkdir -p $DATA_PATH


