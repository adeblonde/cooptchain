FROM ubuntu:latest
RUN apt-get update; \
apt-get -y install software-properties-common; \
add-apt-repository -y ppa:ethereum/ethereum; \
apt-get -y update; \
apt-get -y install vim net-tools curl; \
apt-get -y install ethereum; \
rm -Rf /root/.ethereum;
