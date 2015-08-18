local images = {
    cup = "cup.png"
}

for k, v in pairs(images) do
    images[k] = love.graphics.newImage("images/"..v)
    images[k]:setMipmapFilter("linear")
end

return {
    images = images
}
