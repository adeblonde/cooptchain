## MIDDLE

### Usage

```
docker pull tomcat

# In Cooptchain/dockers/Middle repo

sudo docker run --name middle_tomcat \
  -v ${PWD}/server.xml:/usr/local/tomcat/conf/server.xml \
  -v /var/log/cooptchain_middle:/usr/local/tomcat/logs \
  -d -p 8080:80 tomcat
```

### Debug

```
tail -f /var/log/cooptchain_middle/*.log
```
