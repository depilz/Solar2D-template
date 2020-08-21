return {
    width         = display.actualContentWidth,
    height        = display.actualContentHeight,
    contentWidth  = display.contentWidth,
    contentHeight = display.contentHeight,
    centerX       = display.contentWidth*0.5,
    centerY       = display.contentHeight*0.5,
    originX       = display.screenOriginX,
    originY       = display.screenOriginY,
    edgeX         = display.screenOriginX+display.actualContentWidth,
    edgeY         = display.screenOriginY+display.actualContentHeight
}
