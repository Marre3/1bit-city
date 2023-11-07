local scale = 50
local world = {}
local width = 60
local height = 60
local money = 1000
local road = love.graphics.newImage("road.png")
road:setFilter("nearest", "nearest")
local house = love.graphics.newImage("home.png")
house:setFilter("nearest", "nearest")
local tree = love.graphics.newImage("tree.png")
tree:setFilter("nearest", "nearest")
local crossing = love.graphics.newImage("crossing.png")
crossing:setFilter("nearest", "nearest")
local tcrossing = love.graphics.newImage("tcrossing.png")
tcrossing:setFilter("nearest", "nearest")
local corner = love.graphics.newImage("corner.png")
corner:setFilter("nearest", "nearest")
local building = love.graphics.newImage("building.png")
building:setFilter("nearest", "nearest")
local selected = "house"
local buildSound = love.audio.newSource("build_2.wav", "static")

local gameState = "menu"

-- Citizen class definition
Citizen = {}
Citizen.__index = Citizen

function Citizen.create(x, y)
    local self = setmetatable({}, Citizen)
    self.x = x
    self.y = y
    self.happiness = 50  -- Initial happiness
    self.speed = 1000  -- Citizen movement speed
    self.franticness = 200  -- Increase this value to make citizens more frantic
    return self
end

function Citizen:update(dt)
    -- More frequent and random movements for increased franticness
    if math.random(1, 100) < self.franticness then
        local dx, dy = math.random(-1, 1), math.random(-1, 1)
        self.x = self.x + dx
        self.y = self.y + dy
    end

    -- Citizen gets happier over time
    self.happiness = self.happiness + 0.1 * dt
end

function Citizen:draw()
    love.graphics.setColor(1, 0, 0)  -- Red for citizens
    love.graphics.circle("fill", self.x, self.y, 5)
end

-- Initialize citizens table
local citizens = {}

local numHouses = 0  -- Variable to track the number of houses

function love.load()
    love.graphics.setNewFont(50)
    love.graphics.setBackgroundColor(0, 0, 0)
    for i = 1, width do
        world[i] = {}
        for j = 1, height do
            world[i][j] = { type = "empty", rotation = 0 }
        end
    end

    -- Initialize citizens
    for i = 1, 10 do
        local x, y = math.random(1, width), math.random(1, height)
        table.insert(citizens, Citizen.create(x * scale, y * scale))
    end
end

local function loadGame()
    gameState = "game"
    love.graphics.setNewFont(50)
end

function love.keypressed(key)
    if gameState == "menu" then
        loadGame()
    else
        if key == "1" then
            selected = "empty"
        elseif key == "2" then
            selected = "road"
        elseif key == "3" then
            selected = "house"
        elseif key == "4" then
            selected = "tree"
        elseif key == "5" then
            selected = "crossing"
        elseif key == "6" then
            selected = "tcrossing"
        elseif key == "7" then
            selected = "corner"
        elseif key == "8" then
            selected = "building"
        end
    end
end

function love.mousepressed(x, y)
    if gameState == "menu" then
        loadGame()
    elseif gameState == "game" then
        local squareX = math.floor(x/scale)
        local squareY = math.floor(y/scale)
        if squareX <= width and squareY <= height and squareX > 0 and squareY > 0 then
            if world[squareX][squareY].type == "road" and selected == "road" then
                world[squareX][squareY].rotation = (world[squareX][squareY].rotation + 1) % 4
            elseif world[squareX][squareY].type == "tcrossing" and selected == "tcrossing" then
                world[squareX][squareY].rotation = (world[squareX][squareY].rotation + 1) % 4
            elseif world[squareX][squareY].type == "corner" and selected == "corner" then
                world[squareX][squareY].rotation = (world[squareX][squareY].rotation + 1) % 4
            else
                world[squareX][squareY].type = selected
                world[squareX][squareY].rotation = 0
                buildSound:play()
                money = money - 1
                if selected == "house" then
                    numHouses = numHouses + 1
                end

                -- Create citizens for the new house
                for i = 1, numHouses do
                    local houseX = squareX * scale + math.random(scale)
                    local houseY = squareY * scale + math.random(scale)
                    table.insert(citizens, Citizen.create(houseX, houseY))
                end
            end
        end
    end
end

local t = 0
function love.update(dt)
    t = t + dt
    if t > 1 then
        for i = 1, width do
            for j = 1, height do
                if world[i][j].type == "house" then
                    money = money - 1
                end
            end
        end
        t = 0
    end

    for _, citizen in ipairs(citizens) do
        citizen:update(dt)
    end
end

local function drawRoad()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 1, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.scale(1/32, 1/32)
    love.graphics.draw(road)
end

local function drawTile(tile)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 1, 1)
    love.graphics.translate(0.5, 0.5)
    love.graphics.rotate(tile.rotation * math.pi/2)
    love.graphics.translate(-0.5, -0.5)
    if tile.type == "road" then
        love.graphics.push()
        drawRoad()
        love.graphics.pop()
    elseif tile.type == "house" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(house)
    elseif tile.type == "tree" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(tree)
    elseif tile.type == "crossing" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(crossing)
    elseif tile.type == "tcrossing" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(tcrossing)
    elseif tile.type == "corner" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(corner)
    elseif tile.type == "building" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(1/32, 1/32)
        love.graphics.draw(building)
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.print("Welcome to the city game", 0, 0)
    else
        for i = 1, width do
            for j = 1, height do
                love.graphics.push()
                love.graphics.scale(scale, scale)
                love.graphics.translate(i, j)
                drawTile(world[i][j])
                love.graphics.pop()
            end
        end
        local x, y = love.mouse.getPosition()
        local squareX = math.floor(x/scale)
        local squareY = math.floor(y/scale)
        if squareX <= width and squareY <= height and squareX > 0 and squareY > 0 then
            love.graphics.push()
            love.graphics.scale(scale, scale)
            love.graphics.translate(squareX, squareY)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 0, 0, 1, 0.05)
            love.graphics.rectangle("fill", 0, 0, 0.05, 1)
            love.graphics.rectangle("fill", 0.95, 0, 0.05, 1)
            love.graphics.rectangle("fill", 0, 0.95, 1, 0.05)
            love.graphics.setColor(0, 0, 0 )
            love.graphics.pop()
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(money), 0, 0, 0, 1, 1)

        -- Draw citizens
        for _, citizen in ipairs(citizens) do
            citizen:draw()
        end
    end
end