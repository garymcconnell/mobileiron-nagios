# mobileiron-nagios
##MobileIron Nagios application level scripts

Clever Consulting have developed a series of bash scripts which can be used to monitor the MobileIron platform.
These scripts are divided into two distinct types:
-SNMP Monitoring
-MobileIron Application Level Monitoring.
The SNMP Monitoring scripts use standard nagios snmp checks to query the underlying operating system snmp objects providing information on CPU, storage and network interface usage.

The MobileIron application level monitoring scripts interact with the MobileIron application querying for specific metrics and values. The metrics are retrieved by interacting with the MICS and MIFS web consoles provided by the MobileIron application.  In order to access the MICS and MIFS interfaces application level users must be created on the MobileIron platform and configured in the nagios check scripts.

##Metrics
The SNMP Monitoring checks currently monitor the following metrics:
###MobileIron Host Resources via the SNMP MIB:
*    CPU
*    DISK
*    Network use

###The MobileIron Application level checks currently monitor the following metrics:
*    MobileIron Core
*    Application Status
*    System Backup Status
*   SSL Certificate Expiry
*    MDM Certificate Expiry
*    DNS Gateway health
*    EMAIL relay health
*    MapQuest health
*    NTP Health
*    MobileIron Support Site reachability
*    Ldap Connector Status
*    Ldap Sync Status

###MobileIron Sentry
*    ActiveSync Backend Status
*    NTP Status
*    Core Status
*    DNS Status
*    number of open connections
*    cpu utilization
*    heap memory usage
*    number of connected devices
*    system memory usage 
*    thread pool utilization

###MobileIron Connector
*    NTP Status
*    Core Status
*    DNS Status
    
#Installation  
Installation is broken down into the following steps:
1. Enable SNMP on MobileIron Appliances
2. Create monitoring users on MobileIron applications to allow access from Nagios
3. Install the Nagios MobileIron scripts
4. Configure the Nagios scripts

