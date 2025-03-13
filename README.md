## Deploy dogecoin to k8s

1. Build and push the container
2. Install the storage class for AWS
   - `kubectl apply -f immedate-gp2-storageclass.yaml`
3. Install with overridden rpcPassword
   - `helm install dogecoin-<network> . --set rpcPassword=password_test --namespace default`
   - Replace `<network>` wtih `testnet` or `mainnet`
   - Use `-f values-mainnet.yaml` for `mainnet`
   - Override `--set storage.storageClassName=immediate-gp2` for AWS
   - Note: rpcPassword override creates a secret which is copied into the dogecoin.conf when the container starts

## Accessing dogecoin-cli via kubectl

```
kubectl exec dogecoin-88c4bd4dc-tt85j -- /dogecoin/bin/dogecoin-cli -conf=/tmp/dogecoin.conf getblockchaininfo
```

- Replace `dogecoin-88c4bd4dc-tt85j` with the actual pod from `kubectl get pods`
- Replace `getblockchaininfo` wtih any cli command

## Testing RPC from another pod

Check the services are running

```
kubectl get svc
```

```
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
dogecoin-mainnet   ClusterIP   10.100.104.208   <none>        22556/TCP,22555/TCP   20m
dogecoin-testnet   ClusterIP   10.100.108.164   <none>        44556/TCP,44555/TCP   22m
```

Spin up a debug pod with a terminal

```
kubectl run -i --tty --rm debug --image=busybox --restart=Never -n default -- sh
```

Make an RPC from the pod, using the service name and credentials

```
wget -qO- http://user:password_test@dogecoin-testnet:44555/ --post-data='{"jsonrpc": "1.0", "id":"test", "method": "getblockchaininfo", "params": []}'
```

Check that you get a valid response

```
{"result":{"chain":"test","blocks":217339,"headers":3499999,"bestblockhash":"2b175628405541cb5ba1f0329ff73985eab84e5bb94aaeed5b4dded130431434","difficulty":0.0002764590388906048,"mediantime":1412894572,"verificationprogress":0.04991828136432626,"initialblockdownload":true,"chainwork":"000000000000000000000000000000000000000000000000000000e216d503b2","size_on_disk":216713255,"pruned":false,"softforks":[{"id":"bip34","version":2,"reject":{"status":false}},{"id":"bip66","version":3,"reject":{"status":false}},{"id":"bip65","version":4,"reject":{"status":false}}],"bip9_softforks":{"csv":{"status":"defined","startTime":1456790400,"timeout":1493596800,"since":0}},"warnings":""},"error":null,"id":"test"}
```

## Enabling remote RPC (AWS)

1. Make sure you have the nginx ingress helm repo

   ```
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   ```

2. Install the nginx controller

   ```
   helm upgrade --install ingress-nginx ingress-nginx \
   --namespace ingress-nginx \
   -f ingress-controller-values.yaml
   ```

3. Have TLS secret created for the hosts defined in `rpc-ingress.yaml` and install the services-ingress

   ```
   kubectl apply rpc-ingress.yaml
   ```
