-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

--- Panel type
-- @name Panel
-- @class type
-- @libtbl pnl_methods
-- @libtbl pnl_meta
SF.RegisterType("Panel", false, true, debug.getregistry().Panel)

--- DPanel type
-- @name DPanel
-- @class type
-- @libtbl dpnl_methods
-- @libtbl dpnl_meta
SF.RegisterType("DPanel", false, true, debug.getregistry().DPanel, "Panel")

--- DFrame type
-- @name DFrame
-- @class type
-- @libtbl dfrm_methods
-- @libtbl dfrm_meta
SF.RegisterType("DFrame", false, true, debug.getregistry().DFrame, "Panel")

--- DScrollPanel type
-- @name DScrollPanel
-- @class type
-- @libtbl dscrl_methods
-- @libtbl dscrl_meta
SF.RegisterType("DScrollPanel", false, true, debug.getregistry().DScrollPanel, "Panel")

--- DLabel type
-- @name DLabel
-- @class type
-- @libtbl dlab_methods
-- @libtbl dlab_meta
SF.RegisterType("DLabel", false, true, debug.getregistry().DLabel, "Panel")

--- DButton type
-- @name DButton
-- @class type
-- @libtbl dbut_methods
-- @libtbl dbut_meta
SF.RegisterType("DButton", false, true, debug.getregistry().DButton, "DLabel")

--- VGUI functions.
-- @name vgui
-- @class library
-- @libtbl vgui_library
SF.RegisterLibrary("vgui")

return function(instance)

local panels

instance:AddHook("initialize", function()
	panels = {}
end)

instance:AddHook("deinitialize", function()
	for _, panel in pairs(panels) do
		panel:Remove()
	end
end)

local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local pnl_methods, pnl_meta, pnlwrap, pnlunwrap = instance.Types.Panel.Methods, instance.Types.Panel, instance.Types.Panel.Wrap, instance.Types.Panel.Unwrap
local dpnl_methods, dpnl_meta, dpnlwrap, dpnlunwrap = instance.Types.DPanel.Methods, instance.Types.DPanel, instance.Types.DPanel.Wrap, instance.Types.DPanel.Unwrap
local dfrm_methods, dfrm_meta, dfrmwrap, dfrmunwrap = instance.Types.DFrame.Methods, instance.Types.DFrame, instance.Types.DFrame.Wrap, instance.Types.DFrame.Unwrap
local dscrl_methods, dscrl_meta, dscrlwrap, dscrlunwrap = instance.Types.DScrollPanel.Methods, instance.Types.DScrollPanel, instance.Types.DScrollPanel.Wrap, instance.Types.DScrollPanel.Unwrap
local dlab_methods, dlab_meta, dlabwrap, dlabunwrap = instance.Types.DLabel.Methods, instance.Types.DLabel, instance.Types.DLabel.Wrap, instance.Types.DLabel.Unwrap
local dbut_methods, dbut_meta, dbutwrap, dbutunwrap = instance.Types.DButton.Methods, instance.Types.DButton, instance.Types.DButton.Wrap, instance.Types.DButton.Unwrap
local vgui_library = instance.Libraries.vgui

function pnl_meta:__tostring()
	return "Panel"
end

function dpnl_meta:__tostring()
	return "DPanel"
end

function dfrm_meta:__tostring()
	return "DFrame"
end

function dscrl_meta:__tostring()
	return "DScrollPanel"
end

