local M = {}

M.config = {
  mapping = "!",
  reverse_mapping = "",
  find_smallest_match = true,
}

M.builtins = {
  ampersands = { "&&", "||" },
  capital_true_false = {
    ["%f[%w]True%f[%W]"] = "False",
    ["%f[%w]False%f[%W]"] = "True",
  },
  true_false = {
    ["%f[%w]true%f[%W]"] = "false",
    ["%f[%w]false%f[%W]"] = "true",
  },
  ruby_hash_style = {
    [":([%w_]+)%s*=>%s*"] = "%1: ",
    ["%f[%w]([%w_]+): "] = ":%1 => ",
  },
  ruby_string = {
    ['"([^"]-)"'] = "'%1'",
    ["'([^']-)'"] = '"%1"',
  },
  ruby_lambda = {
    ["lambda%s*{%s*|([^|]+)|"] = "->(%1) {",
    ["%->%s*%(([^)]+)%)%s*{"] = "lambda { |%1|",
    ["lambda%s*{"] = "-> {",
    ["%->%s*{"] = "lambda {",
  },
  ruby_assert_nil = {
    ["assert_equal nil,"] = "assert_nil",
    ["assert_nil"] = "assert_equal nil,",
  },
  rspec_should = { "should ", "should_not " },
  rspec_expect = {
    ["(expect%(.*%))%.to "] = "%1.not_to ",
    ["(expect%(.*%))%.to_not "] = "%1.to ",
    ["(expect%(.*%))%.not_to "] = "%1.to ",
  },
  rspec_to = {
    ["%.to "] = ".not_to ",
    ["%.not_to "] = ".to ",
    ["%.to_not "] = ".to ",
  },
  rspec_be_truthy_falsey = { "be_truthy", "be_falsey" },
  rspec_be_present_blank = { "be_present", "be_blank" },
  eruby_tag_type = {
    ["<%%= (.-) %%>"] = "<% %1 %>",
    ["<%% (.-) %-?%%>"] = "<%# %1 %>",
    ["<%%# (.-) %%>"] = "<%= %1 %>",
  },
  php_echo = {
    ["<%?php echo (.-) %>"] = "<?php %1 ?>",
    ["<%?php ([^e][^c][^h][^o].-) %>"] = "<?php echo %1 ?>",
  },
  cpp_pointer = {
    ["([%w_]+)%."] = "%1->",
    ["([%w_]+)%->"] = "%1.",
  },
  javascript_es6_declarations = {
    ["%f[%w]var%s+"] = "let ",
    ["%f[%w]let%s+"] = "const ",
    ["%f[%w]const%s+"] = "let ",
  },
  javascript_arrow_function = {
    ["function%s*%(%)%s*{"] = "() => {",
    ["function%s*%(([^,%)]+,[^%)]+)%)%s*{"] = "(%1) => {",
    ["function%s*%(([%w_]+)%)%s*{"] = "%1 => {",
    ["%(([^%)]+)%)%s*=>%s*{"] = "function(%1) {",
    ["([%w_]+)%s*=>%s*{"] = "function(%1) {",
  },
  coffee_arrow = {
    ["^(.-)%->"] = "%1=>",
    ["^(.-)=>"] = "%1->",
  },
  clojure_string = {
    ['"([%w_]+)"'] = "'%1",
    ["'([%w_]+)"] = ":%1",
    [":([%w_]+)"] = '"%1"',
  },
  markdown_task_item = {
    ["^(%s*)%- %[ %] (.*)"] = "%1- [x] %2",
    ["^(%s*)%- %[x%] (.*)"] = "%1- [ ] %2",
  },
  rust_string = {
    ['"([^"]*)"'] = 'r"%1"',
    ['r"([^"]*)"'] = 'r#"%1"#',
    ['r#"([^"]*)"#'] = '"%1"',
  },
  rust_is_some = {
    ["%f[%w]is_some%f[%W]"] = "is_none",
    ["%f[%w]is_none%f[%W]"] = "is_some",
  },
  rust_assert = {
    ["%f[%w]assert_eq!"] = "assert_ne!",
    ["%f[%w]assert_ne!"] = "assert_eq!",
  },
  python_dict_get = {
    ["([%w_]+)%[([^%]]+)%]"] = "%1.get(%2)",
    ["([%w_]+)%.get%(([^%)]+)%)"] = "%1[%2]",
  },
  python_string_style = {
    ['f"([^"]-)"'] = "'%1'",
    ["'([^']-)'"] = '"%1"',
    ['"([^"]-)"'] = 'f"%1"',
  },
  python_asserts = {
    ["%f[%w]assertTrue%f[%W]"] = "assertFalse",
    ["%f[%w]assertFalse%f[%W]"] = "assertTrue",
    ["%f[%w]assertIsNone%f[%W]"] = "assertIsNotNone",
    ["%f[%w]assertIsNotNone%f[%W]"] = "assertIsNone",
    ["%f[%w]assertIn%f[%W]"] = "assertNotIn",
    ["%f[%w]assertNotIn%f[%W]"] = "assertIn",
  },
}

