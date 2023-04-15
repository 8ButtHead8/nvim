local lspconfigStatus, lspconfig = pcall(require, 'lspconfig')
local coqStatus, coq = pcall(require, 'coq')

if (not lspconfigStatus or not coqStatus) then
	return
end

lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities({ }))

lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}))

