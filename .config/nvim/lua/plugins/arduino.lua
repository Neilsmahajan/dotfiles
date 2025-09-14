-- ~/.config/nvim/lua/plugins/arduino.lua

return {
  "vim-scripts/Arduino-syntax-file",
  ft = "arduino",
  config = function()
    -- Arduino CLI wrapper functions
    local function arduino_compile()
      local file = vim.fn.expand("%:p")
      local dir = vim.fn.expand("%:p:h")
      vim.cmd("!" ..
      "cd " .. vim.fn.shellescape(dir) .. " && arduino-cli compile --fqbn arduino:avr:uno " .. vim.fn.shellescape(file))
    end

    local function arduino_upload()
      local file = vim.fn.expand("%:p")
      local dir = vim.fn.expand("%:p:h")
      vim.cmd("!" ..
      "cd " ..
      vim.fn.shellescape(dir) ..
      " && arduino-cli upload -p /dev/cu.usbmodem* --fqbn arduino:avr:uno " .. vim.fn.shellescape(file))
    end

    local function arduino_serial()
      vim.cmd("!" .. "arduino-cli monitor -p /dev/cu.usbmodem*")
    end

    -- Set up commands for Arduino files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "arduino",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Disable LSP for Arduino files (buffer-specific)
        vim.diagnostic.config({
          virtual_text = false,
          signs = false,
          underline = false,
        }, bufnr)

        -- Set syntax to C++ for better highlighting
        vim.cmd("set syntax=cpp")

        -- Create buffer-local commands
        vim.api.nvim_buf_create_user_command(0, "ArduinoCompile", arduino_compile, {})
        vim.api.nvim_buf_create_user_command(0, "ArduinoUpload", arduino_upload, {})
        vim.api.nvim_buf_create_user_command(0, "ArduinoSerial", arduino_serial, {})

        vim.notify("Arduino mode activated! Use <leader>av to compile, <leader>au to upload", vim.log.levels.INFO)
      end,
    })
  end,
}
