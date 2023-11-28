-- Multilevel sensor type have no actions to handle
-- To update multilevel sensor state, update property "value" with integer
-- Eg. self:updateProperty("value", 37.21) 

-- To set unit of the sensor, update property "unit". You can set it on QuickApp initialization
-- Eg. 
-- function QuickApp:onInit()
--     self:updateProperty("unit", "KB")
-- end

-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

-- This is QuickApp inital method. It is called right after your QuickApp starts (after each save or on gateway startup). 
-- Here you can set some default values, setup http connection or get QuickApp variables.
-- To learn more, please visit: 
--    * https://manuals.fibaro.com/home-center-3/
--    * https://manuals.fibaro.com/home-center-3-quick-apps/

-- the method for sending data to the device
-- the method can be called from anywhere

    -- Classes
class 'MyAtomcubeSensor' (QuickAppChild)

function MyAtomcubeSensor:__init(device)
    QuickAppChild.__init(self, device)

    self:debug("MyAtomcubeSensor init")
end

function MyAtomcubeSensor:setValue(name, value)
    --self:debug("child "..self.id.." updated value: "..value)
    -- local oldValue = self.properties[name]
    -- if value ~= oldValue then
        --self:debug("Update child #" .. self.id .. " '" .. self.name .. "' property '" .. name .. "' : old value = " .. tostring(oldValue) .. " => new value = " .. tostring(value))
        self:updateProperty(name, value)
    -- end
end

function MyAtomcubeSensor:setIcon(icon)
    --self:debug("child "..self.id.." updated value: "..value)
    self:updateProperty("deviceIcon", icon)
end

function MyAtomcubeSensor:getProperty(name) -- get value of property 'name'
    local value = fibaro.getValue(self.id, name)
    --self:debug("child "..self.id.." unit value: "..unit)
    return value
end



function QuickApp:send(strToSend)
    self.sock:write(strToSend, {
        success = function() -- the function that will be triggered when the data is correctly sent
            self:debug("data sent")
        end,
        error = function(err) -- the function that will be triggered in the event of an error in data transmission
            self:debug("error while sending data")
            self.sock:close() -- closing the socket
            self:debug("socket closed")
        end
    })
end
 
-- method for reading data from the socket
-- since the method itself has been looped, it should not be called from other locations than QuickApp:connect
function QuickApp:waitForResponse()
    self.sock:read({ -- reading a data package from the socket
        success = function(data)
            self:debug("data received")
            self:onDataReceived(data) -- handling of received data
        end,
        error = function() -- a function that will be called in case of an error when trying to receive data, e.g. disconnecting a socket
            self:debug("response error")
            self.sock:close() -- closing the socket
            self:debug("socket closed")
            -- fibaro.setTimeout(5000, function() self:connect() end) -- re-connection attempt (every 5s)
        end
    })
end
 
-- a method to open a TCP connection.
-- if the connection is successful, the data readout loop will be called QuickApp:waitForResponseFunction()
function QuickApp:readRegisters()
    self.sock:connect(self.address, self.port, { -- connection to the device with the specified IP and port
        success = function() -- the function will be triggered if the connection is correct
            self:debug("connected")
            self:requestData()
        end,
        error = function(err) -- a function that will be triggered in case of an incorrect connection, e.g. timeout
            self:debug("connection error")
            self.sock:close() -- closing the socket
            self:debug("socket closed")
            -- fibaro.setTimeout(5000, function() self:connect() end) -- re-connection attempt (every 5s)
        end,
    })
end

function QuickApp:requestData()
    local xxx = string.char(0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x01, 0x04, 0x00, 0x40, 0x00, 0x14)
    self:send(xxx)
    self:waitForResponse()
end
 
