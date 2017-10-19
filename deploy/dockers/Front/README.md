## FRONT

### Usage

```
docker pull nginx

# Run compile_front.sh before

# In Cooptchainœ/dockers/Front repo

sudo docker run --name front_nginx \
  -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
  -v /var/log/cooptchain_front:/var/log/cooptchain \
  -v /var/www/cooptchain:/var/www/cooptchain \
  -d -p 80:80 nginx

# Restart nginx service
docker restart front_nginx
```

### Debug

```
tail -f /var/log/cooptchain_front/*.log
```
