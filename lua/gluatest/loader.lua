local istable = istable
local runClientside = GLuaTest.RUN_CLIENTSIDE
local noop = function() end

local checkSendToClients = function( filePath, cases )
    if not runClientside then return end

    for _, case in ipairs( cases ) do
        if case.clientside then
            return AddCSLuaFile( filePath )
        end
    end
end

-- TODO: How to prevent this from matching: `customtests/blah/blah.lua`?
local getProjectName = function( dir )
    return string.match( dir, "tests/(.+)/.*$" )
end

local simpleError = function( reason, filePath )
    return {
        reason = string.sub( reason, string.find( reason, ":", 3 ) + 2 ),
        sourceFile = filePath,
        lineNumber = -1,
        locals = {}
    }
end

local function processFile( dir, fileName, tests )
    if not string.EndsWith( fileName, ".lua" ) then return end

    local filePath = dir .. "/" .. fileName

    local success, result = pcall( function( filePath )
        local fileContent = file.Read( filePath, "LUA" )
        local compiled = CompileString( fileContent, "1", false )

        if not isfunction( compiled ) then
            return simpleError( compiled, filePath )
        end

        return compiled()
    end, filePath )

    success = success and istable( result ) and not result.sourceFile

    local fileOutput = nil
    if success then
        fileOutput = result
    else
        fileOutput = {
            includeError = istable( result ) and result or simpleError( result, filePath ),
            groupName = fileName,
            cases = {}
        }
    end

    if SERVER and success then checkSendToClients( filePath, fileOutput.cases ) end

    table.insert( tests, {
        fileName = fileName,
        groupName = fileOutput.groupName,
        cases = fileOutput.cases,
        project = getProjectName( filePath ),
        beforeAll = fileOutput.beforeAll or noop,
        beforeEach = fileOutput.beforeEach or noop,
        afterAll = fileOutput.afterAll or noop,
        afterEach = fileOutput.afterEach or noop,
        includeError = fileOutput.includeError
    } )
end

local function getTestsInDir( dir, tests )
    if not tests then tests = {} end
    local files, dirs = file.Find( dir .. "/*", "LUA" )

    for _, fileName in ipairs( files ) do
        processFile( dir, fileName, tests )
    end

    for _, dirName in ipairs( dirs ) do
        local newDir = dir .. "/" .. dirName
        getTestsInDir( newDir, tests )
    end

    return tests
end

return getTestsInDir
