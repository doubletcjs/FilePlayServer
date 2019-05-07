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

# ssh上传文件到服务器
scp /path/filename username@servername:/path/
# 配置MySQL
sudo mysql_secure_installation

#1
VALIDATE PASSWORD PLUGIN can be used to test passwords...
Press y|Y for Yes, any other key for No: N (我的选项)

#2
Please set the password for root here...
New password: (输入密码)
Re-enter new password: (重复输入)

#3
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them...
Remove anonymous users? (Press y|Y for Yes, any other key for No) : N (我的选项)

#4
Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network...
Disallow root login remotely? (Press y|Y for Yes, any other key for No) : Y (我的选项)

#5
By default, MySQL comes with a database named 'test' that
anyone can access...
Remove test database and access to it? (Press y|Y for Yes, any other key for No) : N (我的选项)

#6
Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.
Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y (我的选项) 
