#!/usr/bin/env bash

chown -R elasticsearch:elasticsearch /data
export es_hosts=$(k8s-app-config hosts -n $k8s_namespace -s $k8s_service -w 5 -m ${es_min_master_nodes:-2} -f '"{{ join .hosts "," }}"')

# additional rendering here until redact supports multiple templates
redact render /log4j2.properties.redacted -o /elasticsearch/config/log4j2.properties
