local M = {
    merge = function(t1, t2)
        for key, value in pairs(t2) do
            t1[key] = value
        end
    end,
}

return M
