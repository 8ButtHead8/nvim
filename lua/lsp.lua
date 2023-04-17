local lspconfigStatus, lspconfig = pcall(require, 'lspconfig')
local coqStatus, coq = pcall(require, 'coq')
local lspformatStatus, lspformat = pcall(require, 'lsp-format')

if (not lspconfigStatus or not coqStatus or not lspconfigStatus) then
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