M.definitions = {
  { ["%f[%w]and%f[%W]"] = "or", ["%f[%w]or%f[%W]"] = "and" },
  { ["%f[%w]And%f[%W]"] = "Or", ["%f[%w]Or%f[%W]"] = "And" },
  { ["%f[%w]AND%f[%W]"] = "OR", ["%f[%w]OR%f[%W]"] = "AND" },
  M.builtins.ampersands,
  M.builtins.capital_true_false,
  M.builtins.true_false,
}

local function get_cursor_info()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  return row, col, line
end

local function find_all_matches(text, pattern)
  local matches = {}
  local start_pos = 1

  while true do
    local s, e, captures = text:find(pattern, start_pos)
    if not s then break end

    table.insert(matches, {
      start_pos = s,
      end_pos = e,
      captures = { captures },
    })

    start_pos = e + 1
  end

  return matches
end

local function is_cursor_in_match(col, match) return col + 1 >= match.start_pos and col + 1 <= match.end_pos end

local function find_match(line, col, definitions, options)
  options = options or {}
  local best_match = nil
  local best_pattern = nil
  local best_replacement = nil
  local best_size = math.huge

  for _, def in ipairs(definitions) do
    if type(def) == "table" then
      if #def > 0 then
        for i, value in ipairs(def) do
          local matches = find_all_matches(line, value)
          for _, match in ipairs(matches) do
            if is_cursor_in_match(col, match) then
              local size = match.end_pos - match.start_pos
              if not best_match or (M.config.find_smallest_match and size < best_size) then
                local next_index = options.reverse and (i == 1 and #def or i - 1) or (i == #def and 1 or i + 1)
                best_match = match
                best_pattern = value
                best_replacement = def[next_index]
                best_size = size
              end
            end
          end
        end
      else
        for pattern, replacement in pairs(def) do
          local matches = find_all_matches(line, pattern)
          for _, match in ipairs(matches) do
            if is_cursor_in_match(col, match) then
              local size = match.end_pos - match.start_pos
              if not best_match or (M.config.find_smallest_match and size < best_size) then
                best_match = match
                best_pattern = pattern
                best_replacement = replacement
                best_size = size
              end
            end
          end
        end
      end
    end
  end

  return best_match, best_pattern, best_replacement
end

function M.switch(options)
  options = options or {}
  local row, col, line = get_cursor_info()
  local all_definitions = {}
  vim.list_extend(all_definitions, M.definitions)
  vim.list_extend(all_definitions, vim.g.switch_custom_definitions or {})
  vim.list_extend(all_definitions, vim.b.switch_custom_definitions or {})
  local match, pattern, replacement = find_match(line, col, all_definitions, options)

  if match and replacement then
    local before = line:sub(1, match.start_pos - 1)
    local matched_text = line:sub(match.start_pos, match.end_pos)
    local after = line:sub(match.end_pos + 1)
    local new_text
    if pattern and matched_text:find(pattern) then
      new_text = matched_text:gsub(pattern, replacement)
    else
      new_text = replacement
    end
    local new_line = before .. new_text .. after
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, match.start_pos - 1 })

    return true
  end

  return false
end

function M.setup()
  opts = opts or {}
  M.config = vim.tbl_extend("force", M.config, opts)
  vim.api.nvim_create_user_command("Switch", function() M.switch() end, {})

  vim.api.nvim_create_user_command("SwitchReverse", function() M.switch { reverse = true } end, {})

  if M.config.mapping ~= "" then
    vim.keymap.set("n", M.config.mapping, function() M.switch() end, { silent = true, desc = "Switch" })
  end

  if M.config.reverse_mapping ~= "" then
    vim.keymap.set(
      "n",
      M.config.reverse_mapping,
      function() M.switch { reverse = true } end,
      { silent = true, desc = "Switch Reverse" }
    )
  end
end

return M
