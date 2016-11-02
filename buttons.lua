local buttons = {}
buttons.font = love.graphics.newFont( "saxmono.ttf", 14)

function buttons:add(text,x,y,w,h,func)
    w = w or 6 + 8*text:len()
    self[#self + 1] = {text,x,y,w,h,func}
end
function buttons:update()
    local mx, my = love.mouse.getPosition()
    for i = 1, #self do
        if mx >= self[i][2] and mx <= self[i][2]+self[i][4] and my >= self[i][3] and my <= self[i][3]+self[i][5] then
            self[i][6]()
        end  
    end
end
function buttons:draw()
    love.graphics.setFont(self.font)
    for i = 1, #self do
        local x = self[i][2]+0.5
        local y = self[i][3]-0.5
        local text = self[i][1]
        local h = self[i][5]+1
        local w = self[i][4]-1
        love.graphics.setColor(150,150,150)
        love.graphics.rectangle('fill',x,y,w,h)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',x,y,w,h)
        love.graphics.setColor(0,0,0)
        love.graphics.printf(text,x-0.5,y+8.5,w,"center")
    end
end
function buttons.width(text)
    return 6 + 8*text:len()
end
return buttons