

function love.load()
	offx = 10
	offy = 10
	size = 32
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
			sendMove(pack2D(board))
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
	buttons2 = clone(buttons)
	buttons3 = clone(buttons)

	buttons:add("Free Move",size*cols + size,size*rows/2+54,nil,28,toggleFreemode)
	buttons3:add("Sync",size*cols + size+100,size*rows/2+54,nil,28,sync)
	buttons3:add("Resend",size*cols + size,size*rows/2+54+2*50,nil,28,function( ... ) if not isItMyTurn then sendMove(pack2D(board)) end end)
	

	timeboard = love.graphics.newCanvas(cols*size,rows*size)
    timeboard:setFilter("linear","nearest")
	
	timeDead = {}
	timeDead['t'] = false
	timeDead['T'] = false
	timeDead['f'] = false
	timeDead['F'] = false	





	--white is host
	socket = require("socket")
	hosting = false
	joined = false
	first = true
	targetSlot = -1
	--[[range:2220-2224]]
	serverSlot = 2222
	--serverIP = assert(socket.dns.toip("localhost"))
	serverIP = "192.168.1.79"
	serverIP = "99.101.45.203"
	--serverIP = "99.101.45.203"
	targetIP = "wtf"

	function whiteFunc()
		if hosting == false then
	    	buttons3:add("Drop Connection",size*cols+size,size*rows/2+54+50,nil,28,function( ... ) first = true; udp:setpeername("*") end)
		end
		onlineInfo.color = "white"
		gamemode = 1
		hosting = true
		
	    udp = socket.udp()
	    udp:setsockname("*",serverSlot)
	    udp:settimeout(0)


	end
	function connect()
		udp:send("phages of dunes")
	end
	function blackFunc()
		if joined == false then
	    	buttons3:add("Connect",size*cols+size,size*rows/2+54+50,nil,28,connect)
		end
		onlineInfo.color = "black"
		gamemode = 1

		joined = true
	    first = false

	    udp = socket.udp()
	    targetSlot = serverSlot
	    targetIP = serverIP
	    myLoc = math.random(2300,4000)
	    
	    	udp:setpeername(serverIP, serverSlot)

	    
	    --udp:setsockname("*",myLoc)
	    udp:send("phages of dunes")
	    udp:settimeout(0)
	

	end
	buttons2:add("WHITE (server)",100,100,nil,28,whiteFunc)
	buttons2:add("BLACK (client)",100,129,nil,28,blackFunc)


	gamemode = 0 -- 0 for choose team, 1 for game.
	onlineInfo = {}

	dap2 = assert(socket.dns.toip("localhost"))
	str = pack2D(board)
	print(str)
	board = unpack2D(str)
	text = ""


	udpTimeout = 0
end



game = {}
function game.update(dt)
	if not (selected.x == 0) and not (selected.y > rows) and not (selected.x > cols) then
		c = move.cords(selected.x,selected.y, board, pieces, isLower(board[selected.x][selected.y].char))
	else 
		c = {}
	end
end
function game.mousepressed(x,y,button)
	if button == 1 then
		buttons3:update()
	end
	if button == 1 and isItMyTurn() then
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
function game.draw()
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
	--love.graphics.print(text, love.mouse.getX(), love.mouse.getY())
	buttons:draw()
	if freeMode then
		love.graphics.setColor(255,0,0,25)
		love.graphics.rectangle("fill", 0, 0, size*cols, size*rows)
	end
	buttons3:draw()
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
			selected.x,	selected.y = 0, 0
			sendMove(pack2D(board))
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
			selected.x,	selected.y = 0, 0
			tMax = 0
			tMin = 0
			t = 0
			sendMove(pack2D(board) .. "_")


		end


	else
		selected.x,	selected.y = mx, my
	end
end
function isItMyTurn()
	if onlineInfo.color == "white" then
		return lowerTurn
	end
	return not lowerTurn
end


function getPrevBoard(t)
	local boardPrevStr = field:gsub("-", "\n"):match("%D+") --replace the dashes with newlines, then take all non-digit chars
	--print(boardPrevStr)
	local boardPrev = makeBoard(boardPrevStr)
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
	return boardPrev
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






----------
--Online--
----------
function opponentMakesTurn()
	-- body
end
function sendMove(str)
	udp:send(str)
end
function pack2D(tab)
	local str = ""
	for i = 1,#tab[1] do
		for j = 1, #tab do 
			str = str .. tab[j][i].char
		end
	end
	return str
end
function unpack2D(str)
	local tab = {}
	for i = 1, cols*rows do
		x = ((i-1) % cols)+1
		y = math.ceil(i / rows)
		if type(tab[x]) ~= "table" then
			tab[x] = {}
		end 
		if type(tab[x][y]) ~= "table" then
			tab[x][y] = {}
		end 
		tab[x][y].char = str:sub(i,i)

	end 
	return tab
end



function love.update(dt)
	if gamemode == 1 and not first then
		game.update(dt)
		udpTimeout = udpTimeout + dt
		if udpTimeout > 0.75 then
			sendMove("phages of dunes")
			udpTimeout = 0
		end
		get = udp:receive()
		if get ~= nil and not isItMyTurn() and get~= "phages of dunes" and #get <= cols*rows + 2 then
			text = get
			lowerTurn = not lowerTurn
			board = unpack2D(text)
			pastMoves[#pastMoves + 1] = unpack2D(text)
			tMax = tMax + 1
			if get:sub(-1,-1) == "_" then
				field = makeString(board)
				tMax = 0
				tMin = 0
				t = 0
				pastMoves = {}
				print("rejiiztr'd")
			end
		end
		if get ~= nil and #get >= cols*rows + 2 then
			getSunc(get)
		end
	end
	if hosting == true and first then
		blah, targetIPhold,targetSlothold = udp:receivefrom()
        if blah ~= nil then
            first = false
            targetIP = targetIPhold
            targetSlot = targetSlothold
            --udp:setpeername('*')
            udp:setpeername(targetIP, targetSlot)
        end
	end
end

function love.draw()
	if gamemode == 1 and not first then
		game.draw()
		ipz,portz = udp:getsockname()

		--love.graphics.print("My IP:" .. ipz .. "  My Port:" .. portz .. "\nOther IP:" .. targetIP .. "  Other Port:" .. targetSlot,100,100)
	end
	if gamemode == 0 then
		buttons2:draw()
	end

end

function love.mousepressed( x, y, button, istouch )
	if gamemode == 1 and not first then
		game.mousepressed(x,y,button)
		--sendMove("dikwafel" .. x*y)
	end
	if gamemode == 0 then
		if button == 1 then
			buttons2:update()
		end
	end
end

function getSunc(txt)
	if isItMyTurn() then
		lowerTurn = not lowerTurn
	end
	len = #txt/(cols*rows)
	pastMoves = {}
	field = makeString(unpack2D(txt:sub(1,1*cols*rows)))
	for i=1,len-1 do
		pastMoves[i] = unpack2D(txt:sub(i*cols*rows+1,(i+1)*cols*rows))
	end
	board = clone(pastMoves[#pastMoves])
	tMax = len-1
	--pastMoves[#pastMoves]
end

function sync()
	local str = ""
	for i = tMin, tMax do
		str = str .. pack2D(getPrevBoard(i))
	end
	if not isItMyTurn() then
		lowerTurn = not lowerTurn
	end
	udp:send(str)
end