-- function handling the read data
-- normally this is where the data reported by the device will be handled
function QuickApp:onDataReceived(data)
    -- format: https://www.lua.org/manual/5.3/manual.html#6.4.2
    -- >: Big-Endian
    -- I2: 2byte interger
    -- position
    local txid = string.unpack(">I2", data, 1)
    local length = string.unpack(">I2", data, 5)
    local code = string.unpack(">I", data, 8)
    local byteCount = string.unpack(">I", data, 9)

    self:debug("txid: "..txid)
    self:debug("length: "..length)
    self:debug("code: "..code)
    self:debug("byteCount: "..byteCount)

    local tvoc = string.unpack(">I2", data, 10)
    local pm1 = string.unpack(">I2", data, 12) / 10
    local pm25 = string.unpack(">I2", data, 14) / 10
    local pm4 = string.unpack(">I2", data, 16) / 10
    local pm10 = string.unpack(">I2", data, 18) / 10
    local co2 = string.unpack(">I2", data, 20)
    local t = string.unpack(">i2", data, 22) / 100
    local h = string.unpack(">I2", data, 24) / 100
    local abs_h = string.unpack(">I2", data, 26)
    local p = string.unpack(">I2", data, 28) / 10
    local noise = string.unpack(">I2", data, 30)
    local light = string.unpack(">I2", data, 32)
    local no2 = string.unpack(">I2", data, 34)
    local co = string.unpack(">I2", data, 36)
    local o3 = string.unpack(">I2", data, 38)
    local ch2o = string.unpack(">I2", data, 40)
    local ct = string.unpack(">I2", data, 42)
    local people = string.unpack(">I2", data, 44)
    local voc_index = string.unpack(">I2", data, 46)
    local nox_index = string.unpack(">I2", data, 48)

    -- self:debug("tvoc: "..tvoc)
    -- self:debug("pm1: "..pm1)
    -- self:debug("pm25: "..pm25)
    -- self:debug("pm4: "..pm4)
    -- self:debug("pm10: "..pm10)
    -- self:debug("co2: "..co2)
    -- self:debug("t: "..t)
    -- self:debug("h: "..h)
    -- self:debug("abs_h: "..abs_h)
    -- self:debug("p: "..p)
    -- self:debug("noise: "..noise)
    -- self:debug("light: "..light)
    -- self:debug("no2: "..no2)
    -- self:debug("co: "..co)
    -- self:debug("o3: "..o3)
    -- self:debug("ch2o: "..ch2o)
    -- self:debug("ct: "..ct)
    -- self:debug("people: "..people)
    -- self:debug("voc_index: "..voc_index)
    -- self:debug("nox_index: "..nox_index)
    self.devicesMap["tvoc"]:updateProperty("value", tvoc)
    self.devicesMap["pm1"]:updateProperty("value", pm1)
    self.devicesMap["pm25"]:updateProperty("value", pm25)
    self.devicesMap["pm4"]:updateProperty("value", pm4)
    self.devicesMap["pm10"]:updateProperty("value", pm10)
    self.devicesMap["co2"]:updateProperty("value", co2)
    self.devicesMap["t"]:updateProperty("value", t)
    self.devicesMap["h"]:updateProperty("value", h)
    self.devicesMap["abs_h"]:updateProperty("value", abs_h)
    self.devicesMap["p"]:updateProperty("value", p)
    self.devicesMap["noise"]:updateProperty("value", noise)
    self.devicesMap["light"]:updateProperty("value", light)
    self.devicesMap["no2"]:updateProperty("value", no2)
    self.devicesMap["co"]:updateProperty("value", co)
    self.devicesMap["o3"]:updateProperty("value", o3)
    self.devicesMap["ch2o"]:updateProperty("value", ch2o)
    self.devicesMap["ct"]:updateProperty("value", ct)
    self.devicesMap["people"]:updateProperty("value", people)
    self.devicesMap["voc_index"]:updateProperty("value", voc_index)
    self.devicesMap["nox_index"]:updateProperty("value", nox_index)


    -- self.devicesMap["t"].setValue("text", tostring(t))
    -- self.devicesMap["t"].updateProperty("text", tostring(t))
    -- local xxx = self.devicesMap["t"]
    -- xxx.updateProperty("unit", "C")
    -- self:debug(xxx.updateProperty)
    
    -- self:updateProperty("unit", "KB")

    -- self:updateView("tvoc", "text", tostring(tvoc).." ppb")
    -- self:updateView("pm1", "text", tostring(pm1).." ug/m3")
    -- self:updateView("pm25", "text", tostring(pm25).." ug/m3")
    -- self:updateView("pm4", "text", tostring(pm4).." ug/m3")
    -- self:updateView("pm10", "text", tostring(pm10).." ug/m3")

    -- self:updateView("co2", "text", tostring(co2).." ppm")
    -- self:updateView("t", "text", tostring(t).." C")
    -- self:updateView("h", "text", tostring(h).." %")
    -- self:updateView("abs_h", "text", tostring(abs_h).." g/m3")
    -- self:updateView("p", "text", tostring(p).." mbar"
    -- )
    -- self:updateView("noise", "text", tostring(noise).." dB")
    -- self:updateView("light", "text", tostring(light).." Lux")
    -- self:updateView("no2", "text", tostring(no2).." ppb")
    -- self:updateView("co", "text", tostring(co).." ppb")
    -- self:updateView("o3", "text", tostring(o3).." ppb")

    -- self:updateView("ch2o", "text", tostring(ch2o).." ppb")
    -- self:updateView("ct", "text", tostring(ct).." K")
    -- self:updateView("people", "text", tostring(people).." cnt")
    -- self:updateView("voc_index", "text", tostring(voc_index).." idx")
    -- self:updateView("nox_index", "text", tostring(nox_index).." idx")

    self.sock:close() -- closing the socket
    self:debug("socket closed")
end

