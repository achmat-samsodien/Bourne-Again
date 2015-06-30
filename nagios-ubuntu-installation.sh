#!/bin/bash

if [ $(whoami) != root ]; then
echo
echo 'This script must be run as root (or with root privileges (sudo)!'
echo
exit
else
echo -e '\033[32m'
echo 'Nagios Core Installation Script'
echo 'Achmat Samsodien 2012'
echo
echo 'The following files must be in the same direcory before starting the installation:'
echo '1. nagios-installation.sh (installation script)'
echo '2. nagios-3.4.1.tar.gz (Nagios Core)'
echo '3. nagios-plugins-1.4.15.tar.gz (Nagios Core Plugins)'
echo '4. nagios-vautour-style.zip (Nagios Vautour Theme)'
echo
read -p 'Press Enter to start the installation.'
echo
echo 'Installing Nagios Core pre-requisites in 5...'
sleep 5
echo -e '\033[0m'

echo -e '\033[32m'
echo 'Nagios Core pre-requisites installed.'
echo
apt-get install gcc wget
apt-get install apache2 libapache2-mod-php5 build-essential openssl
echo 'Adding Nagios group and user to the system in 5...'
sleep 5
groupadd nagcmd
useradd -m -s nagios
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache
echo
echo 'Group nagcmd created. Users nagios and apache added to the group.'
echo
echo 'Enter the nagios user account password:'
echo -e '\033[0m'
passwd nagios

echo -e '\033[32m'
echo 'Downloading and Extracting Nagios Core and Nagios Core Plugins in 5...'
sleep 5
echo -e '\033[0m'
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.4.1.tar.gz
wget http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.15.tar.gz
tar xfvz nagios-3.4.1.tar.gz
mv nagios-plugins-1.4.15.tar.gz nagios
rm -f nagios-3.4.1.tar.gz
cd nagios
tar xfvz nagios-plugins-1.4.15.tar.gz
rm -f nagios-plugins-1.4.15.tar.gz
echo -e '\033[32m'
echo 'Nagios Core installation and Nagios Core Plugins extracted.'
echo

echo 'Configuring, compiling and installing Nagios Core in 5...'
sleep 5
echo -e '\033[0m'
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
echo -e '\033[32m'
echo 'Nagios Core installed.'
echo

echo 'Configuring, compiling and installing Nagios Plugins in 5...'
sleep 5
echo -e '\033[0m'
cd nagios-plugins-1.4.15
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
echo -e '\033[32m'
echo 'Nagios Core Plugins installed.'
echo

