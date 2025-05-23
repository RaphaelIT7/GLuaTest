--- @alias GLuaTest_LogColors table<string, Color>

--- @type GLuaTest_LogColors
local colors = {
    red      = Color( 255, 0, 0 ),
    green    = Color( 0, 255, 0 ),
    grey     = Color( 175, 192, 198 ),
    darkgrey = Color( 125, 125, 125 ),
    yellow   = Color( 235, 226, 52 ),
    white    = Color( 220, 220, 220 ),
    blue     = Color( 120, 162, 204 ),

    server   = Color( 100, 200, 255 ),
    client   = Color( 195, 201, 75 ),
}

hook.Run( "GLuaTest_MakeColors", colors )

return colors
