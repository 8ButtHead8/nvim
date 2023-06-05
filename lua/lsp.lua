local lspconfigStatus, lspconfig = pcall(require, 'lspconfig')
local coqStatus, coq = pcall(require, 'coq')
local lspformatStatus, lspformat = pcall(require, 'lsp-format')

if (not lspconfigStatus or not coqStatus or not lspformatStatus) then
	return
end

lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities({
	on_attach = lspformat.on_attach,
}))

lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	on_attach = lspformat.on_attach,
}))

lspconfig.cssls.setup(coq.lsp_ensure_capabilities({
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
	on_attach = lspformat.on_attach,
}))

lspconfig.html.setup(coq.lsp_ensure_capabilities({
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	on_attach = lspformat.on_attach,
}))

local prettier = {
	formatCommand = 'prettierd ${INPUT}',
	formatStdin = true,
}

lspconfig.efm.setup {
	filetypes = { "css", "scss", "less" },
	on_attach = lspformat.on_attach,
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			css = { prettier },
			scss = { prettier },
		},
	},
}

lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	on_attach = lspformat.on_attach,
}))