echo 'Installing Vautour theme in 5...'
sleep 5
wget 
cd /home/
mkdir theme
unzip nagios-vautour-style.zip -d theme/
cd theme/
unalias cp
cp -Rf * /usr/local/nagios/share/
chown -R nagios.nagios /usr/local/nagios/share/*
cd ..
rm -rf nagios-vautour-style.zip theme/
echo 'Vautour theme installed.'
echo

echo 'Removing Nagios Core installation files in 5...'
echo
sleep 5
rm -rf nagios/
echo 'Nagios Core installation files removed.'
echo

echo 'Creating Nagios symbolic links in 5...'
echo
sleep 5
ln -s /usr/local/nagios /nagios
echo 'Nagios symbolic links created.'
echo

echo 'Creating Nagios web interface user in 5...'
echo
sleep 5
echo 'Enter the Nagios web interface administrator account (nagiosadmin) password:'
echo -e '\033[0m'
htpasswd -c /nagios/etc/htpasswd.users nagiosadmin

echo -e '\033[32m'
echo 'Enabling automatic start of Apache in 5...'
sleep 5
chkconfig httpd --level 3 on
echo
echo 'Automatic launch of Apache init script enabled.'
echo

echo 'Starting Apache in 5...'
sleep 5
echo -e '\033[0m'
/etc/init.d/apache2 restart
echo -e '\033[32m'
echo 'Apache started.'
echo

echo 'Enabling automatic start of Nagios in 5...'
sleep 5
chkconfig --add nagios
chkconfig nagios --level 3 on
echo
echo 'Automatic launch of Nagios init script enabled.'
echo

echo 'Changing CGI refresh rate settings from default 90 seconds to 30 seconds in 5...'
sleep 5
sed -i 's/refresh_rate=90/refresh_rate=30/g' /nagios/etc/cgi.cfg
echo
echo 'CGI refresh rate settings changed to 30 seconds.'
echo

echo 'Adding customized host and service templates to the Nagios Core configuration in 5...'
sleep 5
echo >> /nagios/etc/objects/templates.cfg
echo 'define host{' >> /nagios/etc/objects/templates.cfg
echo 'name								linux-host' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'notifications_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'event_handler_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'flap_detection_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'failure_prediction_enabled		1' >> /nagios/etc/objects/templates.cfg
echo 'process_perf_data					1' >> /nagios/etc/objects/templates.cfg
echo 'retain_status_information			1' >> /nagios/etc/objects/templates.cfg
echo 'retain_nonstatus_information		1' >> /nagios/etc/objects/templates.cfg
echo 'check_command						check-host-alive' >> /nagios/etc/objects/templates.cfg
echo 'notification_options				d,r' >> /nagios/etc/objects/templates.cfg
echo 'notification_interval				15' >> /nagios/etc/objects/templates.cfg
echo 'check_period						24x7' >> /nagios/etc/objects/templates.cfg
echo 'notification_period				24x7' >> /nagios/etc/objects/templates.cfg
echo 'check_interval					1' >> /nagios/etc/objects/templates.cfg
echo 'retry_interval					1' >> /nagios/etc/objects/templates.cfg
echo 'max_check_attempts				1' >> /nagios/etc/objects/templates.cfg
echo 'register							1' >> /nagios/etc/objects/templates.cfg
echo '}' >> /nagios/etc/objects/templates.cfg
echo >> /nagios/etc/objects/templates.cfg

echo 'define host{' >> /nagios/etc/objects/templates.cfg
echo 'name								windows-host' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'notifications_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'event_handler_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'flap_detection_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'failure_prediction_enabled		1' >> /nagios/etc/objects/templates.cfg
echo 'process_perf_data					1' >> /nagios/etc/objects/templates.cfg
echo 'retain_status_information			1' >> /nagios/etc/objects/templates.cfg
echo 'retain_nonstatus_information		1' >> /nagios/etc/objects/templates.cfg
echo 'check_command						check-host-alive' >> /nagios/etc/objects/templates.cfg
echo 'notification_options				d,r' >> /nagios/etc/objects/templates.cfg
echo 'notification_interval				15' >> /nagios/etc/objects/templates.cfg
echo 'check_period						24x7' >> /nagios/etc/objects/templates.cfg
echo 'notification_period				24x7' >> /nagios/etc/objects/templates.cfg
echo 'check_interval					1' >> /nagios/etc/objects/templates.cfg
echo 'retry_interval					1' >> /nagios/etc/objects/templates.cfg
echo 'max_check_attempts				1' >> /nagios/etc/objects/templates.cfg
echo 'register							1' >> /nagios/etc/objects/templates.cfg
echo '}' >> /nagios/etc/objects/templates.cfg
echo >> /nagios/etc/objects/templates.cfg

echo 'define service{' >> /nagios/etc/objects/templates.cfg
echo 'name								linux-service' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'active_checks_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'passive_checks_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'parallelize_check					1' >> /nagios/etc/objects/templates.cfg
echo 'obsess_over_service				1' >> /nagios/etc/objects/templates.cfg
echo 'notifications_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'event_handler_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'flap_detection_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'failure_prediction_enabled		1' >> /nagios/etc/objects/templates.cfg
echo 'process_perf_data					1' >> /nagios/etc/objects/templates.cfg
echo 'retain_status_information			1' >> /nagios/etc/objects/templates.cfg
echo 'check_period						24x7' >> /nagios/etc/objects/templates.cfg
echo 'max_check_attempts				1' >> /nagios/etc/objects/templates.cfg
echo 'normal_check_interval				1' >> /nagios/etc/objects/templates.cfg
echo 'retry_check_interval				1' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'notification_options				c,r' >> /nagios/etc/objects/templates.cfg
echo 'notification_interval				15' >> /nagios/etc/objects/templates.cfg
echo 'notification_period				24x7' >> /nagios/etc/objects/templates.cfg
echo 'register							1' >> /nagios/etc/objects/templates.cfg
echo '}' >> /nagios/etc/objects/templates.cfg

echo >> /nagios/etc/objects/templates.cfg
echo 'define service{' >> /nagios/etc/objects/templates.cfg
echo 'name								windows-service' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'active_checks_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'passive_checks_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'parallelize_check					1' >> /nagios/etc/objects/templates.cfg
echo 'obsess_over_service				1' >> /nagios/etc/objects/templates.cfg
echo 'notifications_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'event_handler_enabled				1' >> /nagios/etc/objects/templates.cfg
echo 'flap_detection_enabled			1' >> /nagios/etc/objects/templates.cfg
echo 'failure_prediction_enabled		1' >> /nagios/etc/objects/templates.cfg
echo 'process_perf_data					1' >> /nagios/etc/objects/templates.cfg
echo 'retain_status_information			1' >> /nagios/etc/objects/templates.cfg
echo 'check_period						24x7' >> /nagios/etc/objects/templates.cfg
echo 'max_check_attempts				1' >> /nagios/etc/objects/templates.cfg
echo 'normal_check_interval				1' >> /nagios/etc/objects/templates.cfg
echo 'retry_check_interval				1' >> /nagios/etc/objects/templates.cfg
echo 'contact_groups					admins' >> /nagios/etc/objects/templates.cfg
echo 'notification_options				c,r' >> /nagios/etc/objects/templates.cfg
echo 'notification_interval				15' >> /nagios/etc/objects/templates.cfg
echo 'notification_period				24x7' >> /nagios/etc/objects/templates.cfg
echo 'register							1' >> /nagios/etc/objects/templates.cfg
echo '}' >> /nagios/etc/objects/templates.cfg
echo
echo 'Customized host and service templates added to the Nagios Core configuration.'
echo

echo 'Adding customized commands to the Nagios Core configuration in 5...'
sleep 5
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_current_users' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_users -w $ARG1$ -c $ARG2$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_current_load' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_load -w $ARG1$ -c $ARG2$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_process_cpu_usage' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_procs -w $ARG1$ -c $ARG2$ --metric=CPU"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_check_disk' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_check_swap' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_swap -w $ARG1$ -c $ARG2$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_alert_process_low' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_procs -C $ARG1$ -c $ARG2$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_alert_process_high' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_procs -C $ARG1$ -w $ARG2$ -c $ARG3$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name ssh_alert_process_static' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_by_ssh -H $HOSTADDRESS$ -t 20 -l nagmon -C "/home/nagmon/libexec/check_procs -C $ARG1$ -c $ARG2$"' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg
echo

echo >> /nagios/etc/objects/commands.cfg
echo 'define command{' >> /nagios/etc/objects/commands.cfg
echo 'command_name check_url' >> /nagios/etc/objects/commands.cfg
echo 'command_line $USER1$/check_http -H $HOSTADDRESS$ -t 20 -p $ARG1$ -u $ARG2$ -s $ARG3$ -w $ARG4$ -c $ARG5$' >> /nagios/etc/objects/commands.cfg
echo '}' >> /nagios/etc/objects/commands.cfg
echo
echo 'Customized commands added to the Nagios Core configuration.'

echo
echo 'Creating Linux server template /nagios/etc/objects/linuxtemplate.cfg in 5...'
sleep 5
touch /nagios/etc/objects/linuxtemplate.cfg
chown nagios.nagios /nagios/etc/objects/linuxtemplate.cfg
chmod 664 /nagios/etc/objects/linuxtemplate.cfg
echo 'define host{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                   		linux-host' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name						HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'alias          		        LONG HOST NAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'address		                IPADDRESS' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define hostgroup{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'hostgroup_name				GROUPNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'alias							LONG GROUP NAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'members						HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description   		Process Low Threshold' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_alert_process_low!PROCESSNAME!1:258' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo '#define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#service_description           Process High Threshold' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#check_command                 ssh_alert_process_high!PROCESSNAME!79!99' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo '#define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#service_description           Process Static' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#check_command                 ssh_alert_process_static!PROCESSNAME!1:1' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description           Process CPU Usage' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_process_cpu_usage!80!90' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description           Users Logged In' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_current_users!4!7' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description           Load Average' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_current_load!5.0,5.0,5.0!10.0,10.0,10.0' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description           Free Disk Space /' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_check_disk!10%!5%!/' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo 'define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'service_description           Free Swap Space' >> /nagios/etc/objects/linuxtemplate.cfg
echo 'check_command                 ssh_check_swap!20%!10%' >> /nagios/etc/objects/linuxtemplate.cfg
echo '}' >> /nagios/etc/objects/linuxtemplate.cfg
echo

echo >> /nagios/etc/objects/linuxtemplate.cfg
echo '#define service{' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#use                           linux-service' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#host_name                     HOSTNAME' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#service_description           URL Check' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#check_command                 check_url!80!"/URL"!"STRING ON PAGE"!10!15' >> /nagios/etc/objects/linuxtemplate.cfg
echo '#}' >> /nagios/etc/objects/linuxtemplate.cfg
echo
echo 'Linux server template /nagios/etc/objects/linuxtemplate.cfg created.'
echo

echo 'Creating Windows server template /nagios/etc/objects/windowstemplate.cfg in 5...'
sleep 5
touch /nagios/etc/objects/windowstemplate.cfg
chown nagios.nagios /nagios/etc/objects/windowstemplate.cfg
chmod 664 /nagios/etc/objects/windowstemplate.cfg

echo 'define host{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'use                   		windows-host' >> /nagios/etc/objects/windowstemplate.cfg
echo 'host_name						HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'alias          		        LONG HOST NAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'address		                IPADDRESS' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo 'define hostgroup{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'hostgroup_name				GROUPNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'alias							LONG GROUP NAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'members						HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo 'define service{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'use							windows-service' >> /nagios/etc/objects/windowstemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'service_description           CPU Usage' >> /nagios/etc/objects/windowstemplate.cfg
echo 'check_command                 check_nt!CPULOAD!-l 1,80,90' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo 'define service{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'use							windows-service' >> /nagios/etc/objects/windowstemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'service_description           Memory Usage' >> /nagios/etc/objects/windowstemplate.cfg
echo 'check_command                 check_nt!MEMUSE!-w 80 -c 90' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo 'define service{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'use							windows-service' >> /nagios/etc/objects/windowstemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'service_description           Used Disk Space - C:' >> /nagios/etc/objects/windowstemplate.cfg
echo 'check_command                 check_nt!USEDDISKSPACE!-l c -w 80 -c 90' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo 'define service{' >> /nagios/etc/objects/windowstemplate.cfg
echo 'use							windows-service' >> /nagios/etc/objects/windowstemplate.cfg
echo 'host_name                     HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo 'service_description           Explorer Process' >> /nagios/etc/objects/windowstemplate.cfg
echo 'check_command                 check_nt!PROCSTATE!-d SHOWALL -l Explorer.exe' >> /nagios/etc/objects/windowstemplate.cfg
echo '}' >> /nagios/etc/objects/windowstemplate.cfg

echo >> /nagios/etc/objects/windowstemplate.cfg
echo '#define service{' >> /nagios/etc/objects/windowstemplate.cfg
echo '#use                           windows-service' >> /nagios/etc/objects/windowstemplate.cfg
echo '#host_name                     HOSTNAME' >> /nagios/etc/objects/windowstemplate.cfg
echo '#service_description           URL Check' >> /nagios/etc/objects/windowstemplate.cfg
echo '#check_command                 check_url!80!"/URL"!"STRING ON PAGE"!10!15' >> /nagios/etc/objects/windowstemplate.cfg
echo '#}' >> /nagios/etc/objects/windowstemplate.cfg
echo
echo 'Windows server template /nagios/etc/objects/windowstemplate.cfg created.'

echo
echo 'Testing Nagios configuration in 5...'
sleep 5
echo -e '\033[0m'
/nagios/bin/nagios -v /nagios/etc/nagios.cfg
echo -e '\033[32m'
echo 'Nagios configuration test completed.'
echo

echo 'Starting Nagios in 5...'
sleep 5
echo -e '\033[0m'
service nagios start
echo -e '\033[32m'
echo 'Nagios started.'
echo
echo 'Configuring SELinux settings for Nagios in 5...'
sleep 5
chcon -R -t httpd_sys_content_t /nagios/sbin/
chcon -R -t httpd_sys_content_t /nagios/share/
echo
echo 'SELinux settings configured for Nagios.'
echo

echo 'Installation Complete!'
echo
echo 'Access the Nagios Web Interface:'
echo 'http://[ipaddress of Nagios server]/nagios'
echo 'Log in as nagiosadmin /// [password selected]'
echo 'NOTE: Ensure that the IP Tables firewall is set to allow tcp packets over port 80.'
echo
echo 'vi /usr/local/nagios/etc/objects/contacts.cfg <--- Edit notification e-mail address'
echo
echo 'For successful setup of remote Linux server monitoring, follow the steps below:'
echo 'Use the /nagios/etc/objects/linuxtemplate.cfg file as a template for the remote Linux hosts.'
echo 'Add the new servers in the /nagios/etc/nagios.cfg file.'
echo 'Create user account nagmon on the remote Linux hosts.'
echo 'Copy the /nagios/libexec directory to the home directory of the remote server''s nagmon account.'
echo 'Create directory .ssh on the remote Linux servers with permissions 700.'
echo 'Generate public SSH RSA key on Nagios server (ssh-keygen -t rsa) and store as .ssh/authorized_keys on remote server.'
echo
echo 'For successful setup of remote Linux server monitoring, follow the steps below:'
echo 'Configure a password for the check_nt command in /nagios/etc/objects/commands.cfg (-s password)'
echo 'Install the NSClient++ software on the remote Windows server and modify the NSC.ini file to allow access from the Nagios server.'
echo 'Start the NSClient++ Windows service.'
echo 'Make a copy of the existing Windows server template and modify/enable the new server.'
echo -e '\033[0m'
fi
exit
