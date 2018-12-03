# Nginx configuration for SSL development

This config works right now (taken from superdesk install file). Note that `$host` notation is fine
for nginx but something like `$HOST` is probably from a script, so avoid it. Also, replace
`<sd.my-domain.com>` with whatever you want. Notice that SSL config is managed automatically by certbot
so you shouldn't write it manually.

### `/etc/nginx/sites-available/default`

```
# omitting other server configs

server {
        server_name <sd.my-domain.com>;

        location /ws {
                proxy_pass http://localhost:5100;
                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_read_timeout 3600;
                proxy_set_header Upgrade websocket;
                proxy_set_header Connection "Upgrade";
        }

        location /api {
                proxy_pass http://localhost:5000;
                proxy_set_header Host <sd.my-domain.com>;
                expires epoch;

                sub_filter_once off;
                sub_filter_types application/json;
                sub_filter 'http://localhost' 'http://\$host';
        }

        location / {
                proxy_pass http://localhost:9000;
                sub_filter_once off;
                sub_filter_types application/javascript;
                sub_filter 'http://localhost' 'http://\$host';
                sub_filter 'ws://localhost/ws' 'ws://\$host/ws';
        }

        listen 443 ssl; # managed by Certbot
        ssl_certificate /etc/letsencrypt/live/<sd.my-domain.com>/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/<sd.my-domain.com>/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
        if ($host = <sd.my-domain.com>) {
                return 301 https://$host$request_uri;
        } # managed by Certbot


        listen 80 default_server;
        listen [::]:80 default_server;

        server_name <sd.my-domain.com>;
        return 404; # managed by Certbot
}

server {
        if ($host = <sd.my-domain.com>) {
                return 301 https://$host$request_uri;
        } # managed by Certbot


        server_name <sd.my-domain.com>;
        listen 80;
        return 404; # managed by Certbot
}
```
