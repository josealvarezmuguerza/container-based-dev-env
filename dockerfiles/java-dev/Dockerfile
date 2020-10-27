
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	bash-completion \
	curl \
	sudo \
	default-jdk \
	maven \
	git \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# JDK env
ENV JAVA_HOME=/usr/lib/jvm/default-java/ \
    PATH="${JAVA_HOME}/bin:$PATH" 

# Maven env
ENV M2_HOME="/usr/share/maven/" \ 
    PATH="${M2_HOME}/bin:$PATH" 
    

