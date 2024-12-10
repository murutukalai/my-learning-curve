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
