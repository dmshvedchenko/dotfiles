-- core/persist/scratch.lua
-- Scratch persistence layer: отвечает ТОЛЬКО за текст [No Name] буферов.
-- Сохраняет содержимое на диск и загружает обратно. Ничего не знает
-- про табы, окна и layout — это зона ответственности core.persist.session.
--
-- Хранение: stdpath("state")/persist/scratch/<id>.txt
-- id живёт в buffer-local переменной b:persist_id.

local api = vim.api

local M = {}

local counter = 0
local loaded = {} -- id -> bufnr; защита от дублей при повторном load

local function dir()
  local d = vim.fs.joinpath(vim.fn.stdpath("state"), "persist", "scratch")
  vim.fn.mkdir(d, "p")
  return d
end

local function path_for(id)
  return vim.fs.joinpath(dir(), id .. ".txt")
end

local function new_id()
  counter = counter + 1
  return string.format("%d-%d", os.time(), counter)
end

-- Обычный listed безымянный буфер (не help/qf/terminal)?
local function is_scratch(buf)
  return api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buflisted
    and vim.bo[buf].buftype == ""
    and api.nvim_buf_get_name(buf) == ""
end

local function has_content(buf)
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n"):find("%S") ~= nil
end

-- Персистим только изменённые [No Name] буферы с непустым текстом,
-- а также ранее восстановленные (у них уже есть b:persist_id).
function M.should_persist(buf)
  return is_scratch(buf)
    and (vim.bo[buf].modified or vim.b[buf].persist_id ~= nil)
    and has_content(buf)
end

-- Сохранить текст буфера на диск.
---@return string|nil id nil, если буфер персистить не нужно/не удалось
function M.save(buf)
  if not M.should_persist(buf) then
    return nil
  end
  local id = vim.b[buf].persist_id or new_id()
  vim.b[buf].persist_id = id
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  if vim.fn.writefile(lines, path_for(id)) ~= 0 then
    vim.notify("persist: не удалось записать scratch " .. id, vim.log.levels.WARN)
    return nil
  end
  return id
end

-- Создать (или вернуть уже созданный) буфер с текстом заметки.
-- Если файла на диске нет (metadata не совпала) — вернётся пустой
-- буфер с тем же id: layout не ломаем, текст просто пустой.
---@return integer bufnr
function M.load(id)
  local cached = loaded[id]
  if cached and api.nvim_buf_is_valid(cached) then
    return cached -- один id -> один буфер, даже если он в нескольких окнах
  end
  local buf = api.nvim_create_buf(true, false)
  local file = path_for(id)
  if vim.fn.filereadable(file) == 1 then
    local ok, lines = pcall(vim.fn.readfile, file)
    if ok then
      api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
  end
  vim.b[buf].persist_id = id
  vim.bo[buf].modified = false
  loaded[id] = buf
  return buf
end

-- Удалить с диска заметки, не попавшие в свежий манифест
-- (например, буфер закрыли через :bd в течение сессии).
---@param keep table<string, boolean>
function M.cleanup(keep)
  for name, t in vim.fs.dir(dir()) do
    if t == "file" then
      local id = name:match("^(.+)%.txt$")
      if id and not keep[id] then
        os.remove(path_for(id))
      end
    end
  end
end

return M
