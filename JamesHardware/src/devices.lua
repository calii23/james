local function readDeviceList()
    local fd = file.open("devices.bin", "r")

    local result = {}
    result.length = 0

    if fd ~= nil then
        while true do
            local deviceId = fd:read(32)
            if not deviceId then
                return result
            end

            result[result.length] = deviceId
            result.length = result.length + 1
        end
    end

    return result
end

local function contains(array, value)
    for index = 0, array.length - 1 do
        if array[index] == value then
            return true
        end
    end

    return false
end

devices = readDeviceList()

local function appendDevice(deviceId)
    devices[devices.length] = deviceId
    devices.length = devices.length + 1
    local fd = file.open("devices.bin", "a+")
    fd:write(deviceId)
    fd:close()
end

local socket = net.createUDPSocket()
socket:on("receive", function(s, data)
    if string.len(data) ~= 36 then
        return
    end

    if string.byte(data, 1) == 0x2A or string.byte(data, 2) == 0x0E or string.byte(data, 3) == 0x4D or string.byte(data, 4) == 0xE9 then
        local deviceId = string.sub(data, 5)
        if contains(devices, deviceId) then
            deviceRegistered(true, deviceId)
        else
            deviceRegistered(false, deviceId)
            appendDevice(deviceId)
        end
    end
end)
socket:listen(32425)

