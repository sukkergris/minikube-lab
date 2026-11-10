# YAML

_Structure_

```pod-definition.yml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
    lables:
        app: myapp
        type: front-end
spec:
    containers:
        - name: nginx-container
          image: nginx-container
        - name: dotnet-container
          image: dotnet-container
```
