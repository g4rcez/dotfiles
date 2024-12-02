local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

local s = ls.snippet
local d = ls.dynamic_node
local sn = ls.snippet_node
local i = ls.insert_node
local f = ls.function_node

ls.filetype_extend('typescript', { 'javascript' })

