restart-agent:
	cd ansible; \
	ansible validator -m shell -b -a "systemctl restart amazon-cloudwatch-agent"
.PHONY: restart-agent

start-agent:
	cd ansible; \
	ansible validator -m shell -b -a "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:cw_agent_config"
.PHONY: start-agent

logs-agent:
	cd ansible; \
	ansible validator -m shell -b -a "journalctl -u amazon-cloudwatch-agent"
.PHONY: logs-agent