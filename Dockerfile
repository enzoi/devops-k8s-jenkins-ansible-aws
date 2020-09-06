FROM tomcat:8-jdk8

COPY ./webapp.war /usr/local/tomcat/webapps

RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps