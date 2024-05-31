#!/bin/bash

# Install ADOT Collector
wget https://aws-otel-collector.s3.amazonaws.com/ubuntu/amd64/latest/aws-otel-collector.deb
sudo dpkg -i -E ./aws-otel-collector.deb

# Configure ADOT Collector
cat > /opt/aws/aws-otel-collector/etc/config.yaml << EOF
receivers:
  prometheus:
    config:
      global:
        scrape_interval: 60s
      scrape_configs:
        - job_name: node
          ec2_sd_configs:
            - region: "${region}"
              port: ${node_exporter_port}
              filters:
                - name: tag:service_name
                  values: 
                  - node_exporter
          relabel_configs:
            - source_labels:
                - __meta_ec2_instance_id
              target_label: instance_id
            - source_labels: [__meta_ec2_tag_Role]
              target_label: role
            - source_labels: [__meta_ec2_tag_Name]
              target_label: hostname
            - source_labels: [__meta_ec2_tag_Environment]
              target_label: environment
        - job_name: metrics
          ec2_sd_configs:
            - region: "${region}"
              port: ${prometheus_port}
              filters:
                - name: tag:service_name
                  values: 
                  - node_exporter
          relabel_configs:
            - source_labels:
                - __meta_ec2_instance_id
              target_label: instance_id
            - source_labels: [__meta_ec2_tag_Role]
              target_label: role
            - source_labels: [__meta_ec2_tag_Name]
              target_label: hostname
            - source_labels: [__meta_ec2_tag_Environment]
              target_label: environment
exporters:
  prometheusremotewrite:
    endpoint: "${prometheus_endopoint}api/v1/remote_write"
    auth:
      authenticator: sigv4auth
extensions:
  sigv4auth:
    region: "${region}"
service:
  extensions: [sigv4auth]
  pipelines:
    metrics:
      receivers:
        - prometheus
      exporters: [prometheusremotewrite]
EOF

# Start ADOT Collector
/opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a start
