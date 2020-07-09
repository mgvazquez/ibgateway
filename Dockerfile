FROM phusion/baseimage:18.04-1.0.0

############# Global Tasks #############
USER root

# Default Envs
ENV DEBIAN_FRONTEND=noninteractive \
    DISABLE_SYSLOG=0 \
    DISABLE_SSH=1 \
    DISABLE_CRON=1 \
    DISPLAY=:0

# IBGateway Default port
EXPOSE 4002

#CMD ["/sbin/my_init", "--quiet"]
CMD ["/sbin/my_init"]

# documentacion de phusion/baseimage
RUN install_clean \
        wget \
        unzip \
        xvfb \
        libxrender1 \
        libxtst6 \
        libxi6 \
        x11vnc \
#        openjfx \
        htop \
        net-tools \
 && echo "source /etc/profile" >> /root/.bashrc
########################################

########## VNC & XVFB Services #########
ENV VNC_PASSWORD=123456 \
    VNC_PORT=5900
COPY components/services/vnc /etc/service/vnc
COPY components/services/xvfb /etc/service/xvfb
RUN chmod a+x /etc/service/*/*
########################################

###### Instalacion del IBGateway #######
#/root/Jts/ibgateway/*/ibgateway
ENV IBGATEWAY_PKG_URL="https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh" \
    IBCONTROLLER_VERSION=3.4.0
ADD ${IBGATEWAY_PKG_URL} /tmp/ibgateway.sh
RUN chmod a+x /tmp/ibgateway.sh \
 && echo n | /tmp/ibgateway.sh -c \
 && rm -f /tmp/ibgateway.sh \
 && stat /usr/local/i4j_jres/*/bin | grep File | awk '{print "export JAVA_PATH="$2}' > /etc/profile.d/java.sh
COPY components/ibgateway/* /root/Jts/
########################################

##### Instalacion del IBController #####
ENV IBCONTROLLER_PKG_URL="https://github.com/ib-controller/ib-controller/releases/download/${IBCONTROLLER_VERSION}/IBController-${IBCONTROLLER_VERSION}.zip" \
    IBC_INI=/root/IBController/IBController.ini \
    IBC_PATH=/opt/IBController \
    TWS_MAJOR_VRSN=978 \
    TWS_PATH=/root/Jts \
    TWS_CONFIG_PATH=/root/Jts
    LOG_PATH=/root/IBController/Logs \
    TRADING_MODE=paper \
    TWSUSERID="" \
    TWSPASSWORD="" \
    HIDE=""

ADD ${IBCONTROLLER_PKG_URL} /tmp/ibcontroller.zip
RUN mkdir -p /{root,opt}/IBController/Logs \
 && unzip /tmp/ibcontroller.zip -d /opt/IBController/ \
 && cd /opt/IBController/ \
 && chmod o+x *.sh */*.sh \
 && rm -f /tmp/ibcontroller.zip
COPY components/ibcontroller/* /root/IBController/
########################################

################### Don't move ###################
ARG BUILD_DATE
ARG BUILD_VCS_REF
ARG BUILD_VERSION
ARG BUILD_PROJECT_URL
ARG BUILD_COMMITER_NAME
ARG BUILD_COMMITER_MAIL
LABEL ar.com.scabb-island.ibgateway.maintainer="Manuel Andres Garcia Vazquez <mvazquez@scabb-island.com.ar>" \
      ar.com.scabb-island.ibgateway.license=GPL-3.0 \
      ar.com.scabb-island.ibgateway.build-date=${BUILD_DATE} \
      ar.com.scabb-island.ibgateway.vcs.url="${BUILD_PROJECT_URL}" \
      ar.com.scabb-island.ibgateway.vcs.ref.sha=${BUILD_VCS_REF} \
      ar.com.scabb-island.ibgateway.vcs.ref.name=${BUILD_VERSION} \
      ar.com.scabb-island.ibgateway.vcs.commiter="${BUILD_COMMITER_NAME} <${BUILD_COMMITER_MAIL}>"
##################################################