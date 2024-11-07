To set up a proxy for Chrome in Linux to access your IP, you can configure the proxy settings through system settings or directly within Chrome. Here are both methods:

### Method 1: Using System-Wide Proxy Settings

1. **Open System Proxy Settings**:
   - **On Ubuntu**: Go to **Settings > Network > Network Proxy**.
   - Set the **Manual** option to specify your proxy's IP address and port (for HTTP, HTTPS, FTP, and SOCKS).
   
2. **Apply the Proxy to Environment Variables**:
   - For a system-wide proxy in the terminal, you can set environment variables by adding the following lines to your `~/.bashrc` or `/etc/environment` file:
     ```bash
     export http_proxy="http://proxy_ip:proxy_port"
     export https_proxy="http://proxy_ip:proxy_port"
     export ftp_proxy="http://proxy_ip:proxy_port"
     export no_proxy="localhost,127.0.0.1"
     ```
   - Replace `proxy_ip` and `proxy_port` with your proxy server’s IP address and port.

3. **Restart** your network settings or log out and log in for changes to take effect.

### Method 2: Configuring Proxy in Chrome Directly

If you want to set the proxy only for Chrome:

1. **Launch Chrome with Proxy Settings**:
   - Open a terminal and run Chrome with proxy settings using this command:
     ```bash
     google-chrome --proxy-server="http://proxy_ip:proxy_port"
     ```
   - Replace `proxy_ip` and `proxy_port` with the proxy server’s IP and port.

2. **Persistent Chrome Proxy Setup (Optional)**:
   - To make this change permanent, you can modify Chrome’s desktop entry:
     - Open the desktop entry file with:
       ```bash
       sudo nano /usr/share/applications/google-chrome.desktop
       ```
     - Find the `Exec` line and add the proxy option:
       ```bash
       Exec=/usr/bin/google-chrome-stable --proxy-server="http://proxy_ip:proxy_port" %U
       ```
     - Save and close the file.

3. **Restart Chrome** to apply changes.
