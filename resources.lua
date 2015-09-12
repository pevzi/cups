local images = {
    cup = "cup.png",
    ball = "ball.png"
}

for k, v in pairs(images) do
    images[k] = love.graphics.newImage("images/"..v)
    images[k]:setMipmapFilter("linear", 1)
end

local colors = {
    red = {200, 152, 160},
    green = {160, 200, 152},
    blue = {152, 160, 200}
}

return {
    images = images,
    colors = colors
}
