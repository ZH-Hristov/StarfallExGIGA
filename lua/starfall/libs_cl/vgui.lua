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
SF.RegisterType("DScrollPanel", false, true, debug.getregistry().DScrollPanel, "DPanel")

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

--- AvatarImage type
-- @name AvatarImage
-- @class type
-- @libtbl aimg_methods
-- @libtbl aimg_meta
SF.RegisterType("AvatarImage", false, true, debug.getregistry().AvatarImage, "Panel")

--- DProgress type
-- @name DProgress
-- @class type
-- @libtbl dprg_methods
-- @libtbl dprg_meta
SF.RegisterType("DProgress", false, true, debug.getregistry().DProgress, "Panel")

--- DTextEntry type
-- @name DTextEntry
-- @class type
-- @libtbl dtxe_methods
-- @libtbl dtxe_meta
SF.RegisterType("DTextEntry", false, true, debug.getregistry().DTextEntry, "Panel")

--- DImage type
-- @name DImage
-- @class type
-- @libtbl dimg_methods
-- @libtbl dimg_meta
SF.RegisterType("DImage", false, true, debug.getregistry().DImage, "DPanel")

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
	for panel, _ in pairs(panels) do
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
local aimg_methods, aimg_meta, aimgwrap, aimgunwrap = instance.Types.AvatarImage.Methods, instance.Types.AvatarImage, instance.Types.AvatarImage.Wrap, instance.Types.AvatarImage.Unwrap
local dprg_methods, dprg_meta, dprgwrap, dprgunwrap = instance.Types.DProgress.Methods, instance.Types.DProgress, instance.Types.DProgress.Wrap, instance.Types.DProgress.Unwrap
local dtxe_methods, dtxe_meta, dtxewrap, dtxeunwrap = instance.Types.DTextEntry.Methods, instance.Types.DTextEntry, instance.Types.DTextEntry.Wrap, instance.Types.DTextEntry.Unwrap
local dimg_methods, dimg_meta, dimgwrap, dimgunwrap = instance.Types.DImage.Methods, instance.Types.DImage, instance.Types.DImage.Wrap, instance.Types.DImage.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local plyunwrap = instance.Types.Player.Unwrap
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

function dbut_meta:__tostring()
	return "DButton"
end

function aimg_meta:__tostring()
	return "AvatarImage"
end

function dprg_meta:__tostring()
	return "DProgress"
end

function dtxe_meta:__tostring()
	return "DTextEntry"
end

function dimg_meta:__tostring()
	return "DImage"
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

--- Returns the value the panel holds.
--- In engine is only implemented for CheckButton, Label and TextEntry as a string.
--@param any The value the panel holds.
function pnl_methods:getValue()
	local uwp = pnlunwrap(self)

	return uwp:GetValue()
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

--- Sets the height of the panel.
--@param number newHeight The height to be set.
function pnl_methods:setHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = pnlunwrap(self)

	uwp:SetHeight(val)
end

--- Gets the height of the panel.
--@return number The height of the panel.
function pnl_methods:getHeight()
	local uwp = pnlunwrap(self)

	return uwp:GetTall()
end

