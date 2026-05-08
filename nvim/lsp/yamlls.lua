return {
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      format = {
        enable = true,
      },
      keyOrdering = false,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {
        kubernetes = {
          "*.k8s.yaml",
          "*.k8s.yml",
          "k8s/*.yaml",
          "k8s/*.yml",
          "kubernetes/*.yaml",
          "kubernetes/*.yml",
          "manifests/*.yaml",
          "manifests/*.yml",
          "openshift/*.yaml",
          "openshift/*.yml",
        },
      },
    },
  },
}
