for i = 1, 10 do
    matproxy.Add( {
        name = "SFMProxyFloat"..i,
        init = function( self, mat, values )
            self.ResultTo = values.resultvar
        end,
        bind = function( self, mat, ent )
           if ( ent["SFMProxyFloat"..i] ) then
               mat:SetFloat( self.ResultTo, ent["SFMProxyFloat"..i] )
           end
       end 
    } )

    matproxy.Add( {
        name = "SFMProxyInt"..i,
        init = function( self, mat, values )
            self.ResultTo = values.resultvar
        end,
        bind = function( self, mat, ent )
           if ( ent["SFMProxyInt"..i] ) then
               mat:SetInt( self.ResultTo, ent["SFMProxyInt"..i] )
           end
       end 
    } )

    matproxy.Add( {
        name = "SFMProxyString"..i,
        init = function( self, mat, values )
            self.ResultTo = values.resultvar
        end,
        bind = function( self, mat, ent )
           if ( ent["SFMProxyString"..i] ) then
               mat:SetString( self.ResultTo, ent["SFMProxyString"..i] )
           end
       end 
    } )

    matproxy.Add( {
        name = "SFMProxyVector"..i,
        init = function( self, mat, values )
            self.ResultTo = values.resultvar
        end,
        bind = function( self, mat, ent )
           if ( ent["SFMProxyVector"..i] ) then
               mat:SetVector( self.ResultTo, ent["SFMProxyVector"..i] )
           end
       end 
    } )
end

return function(instance)

    local mtlunwrap = instance.Types.LockedMaterial.Unwrap
    local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
    local matproxy_library = instance.Libraries.matproxy
    local ent_meta, ewrap, eunwrap, ents_methods = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap, instance.Types.Entity.Methods

    --- Set an integer value for a material proxy from 1 to 10 on the entity
    --@param number num The proxy id to change. A number clamped from 1 to 10.
    --@param number value The new integer value to set. Will be rounded if it's a float.
    function ents_methods:setMatProxyInt(num, int)
        num = math.Clamp(num, 1, 10)
        eunwrap(self)["SFMProxyInt"..num] = math.Round(int)
    end

    --- Get an integer value from a material proxy.
    --@param number num The proxy id you want to get.
    --@return number The returned int or nil.
    function ents_methods:getMatProxyInt(num)
        return eunwrap(self)["SFMProxyInt"..num]
    end

    --- Set a float value for a material proxy from 1 to 10 on the entity
    --@param number num The proxy id to change. A number clamped from 1 to 10.
    --@param number value The new float value to set.
    function ents_methods:setMatProxyFloat(num, num2)
        num = math.Clamp(num, 1, 10)
        eunwrap(self)["SFMProxyFloat"..num] = num2
    end

    --- Get a float value from a material proxy.
    --@param number num The proxy id you want to get.
    --@return number The returned float or nil.
    function ents_methods:getMatProxyFloat(num)
        return eunwrap(self)["SFMProxyFloat"..num]
    end

    --- Set a vector value for a material proxy from 1 to 10 on the entity
    --@param number num The proxy id to change. A number clamped from 1 to 10.
    --@param Vector value The new vector value to set.
    function ents_methods:setMatProxyVector(num, vec)
        num = math.Clamp(num, 1, 10)
        eunwrap(self)["SFMProxyVector"..num] = vunwrap(vec)
    end

    --- Get a vector value from a material proxy.
    --@param number num The proxy id you want to get.
    --@return Vector The returned vector or nil.
    function ents_methods:getMatProxyVector(num)
        return vwrap(eunwrap(self)["SFMProxyVector"..num])
    end

    --- Set a string value for a material proxy from 1 to 10 on the entity
    --@param number num The proxy id to change. A number clamped from 1 to 10.
    --@param string value The new string value to set.
    function ents_methods:setMatProxyString(num, str)
        num = math.Clamp(num, 1, 10)
        eunwrap(self)["SFMProxyString"..num] = str
    end

    --- Get a string value from a material proxy.
    --@param number num The proxy id you want to get.
    --@return string The returned string or nil.
    function ents_methods:getMatProxyString(num)
        return eunwrap(self)["SFMProxyString"..num]
    end

end