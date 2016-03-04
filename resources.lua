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

local colors = {
    {200, 152, 160},
    {160, 200, 152},
    {152, 160, 200}
}

return {
    images = images,
    colors = colors
}
