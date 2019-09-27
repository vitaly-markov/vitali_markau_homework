<IfModule mpm_worker_module>
    ServerLimit          5
    StartServers         2
    MaxClients          25
    MinSpareThreads      5
    MaxSpareThreads     10
    ThreadsPerChild     10
</IfModule>


<IfModule mpm_prefork_module>
    ServerLimit           25
    StartServers           2
    MinSpareServers        3
    MaxSpareServers        5
    MaxClients            25
</IfModule>




<VirtualHost *>
ServerName forward.vitali.markau
ProxyRequests on
ProxyVia on
<Proxy *>
AuthType Basic
AuthName "Balancer Manager"
AuthUserFile "/etc/httpd/conf/.htpasswd"
Require valid-user
Order allow,deny
Allow from all

</Proxy>
</VirtualHost>
~






<VirtualHost *>
    ServerName reverse.vitali.markau
    ProxyPreserveHost On
    ProxyPass /test  http://vitali.markau/ping.html
    ProxyPassReverse /test  http://vitali.markau/ping.html
</VirtualHost>
~
