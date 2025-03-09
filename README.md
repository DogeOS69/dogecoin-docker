## Deploy dogecoin to k8s

1. Build and push the container
2. Update the image in values.yaml
3. Install with overridden rpcPassword
   - `helm install dogecoin . --set rpcPassword=password_test --namespace default`
   - Note: rpcPassword override creates a secret which is copied into the dogecoin.conf when the container starts

## Accessing dogecoin-cli via kubectl

```
kubectl exec dogecoin-88c4bd4dc-tt85j -- /dogecoin/bin/dogecoin-cli -conf=/tmp/dogecoin.conf getblockchaininfo
```

- Replace `dogecoin-88c4bd4dc-tt85j` with the actual pod from `kubectl get pods`
- Replace `getblockchaininfo` wtih any cli command

## Testing RPC from another pod

Get the ip address of the service

```
kubectl get svc
```

```
NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                           AGE
dogecoin                   NodePort       10.8.156.248   <none>         44556:30242/TCP,44555:30638/TCP   28m
```

Spin up a debug pod with a terminal

```
kubectl run -i --tty --rm debug --image=busybox --restart=Never -n default -- sh
```

Make an RPC from the pod, using the ip and credentials

```
wget -qO- http://user:password_test@10.8.156.248:44555/ --post-data='{"jsonrpc": "1.0", "id":"test", "method": "getblockchaininfo", "params": []}'
```

```
{"result":{"chain":"test","blocks":217339,"headers":3499999,"bestblockhash":"2b175628405541cb5ba1f0329ff73985eab84e5bb94aaeed5b4dded130431434","difficulty":0.0002764590388906048,"mediantime":1412894572,"verificationprogress":0.04991828136432626,"initialblockdownload":true,"chainwork":"000000000000000000000000000000000000000000000000000000e216d503b2","size_on_disk":216713255,"pruned":false,"softforks":[{"id":"bip34","version":2,"reject":{"status":false}},{"id":"bip66","version":3,"reject":{"status":false}},{"id":"bip65","version":4,"reject":{"status":false}}],"bip9_softforks":{"csv":{"status":"defined","startTime":1456790400,"timeout":1493596800,"since":0}},"warnings":""},"error":null,"id":"test"}
```

Make an RPC from the pod, using the service name and credentials

```
wget -qO- http://user:password_test@dogecoin:44555/ --post-data='{"jsonrpc": "1.0", "id":"test", "method": "getblockchaininfo", "params": []}'
```

```
{"result":{"chain":"test","blocks":217339,"headers":3499999,"bestblockhash":"2b175628405541cb5ba1f0329ff73985eab84e5bb94aaeed5b4dded130431434","difficulty":0.0002764590388906048,"mediantime":1412894572,"verificationprogress":0.04991828136432626,"initialblockdownload":true,"chainwork":"000000000000000000000000000000000000000000000000000000e216d503b2","size_on_disk":216713255,"pruned":false,"softforks":[{"id":"bip34","version":2,"reject":{"status":false}},{"id":"bip66","version":3,"reject":{"status":false}},{"id":"bip65","version":4,"reject":{"status":false}}],"bip9_softforks":{"csv":{"status":"defined","startTime":1456790400,"timeout":1493596800,"since":0}},"warnings":""},"error":null,"id":"test"}
```
