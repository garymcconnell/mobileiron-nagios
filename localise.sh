#!/bin/bash
# update configs and scripts with localised environment

#Change all MobileIron logins and passwords
set -x

#MobileIron Access
mNEW_MICSUSER=CHANGE_MICSUSER
mNEW_MICSPASSWORD=CHANGE_MICSPASSWORD
mNEW_MIFSUSER=CHANGE_MIFSUSER
mNEW_MIFSPASSWORD=CHANGE_MIFSPASSWORD

mNEW_SENTRYMICS=CHANGEME_SENTRYMICS
mNEW_MICSPASSWORD=CHANGEME_SENTRYMICSPASSWORD

#SNMP Community
mNEW_SNMP=CORE_SNMP

#JSON plugin
mNEW_JSON=\/usr\/lib64\/nagios\/plugins\/check_mi_JSON


# Change MobileIron Login
sed -i "s/CHANGEME_MICSUSER/$mNEW_MICSUSER/g" *.cfg
sed -i "s/CHANGEME_MICSPASSWORD/$mNEW_MICSPASSWORD/g" *.cfg
sed -i "s/CHANGEME_MIFSUSER/$mNEW_MIFSUSER/g" *.cfg
sed -i "s/CHANGEME_MIFSPASSWORD/$mNEW_MIFSPASSWORD/g" *.cfg


sed -i "s/CHANGEME_MICS/$mNEW_SENTRYMICS/g" *.cfg
sed -i "s/CHANGEME_MICSPASSWORD/$mNEW_SENTRYMICSPASSWORD/g" *.cfg


# Change snmp
sed -i "s/CORE_SNMP/$mNEW_SNMP/g" *.cfg

# Change JSON plugin location
sed -i "s/\/usr\/lib64\/nagios\/plugins\/check_mi_JSON/$mNEW_JSON/g" *.cfg

#Change Perl Location
mNEW_PERL=$(which perl)
sed -i "s/\/usr\/bin\/perl -w/$mNEW_PERL/g" *.pl