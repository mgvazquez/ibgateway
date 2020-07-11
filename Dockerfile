FROM phusion/baseimage:18.04-1.0.0

############# Global Tasks #############
USER root

ENV DEBIAN_FRONTEND=noninteractive \
    DISABLE_SYSLOG=0 \
    DISABLE_SSH=1 \
    DISABLE_CRON=1 \
    DISPLAY=:0

CMD ["/sbin/my_init"]

RUN install_clean \
        wget \
        unzip \
        xvfb \
        libxrender1 \
        libxtst6 \
        libxi6 \
        x11vnc \
 && echo "source /etc/profile" >> /root/.bashrc
########################################

################ Services ##############
ENV VNC_PASSWORD=123456 \
    VNC_PORT=5900
COPY components/services/xvfb /etc/service/00_xvfb
COPY components/services/vnc /etc/service/01_vnc
COPY components/services/ibcontroller /etc/service/02_ibcontroller
RUN chmod a+x /etc/service/*/*
########################################

###### Instalacion del IBGateway #######
#ENV IBGATEWAY_PKG_URL="http://cdn.quantconnect.com/interactive/ibgateway-latest-standalone-linux-x64-v974.4g.sh"
ENV IBGATEWAY_PKG_URL="https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh"
ADD ${IBGATEWAY_PKG_URL} /tmp/ibgateway.sh
RUN chmod a+x /tmp/ibgateway.sh \
 && echo n | /tmp/ibgateway.sh -c \
 && rm -f /tmp/ibgateway.sh \
 && stat /usr/local/i4j_jres/*/bin | grep File | awk '{print "export JAVA_PATH="$2}' > /etc/profile.d/java.sh
COPY components/ibgateway/* /root/Jts/
########################################

##### Instalacion del IBController #####
#ENV IBCONTROLLER_PKG_URL="https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip" \
ENV IBCONTROLLER_PKG_URL="http://cdn.quantconnect.com/interactive/IBController-QuantConnect-3.2.0.5.zip" \
    IBC_INI=/root/IBController/IBController.ini \
    IBC_PATH=/opt/IBController \
    TWS_MAJOR_VRSN=978 \
    TWS_PATH=/root/Jts \
    TWS_CONFIG_PATH=/root/Jts \
    LOG_PATH=/root/IBController/Logs \
    TRADING_MODE=paper \
    FIXUSERID='' \
    FIXPASSWORD='' \
    TWSUSERID="<usr_change_me>" \
    TWSPASSWORD="<pwd_change_me>" \
    APP=GATEWAY

ADD ${IBCONTROLLER_PKG_URL} /tmp/ibcontroller.zip
RUN mkdir -p /{root,opt}/IBController/Logs \
 && unzip /tmp/ibcontroller.zip -d /opt/IBController/ \
 && cd /opt/IBController/ \
 && chmod o+x *.sh */*.sh \
 && sed -i 's/     >> \"\${log_file}\" 2>\&1/     2>\&1/g' Scripts/DisplayBannerAndLaunch.sh \
 && sed -i 's/light_red=.*/light_red=""/g' Scripts/DisplayBannerAndLaunch.sh \
 && sed -i 's/light_green=.*/light_green=""/g' Scripts/DisplayBannerAndLaunch.sh \
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