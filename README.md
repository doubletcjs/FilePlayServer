# FilePlayServer
FilePlay Perfect接口服务器

mac os:

brew install mysql@5.7 && brew link mysql@5.7 --force

mysql.server start mysql_secure_installation
mysql -uroot -p (默认密码为空，直接回车)

alter user 'root'@'localhost' identified by '新密码'；(MySQL 5.7.6 and later)

set password for 'root'@'localhost'=password('新密码');(MySQL 5.7.5 and earlier)

ubuntu:

16.04系统需更新gcc(5.5.0以上)

sudo apt-get update

sudo apt-get install build-essential software-properties-common -y

sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y

sudo apt-get update

sudo apt-get install gcc-snapshot -y

sudo apt-get update

sudo apt-get install libcurl4-gnutls-dev openssl1.0 libssl1.1-dev openssl uuid-dev mysql-workbench mysql-server mysql-client libmysqlclient-dev clang libicu-dev libpython2.7

.bashrc 加入

export SWIFT_HOME=/opt/swift

export PATH=$SWIFT_HOME/usr/bin:$PATH

export LD_LIBRARY_PATH=$SWIFT_HOME/usr/lib:$LD_LIBRARY_PATH

export LIBRARY_PATH=$SWIFT_HOME/usr/lib:$LIBRARY_PATH

source .bashrc

# ssh上传文件到服务器
scp /path/filename username@servername:/path/
# 配置MySQL
https://www.cnblogs.com/sonofdark/p/10824574.html

彻底删除
https://blog.csdn.net/iehadoop/article/details/82961264