##Enable SNMP on MobileIron Appliances
On each MobileIron appliance which is to be monitored the snmp service must be enabled.  
###Enabling SNMP
  Login to the MICS console on the appliance to be monitored (https://<appliance-address>/mics
  The SNMP Service is disabled by default. To turn it on:   
  Select Enable in the SNMP Control section
  Click on Apply
  
###Editing the Read only community string
  The default community string for the SNMP is set to public. To change this string:
  Edit the default string. 
  Click Apply.  
  
##Create Monitoring Users
  For each MobileIron appliance (Core, Sentry, LdapConnector) that needs to be monitored it is required to create an application level user both in the MICS and MIFS console. 
  
###MIFS (Core)
This procedure is applicable only to the CORE appliance, the mifs interface is not present on Sentry or Ldap Connector.
Login to the MIFS console with an administrative user.
Select "Users And Devices" -> "Users"
Click on "Add -> Add Local User"
Compile the form with all of the required fields (we suggest using a clear naming standard for the username so it is easily identifiable in the user list)  
Click on "Save" 
Select the "Admin" -> "Admins" menu in the console.
Select the userid created in the step above
Click on "Actions" -> "Assign to Space"
In the "Select Space" dropdown menu select "Global"
On the presented form select ONLY "Settings Management -> View Settings".  All other options should be disabled.

###MICS (System Console)

This procedure is applicable to all MobileIron appliances.
Login to the MICS console with an administrative user.
Choose "SECURITY"->"Local Users"
Click on "Add"
Compile the form with all of the required fields (we suggest using a clear naming standard for the username so it is easily identifiable in the user list)
Click on "Apply"
Click on "Save" (top right of screen" and then "OK".

#Install Nagios Scripts

The Nagios scripts can be divided into two distinct groups; snmp standard checks and MobileIron application level checks.

##SNMP commands install


On your Nagios installation download and install the the following Nagios check scripts to your nagios plugins directory, this is "/usr/lib64/nagios/plugins" on my centos box
``` bash
cd /usr/lib64/nagios/plugins
wget http://nagios.manubulon.com/check_snmp_int.pl
wget http://nagios.manubulon.com/check_snmp_load.pl
wget http://nagios.manubulon.com/check_snmp_mem.pl
wget http://nagios.manubulon.com/check_snmp_storage.pl
``` 
Change the permissions on the downloaded scripts so that they can be executed
``` bash
chmod 777 check_snmp_*.pl
``` 
Edit the check_snmp_mem.pl and check_snmp_storage.pl files to change the library location specific to your Nagios install.

For my installation on centos, change :
``` bash
use lib "/usr/local/nagios/libexec";
```
to
``` bash
use lib "/usr/lib64/nagios/plugins";
``` 
Check to make sure that the scripts can query the MobileIron appliance correctly by running the check script directly from the command line.
``` bash
 ./check_snmp_mem.pl -H testmdm.clever-consulting.com -C mipublic  -f -w 99,20 -c 100,85

Ram : 91%, Swap : 22% : > 99, 20 ; WARNING | ram_used=3635664;3938462;3978244;0;3978244 swap_used=911936;838858;3565148;0;4194292
``` 
 You should get a response like the above indicating the Ram and Swap used. The above query is using the parameters to provide a warning if RAM <99%, Swap <20% and critical if RAM is 100% and swap 30%. For details of the specific parameters please see the http://nagios.manubulon.com website.

Copy the file mi_commands_snmp.cfg  into the /etc/nagios/conf.d directory

##MobileIron Application level checks Install

copy the package file containing the mobileiron scripts to the Nagios server (MobileIronNagios.pkg.1.2.tar.gz for example).  Note that this package will also contain the snmp scripts as indicated in the previous section.

unzip the tarball to a temporary directory
``` bash
cd /tmp

tar -zxvf MobileIronNagiosPkg.tar.gz
``` 
Note: run all files through dos2unix to ensure crlf's are converted.

Change the scripts so they are localized to the server environment:

Perl location:
``` bash
mNEW_PERL=$(which perl)

sed -i "s/\/usr\/bin\/perl -w/$mNEW_PERL/g" *.pl

sed -i "s/\/usr\/bin\/perl -w/$mNEW_PERL/g" mi_commands.cfg
``` 
Plugin directory for JSON plugin:
``` bash
# Change JSON plugin location (if necessary)

mNEW_JSON=\/usr\/lib64\/nagios\/plugins\/check_mi_JSON

sed -i "s/\/usr\/lib64\/nagios\/plugins\/check_mi_JSON/$mNEW_JSON/g" *.cfg
``` 

Copy the scripts to the nagios plugins directory and set the correct permissions
``` bash
cd /tmp/MobileIronNagiosPkg

cp check_mi_* /usr/lib64/nagios/plugins

chmod 777 /usr/lib64/nagios/plugins/check_mi_*
``` 



Copy the mi_commands.cfg file to the /etc/nagios/conf.d directory
``` bash
cp mi_commands.cfg /etc/nagios/conf.d
``` 
Define the Nagios server objects for the each MobileIron Core, Sentry and LdapConnector object

For each CORE installation:

copy the file template_core.cfg to the /etc/nagios/conf.d changing the name for the file to reflect the core name following the customer naming standards if any.
``` bash
cp /tmp/MobileIronNagiosPkg/template_core.cfg /etc/nagios/conf.d/clever.core.cfg
``` 
Define the following variables:
``` bash
MI_NAGIOS_NAME	Nagios Hostname
MI_NAGIOS_ALIAS	Nagios Alias
MI_NAGIOS_ADDRESS	ip or dns address 
MI_NAGIOS_SNMP	snmp communitity as set in MICS
MI_NAGIOS_MIFS_USER 	MIFS Application level usernameConfigure Nagios Scripts
MI_NAGIOS_MIFS_PASS 	MIFS Application level password
MI_NAGIOS_MICS_USER 	MICS System level username
MI_NAGIOS_MICS_PASS 	MICS System level password
``` 

Use the following commands to substitute the values in the file, set the variables accordingly and run the sed commands:
``` bash
mFile=/etc/nagios/conf.d/clever.core.cfg

mNEW_MI_NAGIOS_NAME=
mNEW_MI_NAGIOS_ALIAS= 
mNEW_MI_NAGIOS_ADDRESS=
mNEW_MI_NAGIOS_SNMP=
mNEW_MI_NAGIOS_MIFS_USER=
mNEW_MI_NAGIOS_MIFS_PASS=
mNEW_MI_NAGIOS_MICS_USER=
mNEW_MI_NAGIOS_MICS_PASS=
``` 
Once the above variables have been set run the following commands
``` bash
sed -i "s/MI_NAGIOS_NAME/$mNEW_MI_NAGIOS_NAME/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ALIAS/$mNEW_MI_NAGIOS_ALIAS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ADDRESS/$mNEW_MI_NAGIOS_ADDRESS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_SNMP/$mNEW_MI_NAGIOS_SNMP/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MIFS_USER/$mNEW_MI_NAGIOS_MIFS_USER/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MIFS_PASS/$mNEW_MI_NAGIOS_MIFS_PASS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_USER/$mNEW_MI_NAGIOS_MICS_USER/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_PASS/$mNEW_MI_NAGIOS_MICS_PASS/g" $mFILE.cfg
``` 

Run the Nagios preflight checks and correct and errors if they are present.
``` bash
/usr/sbin/nagios -v /etc/nagios/nagios.cfg
```  
restart nagios to apply the new configurations
``` bash
service nagios restart
```  
If the configuration is correct you should now have the snmp monitoring services present in your Nagios console for the core instance.


For each Sentry installation:
copy the file template_sentry.cfg to the /etc/nagios/conf.d changing the name for the file to reflect the core name following the customer naming standards if any.
``` bash
cp /tmp/MobileIronNagiosPkg/template_core.cfg /etc/nagios/conf.d/clever.sentry.cfg
``` 
Define the following variables:
``` bash
MI_NAGIOS_NAME Nagios Hostname
MI_NAGIOS_ALIAS Nagios Alias
MI_NAGIOS_ADDRESS ip or dns address 
MI_NAGIOS_SNMP snmp communitity as set in MICS
MI_NAGIOS_MICS_USER MICS System level username
MI_NAGIOS_MICS_PASS MICS System level password
``` 

use the following commands to substitute the values in the file, set the variables accordingly and run the sed commands:
``` bash
mFile=/etc/nagios/conf.d/clever.sentry.cfg

mNEW_MI_NAGIOS_NAME=
mNEW_MI_NAGIOS_ALIAS= 
mNEW_MI_NAGIOS_ADDRESS=
mNEW_MI_NAGIOS_SNMP=
mNEW_MI_NAGIOS_MICS_USER=
mNEW_MI_NAGIOS_MICS_PASS=
``` 
Once the above variables have been set run the following commands
``` bash
sed -i "s/MI_NAGIOS_NAME/$mNEW_MI_NAGIOS_NAME/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ALIAS/$mNEW_MI_NAGIOS_ALIAS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ADDRESS/$mNEW_MI_NAGIOS_ADDRESS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_SNMP/$mNEW_MI_NAGIOS_SNMP/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_USER/$mNEW_MI_NAGIOS_MICS_USER/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_PASS/$mNEW_MI_NAGIOS_MICS_PASS/g" $mFILE.cfg
``` 

Run the Nagios preflight checks and correct and errors if they are present.
``` bash
/usr/sbin/nagios -v /etc/nagios/nagios.cfg
``` 

restart nagios to apply the new configurations
``` bash
service nagios restart
```  
If the configuration is correct you should now have the snmp monitoring services present in your Nagios console for the Sentry instance.

For each LDAP Connector installation:
copy the file template_sentry.cfg to the /etc/nagios/conf.d changing the name for the file to reflect the core name following the customer naming standards if any.
``` bash
cp /tmp/MobileIronNagiosPkg/template_core.cfg /etc/nagios/conf.d/clever.ldapconnector.cfg
``` 
Define the following variables:

MI_NAGIOS_NAME Nagios Hostname
MI_NAGIOS_ALIAS Nagios Alias
MI_NAGIOS_ADDRESS ip or dns address 
MI_NAGIOS_SNMP snmp communitity as set in MICS
MI_NAGIOS_MICS_USER MICS System level username
MI_NAGIOS_MICS_PASS MICS System level password


use the following commands to substitute the values in the file, set the variables accordingly and run the sed commands:
``` bash
mFile=/etc/nagios/conf.d/clever.ldapconnector.cfg

mNEW_MI_NAGIOS_NAME=
mNEW_MI_NAGIOS_ALIAS= 
mNEW_MI_NAGIOS_ADDRESS=
mNEW_MI_NAGIOS_SNMP=
mNEW_MI_NAGIOS_MICS_USER=
mNEW_MI_NAGIOS_MICS_PASS=
``` 
Once the above variables have been set run the following commands
``` bash
sed -i "s/MI_NAGIOS_NAME/$mNEW_MI_NAGIOS_NAME/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ALIAS/$mNEW_MI_NAGIOS_ALIAS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_ADDRESS/$mNEW_MI_NAGIOS_ADDRESS/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_SNMP/$mNEW_MI_NAGIOS_SNMP/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_USER/$mNEW_MI_NAGIOS_MICS_USER/g" $mFILE.cfg
sed -i "s/MI_NAGIOS_MICS_PASS/$mNEW_MI_NAGIOS_MICS_PASS/g" $mFILE.cfg
``` 

Run the Nagios preflight checks and correct and errors if they are present.
``` bash
/usr/sbin/nagios -v /etc/nagios/nagios.cfg
```  
restart nagios to apply the new configurations
``` bash
service nagios restart
```  
If the configuration is correct you should now have the snmp monitoring services present in your Nagios console for the LDAP Connector instance.


##Perfdata - Nagiosgraph
The following metrics are also providing perdata metrics.  The template configuration files are preconfigured to support nagiosgraph.  This should be removed from the configuration if it is not required.

Remove nagiosgraph
``` bash
sed -i "s/generic-service\,nagiosgraph/generic-service/g" /etc/nagios/conf.d/clever.core.cfg
sed -i "s/generic-service\,nagiosgraph/generic-service/g" /etc/nagios/conf.d/clever.sentry.cfg
sed -i "s/generic-service\,nagiosgraph/generic-service/g" /etc/nagios/conf.d/clever.ldapconnector.cfg
``` 


##Note:
the mics diagnostics arrays can change, run the following command to export the array on console:
``` bash
for i in {0..9}; do (echo $i & ./check_mi_mics_diagnostics <VSP>:8443 <USERNAME> <PASSWORD> $i); done
``` 
