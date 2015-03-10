World = Class("World")

function World:init()
    self.StaticPolygons = {}
    self.Width = 640
    self.Height = 480
end

function World:getWidth()
    return self.Width
end

function World:setWidth( newValue )
    self.Width = newValue
end

function World:getHeight()
    return self.Height
end

function World:setHeight( newValue )
    self.Height = newValue
end

function World:getStaticPolygons()
    return self.StaticPolygons
end

function World:getBackgroundImage()
    return self.BackgroundImage
end

function World:setBackgroundImage( newValue )
    self.BackgroundImage = newValue
end