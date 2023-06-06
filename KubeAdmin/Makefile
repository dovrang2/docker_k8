#!/usr/bin/env make

cluster:
	terraform init && \
		terraform apply -auto-approve && \
      kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml --kubeconfig admin.conf

