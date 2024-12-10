To uninstall MinIO from Xubuntu, follow these steps:

---

### **1. Stop the MinIO Service (if running)**
If you’ve set up MinIO as a systemd service, stop and disable it:
```bash
sudo systemctl stop minio
sudo systemctl disable minio
```

Remove the systemd service file:
```bash
sudo rm /etc/systemd/system/minio.service
```

Reload the systemd daemon to apply changes:
```bash
sudo systemctl daemon-reload
```

---

### **2. Remove the MinIO Binary**
If MinIO was installed to `/usr/local/bin/`:
```bash
sudo rm /usr/local/bin/minio
```

---

### **3. Remove MinIO Data**
If you’ve created a data directory for MinIO, delete it:
```bash
sudo rm -rf /mnt/data/minio
```
(Replace `/mnt/data/minio` with the actual path to your MinIO data directory, if different.)

---

### **4. Remove Configuration Files**
If you’ve created any configuration files for MinIO (e.g., environment files), remove them. For example:
```bash
sudo rm -rf ~/.minio
```

---

### **5. Verify Uninstallation**
Check if the MinIO binary or service is still present:
```bash
which minio
sudo systemctl status minio
```
If no output is returned, MinIO has been successfully uninstalled.

Let me know if you encounter any issues!
_______________
Here are the steps to install MinIO on Xubuntu:

### 1. **Update Your System**
Ensure your system is up to date before proceeding.
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. **Download the MinIO Binary**
Download the latest stable release of the MinIO server binary.
```bash
wget https://dl.min.io/server/minio/release/linux-amd64/minio
```

### 3. **Make the Binary Executable**
Make the downloaded binary executable:
```bash
chmod +x minio
```

### 4. **Move MinIO to a System Path**
Move the binary to `/usr/local/bin/` for easier access:
```bash
sudo mv minio /usr/local/bin/
```

### 5. **Create MinIO Data Directory**
Create a directory to store MinIO data. For example:
```bash
sudo mkdir -p /mnt/data/minio
```

### 6. **Set Up MinIO**
Run MinIO in standalone mode. Replace `/mnt/data/minio` with your desired storage path:
```bash
minio server /mnt/data/minio
```

### 7. **Access MinIO Web Interface**
- MinIO runs on `http://127.0.0.1:9000` by default.
- Open the web browser and access the MinIO web UI.
- The default access and secret keys will be displayed in the terminal.

---

### Optional: Configure MinIO as a Systemd Service
To run MinIO as a service:

1. **Create a Service File**
   ```bash
   sudo nano /etc/systemd/system/minio.service
   ```
   Add the following content:
   ```ini
   [Unit]
   Description=MinIO
   Documentation=https://min.io/docs/
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=root
   Group=root
   ExecStart=/usr/local/bin/minio server /mnt/data/minio
   Restart=always
   RestartSec=5s
   LimitNOFILE=65536

   [Install]
   WantedBy=multi-user.target
   ```

2. **Reload and Start the Service**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable minio
   sudo systemctl start minio
   ```

3. **Check Service Status**
   ```bash
   sudo systemctl status minio
   ```

MinIO will now run as a service on your Xubuntu machine. Let me know if you need help setting up access keys or any additional configuration!
