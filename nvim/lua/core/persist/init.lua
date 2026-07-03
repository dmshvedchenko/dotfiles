-- core/persist/init.lua
-- Точка входа: автокоманды и user-команды.
--   session-слой (табы/окна/порядок) — core.persist.session
--   scratch-слой (текст [No Name])   — core.persist.scratch
--
-- Подключение в init.lua конфига:
--   require("core.persist").setup()

local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("core_persist", { clear = true })
  local stdin = false
  local active = false

  vim.api.nvim_create_autocmd("StdinReadPre", {
    group = group,
    callback = function()
      stdin = true
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    nested = true,
    callback = function()
      -- "главный" инстанс = nvim без аргументов и без stdin.
      -- Только он восстанавливает и (ниже) перезаписывает состояние,
      -- чтобы `nvim file.txt` не перетирал заметки.
      active = vim.fn.argc() == 0 and not stdin
      if active then
        vim.schedule(function()
          require("core.persist.session").restore()
        end)
      end
    end,
  })

  -- VimLeavePre, а не ExitPre: срабатывает ровно один раз при любом
  -- нормальном выходе (включая :qa!), когда табы и окна ещё живы.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if active then
        require("core.persist.session").save()
      end
    end,
  })

  vim.api.nvim_create_user_command("PersistSave", function()
    require("core.persist.session").save()
  end, { desc = "Persist: сохранить layout и scratch-заметки вручную" })

  vim.api.nvim_create_user_command("PersistRestore", function()
    require("core.persist.session").restore()
  end, { desc = "Persist: восстановить сохранённое состояние" })
end

return M
