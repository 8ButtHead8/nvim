local lspconfigStatus, lspconfig = pcall(require, 'lspconfig')
local coqStatus, coq = pcall(require, 'coq')

if (not lspconfigStatus or not coqStatus) then
	return
end

local on_attach = function(client, bufnr)
	if client:supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({
					bufnr = bufnr,
					async = false,
				})
			end,
		})
	end
end


vim.lsp.config('lua_ls', coq.lsp_ensure_capabilities({
	on_attach = on_attach,
}))

vim.lsp.config('ts_ls', coq.lsp_ensure_capabilities({
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	on_attach = on_attach,
}))

vim.lsp.config('cssls', coq.lsp_ensure_capabilities({
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
}))

vim.lsp.config('html', coq.lsp_ensure_capabilities({
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	on_attach = on_attach,
}))

local prettier = {
	formatCommand = 'prettierd ${INPUT}',
	formatStdin = true,
}

vim.lsp.config('efm', {
	filetypes = { "css", "scss", "less", "json", "jsonc" },
	on_attach = on_attach,
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			css = { prettier },
			scss = { prettier },
			json = { prettier },
			jsonc = { prettier },
		},
	},
})

vim.lsp.config('gopls', coq.lsp_ensure_capabilities({
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	on_attach = on_attach,
}))

vim.lsp.config('pyright', coq.lsp_ensure_capabilities({
	filetypes = { "python" },
}))

vim.lsp.config('phpactor', coq.lsp_ensure_capabilities({
	filetypes = { "php" },
	on_attach = on_attach,
}))

--[[ vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.php",
	callback = function()
		local filepath = vim.fn.expand('%:p')
		vim.fn.system("export PHP_CS_FIXER_IGNORE_ENV=1 && php-cs-fixer fix " ..
			filepath .. " --rules=@PSR12 --using-cache=no")
		vim.cmd('e!')
	end,
}) ]]


vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('cssls')
vim.lsp.enable('html')
vim.lsp.enable('efm')
vim.lsp.enable('gopls')
vim.lsp.enable('pyright')
vim.lsp.enable('phpactor')
