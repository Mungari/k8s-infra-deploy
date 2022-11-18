variable "k8s-nodes" {
    type = map(object({
        disk = string
        ip = string
    }))
}