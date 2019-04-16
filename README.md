# Ethos
A collection of useful building blocks to help rapidly develop iOS apps using Swift

To add a new podspec run:

1. create <pod_name>.podspec

```
pod repo add <pod_name>Spec https://github.com/egouletlang/EthosSpecs
```

To release new pod version
```
# specific pod 
python .tools/release_pod.py --pods <pod_name_1> <pod_name_2>
eg. python .tools/release_pod.py --pods network
eg. python .tools/release_pod.py --pods network ui

# all pods
python .tools/release_pod.py
```