/*
Created by KING Darnel Edwards of Group 3 Bliss batch JJtech 2021
By default this template will work in the us-west-2 region if the default VPC has not been modified don't forget to use YOUR keyname (THAT YOU CREATED). If you plan to use this template in another region please remember to modify the AMI, and set your provider.tf file accordingly. Feel free to modify and paramaterize (create variables) this template as you see fit to benefit other students of jjtech and for future use.

Description: This template creates 3 Ec2 Medium instances, With Sonar, Nexus and Jenkins installed as well as a Security group will all ports open. This covers the first part of the CICD tools install that was done in class on Friday. Please note that you still have to enter the steps in the GUI after navigating to the servers in your web browser.
*/

#################SONAR INSTANCE##############################3
resource "aws_instance" "Sonar_instance" {
  ami           = "ami-0dc8f589abe99f538"
instance_type = "t2.medium"
associate_public_ip_address = true
key_name = "Oregenec2"
vpc_security_group_ids = [aws_security_group.KINGDON_CICD_SG.name]
user_data = <<EOF
#!/bin/bash
sudo su
yum upgrade -y
yum update -y
yum install java-1.8.0 -y
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
yum install sonar -y
service sonar start
EOF
tags = {
  Name = "Sonar Qube"
}

}

output "Sonar_IP" {
  value       = aws_instance.Sonar_instance.public_ip
}

##################NEXUS INSTANCE #################################

resource "aws_instance" "Nexus_instance" {
  ami           = "ami-0dc8f589abe99f538"
instance_type = "t2.medium"
associate_public_ip_address = true
key_name = "Oregenec2"
vpc_security_group_ids = [aws_security_group.KINGDON_CICD_SG.name]
user_data = <<EOF
#!/bin/bash
sudo su
yum upgrade -y
yum install wget -y
yum install java-1.8.0-openjdk.x86_64 -y
mkdir /app && cd /app
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -xvf nexus.tar.gz
mv nexus-3* nexus
adduser nexus
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work
sed -i 's/""/"nexus"/gi' /app/nexus/bin/nexus.rc
cat >/etc/systemd/system/nexus.service <<EOL
[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
chkconfig nexus on
sudo systemctl start nexus
EOF
tags = {
  Name = "Nexus"
}
}
output "Nexus_IP" {
  value       = aws_instance.Nexus_instance.public_ip
}

##########################JENKINS INSTANCE##################################
resource "aws_instance" "Jenkins_instance" {
  ami = "ami-0dc8f589abe99f538"
  instance_type = "t2.medium"
  associate_public_ip_address = true
  key_name = "Oregenec2"
  vpc_security_group_ids = [aws_security_group.KINGDON_CICD_SG.name]
  user_data = <<EOF

#!/bin/bash
cd /home/ec2-user
sudo yum install java-1.8* -y
sudo yum install wget -y
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot
sudo systemctl enable jenkins
cd /home/ec2-user
ls -hart
EOF
tags = {
		Name = "Jenkins"

	}

}
output "Jenkins_IP" {
  value       = aws_instance.Jenkins_instance.public_ip
}



##############SECURITY GROUP ALLOWING ALL IN/OUT TRAFFIC###############
resource "aws_security_group" "KINGDON_CICD_SG" {
  name        = "KINGDON_CICD_SG"
  description = "Open All Ports"

  ingress {
    description      = "Alow_ALL"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow All Traffic"
  }
}
