1.1
```
When the proxy settings are in the environment proxy variables, Chrome did not work by putting the full proxy settings on the launcher.

--proxy-server="IP proxy Server:port" (ex: --proxy-server="127.0.0.1:8080") 

But it worked when I put it to detect the automatic configurations

--proxy-auto-detect 

And it worked in Vivaldi.
```

1.2
```
Just execute below command in terminal

sudo nano /usr/share/applications/google-chrome.desktop
in Command value append below line

--proxy-server="192.168.1.251:8080" 
Change it with your proxy. its example of non - authentication proxy. For a proxy with authentication one should use,

--proxy-server="username:password@proxy_address:port"   
```

2
```
How do I set systemwide proxy servers in Xubuntu, Lubuntu or Ubuntu Studio? points to the file /etc/environment where you can insert the following lines as root:

http_proxy=http://myproxy.server.com:8080/
https_proxy=http://myproxy.server.com:8080/
ftp_proxy=http://myproxy.server.com:8080/
no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
The top answer (very elaborate) also contains a script to enable/disable on demand. (But if you need that, Firefox has an options page for choosing the proxy and you might want to consider using it).
```


3
```
The following is for general proxy, apt and wget and you can remove the user:password@ for a proxy that doesn't require it:

For General proxy:

touch /etc/profile.d/proxy.sh
add the following:

export ftp_proxy=ftp://user:password@host:port
export http_proxy=http://user:password@host:port
export https_proxy=https://user:password@host:port
export socks_proxy=https://user:password@host:port
For APT proxy:

touch /etc/apt/apt.conf.d/99HttpProxy
add the following:

Acquire::http::Proxy "http://user:password@host:port";
For wget:

nano /etc/wgetrc 
find and uncomment proxy lines or add them if not present

http_proxy = http://user:password@host:port
https_proxy = ...
```
