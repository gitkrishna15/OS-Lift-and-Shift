#script to perform preparation steps on guest, to move an instance to cloud
#also use this script to revert the changes made to guest system using the keyword rollback




usage(){
        echo "Usage: $0 <keyword>
        Use one of the keyword (prepare/rollback)
        prepare : performs all the steps to preapre the instance for move to cloud
        rollback : performs rollback of steps in prepare stage to revert to previous state"
        exit 1
}

main(){
case $1 in
        "prepare")

                        if [ -d $BACKUP_DIR ]
                        then
                        mv $BACKUP_DIR `echo $BACKUP_DIR`_$CURRDATE
                        
                        fi

                        mkdir $BACKUP_DIR

                        

                        #add user opc and set password for it

                        /usr/sbin/useradd -p `openssl passwd -1 $PASS` opc

                        #make change in sudoers

                        

                        if [ -f /etc/sudoers ]; then
                        cp -p /etc/sudoers $BACKUP_DIR/sudoers_$CURRDATE.txt
                        fi

                        cat >> /etc/sudoers <<!
                        #adding opc to the Sudoers list
                        %opc   ALL=(ALL)       NOPASSWD:
!


                        #configure network setting for the VM

                        

                        if [ -f /etc/selinux/config ] ; then

                        cp -p /etc/selinux/config $BACKUP_DIR/selinuxconfig_$CURRDATE.txt

                        sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
                        sed -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
                        fi




                        #Stop iptable service
                        

                        service iptables stop
                        chkconfig iptables off


                        #check hard-coded mac addresses

                        

                        if [ -f /etc/udev/rules.d/70-persistent-net.rules ] ; then

                        cp -p /etc/udev/rules.d/70-persistent-net.rules $BACKUP_DIR/70-persistent-net.rules_$CURRDATE.txt

                        fi
                        >| /etc/udev/rules.d/70-persistent-net.rules

                        if [ -f /lib/udev/rules.d/75-persistent-net-generator.rules ] ; then

                        cp -p /lib/udev/rules.d/75-persistent-net-generator.rules $BACKUP_DIR/75-persistent-net-generator.rules_$CURRDATE.txt

                        fi
                        >| /lib/udev/rules.d/75-persistent-net-generator.rules

                        if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then

                        cp -p  /etc/sysconfig/network-scripts/ifcfg-eth0 $BACKUP_DIR/ifcfg-eth0_$CURRDATE.txt

                        fi

                        for f in `ls  /etc/sysconfig/network-scripts/ifcfg* | grep -v ifcfg-lo`; do cp -p $f $BACKUP_DIR/$(basename $f)_backup_$CURRDATE; done;



                        if [ -f /etc/sysconfig/network ] ; then

                        cp -p /etc/sysconfig/network $BACKUP_DIR/sysconfig_network_$CURRDATE.txt

                        fi

                        cat > /etc/sysconfig/network <<!
                        NETWORKING=yes
                        HOSTNAME=$HOSTNAME
                        IPV6_AUTOCONF=no
                        NOZEROCONF=yes
!

                        

                        uname -r > version.txt
                        V=$(cat version.txt | cut -d'.' -f 6 | cut -c3)

                        if [[ "$V" -eq 7 ]] ; then

                            for f in `ls /boot/*img*`; do mv $f $BACKUP_DIR/$(basename $f)_backup_$CURRDATE;
                            dracut --add-drivers "xen-blkfront xen-netfront" $f; done;

                        fi

						cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<!
                        DEVICE=eth0
                        ONBOOT=yes
                        TYPE=Ethernet
                        BOOTPROTO=dhcp
                        PERSISTENT_DHCLIENT=1
!

						ifdown eth0
						ifup eth0
                ;;

        "rollback")

        
        for f in `ls  $BACKUP_DIR/ `; do

                filename=`echo $(basename $f)|cut -d'_' -f1`
        

                if [ $filename ==  'sudoers' ]; then
                cp -p $BACKUP_DIR/sudoers_*.txt /etc/sudoers
                fi

                if [ $filename == 'selinuxconfig' ]; then
                cp -p $BACKUP_DIR/selinuxconfig_*.txt /etc/selinux/config
                fi


                if [ $filename == '70-persistent-net.rules' ]; then
                cp -p $BACKUP_DIR/70-persistent-net.rules_*.txt /etc/udev/rules.d/70-persistent-net.rules
                elif [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
                rm /etc/udev/rules.d/70-persistent-net.rules
                fi

                if [ $filename == '75-persistent-net-generator.rules' ]; then
                cp -p $BACKUP_DIR/75-persistent-net-generator.rules_*.txt /lib/udev/rules.d/75-persistent-net-generator.rules
                elif [ -f /lib/udev/rules.d/75-persistent-net-generator.rules ]; then
                rm /lib/udev/rules.d/75-persistent-net-generator.rules
                fi

                if [ $filename == 'ifcfg-eth0' ]; then
                cp -p $BACKUP_DIR/ifcfg-eth0_*.txt  /etc/sysconfig/network-scripts/ifcfg-eth0
                elif [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then
                rm /etc/sysconfig/network-scripts/ifcfg-eth0
                fi

                if [ $filename == 'sysconfig' ]; then
                cp -p $BACKUP_DIR/sysconfig_network_*.txt  /etc/sysconfig/network
                elif [ -f /etc/sysconfig/network ]; then
                rm /etc/sysconfig/network
                fi

        done;

                
                service iptables start
                chkconfig iptables on

                uname -r > version.txt
                V=$(cat version.txt | cut -d'.' -f 6 | cut -c3)

                if [[ "$V" -eq 7 ]] ; then
					#moving edited image files to BACKUP_DIR from /boot
					for f in `ls /boot/*img*` ; do mv $f $BACKUP_DIR/$(basename $f)_edited_$CURRDATE; done;

					#restoring original image files back to /boot directory
					for f in `ls $BACKUP_DIR/*img*` ; do cp -p $f /boot/`echo $(basename $f)`; done;
				    for f in `ls /boot/*img*` ; do N = `ls $f | awk -F '.img' '{print $1}'`;
											            mv $f `echo $N`.img; done;
				fi
				
				for f in `ls $BACKUP_DIR/ifcfg* `;do cp -p $f /etc/sysconfig/network-scripts/`echo $(basename $f)|cut -d'_' -f1`; done;
				ifdown eth0
				ifup eth0
				
                ;;

        *)
                echo "Enter correct input parameter as per usage"
                usage
                ;;

esac
}
. ./OS_lift_shift_setenv.env
#Creating backup directory

if [ $# -eq 0 ] ; then
usage
fi
CURRDATE=`date +"%Y%m%d_%H%M"`
main $*
