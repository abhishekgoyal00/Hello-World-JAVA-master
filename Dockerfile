FROM tomcat:alpine
MAINTAINER AbhishekGoyal
COPY target/*.war /usr/local/tomcat/webapps/abhishekgoyal.war
EXPOSE 8080
CMD /usr/local/tomcat/bin/catalina.sh run