function QuickApp:loop(interval)
    fibaro.setTimeout(interval, function() 
        self:readRegisters()
        self:loop(interval)
    end)
end

function QuickApp:createChildDevices()
    local tvoc = self:createChildDevice({
        name = "Volatile Organic Compounds (VOC)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    tvoc:updateProperty("unit", "ppb")

    local pm1 = self:createChildDevice({
        name = "PM 1.0",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    pm1:updateProperty("unit", "ug/m3")

    local pm25 = self:createChildDevice({
        name = "PM 2.5",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    pm25:updateProperty("unit", "ug/m3")

    local pm4 = self:createChildDevice({
        name = "PM 4",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    pm4:updateProperty("unit", "ug/m3")

    local pm10 = self:createChildDevice({
        name = "PM 10",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    pm10:updateProperty("unit", "ug/m3")

    local co2 = self:createChildDevice({
        name = "Carbon dioxide (CO2)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    co2:updateProperty("unit", "ppm")

    local t = self:createChildDevice({
        name = "Temperature",
        type = "com.fibaro.temperatureSensor",
    }, MyAtomcubeSensor)

    local h = self:createChildDevice({
        name = "Humidity",
        type = "com.fibaro.humiditySensor",
    }, MyAtomcubeSensor)

    local abs_h = self:createChildDevice({
        name = "Absolute humidity",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    abs_h:updateProperty("unit", "g/m3")

    local p = self:createChildDevice({
        name = "Pressure",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    p:updateProperty("unit", "mbar")

    local noise = self:createChildDevice({
        name = "Noise",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    noise:updateProperty("unit", "dB")

    local light = self:createChildDevice({
        name = "light",
        type = "com.fibaro.lightSensor",
    }, MyAtomcubeSensor)

    local no2 = self:createChildDevice({
        name = "Nitrogen dioxide (NO2)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    no2:updateProperty("unit", "ppb")

    local co = self:createChildDevice({
        name = "Carbon monoxide (CO)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    co:updateProperty("unit", "ppb")

    local o3 = self:createChildDevice({
        name = "Ozone (O3)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    o3:updateProperty("unit", "ppb")

    local ch2o = self:createChildDevice({
        name = "Formaldehyde (CH2O)",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    ch2o:updateProperty("unit", "ppb")

    local ct = self:createChildDevice({
        name = "Color temperature",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    ct:updateProperty("unit", "K")

    local people = self:createChildDevice({
        name = "People count",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    people:updateProperty("unit", "count")

    local voc_index = self:createChildDevice({
        name = "VOC index",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    voc_index:updateProperty("unit", "Index points")

    local nox_index = self:createChildDevice({
        name = "NOx index",
        type = "com.fibaro.multilevelSensor",
    }, MyAtomcubeSensor)
    nox_index:updateProperty("unit", "Index points")

    -- self:trace("Child device created: ", t.id)
    local devices = {}
    devices["tvoc"] = tvoc
    devices["pm1"] = pm1
    devices["pm25"] = pm25
    devices["pm4"] = pm4
    devices["pm10"] = pm10
    devices["co2"] = co2
    devices["t"] = t
    devices["h"] = h
    devices["abs_h"] = abs_h
    devices["p"] = p
    devices["noise"] = noise
    devices["light"] = light
    devices["no2"] = no2
    devices["co"] = co
    devices["o3"] = o3
    devices["ch2o"] = ch2o
    devices["ct"] = ct
    devices["people"] = people
    devices["voc_index"] = voc_index
    devices["nox_index"] = nox_index

    self.devicesMap = devices
    -- t:updateProperty("text", "hello")
end
 
function QuickApp:onInit()
    self:debug("onInit")

    -- Setup classes for child devices.
    -- Here you can assign how child instances will be created.
    -- If type is not defined, QuickAppChild will be used.
    self:initChildDevices({
        ["com.fibaro.temperatureSensor"] = MyAtomcubeSensor,
        ["com.fibaro.humiditySensor"] = MyAtomcubeSensor,
        ["com.fibaro.LightSensor"] = MyAtomcubeSensor,
        ["com.fibaro.MultilevelSensor"] = MyAtomcubeSensor,
    })

    -- Print all child devices.
    self:debug("Child devices:")
    for id,device in pairs(self.childDevices) do
        self:debug("[", id, "]", device.name, ", type of: ", device.type)
        self:removeChildDevice(id)
        -- device.updateProperty("unit", "C")
    end

    self:createChildDevices()

    self:updateProperty("manufacturer", "ATMO(R)")
    self:updateProperty("model", "Atmocube")
    
 
    self.address = self:getVariable("address")
    self.port = tonumber(self:getVariable("port"))
    self.sock = net.TCPSocket() -- creation of a TCPSocket instance

    -- self:loop(10000)
    -- self:readRegisters()

    
end