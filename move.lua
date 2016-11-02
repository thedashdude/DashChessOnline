local move = {}
function move.canMove(x1,y1,x2,y2,cords,board, teamLower)
    teamStart = 1
    if board[x1][y1].char:lower() == board[x1][y1].char then teamStart = 2 end
    if board[x1][y1].char == ' ' then teamStart = 3 end

    if teamLower == (teamStart == 2) then return false end


    teamEnd = 1
    if board[x2][y2].char:lower() == board[x2][y2].char then teamEnd = 2 end
    if board[x2][y2].char == ' ' then teamEnd = 3 end


    if cords == nil then return false end
    --print [[made it 1]]
    for _, cord in pairs(cords) do 
        if x2 == cord[1] and y2 == cord[2] and not (teamStart == teamEnd) then return move.checkCan(cord[3], teamStart, teamEnd) end
        if x2 == cord[1] and y2 == cord[2] and cord[3] == '4' then return move.checkCan(cord[3], teamStart, teamEnd) end
    end
    --print [[made it 2]]
    return false
end
function move.checkCan(moveType,teamStart,teamEnd)
    --print(moveType)
    if moveType == '1' then return true end
    if moveType == '2' then return teamEnd == 3 end
    if moveType == '3' then return not (teamEnd == teamStart) and not (teamEnd == 3) end
    if moveType == '4' then return true end

    --if moveType == '4' then return false end
end
function canMove(xMove,yMove,board,nowIsLower, when)
    ret = {}
    ret.valid = false
    ret.stop = true
    if not board[xMove] or not board[xMove][yMove] or not board[xMove][yMove].char then
        return ret
    end
    if board[xMove][yMove].char == ' ' then 
        ret.valid = true
        ret.stop = false
        return ret
    end

    ret.stop = true
    
    if when == '4' then 
        --print("CALLED THEM VALID")
        ret.valid = true
        return ret
    end
    if board[xMove][yMove].char:lower() == board[xMove][yMove].char then 
        ret.valid = not nowIsLower
        return ret 
    end

    if not (board[xMove][yMove].char:lower() == board[xMove][yMove].char) then 
        ret.valid = nowIsLower
        return ret 
    end

    return false
end
function move.cords(x, y, board, pieces, isLower)
    local cords = {}
    local strA = {}

    if pieces[board[x][y].char:lower()] == nil then return nil end
    str = pieces[board[x][y].char:lower()].move
    --print(str .. "HERE IT IS!")
    for rule in str:gmatch("%d+%a+%d+") do 
        local moveWhen = rule:sub(1,1)
        local moveHow = rule:match("%a+")
        local moveNumber = tonumber(rule:sub(2):match("%d+"))
        if moveNumber == 0 then 
            moveNumber = 100 
        end



        if moveHow == 'o' then
            for i = 1, moveNumber do 
                --print( board[x+i] )
                if board[x+i] and board[x+i][y] and board[x+i][y].char and canMove(x+i,y,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x+i,y,moveWhen}
                end 
                if canMove(x+i,y,board,isLower).stop then
                    break 
                end
                --[[                    cords[#cords + 1] = {x+i,y,'3'}
                    break
                else
                    ]]
            end
            for i = 1, moveNumber do 
                if board[x-i] and board[x-i][y] and board[x-i][y].char and canMove(x-i,y,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x-i,y,moveWhen}
                end 
                if canMove(x-i,y,board,isLower, moveWhen).stop then
                    break 
                end
            end
            for i = 1, moveNumber do 
                if board[x] and board[x][y+i] and board[x][y+i].char and canMove(x,y+i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x,y+i,moveWhen}
                end 
                if canMove(x,y+i,board,isLower, moveWhen).stop then
                    break 
                end
            end
            for i = 1, moveNumber do 
                if board[x] and board[x][y-i] and board[x][y-i].char and canMove(x,y-i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x,y-i,moveWhen}
                end 
                if canMove(x,y-i,board,isLower, moveWhen).stop then
                    break 
                end
            end
        elseif moveHow == 'b' then

            for i = 1, moveNumber do 
                --print( board[x+i] )
                if board[x+i] and board[x+i][y+i] and board[x+i][y+i].char and canMove(x+i,y+i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x+i,y+i,moveWhen}
                end 
                if canMove(x+i,y+i,board,isLower, moveWhen).stop then
                    break 
                end
            end

            for i = 1, moveNumber do 
                if board[x-i] and board[x-i][y-i] and board[x-i][y-i].char and canMove(x-i,y-i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x-i,y-i,moveWhen}
                end 
                if canMove(x-i,y-i,board,isLower, moveWhen).stop then
                    break 
                end
            end

            for i = 1, moveNumber do 
                if board[x-i] and board[x-i][y+i] and board[x-i][y+i].char and canMove(x-i,y+i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x-i,y+i,moveWhen}
                end 
                if canMove(x-i,y+i,board,isLower, moveWhen).stop then
                    break 
                end
            end

            for i = 1, moveNumber do 
                if board[x+i] and board[x+i][y-i] and board[x+i][y-i].char and canMove(x+i,y-i,board,isLower, moveWhen).valid then
                    cords[#cords + 1] = {x+i,y-i,moveWhen}
                end 
                if canMove(x+i,y-i,board,isLower, moveWhen).stop then
                    break 
                end
            end
        elseif moveHow == 'j' then
            a,b = moveNumber%10, math.floor(moveNumber/10)
            if board[x+a] and board[x+a][y+b] and board[x+a][y+b].char and canMove(x+a,y+b,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x+a,y+b,moveWhen}
            end
            if board[x+a] and board[x+a][y-b] and board[x+a][y-b].char and canMove(x+a,y-b,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x+a,y-b,moveWhen}
            end
            if board[x-a] and board[x-a][y+b] and board[x-a][y+b].char and canMove(x-a,y+b,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x-a,y+b,moveWhen}
            end
            if board[x-a] and board[x-a][y-b] and board[x-a][y-b].char and canMove(x-a,y-b,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x-a, y-b, moveWhen}
            end


            if board[x+b] and board[x+b][y+a] and board[x+b][y+a].char and canMove(x+b,y+a,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x+b,y+a,moveWhen}
            end
            if board[x+b] and board[x+b][y-a] and board[x+b][y-a].char and canMove(x+b,y-a,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x+b,y-a,moveWhen}
            end
            if board[x-b] and board[x-b][y+a] and board[x-b][y+b].char and canMove(x-b,y+a,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x-b,y+a,moveWhen}
            end
            if board[x-b] and board[x-b][y-a] and board[x-b][y-a].char and canMove(x-b,y-a,board,isLower, moveWhen).valid then
                cords[#cords + 1] = {x-b,y-a,moveWhen}
            end
        else --if in exact form, frlr
            _, up = moveHow:gsub("u","u")
            _, down = moveHow:gsub("d","d")
            _, left = moveHow:gsub("l","l")
            _, right = moveHow:gsub("r","r")
            if not isLower then 
                up = -up
                down = -down
            end
            if board[x+right-left] and board[x+right-left][y-up+down] and board[x+right-left][y-up+down].char then
                cords[#cords + 1] = {x+right-left,y-up+down,moveWhen}
            elseif board[x+right-left] and board[x+right-left][y-up+down] and not ( board[x+right-left][y-up+down].char == ' ' ) then 
                --cords[#cords + 1] = {x+right-left,y-up+down,'3'}
            end
        end


    end
    --for k,v in pairs(cords) do print(v[1] .. "," .. v[2])end
    return cords
end




return move