variable "k8s-nodes" {
    type = map(object({
        name = string
        ip = string
        disk = string
    }))
}