vim.filetype.add({
	filetype = {
		[".env"] = "sh",
		[".envrc"] = "sh",
		["*.env"] = "sh",
		["*.envrc"] = "sh"
	},
  pattern = {
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/charts/.*/templates/.*%.ya?ml"] = "helm",
    [".*/charts/.*/templates/.*%.tpl"] = "helm",
  },
})
