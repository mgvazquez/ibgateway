# Interactive Brokers Gateway Docker

---

### Docker Image

[![](https://images.microbadger.com/badges/version/mgvazquez/ibgateway.svg)](https://microbadger.com/images/mgvazquez/ibgateway "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/mgvazquez/ibgateway.svg)](https://microbadger.com/images/mgvazquez/ibgateway "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/mgvazquez/ibgateway.svg)](https://microbadger.com/images/mgvazquez/ibgateway "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/mgvazquez/ibgateway.svg)](https://microbadger.com/images/mgvazquez/ibgateway "Get your own license badge on microbadger.com")


### Docker Compose

Requiere archivos de configuracion `IBController.ini`, `jts.ini` ( ejemplo de ambos es en repositorio)

```yaml
version: '3'
services:
  gateway:
    image: mgvazquez/ibgateway:latest
    restart: always
    ports:
      - "4001:4001"
      - "5900:5900"
    volumes:
      - ../components/ibcontroller/IBController.ini:/root/IBController/IBController.ini
      - ../components/ibgateway/jts.ini:/root/Jts/jts.ini
    environment:
      - TZ=America/Argentina/Buenos_Aires
      - VNC_PASSWORD=123456789
      - VNC_PORT=5900
      - TWSUSERID="<usr_change_me>"
      - TWSPASSWORD="<pwd_change_me>"
      - IBC_INI=/root/IBController/IBController.ini
      - TWS_PATH=/root/Jts
      - TWS_CONFIG_PATH=/root/Jts
      - TRADING_MODE=paper
      - FIXUSERID=''
```

---

<p align="center"><img src="http://www.catb.org/hacker-emblem/glider.png" alt="hacker emblem"></p>