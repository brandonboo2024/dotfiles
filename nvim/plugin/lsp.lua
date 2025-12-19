vim.diagnostic.config({
	virtual_text  = true,
	severity_sort = true,
	float         = {
		style  = 'minimal',
		border = 'rounded',
		source = 'if_many',
		header = '',
		prefix = '',
	},
	signs         = {
		text = {
			[vim.diagnostic.severity.ERROR] = '✘',
			[vim.diagnostic.severity.WARN]  = '▲',
			[vim.diagnostic.severity.HINT]  = '⚑',
			[vim.diagnostic.severity.INFO]  = '»',
		},
	},
})

local orig = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts            = opts or {}
	opts.border     = opts.border or 'rounded'
	opts.max_width  = opts.max_width or 80
	opts.max_height = opts.max_height or 24
	opts.wrap       = opts.wrap ~= false
	return orig(contents, syntax, opts, ...)
end

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local buf    = args.buf

		vim.api.nvim_create_autocmd('BufWritePre', {
			group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
			buffer = buf,
			callback = function()
				vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 1000 })
			end,
		})
	end,
})


vim.lsp.config['luals'] = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
	capabilities = caps,
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' },
			diagnostics = { globals = { 'vim' } },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file('', true),
			},
			telemetry = { enable = false },
		},
	},
}

vim.lsp.config['cssls'] = {
	cmd = { 'vscode-css-language-server', '--stdio' },
	filetypes = { 'css', 'scss', 'less' },
	root_markers = { 'package.json', '.git' },
	capabilities = caps,
	settings = {
		css = { validate = true },
		scss = { validate = true },
		less = { validate = true },
	},
}


vim.lsp.config['ts_ls'] = {
	cmd = { 'typescript-language-server', '--stdio' },
	filetypes = {
		'javascript', 'javascriptreact', 'javascript.jsx',
		'typescript', 'typescriptreact', 'typescript.tsx',
	},
	root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
	capabilities = caps,
	settings = {
		completions = {
			completeFunctionCalls = true,
		},
	},
}

vim.lsp.config['zls'] = {
	cmd = { 'zls' },
	filetypes = { 'zig', 'zir' },
	root_markers = { 'zls.json', 'build.zig', '.git' },
	capabilities = caps,
	settings = {
		zls = {
			enable_build_on_save = true,
			build_on_save_step = "install",
			warn_style = false,
			enable_snippets = true,
		}
	}
}

vim.lsp.config['nil'] = {
	cmd = { "nil" },
	filetypes = { 'nix' },
	root_markers = { 'flake.nix', 'default.nix', '.git' },
	capabilities = caps,
	settings = {
		['nil'] = {
			formatting = {
				command = { "alejandra" }
			}
		}
	}
}

vim.lsp.config['rust_analyzer'] = {
	cmd = { 'rust-analyzer' },
	filetypes = { 'rust' },
	root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
	capabilities = caps,
	settings = {
		['rust-analyzer'] = {
			cargo = { allFeatures = true },
			formatting = {
				command = { "rustfmt" }
			},
		},
	},
}

-- C / C++ via clangd
vim.lsp.config['clangd'] = {
	cmd = {
		'clangd',
		'--background-index',
		'--clang-tidy',
		'--header-insertion=never',
		'--completion-style=detailed',
		'--query-driver=/nix/store/*-gcc-*/bin/gcc*,/nix/store/*-clang-*/bin/clang*,/run/current-system/sw/bin/cc*',
	},
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
	root_markers = { 'compile_commands.json', '.clangd', 'configure.ac', 'Makefile', '.git', vim.uv.cwd() },
	capabilities = caps,
	init_options = {
		fallbackFlags = { '-std=c23' }, -- Default to C23
	},
}

vim.lsp.config['jsonls'] = {
	cmd = { 'vscode-json-languageserver', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	root_markers = { 'package.json', '.git', 'config.jsonc' },
	capabilities = caps,
}

vim.lsp.config['pylsp'] = {
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { 'W391' },
					maxLineLength = 120
				}
			}
		}
	},
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
}

vim.lsp.config['jdtls'] = {
	cmd = { "jdtls" },
	filetypes = { "java" },
	root_markers = { { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" }, { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" } }
}

vim.filetype.add({
	extension = {
		h = 'c',
	},
})

vim.lsp.enable({
	"luals",
	"cssls",
	"ts_ls",
	"zls",
	"nil",
	"rust_analyzer",
	"clangd",
	"jsonls",
	"pylsp",
	"jdtls",
})
