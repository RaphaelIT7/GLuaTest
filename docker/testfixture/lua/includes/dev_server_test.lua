local table_concat = table.concat
local table_insert = table.insert
local string_Split = string.Split
local string_format = string.format

local failures = {}

--- @diagnostic disable-next-line: param-type-mismatch
local ghOutput = CreateConVar( "gluatest_github_output", "1", FCVAR_UNREGISTERED, "", 0, 1 )

-- Quick status command to show the server setup
RunConsoleCommand( "status" )

local function cleanSource( fileName )
    local spl = string_Split( fileName, "/" )
    for i, step in ipairs( spl ) do
        if step == "lua" then
            return table_concat( spl, "/", i, #spl )
        end
    end

    return spl
end

hook.Add( "GLuaTest_LoggedTestFailure", "TestLog", function( errInfo )
    local failInfo = {
        reason = errInfo.reason,
        lineNumber = errInfo.lineNumber,
        sourceFile = cleanSource( errInfo.sourceFile )
    }
    table_insert( failures, failInfo )

    if ghOutput:GetBool() then
        local fi = failInfo
        local str = "\n::error file=%s,line=%s::%s" -- RaphaelIT7: We require the \n at the beginning since print uses colors in the output which would cause Github to not recognize the ::error:: unless it's a new line. (Thx Rubat for suggesting this <3)
        print( string_format( str, fi.sourceFile, fi.lineNumber, fi.reason ) ) -- ToDo: Switch to MsgC( color_white ) in the next GMod update because of https://github.com/Facepunch/garrysmod-requests/issues/2712
    end
end )

hook.Add( "GLuaTest_Finished", "TestComplete", function()
    if #failures > 0 then
        print( tostring( #failures ) .. " test failures detected, writing to log.." )
        local failureJSON = util.TableToJSON( failures )
        file.Write( "gluatest_failures.json", failureJSON )
    end

    print( "Got GLuaTest TestComplete callback, exiting" )
    file.Write( "gluatest_clean_exit.txt", "true" )

    timer.Simple( 1, engine.CloseServer )
end )
