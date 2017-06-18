[![Build Status](https://travis-ci.org/emacski/k8s-elasticsearch.svg?branch=master)](https://travis-ci.org/emacski/k8s-elasticsearch)

Kubernetes Elasticsearch
-----------------------

Alternative elasticsearch docker image designed as a drop-in replacement for the
es-image in the fluentd-elasticsearch cluster-level logging addon.

**Components**

| Component | Version |
| --------- | ------- |
| elasticsearch | 5.4.1 |

**Required Configuration**

| Environment Variable | Description |
| -------------------- | ----------- |
| `K8S_NAMESPACE` | The k8s namespace of the elasticsearch cluster |
| `K8S_SERVICE` | The k8s service of the elasticsearch cluster |

**Configuration**

| Environment Variable | Description |
| -------------------- | ----------- |
| `ES_CLUSTER_NAME` | The name of the elasticsearch cluster (Default: `kubernetes-logging`) |
| `ES_NODE_NAME` | The name of the elasticsearch node (Default: `$HOSTNAME`) |
| `ES_NODE_MASTER` | Whether or not this node is eligible to be a master node (Default: `true`) |
| `ES_NODE_DATA` | Whether or not this node is eligible to be a data node (Default: `true`) |
| `ES_TRANSPORT_PORT` | The elasticsearch transport port (Default: `9300`) |
| `ES_HTTP_PORT` | The elasticsearch http port (Default: `9200`) |
| `ES_MIN_MASTER_NODES` | The minimum number of master nodes (Default: `2`) |

**Special Configuration**

These configuration directives are automatically resolved using the `k8s-app-config` helper utility

| Environment Variable | Description |
| -------------------- | ----------- |
| `ES_HOSTS` | The elasticsearch hosts in the cluster, used for discovery (Default: empty) |

**Example ReplicaSet Deployment and Service**
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: elasticsearch-logging-v1
  namespace: kube-system
  labels:
    k8s-app: elasticsearch-logging
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      k8s-app: elasticsearch-logging
      version: v1
  template:
    metadata:
      labels:
        k8s-app: elasticsearch-logging
        version: v1
    spec:
      containers:
      - image: emacski/k8s-elasticsearch:latest
        name: elasticsearch-logging
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: es-persistent-storage
          mountPath: /data
        env:
        - name: "K8S_NAMESPACE"
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: "K8S_SERVICE"
          value: "elasticsearch-logging"
      volumes:
      - name: es-persistent-storage
        emptyDir: {}

---

apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-logging
  namespace: kube-system
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/name: "Elasticsearch"
    kubernetes.io/cluster-service: "true"
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  selector:
    k8s-app: elasticsearch-logging

```
