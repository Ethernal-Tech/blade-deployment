ansible-playbook = ansible-playbook --inventory ./inventory/aws_ec2.yml 
ansible = ansible --inventory ./inventory/aws_ec2.yml 

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

ping:
	cd ansible; \
	${ansible} validator -m ping
.PHONY: ping

create:
	sudo rm -rf /tmp/*
	terraform apply -auto-approve
	
.PHONY: create

keys:
	terraform output pk_ansible > ~/private.key
	chmod 600 ~/private.key 
	eval "$(ssh-agent)"
	ssh-add ~/private.key
.PHONY: keys


blade-status:
	cd ansible; \
	ansible validator -m shell -b -a "systemctl status blade"
.PHONY: blade-status

upload-logs:
	cd ansible; \
	${ansible-playbook} upload-logs.yml
.PHONY: upload-logs

check-explorer:
	cd ansible;\
	ansible explorer -m shell -b -a "docker ps"
.PHONY: check-explorer

check-docker:
	cd ansible; \
	ansible validator -m shell -b -a "docker logs --tail 10 besu"
.PHONY: check-docker

site:
	cd ansible; \
	${ansible-playbook} site.yml
.PHONY: site