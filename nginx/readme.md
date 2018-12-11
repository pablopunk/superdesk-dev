# Nginx configuration for SSL development


### `/etc/nginx/sites-available/default`

```
# omitting other server configs

server {
        server_name <sd.my-domain.com>;

        location / {
                proxy_pass http://localhost:9000;
                sub_filter_once off;
                sub_filter_types application/javascript;
                sub_filter 'http://localhost' 'http://\$host';
        }
}
```

### Certbot

```bash
$ sudo certbot --nginx
```
