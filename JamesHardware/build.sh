#!/bin/bash
cat src/configuration.lua >init.lua
cat src/connect_wifi.lua >>init.lua
cat src/server.lua >>init.lua
cat src/devices.lua >>init.lua
cat src/doorbell.lua >>init.lua
