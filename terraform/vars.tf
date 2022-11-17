variable "k8s-nodes" {
    type = map(object({
        ip = string
        disk = string
    }))
}