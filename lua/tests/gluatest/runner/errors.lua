return {
    groupName = "Errors",

    cases = {
        {
            name = "Handles tail call errors",
            func = function()
                local yes = true
                return error("Fails")
            end
        },
    }
}
