mkdir -p /opt/mod_jk/
cd /opt/mod_jk
wget http://www.eu.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar -xvzf tomcat-connectors-1.2.46-src.tar.gz
cd tomcat-connectors-1.2.46-src/native
./configure --with-apxs=/usr/bin/apxs
make
libtool --finish /usr/lib64/httpd/modules
make install




#Tomcat installation


hostnamectl set-hostname markau-tomcat1



cd /tmp
wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.26/bin/apache-tomcat-9.0.26.tar.gz
tar -xf apache-tomcat-9.0.26.tar.gz
mv apache-tomcat-9.0.26 /opt/tomcat/
sudo vim /etc/systemd/system/tomcat.service



[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking


Environment="JAVA_HOME=/usr/lib/jvm/jre"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload

sudo systemctl enable tomcat
sudo systemctl start tomcat

sudo systemctl status tomcat

sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --reload


sudo vim /opt/tomcat/conf/tomcat-users.xml

<role rolename="admin-gui"/>
<role rolename="manager-gui"/>
<user username="admin" password="123456" roles="admin-gui,manager-gui"/>


sudo vim /opt/tomcat/webapps/manager/META-INF/context.xml

#vhost.conf

<VirtualHost *:80>
    ServerName markau-cluster.lab
    JkMount /* markau-cluster
</VirtualHost>
~

#"workers.properties
worker.list=markau-tomcat1,markau-tomcat2,markau-tomcat3,markau-cluster

worker.default.type=ajp13
worker.default.port=8009
worker.default.lbfactor=1
worker.markau-tomcat1.host=markau-tomcat1.lab
worker.markau-tomcat2.host=markau-tomcat2.lab
worker.markau-tomcat3.host=markau-tomcat3.lab

worker.markau-cluster.type=lb
worker.markau-cluster.balanced_workers=markau-tomcat1,markau-tomcat2,markau-tomcat3
worker.markau-cluster.sticky_session=1

~
#mod_jk.conf

LoadModule jk_module "/etc/httpd/modules/mod_jk.so"

JkWorkersFile /etc/httpd/conf/workers.properties
JkShmFile     /var/run/httpd/mod_jk.shm
JkLogFile     /var/log/httpd/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
JkRequestLogFormat "%w %V %T"
JkMount /clusterjsp  markau-cluster
JkMount /clusterjsp/*  markau-cluster
~
~
~#setenv.sh
LOG4J_JARS="log4j-core-2.12.1.jar log4j-api-2.12.1.jar log4j-jul-2.12.1.jar"
# make log4j2.xml available
if [ ! -z "$CLASSPATH" ] ; then CLASSPATH="$CLASSPATH": ; fi
CLASSPATH="$CLASSPATH""$CATALINA_BASE"/lib
# Add log4j2 jar files to CLASSPATH
for jar in $LOG4J_JARS ; do
  if [ -r "$CATALINA_HOME"/lib/"$jar" ] ; then
    CLASSPATH="$CLASSPATH":"$CATALINA_HOME"/lib/"$jar"
  else
    echo "Cannot find $CATALINA_HOME/lib/$jar"
    echo "This file is needed to properly configure log4j2 for this program"
    exit 1
  fi
done
# use the logging manager from log4j-jul
LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"
LOGGING_CONFIG="-Dlog4j.configurationFile=${CATALINA_BASE}/conf/log4j2.xml"

~
~
~
