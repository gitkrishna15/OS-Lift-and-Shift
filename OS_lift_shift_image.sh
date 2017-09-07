#Script to create raw image and compress the image to create the tar.gz file of it
#Enter the details for the script to work as expected

echo "Enter the IP for the Source Server: "
read SOURCE_IP

echo "\n Enter the Disk/LUN full name (Eg: /dev/sda): "
read DISKNAME

echo "\n Enter name of the raw image along with path (Eg: /full/path/to/imagename.raw): "
read IMAGENAME

echo "\n Enter name of the tar image along with path (Eg: /full/path/to/imagename.tar.gz): "
read TARIMAGE


ssh root@$SOURCE_IP "dd if=$DISKNAME bs=8M " >$IMAGENAME
tar -czSvf $TARIMAGE $IMAGENAME

echo "\n The Image and Tar.gz file are $IMAGENAME and $TARIMAGE respectively"