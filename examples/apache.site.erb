<% if has_variable?("listen_web") and listen_web.length > 0  -%>
  <%= listen_web %>
<% end -%>
<VirtualHost *:<%= server_web_port %>>
  ServerName <%= server_name %>
<% if has_variable?("server_alias") and server_alias.length > 0  -%>
  ServerAlias <%= server_alias %>
<% end -%>
  DocumentRoot <%= document_root %>
  PassengerMinInstances 1
  # PassengerPreStart http://<%= server_name %>/
  SetEnv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  <Directory <%= document_root %>>
    AllowOverride AuthConfig
    Options -MultiViews
  </Directory>

  <Location "/images/page/logo_paypal.png">
    Allow from all
    Satisfy Any
  </Location>

  # redirect all traffic to maintenance-page if it exists
  ErrorDocument 503 /system/maintenance.html
  RewriteEngine On
  RewriteCond %{REQUEST_URI} !(gif|jpg|png)$
  RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -l
  RewriteCond %{SCRIPT_FILENAME} !maintenance.html
  RewriteRule ^.*$  -  [redirect=503,last]

  #RewriteEngine On
  #RewriteLog <%= document_root %>../log/rewrite.log
  #RewriteLogLevel 0

  ## Canonical host
  #RewriteCond %{HTTP_HOST}   !^<%= server_name %> [NC]
  #RewriteCond %{HTTP_HOST}   !^$
  #RewriteRule ^/(.*)$        http://<%= server_name %> /$1 [L,R=301]
</VirtualHost>

<% if has_variable?("listen_ssl") and listen_ssl.length > 0  -%>
  <%= listen_ssl %>
<% end -%>
<VirtualHost *:<%= server_ssl_port %>>
  ServerName <%= server_name %>
<% if has_variable?("server_alias") and server_alias.length > 0  -%>
  ServerAlias <%= server_alias %>
<% end -%>
  DocumentRoot <%= document_root %>
  PassengerMinInstances 1
  # PassengerPreStart http://<%= server_name %>/
  SetEnv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

  <Directory <%= document_root %>>
    AllowOverride AuthConfig
    Options -MultiViews
  </Directory>

  <Location "/images/page/logo_paypal.png">
    Allow from all
    Satisfy Any
  </Location>

  # redirect all traffic to maintenance-page if it exists
  ErrorDocument 503 /system/maintenance.html
  RewriteEngine On
  RewriteCond %{REQUEST_URI} !(gif|jpg|png)$
  RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -l
  RewriteCond %{SCRIPT_FILENAME} !maintenance.html
  RewriteRule ^.*$  -  [redirect=503,last]

  #RewriteEngine On
  #RewriteLog <%= document_root %>../log/rewrite.log
  #RewriteLogLevel 0

  ## Canonical host
  #RewriteCond %{HTTP_HOST}   !^<%= server_name %> [NC]
  #RewriteCond %{HTTP_HOST}   !^$
  #RewriteRule ^/(.*)$        http://<%= server_name %> /$1 [L,R=301]

  SSLEngine on
  SSLCertificateFile    <%= ssl_cert_path %>
  SSLCertificateKeyFile <%= ssl_cert_key_path %>
</VirtualHost>

# vim:ft=apache.eruby
