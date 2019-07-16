Set file="%windir%\System32\drivers\etc\hosts"
echo 10.8.255.6 uswest-tst-sql1 >> %file%
echo 10.8.255.6 uswest-tst-sql1.azprod.vdveps.com >> %file%
echo 10.41.255.6 useast-tst-sql1 >>  %file%
echo 10.41.255.6 uswest-tst-sql1.azprod.vdveps.com >> %file%

http://woshub.com/workgroup-failover-cluster-windows-server-2016/

1. Install Failover Clustering role: Install-WindowsFeature Failover-Clustering –IncludeManagementTools

2. Create a local account with the administrator privileges (or use the integrated administrator account) with the same passwords:
net user /add clustadm Sup33P@ssw0Rd!
net localgroup administrators clustadm /addpowershell install Failover Clustering feature on workgroup servers

3.Uncheck Register DNS connection addresses in the Advanced TCP/IP Settings.dont register connection in dns
Make changes to hosts file so that the servers could resolve the names of other cluster members and the name of the cluster (including FQDN names). You can add the names to c:\windows\system32\drivers\etc\hosts as follows:
Set file="%windir%\System32\drivers\etc\hosts"
echo 192.168.1.21 clust-host1 >> %file%
echo 192.168.1.21 clust-host1.mylocal.net >> %file%
echo 192.168.1.22 clust-host2 >>  %file%
echo 192.168.1.22 clust-host2.mylocal.net >> %file%
echo 192.168.1.20 cluster1 >> %file%
echo 192.168.1.20 cluster1.mylocal.net>> %file%
hosts file with cluster nodes addresses

To validate cluster nodes, you can use the following command:

test-cluster -node "clust-host1.mylocal.net"," clust-host2.mylocal.net"
To create a cluster using PowerShell, run this command:

New-Cluster -Name cluster1 -Node clust-host1.mylocal.net, clust-host2.mylocal.net -AdministrativeAccessPoint DNS -StaticAddress 192.168.1.20

Now you can check the status of the cluster and its components with the help of get-cluster and get-clusterresource cmdlets.

To connect (and remotely manage) the cluster through a GUI, you need to use Failover Cluster Manager snap-in (included in RSAT for Windows 10).

Now, using Connect to cluster menu item, you can connect to the created cluster. If the cluster has even number of servers, you will have to configure a witness resource. Note that you cannot use the SMB shared folder as a quorum witness. Two modes are supported: Disk Witness — a shared disk (with the simultaneous access to it from both nodes), or Cloud Witness — a cloud disk resource in Azure.


PS C:\windows\system32> Enable-WSManCredSSP -Role server

CredSSP Authentication Configuration for WS-Management
CredSSP authentication allows the server to accept user credentials from a remote computer. If you enable CredSSP authentication on the
server, the server will have access to the user name and password of the client computer if the client computer sends them. For more
information, see the Enable-WSManCredSSP Help topic.
Do you want to enable CredSSP authentication?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y


cfg               : http://schemas.microsoft.com/wbem/wsman/1/config/service/auth
lang              : en-US
Basic             : false
Kerberos          : true
Negotiate         : true
Certificate       : false
CredSSP           : true
CbtHardeningLevel : Relaxed



PS C:\windows\system32> Get-WSManCredSSP
The machine is not configured to allow delegating fresh credentials.
This computer is configured to receive credentials from a remote client computer.


PS C:\windows\system32> Enable-WSManCredSSP -Role Client -DelegateComputer *

CredSSP Authentication Configuration for WS-Management
CredSSP authentication allows the user credentials on this computer to be sent to a remote computer. If you use CredSSP authentication for
 a connection to a malicious or compromised computer, that computer will have access to your user name and password. For more information,
 see the Enable-WSManCredSSP Help topic.
Do you want to enable CredSSP authentication?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): Y


cfg         : http://schemas.microsoft.com/wbem/wsman/1/config/client/auth
lang        : en-US
Basic       : true
Digest      : true
Kerberos    : true
Negotiate   : true
Certificate : true
CredSSP     : true

PS C:\windows\system32> enable-PSRemoting -Force

PS C:\windows\system32> test-cluster -node "uswest-tst-sql1.azprod.vdveps.com","useast-tst-sql1.azprod.vdveps.com"
WARNING: System Configuration - Validate Active Directory Configuration: The test reported some warnings..
WARNING: System Configuration - Validate Software Update Levels: The test reported some warnings..
WARNING:
Test Result:
HadUnselectedTests, ClusterConditionallyApproved
Testing has completed for the tests you selected. You should review the warnings in the Report.  A cluster solution is supported by
Microsoft only if you run all cluster validation tests, and all tests succeed (with or without warnings).
Test report file path: C:\Users\SqlAdmin\AppData\Local\Temp\Validation Report 2019.03.04 At 12.17.33.htm

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         3/4/2019  12:24 PM         705761 Validation Report 2019.03.04 At 12.17.33.htm


PS C:\windows\system32> New-Cluster -Name test-sql1 -Node uswest-tst-sql1.azprod.vdveps.com,useast-tst-sql1.azprod.vdveps.com -Administrati
veAccessPoint DNS -StaticAddress 10.8.255.9
WARNING: There were issues while creating the clustered role that may prevent it from starting. For more information view the report file
below.
WARNING: Report file location: C:\windows\cluster\Reports\Create Cluster Wizard test-sql1 on 2019.03.04 At 12.29.52.htm

Name
----
test-sql1



restart sql server once by disabling always on abd again by enabiolng alwayson
Run following commandUSE [master]
GO
CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO 


GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM]
GO
GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM]
GO
GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM]
GO 


USE [master]
GO
CREATE LOGIN [NT AUTHORITY\NETWORK SERVICE] FROM WINDOWS

GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\NETWORK SERVICE]
GO
GRANT CONNECT SQL TO [NT AUTHORITY\NETWORK SERVICE]
GO
GRANT VIEW SERVER STATE TO [NT AUTHORITY\NETWORK SERVICE]
GO 
GRANT CONNECT SQL TO [NT AUTHORITY\NETWORK SERVICE]
GO

click step by step alwayson configuration