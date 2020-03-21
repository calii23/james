local station_cfg = {}
station_cfg.ssid = ssid
station_cfg.pwd = password
station_cfg.save = false
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