--- Sets the width of the panel.
--@param number newWidth The width to be set.
function pnl_methods:setWidth(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = pnlunwrap(self)

	uwp:SetWidth(val)
end

--- Gets the width of the panel.
--@return number The width of the panel.
function pnl_methods:getWidth()
	local uwp = pnlunwrap(self)

	return uwp:GetWide()
end

--- Sets the text value of a panel object containing text, such as DLabel, DTextEntry or DButton.
--@param string text The text value to set.
function pnl_methods:setText(text)
	checkluatype(text, TYPE_STRING)
	local uwp = pnlunwrap(self)
	
	uwp:SetText(text)
end

--- Sets the tooltip to be displayed when a player hovers over the panel object with their cursor.
--@param string text The text to be displayed in the tooltip.
function pnl_methods:setTooltip(text)
	checkluatype(text, TYPE_STRING)
	local uwp = pnlunwrap(self)

	uwp:SetTooltip(text)
end

--- Removes the tooltip on the panel set with Panel:setTooltip
function pnl_methods:unsetTooltip()
	local uwp = pnlunwrap(self)

	uwp:SetTooltip(false)
end

--- Sets the panel to be displayed as contents of a DTooltip when a player hovers over the panel object with their cursor.
--@param Panel The panel to use as the tooltip.
function pnl_methods:setTooltipPanel(setPnl)
	local uwp = pnlunwrap(self)
	local uwsp = pnlunwrap(setPnl)

	uwp:SetTooltipPanel(uwsp)
end

--- Removes the tooltip panel set on this panel with Panel:setTooltipPanel
function pnl_methods:unsetTooltipPanel()
	local uwp = pnlunwrap(self)

	uwp:SetTooltipPanel(nil)
end

--- Sets whether text wrapping should be enabled or disabled on Label and DLabel panels. 
--- Use DLabel:setAutoStretchVertical to automatically correct vertical size; Panel:sizeToContents will not set the correct height.
--@param boolean wrap True to enable text wrapping, false otherwise.
function pnl_methods:setWrap(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)

	uwp:SetWrap(enable)
end

--- Resizes the panel object's width so that its right edge is aligned with the left of the passed panel. 
--- An offset greater than zero will reduce the panel's width to leave a gap between it and the passed panel.
--@param Panel targetPanel The panel to align the bottom of this one with.
--@param number offset The gap to leave between this and the passed panel. Negative values will cause the panel's height to increase, forming an overlap.
function pnl_methods:stretchRightTo(target, off)
	local uwp = pnlunwrap(self)
	local uwtp = pnlunwrap(target)

	uwp:StretchRightTo(uwtp, off)
end

--- Resizes the panel object's height so that its bottom is aligned with the top of the passed panel. 
--- An offset greater than zero will reduce the panel's height to leave a gap between it and the passed panel.
--@param Panel targetPanel The panel to align the bottom of this one with.
--@param number offset The gap to leave between this and the passed panel. Negative values will cause the panel's height to increase, forming an overlap.
function pnl_methods:stretchBottomTo(target, off)
	local uwp = pnlunwrap(self)
	local uwtp = pnlunwrap(target)

	uwp:StretchBottomTo(uwtp, off)
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
	
	panels[uwp] = nil
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

--- Returns the internal name of the panel. Can be set via Panel:setName.
--@return string The internal name of the panel.
function pnl_methods:getName()
	local uwp = pnlunwrap(self)

	return uwp:GetName()
end

--- Sets the internal name of the panel. Can be retrieved with Panel:getName.
--@param string newname New internal name for the panel.
function pnl_methods:setName(val)
	checkluatype(val, TYPE_STRING)
	local uwp = pnlunwrap(self)

	uwp:SetName(val)
end

--- Sets the enabled state of a disable-able panel object, such as a DButton or DTextEntry.
--- See Panel:isEnabled for a function that retrieves the "enabled" state of a panel.
--@param boolean enabled Whether to enable or disable the panel object.
function pnl_methods:setEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = pnlunwrap(self)

	uwp:SetEnabled(enable)
end

--- Returns whether the the panel is enabled or disabled.
--- See Panel:setEnabled for a function that makes the panel enabled or disabled.
--@return boolean Whether the panel is enabled or disabled.
function pnl_methods:isEnabled()
	local uwp = pnlunwrap(self)

	return uwp:IsEnabled()
end

--- Resizes the panel to fit the bounds of its children.
--- The sizeW and sizeH parameters are false by default. Therefore, calling this function with no arguments will result in a no-op.
--@param boolean sizeW Resize with width of the panel.
--@param boolean sizeH Resize the height of the panel.
function pnl_methods:sizeToChildren(w, h)
	checkluatype(w, TYPE_BOOL)
	checkluatype(h, TYPE_BOOL)	
	local uwp = pnlunwrap(self)

	uwp:SizeToChildren(w, h)
	uwp:InvalidateLayout()
end

--- Resizes the panel so that its width and height fit all of the content inside.
--- Only works on Label derived panels such as DLabel by default, and on any panel that manually implemented the Panel:SizeToContents method, such as DNumberWang and DImage.
function pnl_methods:sizeToContents()
	local uwp = pnlunwrap(self)

	uwp:SizeToContents()
end

--- Resizes the panel object's width to accommodate all child objects/contents.
--- Only works on Label derived panels such as DLabel.
--- You must call this function AFTER setting text/font or adjusting child panels.
--@param number addValue The number of extra pixels to add to the width. Can be a negative number, to reduce the width.
function pnl_methods:sizeToContentsX(addVal)
	checkluatype(addVal, TYPE_NUMBER)
	local uwp = pnlunwrap(self)

	uwp:SizeToContentsX(addVal)
end

--- Resizes the panel object's height to accommodate all child objects/contents.
--- Only works on Label derived panels such as DLabel.
--- You must call this function AFTER setting text/font or adjusting child panels.
--@param number addValue The number of extra pixels to add to the height. Can be a negative number, to reduce the height.
function pnl_methods:sizeToContentsY(addVal)
	checkluatype(addVal, TYPE_NUMBER)
	local uwp = pnlunwrap(self)

	uwp:SizeToContentsY(addVal)
end

--- Creates a DPanel. A simple rectangular box, commonly used for parenting other elements to. Pretty much all elements are based on this. Inherits from Panel
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DPanel The new DPanel
function vgui_library.createDPanel(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DPanel", parent, name)
	if !parent then panels[new] = true end -- Only insert parent panels as they will have all their children removed anyway.
	return dpnlwrap(new)
end

--- Sets the background color of the panel.
--@param Color bgcolor The background color.
function dpnl_methods:setBackgroundColor(clr)
	local uwp = dpnlunwrap(self)
	local uwc = cunwrap(clr)

	uwp:SetBackgroundColor(uwc)
end

--- Gets the background color of the panel.
--@return Color Background color of the panel.
function dpnl_methods:getBackgroundColor()
	local uwp = dpnlunwrap(self)

	return cwrap(uwp:GetBackgroundColor())
end

--- Sets whether or not to paint/draw the panel background.
--@param boolean paint True to show the panel's background, false to hide it.
function dpnl_methods:setPaintBackground(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dpnlunwrap(self)

	uwp:SetPaintBackground(enable)
end

--- Returns whether or not the panel background is being drawn.
--@return boolean True if the panel background is drawn, false otherwise.
function dpnl_methods:getPaintBackground()
	local uwp = dpnlunwrap(self)

	return uwp:getPaintBackground()
end

--- Sets whether or not to disable the panel.
--@param boolean disable True to disable the panel (mouse input disabled and background alpha set to 75), false to enable it (mouse input enabled and background alpha set to 255).
function dpnl_methods:setDisabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dpnlunwrap(self)

	uwp:SetDisabled(enable)
end

--- Returns whether or not the panel is disabled.
--@return boolean True if the panel is disabled (mouse input disabled and background alpha set to 75), false if its enabled (mouse input enabled and background alpha set to 255).
function dpnl_methods:getDisabled()
	local uwp = dpnlunwrap(self)

	return uwp:getDisabled()
end

--- Creates a DFrame. The DFrame is the momma of basically all VGUI elements. 98% of the time you will parent your element to this.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DFrame The new DFrame
function vgui_library.createDFrame(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DFrame", parent, name)
	if !parent then panels[new] = true end
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
	if !parent then panels[new] = true end
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
	if !parent then panels[new] = true end
	return dlabwrap(new)
end

--- Called when the label is left clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--- This can be overridden; by default, it calls DLabel:toggle.
--@param function callback The function to run when the label is pressed. Has one argument which is the DLabel itself.
function dlab_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)
	
	uwp.DoClick = function() instance:runFunction(func, self) end
end

--- Called when the label is double clicked by the player with left clicks.
--- DLabel:setDoubleClickingEnabled must be set to true for this hook to work, which it is by default.
--- This will be called after DLabel:onDepressed and DLabel:onReleased and DLabel:onClick.
--@param function callback The function to run when the label is double clicked. Has one argument which is the DLabel itself.
function dlab_methods:onDoubleClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.DoDoubleClick = function() instance:runFunction(func, self) end
end

--- Sets whether or not double clicking should call DLabel:DoDoubleClick.
--- This is enabled by default.
--@param boolean enabled True to enable, false to disable.
function dlab_methods:setDoubleClickingEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetDoubleClickingEnabled(enable)
end

--- Returns whether or not double clicking will call DLabel:onDoubleClick.
--@return boolean Whether double clicking functionality is enabled.
function dlab_methods:getDoubleClickingEnabled()
	local uwp = dlabunwrap(self)

	return uwp:GetDoubleClickingEnabled()
end

--- Called when the label is right clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--@param function callback The function to run when the label is right clicked. Has one argument which is the DLabel itself.
function dlab_methods:onRightClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.DoRightClick = function() instance:runFunction(func, self) end
end

--- Called when the label is middle clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--@param function callback The function to run when the label is middle clicked. Has one argument which is the DLabel itself.
function dlab_methods:onMiddleClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.DoMiddleClick = function() instance:runFunction(func, self) end
end

--- Called when the player presses the label with any mouse button.
--@param function callback The function to run when the label is pressed. Has one argument which is the DLabel itself.
function dlab_methods:onDepressed(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.OnDepressed = function() instance:runFunction(func, self) end
end

--- Called when the player releases any mouse button on the label. This is always called after DLabel:onDepressed.
--@param function callback The function to run when the label is released. Has one argument which is the DLabel itself.
function dlab_methods:onReleased(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.OnReleased = function() instance:runFunction(func, self) end
end

--- Called when the toggle state of the label is changed by DLabel:Toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@param function callback The function to run when the label is toggled. Has 2 arguments: the DLabel itself and the state of the toggled button.
function dlab_methods:onToggled(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	uwp.OnReleased = function(toggleState) instance:runFunction(func, self, toggleState) end
end

--- Enables or disables toggle functionality for a label. Retrieved with DLabel:getIsToggle.
--- You must call this before using DLabel:setToggle, DLabel:getToggle or DLabel:toggle.
--@param boolean enable Whether or not to enable toggle functionality.
function dlab_methods:setIsToggle(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetIsToggle(enable)
end

--- Returns whether the toggle functionality is enabled for a label. Set with DLabel:setIsToggle.
--@return boolean Whether toggle functionality is enabled.
function dlab_methods:getIsToggle()
	local uwp = dlabunwrap(self)

	return uwp:GetIsToggle()
end

--- Toggles the label's state. This can be set and retrieved with DLabel:SetToggle and DLabel:GetToggle.
---In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
function dlab_methods:toggle()
	local uwp = dlabunwrap()

	uwp:Toggle()
end

--- Sets the toggle state of the label. This can be retrieved with DLabel:getToggle and toggled with DLabel:toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@param boolean newState The new state of the toggle.
function dlab_methods:setToggle(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetToggle(enable)
end

--- Returns the current toggle state of the label. This can be set with DLabel:setToggle and toggled with DLabel:toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@return boolean The state of the toggleable label.
function dlab_methods:getToggle()
	local uwp = dlabunwrap(self)

	return uwp:GetToggle()
end

--- Sets the font in the DLabel.
--@param string fontName The name of the font. Check render.setFont for a list of default fonts.
function dlab_methods:setFont(fontName)
	checkluatype(fontName, TYPE_STRING)
	local uwp = dlabunwrap(self)

	uwp:SetFont(fontName)
end

--- Gets the font in the DLabel.
--@return string The font name.
function dlab_methods:getFont()
	local uwp = dlabunwrap(self)

	return uwp:GetFont()
end

--- Sets the text color of the DLabel.
--@param Color textColor The text color.
function dlab_methods:setTextColor(clr)
	local uwp = dlabunwrap(self)

	uwp:SetTextColor(cunwrap(clr))
end

--- Returns the "override" text color, set by DLabel:setTextColor.
--@return Color The color of the text, or nil.
function dlab_methods:getTextColor()
	local uwp = dlabunwrap(self)

	return cwrap(uwp:GetTextColor())
end

--- Automatically adjusts the height of the label dependent of the height of the text inside of it.
--@param boolean stretch Whether to stretch the label vertically or not.
function dlab_methods:setAutoStretchVertical(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetAutoStretchVertical(enable)
end

--- Gets whether the label will automatically adjust its height based on the height of the text inside of it.
--@return boolean Whether the label stretches vertically or not.
function dlab_methods:getAutoStretchVertical()
	local uwp = dlabunwrap(self)

	return uwp:GetAutoStretchVertical()
end

--- Creates a DButton. Inherits functions from DLabel.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DButton The new DButton.
function vgui_library.createDButton(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DButton", parent, name)
	if !parent then panels[new] = true end
	return dbutwrap(new)
end

--- Called when the button is left clicked (on key release) by the player. This will be called after DButton:isDown.
--@param function callback The function to run when the button is pressed. Has one argument which is the Button itself.
function dbut_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dbutunwrap(self)
	
	uwp.DoClick = function() instance:runFunction(func, self) end
end

--- Sets an image to be displayed as the button's background.
--@param string imagePath The image file to use, relative to /materials. If this is nil, the image background is removed.
function dbut_methods:setImage(image)
	checkluatype(image, TYPE_STRING)
	local uwp = dbutunwrap(self)

	uwp:SetImage(image)
end

--- Returns true if the DButton is currently depressed (a user is clicking on it).
--@return boolean Whether or not the button is depressed.
function dbut_methods:isDown()
	local uwp = dbutunwrap(self)

	return uwp:IsDown()
end

--- Creates an AvatarImage. Inherits functions from Panel.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return AvatarImage The new AvatarImage.
function vgui_library.createAvatarImage(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("AvatarImage", parent, name)
	if !parent then panels[new] = true end
	return aimgwrap(new)
end

--- Sets the image to the specified player's avatar.
--@param Player player The player to use avatar of.
--@param number size The resolution size of the avatar to use. Acceptable sizes are 32, 64, 184.
function aimg_methods:setPlayer(ply, size)
	checkluatype(size, TYPE_NUMBER)
	local uwp = pnlunwrap(self)
	local uwply = plyunwrap(ply)

	uwp:SetPlayer(uwply, size)
end

--- Sets the image to the specified user's avatar using 64-bit SteamID.
--@param string steamid The 64bit SteamID of the player to load avatar of.
--@param number size The resolution size of the avatar to use. Acceptable sizes are 32, 64, 184.
function aimg_methods:setSteamID(steamid, size)
	checkluatype(size, TYPE_NUMBER)
	checkluatype(steamid, TYPE_STRING)
	local uwp = pnlunwrap(self)

	uwp:SetSteamID(steamid, size)
end

--- Creates a DProgress. A progressbar, works with a fraction between 0 and 1 where 0 is 0% and 1 is 100%. Inherits functions from Panel.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DProgress The new DProgress.
function vgui_library.createDProgress(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DProgress", parent, name)
	if !parent then panels[new] = true end
	return dprgwrap(new)
end

--- Sets the fraction of the progress bar. 0 is 0% and 1 is 100%.
--@param number fraction Fraction of the progress bar. Range is 0 to 1 (0% to 100%).
function dprg_methods:setFraction(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dprgunwrap(self)

	uwp:SetFraction(val)
end

--- Returns the progress bar's fraction. 0 is 0% and 1 is 100%.
--@return number Current fraction of the progress bar.
function dprg_methods:getFraction()
	local uwp = dprgunwrap(self)

	return uwp:GetFraction()
end

--- Creates a DTextEntry. A form which may be used to display text the player is meant to select and copy or alternately allow them to enter some text of their own. Inherits functions from Panel.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DTextEntry The new DTextEntry.
function vgui_library.createDTextEntry(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DTextEntry", parent, name)
	if !parent then panels[new] = true end
	return dtxewrap(new)
end

--- Sets the placeholder text that will be shown while the text entry has no user text. The player will not need to delete the placeholder text if they decide to start typing.
--@param string placeholder The placeholder text.
function dtxe_methods:setPlaceholderText(text)
	checkluatype(text, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetPlaceholderText(text)
end

--- Gets the DTextEntry's placeholder text.
--@return string The placeholder text.
function dtxe_methods:getPlaceholderText()
	local uwp = dtxeunwrap(self)

	return uwp:GetPlaceholderText()
end

--- Allow you to set placeholder color.
--@param Color placeholderColor The color of the placeholder.
function dtxe_methods:setPlaceholderColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetPlaceholderColor(cunwrap(clr))
end

--- Returns the placeholder color.
--@return Color The placeholder color.
function dtxe_methods:getPlaceholderColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetPlaceholderColor())
end

--- Sets whether or not to decline non-numeric characters as input.
--- Numeric characters are 1234567890.-
--@param boolean numericOnly Whether to accept only numeric characters.
function dtxe_methods:setNumeric(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetNumeric(enable)
end

--- Returns whether only numeric characters (123456789.-) can be entered into the DTextEntry.
--@return boolean Whether the DTextEntry is numeric or not.
function dtxe_methods:getNumeric()
	local uwp = dtxeunwrap(self)

	return uwp:GetNumeric()
end

--- Sets whether we should fire DTextEntry:onValueChange every time we type or delete a character or only when Enter is pressed.
--@param boolean enable Fire onValueChange every time the entry is modified?
function dtxe_methods:setUpdateOnType(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetUpdateOnType(enable)
end

--- Gets whether the DTextEntry fires onValueChange every time it is modified.
--@return boolean Fire onValueChange on every update?
function dtxe_methods:getUpdateOnType()
	local uwp = dtxeunwrap(self)

	return uwp:GetUpdateOnType()
end

--- Sets the text of the DTextEntry and calls DTextEntry:onValueChange.
--@param string value The value to set.
function dtxe_methods:setValue(text)
	checkluatype(text, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetValue(text)
end

--- Disables Input on a DTextEntry. This differs from Panel:SetDisabled - SetEditable will not affect the appearance of the textbox.
--@param boolean enabled Whether the DTextEntry should be editable.
function dtxe_methods:setEditable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetEditable(enable)
end

--- Returns the contents of the DTextEntry as a number.
--@return number Text of the DTextEntry as a float, or nil if it cannot be converted to a number using tonumber.
function dtxe_methods:getFloat()
	local uwp = dtxeunwrap(self)

	return uwp:GetFloat()
end

--- Same as DTextEntry:GetFloat(), but rounds value to nearest integer.
--@return number Text of the DTextEntry as an int, or nil if it cannot be converted to a number.
function dtxe_methods:getInt()
	local uwp = dtxeunwrap(self)

	return uwp:GetInt()
end

--- Sets the cursor's color in DTextEntry (the blinking line).
--@param Color cursorColor The color to set the cursor to.
function dtxe_methods:setCursorColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetCursorColor(cunwrap(clr))
end

--- Returns the cursor color of a DTextEntry.
--@param Color The color of the cursor as a Color.
function dtxe_methods:getCursorColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetCursorColor())
end

--- Changes the font of the DTextEntry.
--@param string fontName The name of the font. Check render.setFont for a list of default fonts.
function dtxe_methods:setFont(fontName)
	checkluatype(fontName, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetFont(fontName)
end

--- Sets whether or not to paint/draw the DTextEntry's background.
--@param boolean paint True to show the entry's background, false to hide it.
function dtxe_methods:setPaintBackground(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetPaintBackground(enable)
end

--- Returns whether or not the entry background is being drawn.
--@return boolean True if the entry background is drawn, false otherwise.
function dtxe_methods:getPaintBackground()
	local uwp = dtxeunwrap(self)

	return uwp:getPaintBackground()
end

--- Called internally by DTextEntry:OnTextChanged when the user modifies the text in the DTextEntry.
--- You should override this function to define custom behavior when the DTextEntry text changes.
--@param function callback The function to run when the user modifies the text. There is only one argument which is the DTextEntry itself.
function dtxe_methods:onChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	uwp.OnChange = function() instance:runFunction(func, self) end
end

--- Called internally when the text changes of the DTextEntry are applied.
--- See also DTextEntry:onChange for a function that is called on every text change.
--- You should override this function to define custom behavior when the text changes.
--- This method is called:
--- 	When Enter is pressed after typing
--- 	When DTextEntry:setValue is used
--- 	For every key typed - only if DTextEntry:setUpdateOnType was set to true (default is false)
--@param function callback The function to run when the text changes are applied. Has 2 arguments: The DTextEntry itself and the value that was applied.
function dtxe_methods:onValueChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	uwp.OnValueChange = function(value) instance:runFunction(func, self, value) end
end

--- Called whenever enter is pressed on a DTextEntry.
--- DTextEntry:isEditing will still return true in this callback!
--@param function callback The function to run when the text changes are applied. Has 2 arguments: The DTextEntry itself and the value that was applied.
function dtxe_methods:onEnter(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	uwp.OnEnter = function(value) instance:runFunction(func, self, value) end
end

--- Returns whether this DTextEntry is being edited or not. (i.e. has focus)
--@return boolean Whether this DTextEntry is being edited or not.
function dtxe_methods:isEditing()
	local uwp = dtxeunwrap(self)

	return uwp:IsEditing()
end

--- Called whenever the DTextEntry gains focus.
--@param function callback The function to run when entry gains focus. There is only one argument which is the DTextEntry itself.
function dtxe_methods:onGetFocus(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	uwp.OnGetFocus = function() instance:runFunction(func, self) end
end

--- Called whenever the DTextEntry loses focus.
--@param function callback The function to run when the entry loses focus. There is only one argument which is the DTextEntry itself.
function dtxe_methods:onLoseFocus(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	uwp.OnLoseFocus = function() instance:runFunction(func, self) end
end

--- Sets the text color of the DTextEntry.
--@param Color textColor The text color.
function dtxe_methods:setTextColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetTextColor(cunwrap(clr))
end

--- Returns the "override" text color, set by DTextEntry:setTextColor.
--@return Color The color of the text, or nil.
function dtxe_methods:getTextColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetTextColor())
end

--- Creates a DImage. A panel which displays an image. Inherits functions from DPanel.
--@param Panel? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DImage The new DImage.
function vgui_library.createDImage(parent, name)
	if parent then parent = pnlunwrap(parent) end
	
	local new = vgui.Create("DImage", parent, name)
	if !parent then panels[new] = true end
	return dimgwrap(new)
end

--- Sets the image to load into the frame. If the first image can't be loaded and strBackup is set, that image will be loaded instead.
--@param string imagePath The path of the image to load. When no file extension is supplied the VMT file extension is used.
--@param string? backup The path of the backup image.
function dimg_methods:setImage(imagePath, backup)
	checkluatype(imagePath, TYPE_STRING)
	local uwp = dimgunwrap(self)

	uwp:SetImage(imagePath, backup)
end

--- Returns the image loaded in the image panel.
--@return string The path to the image that is loaded.
function dimg_methods:getImage()
	local uwp = dimgunwrap(self)

	return uwp:GetImage()
end

--- Sets the image's color override.
--@param Color imgColor The color override of the image. Uses the Color.
function dimg_methods:setImageColor(clr)
	local uwp = dimgunwrap(self)
	local uwc = cunwrap(clr)

	uwp:SetImageColor(uwc)
end

--- Gets the image's color override.
--@return Color The color override of the image.
function dimg_methods:getImageColor()
	local uwp = dimgunwrap(self)

	return cwrap(uwp:GetImageColor())
end

--- Sets whether the DImage should keep the aspect ratio of its image when being resized.
--- Note that this will not try to fit the image inside the button, but instead it will fill the button with the image.
--@param boolean keep True to keep the aspect ratio, false not to.
function dimg_methods:setKeepAspect(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dimgunwrap(self)

	uwp:SetKeepAspect(enable)
end

--- Returns whether the DImage should keep the aspect ratio of its image when being resized.
--@return boolean Whether the DImage should keep the aspect ratio of its image when being resized.
function dimg_methods:getKeepAspect()
	local uwp = dimgunwrap(self)

	return uwp:GetKeepAspect()
end

end