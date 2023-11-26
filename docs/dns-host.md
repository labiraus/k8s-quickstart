# DNS Host

In order to test locally using a browser with a specified address you'll need to change your dns host files to point that address at localhost.

Based on: `https://www.liquidweb.com/kb/dns-hosts-file`

## Windows

Access the host file in notepad as administrator:

> C:\Windows\System32\drivers\etc\hosts

Add in the following:

``` text
# Added for k8s testing
127.0.0.1 local.k8s-demo.com
# End of section
```

Flush the dns

> ipconfig /flushdns

## Mac

Access the host file using command line

> sudo nano /private/etc/hosts

Add in the following:

```
# Added for k8s testing
127.0.0.1 local.k8s-demo.com
# End of section
```

> dscacheutil -flushcache; sudo killall -HUP mDNSResponder

If you're on version 10.10 - 10.10.3 then run the following:

> sudo discoveryutil mdnsflushcache; sudo discoveryutil udnsflushcaches

## Linux

### VIM

> sudo vim /etc/hosts

Add in the following:

```
# Added for k8s testing
127.0.0.1 local.k8s-demo.com
# End of section
```

### Command Line

> echo "127.0.0.1 local.k8s-demo.com" | sudo tee -a /etc/hosts >/dev/null

For Ubuntu/Debian:

> sudo service dns-clean restart.

For other distros:

> sudo service nscd restart 
> sudo systemctl restart nscd.service
> nscd -I hosts
