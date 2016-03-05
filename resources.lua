local images = {
    cup = "cup.png",
    ball = "ball.png",
    question = "question.png",
    correct = "correct.png",
    incorrect = "incorrect.png"
}

for k, v in pairs(images) do
    images[k] = love.graphics.newImage("images/"..v, {mipmaps = true})
    images[k]:setMipmapFilter("linear", 1)
end

local fonts = {
    main = love.graphics.newFont("fonts/PTS75F.ttf", 20)
}

local colors = {
    {200, 152, 160},
    {160, 200, 152},
    {152, 160, 200},

    background = {251, 247, 233},
    text1 = {162, 155, 130},
    text2 = {139, 131, 103}
}

return {
    images = images,
    fonts = fonts,
    colors = colors
}
