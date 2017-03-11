FROM ubuntu:16.04

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN apt-get update -y && apt-get install -y software-properties-common \
  && add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main" \
  && apt-get update -y \
  && apt-get install -y hhvm=3.18.1~xenial \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
