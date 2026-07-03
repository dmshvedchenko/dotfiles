-- core/persist/session.lua
-- Session/layout layer: отвечает ТОЛЬКО за табы, окна и порядок табов.
-- Вместо mksession — собственный JSON-манифест, потому что mksession
-- не умеет восстанавливать текст [No Name] буферов.
--
-- Хранение: stdpath("state")/persist/session.json
-- Текст scratch-буферов — зона ответственности core.persist.scratch.

local api = vim.api
local scratch = require("core.persist.scratch")

local M = {}

local restored = false -- защита от повторного restore

local function state_dir()
  local d = vim.fs.joinpath(vim.fn.stdpath("state"), "persist")
  vim.fn.mkdir(d, "p")
  return d
end

local function manifest_path()
  return vim.fs.joinpath(state_dir(), "session.json")
end

---------------------------------------------------------------------- save

-- Описание того, что показывает окно.
local function leaf_ref(win, keep)
  local buf = api.nvim_win_get_buf(win)
  if not api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return { kind = "empty" } -- help/quickfix/terminal не восстанавливаем
  end
  local name = api.nvim_buf_get_name(buf)
  if name ~= "" then
    return { kind = "file", path = name } -- обычный файл: только путь
  end
  local id = scratch.save(buf) -- [No Name]: текст пишет scratch-слой
  if id then
    keep[id] = true
    return { kind = "scratch", id = id }
  end
  return { kind = "empty" } -- пустой/неизменённый [No Name]
end

-- winlayout(): {'leaf', winid} | {'row'|'col', {node, ...}}
local function convert(node, keep)
  if node[1] == "leaf" then
    return { "leaf", leaf_ref(node[2], keep) }
  end
  local children = {}
  for _, child in ipairs(node[2]) do
    children[#children + 1] = convert(child, keep)
  end
  return { node[1], children }
end

function M.save()
  local keep = {}
  local tabs = {}
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    local tabnr = api.nvim_tabpage_get_number(tab)
    tabs[#tabs + 1] = { layout = convert(vim.fn.winlayout(tabnr), keep) }
  end
  local manifest = {
    version = 1,
    current = api.nvim_tabpage_get_number(api.nvim_get_current_tabpage()),
    tabs = tabs,
  }

  local ok, json = pcall(vim.json.encode, manifest)
  if not ok then
    return
  end

  -- атомарная запись: tmp + rename, чтобы не оставить битый манифест
  local path = manifest_path()
  local tmp = path .. ".tmp"
  local fd = io.open(tmp, "w")
  if not fd then
    return
  end
  fd:write(json)
  fd:close()
  os.rename(tmp, path)

  scratch.cleanup(keep)
end

------------------------------------------------------------------- restore

local function open_leaf(ref)
  if type(ref) ~= "table" then
    return
  end
  if ref.kind == "file" and type(ref.path) == "string" then
    local buf = vim.fn.bufadd(ref.path)
    vim.bo[buf].buflisted = true
    pcall(api.nvim_win_set_buf, 0, buf)
  elseif ref.kind == "scratch" and type(ref.id) == "string" then
    pcall(api.nvim_win_set_buf, 0, scratch.load(ref.id))
  end
  -- kind == "empty": оставляем пустое окно как есть
end

local function apply_layout(node)
  if type(node) ~= "table" then
    return
  end
  if node[1] == "leaf" then
    open_leaf(node[2])
    return
  end
  local children = node[2]
  if type(children) ~= "table" or #children == 0 then
    return
  end
  -- сначала создаём все окна этого уровня слева-направо / сверху-вниз,
  -- потом рекурсивно заполняем каждое
  local wins = { api.nvim_get_current_win() }
  for _ = 2, #children do
    vim.cmd(node[1] == "row" and "rightbelow vsplit" or "rightbelow split")
    wins[#wins + 1] = api.nvim_get_current_win()
  end
  for i, child in ipairs(children) do
    api.nvim_set_current_win(wins[i])
    apply_layout(child)
  end
end

local function quarantine(path)
  local bad = path .. ".corrupt." .. os.time()
  os.rename(path, bad)
  vim.notify("persist: session.json повреждён, перемещён в " .. bad, vim.log.levels.WARN)
end

-- Убрать пустые [No Name] буферы, оставшиеся от старта/`$tabnew`.
local function drop_empty_leftovers()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and api.nvim_buf_get_name(buf) == ""
      and not vim.bo[buf].modified
      and vim.b[buf].persist_id == nil
      and #vim.fn.win_findbuf(buf) == 0
    then
      pcall(api.nvim_buf_delete, buf, {})
    end
  end
end

function M.restore()
  if restored then
    return
  end
  restored = true

  local path = manifest_path()
  if vim.fn.filereadable(path) ~= 1 then
    return
  end

  local fd = io.open(path, "r")
  if not fd then
    return
  end
  local raw = fd:read("*a")
  fd:close()

  local ok, manifest = pcall(vim.json.decode, raw)
  if not ok or type(manifest) ~= "table" or type(manifest.tabs) ~= "table" then
    quarantine(path)
    return
  end

  for i, tab in ipairs(manifest.tabs) do
    if i > 1 then
      vim.cmd("$tabnew") -- всегда в конец: порядок табов сохраняется
    end
    if type(tab) == "table" then
      pcall(apply_layout, tab.layout)
    end
  end

  if type(manifest.current) == "number" and manifest.current <= #manifest.tabs then
    pcall(vim.cmd, manifest.current .. "tabnext")
  end

  drop_empty_leftovers()
end

return M
