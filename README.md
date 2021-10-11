# iperf3-k8s

Simple iperf3 to measure network bandwidth from all nodes of a Kubernetes cluster.

## How to use

*Make sure you are using the correct cluster context before running this script: `kubectl config current-context`*

```sh
./iperf3-k8s.sh
```

Any options supported by iperf3 can be added, e.g.:

```sh
./iperf3-k8s.sh -t 2
```

### NetworkPolicies

If you need NetworkPolicies you can install it:

```sh
kubectl apply -f network-policy.yaml
```

And cleanup afterwards:

```sh
kubectl delete -f network-policy.yaml
``