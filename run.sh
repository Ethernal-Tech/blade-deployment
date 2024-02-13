### Creating resources with Terraform
terraform init
terraform plan
terraform apply -auto-approve

### Output the private key for instances
terraform output pk_ansible > ~/private.key
chmod 600 ~/private.key
ssh-add ~/private.key

cd ansible

### Run ansible to configure the nodes
ansible all -m ping
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml --ask-become-pass