--- Sets the position of the panel's top left corner.
--@param number x The x coordinate of the position.
--@param number y The y coordinate of the position.
function pnl_methods:setPos(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:SetPos(x, y)
end

--- Returns the position of the panel relative to its Panel:getParent.
--@return number X coordinate, relative to this panels parents top left corner.
--@return number Y coordinate, relative to this panels parents top left corner.
function pnl_methods:getPos()
	local uwp = pnlunwrap(self)
	
	return uwp:GetPos()
end

--- Sets the size of the panel.
--@param number x Width of the panel.
--@param number y Height of the panel.
function pnl_methods:setSize(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:SetSize(x, y)
end

--- Returns the size of the panel.
--@return number width
--@return number height
function pnl_methods:getSize()
	local uwp = pnlunwrap(self)
	
	return uwp:GetSize()
end

--- Sets the text value of a panel object containing text, such as DLabel, DTextEntry or DButton.
--@param string text The text value to set.
function pnl_methods:setText(text)
	checkluatype(text, TYPE_STRING)
	local uwp = pnlunwrap(self)
	
	uwp:SetText(text)
end

--- Focuses the panel and enables it to receive input.
function pnl_methods:makePopup()
	local uwp = pnlunwrap(self)
	
	uwp:MakePopup()
end

--- Centers the panel.
function pnl_methods:center()
	local uwp = pnlunwrap(self)
	
	uwp:Center()
end

--- Removes the panel and all its children.
function pnl_methods:remove()
	local uwp = pnlunwrap(self)
	
	uwp:Remove()
end

--- Sets the alpha multiplier for the panel
--@param number alpha The alpha value in the range of 0-255.
function pnl_methods:setAlpha(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:SetAlpha(val)
end

--- Sets the dock type for the panel, making the panel "dock" in a certain direction, modifying it's position and size.
--@param number Dock type using https://wiki.facepunch.com/gmod/Enums/DOCK.
function pnl_methods:dock(enum)
	checkluatype(enum, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:Dock(enum)
end

--- Sets the dock margin of the panel.
--- The dock margin is the extra space that will be left around the edge when this element is docked inside its parent element.
--@param number left The left margin.
--@param number top The top margin.
--@param number right The right margin.
--@param number botton The bottom margin.
function pnl_methods:dockMargin(left, top , right, bottom)
	checkluatype(left, TYPE_NUMBER)
	checkluatype(right, TYPE_NUMBER)
	checkluatype(top, TYPE_NUMBER)
	checkluatype(bottom, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:DockMargin(left, top, right, bottom)
end

--- Sets the dock padding of the panel.
--- The dock padding is the extra space that will be left around the edge when child elements are docked inside this element.
--@param number left The left padding.
--@param number top The top padding.
--@param number right The right padding.
--@param number botton The bottom padding.
function pnl_methods:dockPadding(left, top , right, bottom)
	checkluatype(left, TYPE_NUMBER)
	checkluatype(right, TYPE_NUMBER)
	checkluatype(top, TYPE_NUMBER)
	checkluatype(bottom, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:DockPadding(left, top, right, bottom)
end

--- Aligns the panel on the top of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignTop(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:AlignTop(off)
end

--- Aligns the panel on the left of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignLeft(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:AlignLeft(off)
end

--- Aligns the panel on the right of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignRight(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:AlignRight(off)
end

--- Aligns the panel on the bottom of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignBottom(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:AlignBottom(off)
end

--- Translates global screen coordinate to coordinates relative to the panel.
--@param number screenX The x coordinate of the screen position to be translated.
--@param number screenY The y coordinate of the screen position to be translated.
--@return number Relative position X
--@return number Relative position Y
function pnl_methods:screenToLocal(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	return uwp:ScreenToLocal(x, y)
end

--- Gets the absolute screen position of the position specified relative to the panel.
--@param number posX The X coordinate of the position on the panel to translate.
--@param number posY The Y coordinate of the position on the panel to translate.
--@return number The X coordinate relative to the screen.
--@return number The Y coordinate relative to the screen.
function pnl_methods:localToScreen(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	return uwp:LocalToScreen(x, y)
end

--- Creates a DFrame. The DFrame is the momma of basically all VGUI elements. 98% of the time you will parent your element to this.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DFrame The new DFrame
function vgui_library.createDFrame(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DFrame", parent, name)
	if !parent then table.insert(panels, new) end -- Only insert parent panels as they will have all their children removed anyway.
	return dfrmwrap(new)
end

--- Sets a callback function to run when the frame is closed. This applies when the close button in the DFrame's control box is clicked. 
--- This is not called when the DFrame is removed with Panel:remove, see PANEL:onRemove for that.
--@param function callback The function to run when the frame is closed. Has one argument which is the frame itself.
function dfrm_methods:onClose(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dfrmunwrap(self)
	
	uwp.OnClose = function() instance:runFunction(func, self) end
end

--- Centers the frame relative to the whole screen and invalidates its layout.
function dfrm_methods:center()
	local uwp = dfrmunwrap(self)
	
	uwp:Center()
end

--- Sets whether the frame should be draggable by the user. The DFrame can only be dragged from its title bar.
--@param boolean draggable Whether to be draggable or not.
function dfrm_methods:setDraggable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:SetDraggable(enable)
end

--- Gets whether the frame can be dragged by the user.
--@return boolean Whether the frame is draggable.
function dfrm_methods:getDraggable()
	local uwp = pnlunwrap(self)
	
	return uwp:GetDraggable()
end

--- Sets the title of the frame.
--@param string title New title of the frame.
function dfrm_methods:setTitle(val)
	checkluatype(val, TYPE_STRING)
	local uwp = pnlunwrap(self)
	
	uwp:SetTitle(val)
end

--- Gets the title of the frame.
--@return string The title of the frame.
function dfrm_methods:getTitle()
	local uwp = pnlunwrap(self)
	
	return uwp:GetTitle(val)
end

--- Determines if the frame or one of its children has the screen focus.
--@return boolean Whether or not the frame has focus.
function dfrm_methods:isActive()
	local uwp = pnlunwrap(self)
	
	return uwp:IsActive()
end

--- Sets whether or not the DFrame can be resized by the user.
--- This is achieved by clicking and dragging in the bottom right corner of the frame.
--- You can set the minimum size using DFrame:setMinWidth and DFrame:setMinHeight.
--@param boolean sizable Whether the frame should be resizeable or not.
function dfrm_methods:setSizable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:SetSizable(enable)
end

--- Gets whether the DFrame can be resized by the user.
--@return boolean Whether the DFrame can be resized.
function dfrm_methods:setSizable()
	local uwp = pnlunwrap(self)
	
	return uwp:GetSizable()
end

--- Sets the minimum width the DFrame can be resized to by the user.
--@param number minwidth The minimum width the user can resize the frame to.
function dfrm_methods:setMinWidth(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:SetMinWidth(val)
end

--- Gets the minimum width the DFrame can be resized to by the user.
--@return number The minimum width.
function dfrm_methods:getMinWidth()
	local uwp = pnlunwrap(self)
	
	return uwp:GetMinWidth()
end

--- Sets the minimum height the DFrame can be resized to by the user.
--@param number minheight The minimum height the user can resize the frame to.
function dfrm_methods:setMinHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	
	uwp:SetMinHeight(val)
end

--- Gets the minimum height the DFrame can be resized to by the user.
--@return number The minimum height.
function dfrm_methods:getMinHeight()
	local uwp = pnlunwrap(self)
	
	return uwp:GetMinHeight()
end

--- Sets whether the DFrame is restricted to the boundaries of the screen resolution.
--@param boolean locked If true, the frame cannot be dragged outside of the screen bounds.
function dfrm_methods:setScreenLock(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:SetScreenLock(enable)
end

--- Adds or removes an icon on the left of the DFrame's title.
--@param string iconpath Set to nil to remove the icon. Otherwise, set to file path to create the icon.
function dfrm_methods:setIcon(path)
	checkluatype(path, TYPE_STRING)
	local uwp = pnlunwrap(self)
	
	uwp:SetIcon(path)
end

--- Blurs background behind the frame.
--@param boolean blur Whether or not to create background blur or not.
function dfrm_methods:setBackgroundBlur(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:SetBackgroundBlur(enable)
end

--- Returns whether the background is being blurred by DFrame:setBackGroundBlur.
--@return boolean Whether the background is blurred.
function dfrm_methods:setBackgroundBlur()
	local uwp = pnlunwrap(self)
	
	return uwp:GetBackgroundBlur()
end

--- Determines whether the DFrame's control box (close, minimise and maximise buttons) is displayed.
--@param boolean show false hides the control box; this is true by default.
function dfrm_methods:showCloseButton(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:ShowCloseButton(enable)
end

--- Gets whether or not the shadow effect bordering the DFrame is being drawn.
--@return boolean Whether or not the shadow is being drawn.
function dfrm_methods:getPaintShadow()
	local uwp = pnlunwrap(self)
	
	return uwp:GetPaintShadow()
end

--- Sets whether or not the shadow effect bordering the DFrame should be drawn.
--@param boolean draw Whether or not to draw the shadow. This is true by default.
function dfrm_methods:setPaintShadow(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)
	
	uwp:SetPaintShadow(enable)
end

--- Creates a DScrollPanel. DScrollPanel is a VGUI Element similar to DPanel however it has a vertical scrollbar docked to the right which can be used to put more content in a smaller area.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DScrollPanel The new DScrollPanel
function vgui_library.createDScrollPanel(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DScrollPanel", parent, name)
	if !parent then table.insert(panels, new) end
	return dscrlwrap(new)
end

--- Returns the canvas ( The panel all child panels are parented to ) of the DScrollPanel.
--@return Panel The canvas.
function dscrl_methods:getCanvas()
	local uwp = dscrlunwrap(self)
	
	return pnlwrap(uwp:GetCanvas())
end

--- Clears the DScrollPanel's canvas, removing all added items.
function dscrl_methods:clear()
	local uwp = dscrlunwrap(self)
	
	uwp:Clear()
end

--- Creates a DLabel. A standard Derma text label. A lot of this panels functionality is a base for button elements, such as DButton.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DLabel The new DLabel.
function vgui_library.createDLabel(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DLabel", parent, name)
	if !parent then table.insert(panels, new) end
	return dlabwrap(new)
end

--- Called when the label is left clicked (on key release) by the player.
--- This will be called after DLabel:OnDepressed and DLabel:OnReleased.
--- This can be overridden; by default, it calls DLabel:Toggle.
--- See also DLabel:DoRightClick, DLabel:DoMiddleClick and DLabel:DoDoubleClick.
--@param function callback The function to run when the label is pressed. Has one argument which is the DLabel itself.
function dlab_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)
	
	uwp.DoClick = function() instance:runFunction(func, self) end
end

--- Creates a DButton. A standard Derma text label. A lot of this panels functionality is a base for button elements, such as DButton.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DButton The new DButton.
function vgui_library.createDButton(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DButton", parent, name)
	if !parent then table.insert(panels, new) end
	return dbutwrap(new)
end

--- Called when the button is left clicked (on key release) by the player. This will be called after DButton:isDown.
--@param function callback The function to run when the button is pressed. Has one argument which is the Button itself.
function dbut_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dbutunwrap(self)
	
	uwp.DoClick = function() instance:runFunction(func, self) end
end

end