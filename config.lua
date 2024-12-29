-- install plugins
lvim.plugins = {
    "ChristianChiarulli/swenv.nvim",
    "stevearc/dressing.nvim",
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest",
    "nvim-neotest/neotest-python",
    "olexsmir/gopher.nvim",
    "leoluz/nvim-dap-go",
    "lunarvim/colorschemes",
    "folke/tokyonight.nvim",
    "catppuccin/nvim",
  }
  
  -- status line
  lvim.builtin.lualine.style = "lvim"
  lvim.builtin.lualine.options.theme = "default"
  
  -- colorscheme
  lvim.colorscheme = "lvim"
  
  -- automatically install python syntax highlighting
  lvim.builtin.treesitter.ensure_installed = {
    "python",
    "go",
    "gomod",
  }
  
  -- setup formatting
  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    { name = "black" },
    { command = "goimports", filetypes = { "go" } },
    { command = "gofumpt", filetypes = { "go" } },
  }
  
  lvim.format_on_save.enabled = true
  lvim.format_on_save.pattern = {
    "*.py",
    "*.go"
  }
  
  -- setup linting
  -- python
  local linters = require "lvim.lsp.null-ls.linters"
  linters.setup { { command = "flake8", filetypes = { "python" } } }
  
  -- go
  local dap_ok, dapgo = pcall(require, "dap-go")
  if not dap_ok then
    return
  end
  
  dapgo.setup()
  
  vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "gopls" })
  
  local lsp_manager = require "lvim.lsp.manager"
  lsp_manager.setup("golangci_lint_ls", {
    on_init = require("lvim.lsp").common_on_init,
    capabilities = require("lvim.lsp").common_capabilities(),
  })
  
  lsp_manager.setup("gopls", {
    on_attach = function(client, bufnr)
      require("lvim.lsp").common_on_attach(client, bufnr)
      local _, _ = pcall(vim.lsp.codelens.refresh)
      local map = function(mode, lhs, rhs, desc)
        if desc then
          desc = desc
        end
  
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
      end
      map("n", "<leader>Ci", "<cmd>GoInstallDeps<Cr>", "Install Go Dependencies")
      map("n", "<leader>Ct", "<cmd>GoMod tidy<cr>", "Tidy")
      map("n", "<leader>Ca", "<cmd>GoTestAdd<Cr>", "Add Test")
      map("n", "<leader>CA", "<cmd>GoTestsAll<Cr>", "Add All Tests")
      map("n", "<leader>Ce", "<cmd>GoTestsExp<Cr>", "Add Exported Tests")
      map("n", "<leader>Cg", "<cmd>GoGenerate<Cr>", "Go Generate")
      map("n", "<leader>Cf", "<cmd>GoGenerate %<Cr>", "Go Generate File")
      map("n", "<leader>Cc", "<cmd>GoCmt<Cr>", "Generate Comment")
      map("n", "<leader>DT", "<cmd>lua require('dap-go').debug_test()<cr>", "Debug Test")
    end,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = require("lvim.lsp").common_capabilities(),
    settings = {
      gopls = {
        usePlaceholders = true,
        gofumpt = true,
        codelenses = {
          generate = false,
          gc_details = true,
          test = true,
          tidy = true,
        },
      },
    },
  })
  local status_ok, gopher = pcall(require, "gopher")
  if not status_ok then
    return
  end
  
  gopher.setup {
    commands = {
      go = "go",
      gomodifytags = "gomodifytags",
      gotests = "gotests",
      impl = "impl",
      iferr = "iferr",
    },
  }
  
  -- setup debug adapter
  lvim.builtin.dap.active = true
  local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
  pcall(function()
    require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
  end)
  
  -- setup testing
  require("neotest").setup({
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        dap = {
          justMyCode = false,
          console = "integratedTerminal",
        },
        args = { "--log-level", "DEBUG", "--quiet" },
        runner = "pytest",
      })
    }
  })
  
  lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
    "Test Method" }
  lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
    "Test Method DAP" }
  lvim.builtin.which_key.mappings["df"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
  lvim.builtin.which_key.mappings["dF"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
  lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }
  
  
  -- key binding
  lvim.builtin.which_key.mappings["C"] = {
    name = "Python",
    c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
  }
  
  -- lvim.builtin.terminal.open_mapping = "<c-t>"
  lvim.builtin.which_key.mappings["t"] = {
    name = "+Terminal",
    f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
    v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
    h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
  }
  