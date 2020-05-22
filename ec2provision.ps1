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
yum -y install java-11-openjdk-devel wget unzip
touch /etc/profile.d/java.sh
echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" >> /etc/profile.d/java.sh
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile.d/java.sh
echo "export JRE_HOME=/usr/lib/jvm/jre" >> /etc/profile.d/java.sh
echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh
mkdir -p /home/ec2-user/node
chmod -R 777 /home/ec2-user/node/
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y --enablerepo epel-playground  ansible 
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
cp -rp terraform /usr/local/bin/
cd /home/ec2-user/node/
wget http://13.211.177.44:8080/jnlpJars/agent.jar
java -jar agent.jar -jnlpUrl http://13.211.177.44:8080/computer/Rhel-agent/slave-agent.jnlp -secret 0530a4e38be94f2548db1c7c57c161128bab65100817796c660568068686204f -workDir "/home/ec2-user/node/"
'@
Set-AWSCredential -AccessKey AKIAZN2TGWISBQXQXD33 -SecretKey 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 -StoreAs user1
Initialize-AWSDefaults -ProfileName user1 -Region ap-southeast-2
$ec2instance = New-EC2Instance -ImageId ami-0810abbfb78d37cdf -MinCount 1 -MaxCount 1 -KeyName myPSKeyPair -SecurityGroupId sg-0cf2aef034f1116d9 -InstanceType t2.micro -SubnetId subnet-7323b92b -Userdata $userData -EncodeUserData -ProfileName user1 -Region ap-southeast-2
$Tag = New-Object Amazon.EC2.Model.Tag
$Tag.Key = "Name"
$Tag.Value = $env:BUILD_TAG
$InstanceId = $ec2instance.Instances | Select-Object -ExpandProperty InstanceId
write-host $InstanceId
New-EC2Tag -Resource $InstanceId -Tag $Tag
$build_number= $env:BUILD_NUMBER
write-host $build_number