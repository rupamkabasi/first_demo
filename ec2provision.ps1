$userData = @'
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
'@
Set-AWSCredential -AccessKey AKIAZN2TGWISBQXQXD33 -SecretKey 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 -StoreAs user1

New-EC2Instance -ImageId ami-0810abbfb78d37cdf -MinCount 1 -MaxCount 1 -KeyName myPSKeyPair -SecurityGroupId sg-0cf2aef034f1116d9 -InstanceType t2.micro -SubnetId subnet-7323b92b -Userdata $userData -EncodeUserData -ProfileName user1 -Region ap-southeast-2

$build_number= $env:BUILD_NUMBER
write-host $build_number