function Class(name,  baseClass )

    local new_class = {}
    new_class.__index = new_class
    
    local new_class_mt = { __tostring = function() return name .. " Class" end, __call = function (c, ...)
            local newinst = {}
            
            if baseClass then
                newinst.super = {}
                local supermt = {}

                newinst.super.__stack = 1
                newinst.super.inst = newinst

                function supermt.__index(t, k)
                    local superclass = new_class
                    
                    for i = 1, t.__stack do
                        local s = superclass:getSuperClass()
                        local foundSuper = false
                        
                        if s then
                            if s[k] then
                                superclass = s
                                if i == t.__stack then
                                    t.__stack = t.__stack + 1
                                    break
                                end
                                foundSuper = true
                            end
                        end
                        assert(foundSuper, "Cannot find super class in current Class")
                    end
                    return function(s, ...) local r = superclass[k](s.inst, ...) ; s.__stack = s.__stack -1 return r end
                end

                setmetatable(newinst.super, supermt)
            end
    
            setmetatable( newinst, c )
            if newinst.init then newinst.init(newinst, ...) end
            return newinst
        end}

    if baseClass then
        new_class_mt.__index = baseClass
        
        local metaevents = {"__tostring","__len","__gc","__unm","__add","__sub","__mul","__div","__mod","__pow","__concat","__eq","__lt","__le"}
        for k, v in pairs(baseClass) do
            if type(v) == "function" then
                for _, event in pairs(metaevents) do
                    if k == event then
                        new_class[k] = v
                    end
                end
            end
        end
    end

    setmetatable( new_class, new_class_mt)

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:getClass()
        return new_class
    end

    function new_class:getSuperClass()
        return baseClass
    end

    function new_class:__tostring()
        return name
    end
            
    function new_class:getName(v)
        return name
    end
    
    function new_class:made( theInstance )
        if type( theInstance ) == "table" then
            if type(theInstance.typeOf) == "function" then
                return theInstance:typeOf(self)
            end
        end
    end
    
    -- Return true if the caller is an instance of theClass
    function new_class:typeOf( theClass )
        local is_a = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == is_a ) do
            if cur_class == theClass then
                is_a = true
            else
                cur_class = cur_class:getSuperClass()
            end
        end

        return is_a
    end

    return new_class
end