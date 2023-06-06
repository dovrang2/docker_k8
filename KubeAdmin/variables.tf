variable "cluster_names" {
  type        = string
  description = "Names for the individual clusters. If the value for a specific cluster is null, a random name will be automatically chosen."
  default     = "admin"
}