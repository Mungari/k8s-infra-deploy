variable "k8s_nodes" {
    type = map(object({
        name = string
        ip = string
        disk = string
    }))
}