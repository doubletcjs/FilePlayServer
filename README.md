# FilePlayServer
FilePlay Perfect接口服务器

mac os:
brew install mysql@5.7 && brew link mysql@5.7 --force

mysql.server start mysql_secure_installation
mysql -uroot -p (默认密码为空，直接回车)

alter user 'root'@'localhost' identified by '新密码'；(MySQL 5.7.6 and later)

set password for 'root'@'localhost'=password('新密码');(MySQL 5.7.5 and earlier)

ubuntu:
sudo apt-get install libcurl4-gnutls-dev openssl1.0 libssl1.1-dev openssl uuid-dev mysql-workbench mysql-server mysql-client libmysqlclient-dev clang libicu-dev
