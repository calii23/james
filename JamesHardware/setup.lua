if not file.exists("config.bin") then
    print("missing config.bin file!")
    return
end

if not file.exists("init.lua") then
    print("missing init.lua file!")
    return
end

node.compile("init.lua")
file.remove("init.lua")
file.putcontents("init.lua", "dofile(\"init.lc\")")
file.remove("setup.lua")
node.restart()
