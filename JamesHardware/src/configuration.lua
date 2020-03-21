local fd = file.open("config.bin", "r")

local ssidLength = fd:read(2)
ssid = fd:read(bit.bor(bit.lshift(string.byte(ssidLength, 1), 8), string.byte(ssidLength, 2)))

local passwordLength = fd:read(2)
password = fd:read(bit.bor(bit.lshift(string.byte(passwordLength, 1), 8), string.byte(passwordLength, 2)))

local serverLength = fd:read(2)
server = fd:read(bit.bor(bit.lshift(string.byte(serverLength, 1), 8), string.byte(serverLength, 2)))

local rawPort = fd:read(2)
port = bit.bor(bit.lshift(string.byte(rawPort, 1), 8), string.byte(rawPort, 2))

local rawDeviceId = fd:read(2)
deviceId = bit.bor(bit.lshift(string.byte(rawDeviceId, 1), 8), string.byte(rawDeviceId, 2))

secret = fd:read(32)

fd:close()
