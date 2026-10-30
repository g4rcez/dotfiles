---@meta
-- LuaLS definitions for the Rex Lua API (https://www.superlogical.com/rex/docs/reference/lua).
-- Hand-written from the docs; Rex does not ship its own. Rex runs Lua 5.1.

---@alias RexOrigin "key"|"palette"|"cli"|"api"|"script"|"timer"
---@alias RexLogLevel "debug"|"info"|"warn"|"error"
---@alias RexDirection "left"|"right"|"up"|"down"
---@alias RexBounds number[]|{x: number, y: number, w: number, h: number} [x, y, w, h] as fractions of the window

---@class RexCtx
---@field session_id? string
---@field block_id? string
---@field client_id? string
---@field origin? RexOrigin
---@field server? string

---@class RexKeyEvent
---@field keybinding string
---@field prefix? string[]

---@class RexBinding
---@field key string
---@field mode? string
---@field action? string
---@field fn? fun(ctx: RexCtx, ev: RexKeyEvent): boolean?
---@field args? table
---@field source string

---@class RexModeInfo
---@field name string
---@field exclusive boolean
---@field source string

---@class RexActionSpec
---@field name string Lowercase letters, digits, underscores. No dots.
---@field title string
---@field run fun(ctx: RexCtx, args: table): any
---@field description? string
---@field category? string
---@field keywords? string
---@field args? table<string, string>|table Types: string, number, integer, boolean, object, array, any. Trailing `?` = optional. Or a JSON Schema.
---@field repeats? boolean

---@class RexHostSpec
---@field label string
---@field endpoints? string[]
---@field endpoint? string
---@field id? string
---@field icon? string

---@class RexLayout
---@class RexBlockSpec
---@field flavor string e.g. "com.superlogical.terminal.shell"
---@field label? string
---@field options? RexTerminalOptions

---@class RexTerminalOptions
---@field command? string[]
---@field shell? string "none" runs `command` directly
---@field cwd? string
---@field initial_input? string
---@field exit? {on_completion: boolean}

---@class RexExecOpts
---@field cwd? string
---@field env? table<string, string|false>
---@field clear_env? boolean
---@field stdin? string
---@field timeout? number
---@field stdout? boolean
---@field stderr? boolean
---@field text? boolean

---@class RexExecStartOpts: RexExecOpts
---@field stdin? string|boolean
---@field stdout? boolean|fun(chunk: string)
---@field stderr? boolean|fun(chunk: string)
---@field detach? boolean

---@class RexExecResult
---@field code integer
---@field signal? string
---@field stdout string
---@field stderr string
---@field timed_out boolean
---@field ok boolean

---@class RexProcess
---@field pid integer
---@field wait fun(self: RexProcess, seconds?: number): RexExecResult?, string?
---@field write fun(self: RexProcess, data: string): boolean?, string?
---@field close_stdin fun(self: RexProcess)
---@field kill fun(self: RexProcess, signal?: string|integer)
---@field running fun(self: RexProcess): boolean

---@class RexTimer
---@field cancel fun(self: RexTimer)
---@field active fun(self: RexTimer): boolean

---@class RexSessionApi
---@field view fun(args?: table): table?, string?
---@field list_blocks fun(args?: table): {blocks: {block_id: string, label: string, placement: "placed"|"detached", window_id?: string, flavor: string}[]}?, string?
---@field list_clients fun(args?: table): table?, string?
---@field describe_block fun(args: {block_id: string}): table?, string?
---@field new_window fun(args: {layout: RexLayout, focus?: boolean, window_label?: string, session_id?: string}): {window_id: string, block_ids: string[], revision: integer}?, string?
---@field new_split fun(args: table): table?, string?
---@field new_block fun(args: table): table?, string?
---@field new_layer fun(args: {layout: RexLayout, bounds: RexBounds, focus?: boolean, window_id?: string, session_id?: string}): {block_ids: string[], layer_id: string}?, string?
---@field close_window fun(args: {window_id: string}): table?, string?
---@field close_layer fun(args: {layer_id: string}): table?, string?
---@field move_block fun(args: {block_id: string, anchor_block_id: string, direction?: "horizontal"|"vertical", side?: "before"|"after", ratio?: number}): table?, string?
---@field swap_blocks fun(args: {block_id: string, other_block_id: string}): table?, string?
---@field detach_block fun(args: {block_id: string}): table?, string?
---@field float_block fun(args: {block_id: string, bounds?: RexBounds}): {layer_id: string}?, string?
---@field zoom_block fun(args: {block_id: string, zoomed?: boolean}): table?, string?
---@field resize_pane fun(args: table): table?, string?
---@field resize_layer fun(args: {layer_id: string, bounds: RexBounds}): table?, string?
---@field raise_layer fun(args: {layer_id: string}): table?, string?
---@field lower_layer fun(args: {layer_id: string}): table?, string?
---@field move_window fun(args: table): table?, string?
---@field focus_block fun(args: {block_id: string}): table?, string?
---@field focus_window fun(args: {window_id: string}): table?, string?
---@field focus_direction fun(args: {direction: RexDirection}): table?, string?
---@field focus_next_pane fun(args?: table): table?, string?
---@field focus_previous_pane fun(args?: table): table?, string?
---@field focus_next_window fun(args?: table): table?, string?
---@field focus_previous_window fun(args?: table): table?, string?
---@field set_label fun(args: {label: string}): table?, string?
---@field set_window_label fun(args: {window_id: string, label: string}): table?, string?
---@field set_block_label fun(args: {block_id: string, label: string}): table?, string?
---@field help fun(args?: table): table?, string?

---@class RexLayoutApi
---@field block fun(spec: RexBlockSpec): RexLayout
---@field horizontal fun(ratio: number, a: RexLayout, b: RexLayout): RexLayout
---@field vertical fun(ratio: number, a: RexLayout, b: RexLayout): RexLayout

---@class RexBlockApi
---@field call fun(creator: string, method: string, args?: table): table?, string?

---@class RexClientApi
---@field queue fun(name: string, args?: table)

---@class RexJsonApi
---@field encode fun(value: any, opts?: {indent?: boolean}): string?, string?
---@field decode fun(text: string): any, string?

---@class RexServer
---@field session RexSessionApi
---@field block RexBlockApi
---@field call fun(method: string, args?: table): table?, string?

---@class RexExecApi
---@overload fun(argv: string[], opts?: RexExecOpts): RexExecResult?, string?
---@field start fun(argv: string[], opts?: RexExecStartOpts): RexProcess?, string?

---@class Rex
---@field session RexSessionApi
---@field block RexBlockApi
---@field client RexClientApi
---@field layout RexLayoutApi
---@field json RexJsonApi
---@field exec RexExecApi
---@field args table Scripts only.
---@field session_id string Scripts only.
---@field block_id? string Scripts only.
rex = {}

---Bind a key, sequence (`a>b`) or `mode/key` to an action name or a Lua function.
---@overload fun(key: string, fn: fun(ctx: RexCtx, ev: RexKeyEvent): boolean?)
---@param key string
---@param action string
---@param args? table
function rex.bind(key, action, args) end

---@overload fun(spec: {mode: string}): integer
---@overload fun(binding: RexBinding): integer
---@param key string
---@param target? string|function
---@return integer removed
function rex.unbind(key, target) end

---@param name string
---@param options? {exclusive?: boolean}
function rex.mode(name, options) end

---@param filter? {key?: string, mode?: string, action?: string}
---@return RexBinding[]
function rex.bindings(filter) end

---@return RexModeInfo[]
function rex.modes() end

---@param spec RexActionSpec
function rex.action(spec) end

---@param name string
---@param args? table
---@return any result, string? err
function rex.invoke(name, args) end

---@param method string
---@param args? table
---@return table? result, string? err
function rex.call(method, args) end

---@param event string
---@param fn fun(ctx: RexCtx, ev: table)
function rex.on(event, fn) end

---@param event string
---@param filter? table|fun(ev: table, ctx: RexCtx): boolean
---@param timeout? number
---@return table? ev, RexCtx|string ctx
function rex.wait(event, filter, timeout) end

---@param seconds number
function rex.sleep(seconds) end

---@param code? integer
function rex.stop(code) end

---@param spec RexHostSpec
function rex.host(spec) end

---@return string[]
function rex.servers() end

---@param label string
---@return RexServer
function rex.server(label) end

---@param seconds number
---@param fn fun(ctx: RexCtx)
---@return RexTimer
function rex.after(seconds, fn) end

---@param seconds number
---@param fn fun(ctx: RexCtx)
---@return RexTimer
function rex.every(seconds, fn) end

---@overload fun(message: string)
---@param level RexLogLevel
---@param message string
function rex.log(level, message) end
