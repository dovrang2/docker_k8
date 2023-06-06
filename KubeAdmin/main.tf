module "cluster" {
  source = "weibeld/kubeadm/aws"
  cluster_name = "admin"
}
