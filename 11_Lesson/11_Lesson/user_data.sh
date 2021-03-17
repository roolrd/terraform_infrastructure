#!/bin/bash
yum update -y
yum install httpd -y

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h1><font color="gold">Web Server with Private IP: <font color="aqua">$myip</h1><br>
<h2><font color="green"> Build by Ruslan on Terraform <font color="red"> v0.12</font></h2><br>
<font color="magenta">
<b>Version 3.0</b>
</body>
</html>
EOF
sudo service httpd start
chkconfig httpd on
