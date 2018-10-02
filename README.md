[![Build Status](https://travis-ci.org/emacski/k8s-elasticsearch.svg?branch=master)](https://travis-ci.org/emacski/k8s-elasticsearch)

Kubernetes Elasticsearch
-----------------------

Alternative elasticsearch docker image designed as a drop-in replacement for the es-image in the fluentd-elasticsearch cluster-level logging addon.

**Components**

| Component | Version |
| --------- | ------- |
| elasticsearch | 6.4.2 |

**Required Configuration**

| Environment Variable | Description |
| -------------------- | ----------- |
| `k8s_namespace` | The k8s namespace of the elasticsearch cluster |
| `k8s_service` | The k8s service of the elasticsearch cluster |

**Configuration**

Uses [ReDACT](https://github.com/emacski/redact) for elasticsearch configuration.

| Environment Variable | Description |
| -------------------- | ----------- |
| `es_cluster_name` | The name of the elasticsearch cluster (Default: `kubernetes-logging`) |
| `es_node_name` | The name of the elasticsearch node (Default: `$HOSTNAME`) |
| `es_node_master` | Whether or not this node is eligible to be a master node (Default: `true`) |
| `es_node_data` | Whether or not this node is eligible to be a data node (Default: `true`) |
| `es_transport_port` | The elasticsearch transport port (Default: `9300`) |
| `es_http_port` | The elasticsearch http port (Default: `9200`) |
| `es_min_master_nodes` | The minimum number of master nodes (Default: `2`) |

**Special Configuration**

These configuration directives are automatically resolved using [ReDACT](https://github.com/emacski/redact) and the `k8s-app-config` helper utility

| Environment Variable | Description |
| -------------------- | ----------- |
| `es_hosts` | The elasticsearch hosts in the cluster, used for discovery (Default: empty) |

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
        - name: "k8s_namespace"
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: "k8s_service"
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
