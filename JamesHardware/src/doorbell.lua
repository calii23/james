gpio.mode(0, gpio.OUTPUT)
gpio.write(0, gpio.LOW)
gpio.mode(0, gpio.INPUT)

local counter = 0

tmr.create():alarm(10, tmr.ALARM_AUTO, function()
    if gpio.read(0) == gpio.HIGH then
        counter = counter + 1
        if counter == 10 then
            doorbell()
        end
        gpio.write(0, gpio.LOW)
    else
        counter = 1
    end
end)
