sudo setenforce 0 && \
sudo sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo yum install -y epel-release
sudo yum install -y jq
sudo tee /etc/yum.repos.d/docker.repo << EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum install -y docker-engine
sudo yum -y update
sudo systemctl enable docker
sudo systemctl start docker