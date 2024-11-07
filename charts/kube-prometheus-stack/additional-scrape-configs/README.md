```
kubectl -n monitoring create secret generic kube-prometheus-stack-prometheus-scrape-confg --from-file=./additional-scrape-configs.yaml --dry-run=client -o yaml > ./kube-prometheus-stack-prometheus-scrape-confg.yaml
kubectl apply -f ./kube-prometheus-stack-prometheus-scrape-confg.yaml
```
