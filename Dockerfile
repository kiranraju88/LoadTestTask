#Install Alpine Linux
FROM alpine:latest

# This line is useful to track the ownership of an image.
LABEL maintainer=kiran.raju@cognizant.com

# An argument customizable via the command line when the build is invoked. It contains a default value. 
ARG JMETER_VERSION="5.1.1"

# The environment variables configured using ENV will persist when a container is run from the resulting image.
ENV JMETER_HOME /opt/jmeter
ENV JMETER_BIN  ${JMETER_HOME}/bin
ENV MIRROR_HOST https://archive.apache.org/dist/jmeter/
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGINS_DOWNLOAD_URL http://repo1.maven.org/maven2/kg/apc
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext/
ENV PATH "/root/.local/bin:$PATH"
ENV SCRIPTS_HOME /opt/scripts

#"RUN" keyword - invokes the command line on the current image status. So for copy-on-write concepts before this line we have an image id with all the modifications defined into this command.
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
            && apk add --update openjdk8-jre tzdata curl unzip bash \
            && cp /usr/share/zoneinfo/Europe/Rome /etc/localtime \
            && echo "Europe/Rome" >  /etc/timezone \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xvf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies
# Instead of putting many shell commands using '&&', we can use a single "RUN" keyword for a single shell command.
RUN curl -L --silent ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-dummy/0.2/jmeter-plugins-dummy-0.2.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-dummy-0.2.jar
RUN curl -L --silent ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-cmn-jmeter/0.5/jmeter-plugins-cmn-jmeter-0.5.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-cmn-jmeter-0.5.jar

WORKDIR /opt

RUN mv apache-jmeter-${JMETER_VERSION} jmeter && \
    chown root:root -R jmeter

WORKDIR $SCRIPTS_HOME
ENTRYPOINT ["./jmeter-entrypoint.sh"]

CMD [ "" ]
