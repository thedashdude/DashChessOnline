function love.load()
    offx = 10
    offy = 10
    size = 64
    font = love.graphics.newFont( "saxmono.ttf", 50)
    love.graphics.setFont(font)

    
    mx,my = 0 ,0
    pastMoves = {}

    t = 0
    tMax = 0
    tMin = 0
    function toggleFreemode()
        if freeMode == false then
            freeMode = true
            swap = false
            selected.x = 0
        else
            pastMoves[#pastMoves + 1] = clone(board)
            freeMode = false
            lowerTurn = not lowerTurn
            tMax = tMax + 1
        end
    end
    freeModeRecord = {mode = 'lots'}
    freeMode = false
    swap = false




    field = require('levels')
    move = require('move')
    boardString = field:gsub("-","\n")

    cols = boardString:find("\n")-1
    _, rows = boardString:gsub("\n","\n")
    rows = rows + 1
    Tiles = 'pieces.png'
    Tileset = love.graphics.newImage(Tiles)
    


    board = makeBoard(boardString)
    boardPrev = makeBoard(boardString)
    
    definePieces()

    selected = {}
    selected.x = 0
    selected.y = 0
    --c = move.cords(selected.x,selected.y,pieces.r.move, board)
    clickTimeMax = .25
    clickTime = 0
    lowerTurn = true

    height = rows*size+size
    width = cols*size+size*2 + size*cols/2

    love.window.setMode(width, height)
    
    buttons = require("buttons")
    buttons:add("Free Move",size*cols + size,372,nil,28,toggleFreemode)

    timeboard = love.graphics.newCanvas(cols*size,rows*size)
    timeboard:setFilter("linear","nearest")
    
    timeDead = {}
    timeDead['t'] = false
    timeDead['T'] = false
    timeDead['f'] = false
    timeDead['F'] = false   

end

function love.update(dt)

    
    clickTime = clickTime + dt
    if not (selected.x == 0) and not (selected.y > rows) and not (selected.x > cols) then
        c = move.cords(selected.x,selected.y, board, pieces, isLower(board[selected.x][selected.y].char))
    else 
        c = {}
    end
end
function freeModeMoves()
    if not (selected.x == 0) and not (selected.y > rows) and not (my > rows) and not (selected.x > cols) and not (mx > cols) and swap then
        holdChar = board[mx][my].char
        board[mx][my].char = board[selected.x][selected.y].char
        board[selected.x][selected.y].char = holdChar
        if selected.x == mx and selected.y == my then
            board[selected.x][selected.y].char = cycle(board[selected.x][selected.y].char)
        end
        swap = false
        selected.x = 0
    else
        selected.x = mx
        selected.y = my
        swap = true
    end
end
function cycle(chr)
    loop = {'p','r','n','b','q','k','t','f','P','R','N','B','Q','K','T','F',' '}
    for i=1,#loop-1 do
        if loop[i] == chr then return loop[i+1] end
    end
    return 'p'
end
function makeMove( ... )
    if not (selected.x == 0) and not (selected.y > rows) and not (my > rows) and not (selected.x > cols) and not (mx > cols) and move.canMove(selected.x,selected.y,mx,my,c,board,lowerTurn) then 
        --THIS IS MAKING A MOVE
        lowerTurn = not lowerTurn
        print((board[selected.x][selected.y].char:lower() == 't'))
        print(board[mx][my].char == ' ')
        if not ( ( (board[selected.x][selected.y].char:lower() == 't') or (board[selected.x][selected.y].char:lower() == 'f') ) and not(board[mx][my].char == ' ') ) then
            --temp = board[mx][my]
            if not(timeDead[board[mx][my].char] == nil) then timeDead[board[mx][my].char] = true end
            board[mx][my].char = board[selected.x][selected.y].char
            if board[mx][my].char:lower() == "s" then
                board[mx][my].char = setCase("p",board[mx][my].char)
            end
            --field = field .. selected.x  .. selected.y .. mx .. my
            pastMoves[#pastMoves + 1] = {tonumber(selected.x),tonumber(selected.y),tonumber(mx),tonumber(my)}
            --print(field)

            

            board[selected.x][selected.y].char = " "
            selected.x, selected.y = 0, 0
            tMax = tMax + 1
        else 


            --TIME TRAVEL!!!!
            traveler = board[mx][my].char
            for kx, xPart in pairs(boardPrev) do 
                for ky, yPart in pairs(xPart) do 
                    for kc, charsNStuff in pairs(yPart) do 
                        board[kx][ky][kc] = charsNStuff
                    end
                end
            end
            field = makeString(board)

            print(field)
            _, numOfTraveler = field:gsub(traveler,traveler)
            print(numOfTraveler)
            print("trav:" .. traveler)
            print(pieces[traveler:lower()].max)

            if pieces[traveler:lower()].max < numOfTraveler+1 then traveler=setCase('p',traveler)  end
            board[mx][my].char = traveler
            
            pastMoves = {}
            --pastMoves[#pastMoves + 1] = {tonumber(selected.x),tonumber(selected.y),tonumber(mx),tonumber(my)}
            field = makeString(board)

            --KILL ALL TIME TRAVELERS
            for char, isDead in pairs(timeDead) do 
                if isDead then
                    field = field:gsub(char, " ")
                end
            end
            board = makeBoard(field)
            print(field)
            selected.x, selected.y = 0, 0
            tMax = 0
            tMin = 0
            t = 0



        end


    else
        selected.x, selected.y = mx, my
    end
end

function love.mousepressed( x, y, button, istouch )
    if button == 1 then
        buttons:update()
        clickTime = 0
        mx, my = math.floor(love.mouse.getX() / size)+1, math.floor(love.mouse.getY() / size)+1
        --print("rows:" .. rows .. " selected.y:" .. selected.y)
        if not freeMode then
            makeMove()
        else
            freeModeMoves()
        end
    end
end

function drawPrev()
    love.graphics.setCanvas(timeboard)
    drawGrid(0,0)
    boardPrevStr = field:gsub("-", "\n"):match("%D+") --replace the dashes with newlines, then take all non-digit chars
    --print(boardPrevStr)
    boardPrev = makeBoard(boardPrevStr)
    if not (pastMoves == nil) then

        for i = 1, t do
            --startandfinish = readField(turns, t)
            if #pastMoves[i] == 4 then
                beginX = pastMoves[i][1]
                beginY = pastMoves[i][2]
                endX   = pastMoves[i][3]
                endY   = pastMoves[i][4]
                temp = boardPrev[endX][endY]
                boardPrev[endX][endY].char = boardPrev[beginX][beginY].char
                if boardPrev[endX][endY].char:lower() == "s" then
                    boardPrev[endX][endY].char = setCase("p",boardPrev[endX][endY].char)
                end
                --field = field .. selected.x .. selected.y .. mx .. my
                --print(field)
                boardPrev[beginX][beginY].char = " "
            else
                boardPrev = clone(pastMoves[i])
            end
        end 
    end

    for x = 1, cols do
        for y = 1, rows do
            if pieces[boardPrev[x][y].char:lower()] then
                if boardPrev[x][y].char:lower() == boardPrev[x][y].char then 
                    love.graphics.setColor(0,0,0)
                else
                    love.graphics.setColor(255,255,255)
                end
                love.graphics.draw(Tileset, pieces[boardPrev[x][y].char:lower()].quad, (x - 1)*size, (y - 1)*size)
            end
        end
    end
    love.graphics.setCanvas()
end

function love.draw()

    bg = 25
    if not lowerTurn then bg = 25 else bg = 225 end
    love.graphics.setColor(bg,bg,bg)
    love.graphics.rectangle("fill", 0, 0, width, height)
    drawGrid()
    drawBoard()
    drawSelect()
    love.graphics.setColor(0,0,0)
    --love.graphics.print(selected.x .. "," .. selected.y, love.mouse.getX()+32, love.mouse.getY()+32)
    --love.graphics.print(selected.x .. "," .. selected.y, love.mouse.getX()+32, love.mouse.getY()+32)
    if not freeMode then
        drawMove()
    end



    drawPrev(t)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(timeboard,cols*size+size,0,0,0.5)
    love.graphics.setFont(font)
    love.graphics.setColor(255-bg,255-bg,255-bg)
    love.graphics.print("Turn " .. t, size*cols+size, size*rows/2)
    love.graphics.print(love.mouse.getX() .. " " .. love.mouse.getY(), love.mouse.getX(), love.mouse.getY())
    buttons:draw()
    if freeMode then
        love.graphics.setColor(255,0,0,25)
        love.graphics.rectangle("fill", 0, 0, size*cols, size*rows)
    end
end












--housekeeping:

function makeBoard(str)
    local b = {}
    
    for x = 1, cols do
        b[x] = {}
        for y = 1, rows do 
            b[x][y] = {}
            b[x][y].char = str:sub( (y - 1) * (cols + 1) + x,  (y - 1) * (cols + 1) + x)
            --print(b[x][y])
        end
    end
    b[0] = {}
    b[0][0] = {}
    b[0][0].char = nil
    return b
end
function isLower(str)
    str = str or "a"
    return str:lower() == str
end
function setCase(str1, str2)
    if isLower(str2) then 
        return str1:lower()
    end
    return str1:upper()
end
function drawSelect()
    if not (selected.x == 0) and not (selected.y > rows) and not (selected.x > cols) then
        love.graphics.setColor(75,75,255,100)
        love.graphics.rectangle("fill", (selected.x - 1)*size, (selected.y - 1)*size, size, size)
    end
end
function makeString(aBoard)
    str = ""
    for kx,vx in ipairs(aBoard) do 
        for ky,vy in ipairs(vx) do 
            str = str .. aBoard[ky][kx].char
        end
        str = str .. '-'
    end
    str = str:sub(1,#str-1)
    return str
end
function drawGrid(offsetx, offsety)
    offsetx = offsetx or 0
    offsety = offsety or 0
    for x = 1, cols do
        for y = 1, rows do 
            love.graphics.setColor(255 * ( (x + y) % 2) + 50, 255 * ( (x + y) % 2) + 50, 255 * ( (x + y) % 2) + 50)
            love.graphics.rectangle("fill",(x - 1) * size + offsetx, (y - 1) * size + offsety, size, size)
        end
    end
end
function drawBoard()
    for x = 1, cols do
        for y = 1, rows do
            if pieces[board[x][y].char:lower()] then
                if board[x][y].char:lower() == board[x][y].char then 
                    love.graphics.setColor(0,0,0);
                else
                    love.graphics.setColor(255,255,255)
                end
                love.graphics.draw(Tileset, pieces[board[x][y].char:lower()].quad, (x - 1)*size, (y - 1)*size)
            end
        end
    end
end
function drawMove()
    if c == nil then return nil end
    for key, value in pairs(c) do
        --print(value[3])
        should = true
        if value[3] == '1' then 
            love.graphics.setColor(50,50,200) 
        elseif value[3] == '2' then 
            love.graphics.setColor(50,50,200)
            --if board[value[1],value[2]].char
        elseif value[3] == '3' then 
            love.graphics.setColor(50,50,200)
        elseif value[3] == '4' then 
            love.graphics.setColor(50,50,200)
        else 
            love.graphics.setColor(0,0,0) 
        end

        if move.canMove(selected.x,selected.y,value[1],value[2],c,board,lowerTurn) then
            love.graphics.rectangle("fill", (value[1]-1)*size+size/3, (value[2]-1)*size+size/3, size/3, size/3) 
        end
    end
end



function love.keypressed( key, scancode, isrepeat )
    if key == "right" then t = t + 1 end
    if key == "left"  then t = t - 1 end
    if t > tMax then t = tMax end
    if t < tMin then t = tMin end
end
function definePieces()
    pieces = {}
    pieces.p = {}
    pieces.r = {}
    pieces.k = {}
    pieces.q = {}
    pieces.b = {}
    pieces.n = {}
    pieces.t = {}
    pieces.f = {}

    pieces.p.quad = love.graphics.newQuad(0,0,size,size,size*4,size*4)
    pieces.p.move = "2u0 3ur0 3ul0"
    pieces.p.max = 16

    pieces.r.quad = love.graphics.newQuad(size,0,size,size,size*4,size*4)
    pieces.r.move = "1o0"
    pieces.r.max = 4

    pieces.k.quad = love.graphics.newQuad(0,size,size,size,size*4,size*4)
    pieces.k.move = "1o1 1b1"
    pieces.k.max = 0

    pieces.q.quad = love.graphics.newQuad(size,size,size,size,size*4,size*4)
    pieces.q.move = "1o0 1b0"
    pieces.q.max = 2

    pieces.b.quad = love.graphics.newQuad(2*size,0,size,size,size*4,size*4)
    pieces.b.move = "1b0"
    pieces.b.max = 4

    pieces.n.quad = love.graphics.newQuad(2*size+size,0,size,size,size*4,size*4)
    pieces.n.move = "1j12"
    pieces.n.max = 4

    pieces.t.quad = love.graphics.newQuad(2*size,size,size,size,size*4,size*4)
    pieces.t.move = "4b0"
    pieces.t.max = 0

    pieces.f.quad = love.graphics.newQuad(2*size,size,size,size,size*4,size*4)
    pieces.f.move = "4b0"
    pieces.f.max = 0

end

function clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end