local magicNumber = string.char(0x1A) .. string.char(0x0E) .. string.char(0x4D) .. string.char(0xE7)

local function uint16ToBinary(value)
    return string.char(bit.rshift(value, 8)) .. string.char(bit.band(value, 0xFF))
end

local function uint32ToBinary(value)
    return string.char(bit.band(bit.rshift(value, 24), 0xFF)) .. string.char(bit.band(bit.rshift(value, 16), 0xFF)) .. string.char(bit.band(bit.rshift(value, 8), 0xFF)) .. string.char(bit.band(value, 0xFF))
end

local function binaryToUint32(value)
    return bit.bor(bit.lshift(string.byte(value, 1), 24), bit.lshift(string.byte(value, 2), 16), bit.lshift(string.byte(value, 3), 8), string.byte(value, 4))
end

local registerDevicePacketBase = magicNumber .. uint16ToBinary(bit.bor(deviceId, 0x4000)) .. uint16ToBinary(string.len(ssid)) .. ssid
local alreadyRegisterDevicePacketBase = magicNumber .. uint16ToBinary(bit.bor(deviceId, 0x8000)) .. uint16ToBinary(string.len(ssid)) .. ssid
local doorbellPacketBase = magicNumber .. uint16ToBinary(deviceId) .. uint16ToBinary(string.len(ssid)) .. ssid

local counter
if file.exists("counter") then
    counter = binaryToUint32(file.getcontents("counter"))
else
    counter = 0
end

local socket = net.createUDPSocket()

local function sendPacket(packet)
    counter = counter + 1
    file.putcontents("counter", uint32ToBinary(counter))
    packet = packet .. crypto.hmac("SHA256", packet, secret)
    socket:send(port, server, packet)
end

function deviceRegistered(alreadyRegistered, deviceId)
    local packet
    if alreadyRegistered then
        packet = alreadyRegisterDevicePacketBase
    else
        packet = registerDevicePacketBase
    end
    packet = packet .. uint32ToBinary(counter) .. deviceId
    sendPacket(packet)
end

function doorbell()
    if wifi.sta.status() ~= wifi.STA_GOTIP then
        return
    end

    local packet = doorbellPacketBase .. uint32ToBinary(counter) .. string.char(devices.length)

    for index = 0, devices.length - 1 do
        packet = packet .. devices[index]
    end

    sendPacket(packet)
end
