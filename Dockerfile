FROM tomcat:alpine
MAINTAINER AbhigoyalDev
COPY target/*.war /usr/local/tomcat/webapps/launchstation04.war
EXPOSE 8080
CMD /usr/local/tomcat/bin/catalina.sh run