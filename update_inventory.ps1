# Retrieve instance IP address from Terraform output
$SPARROW_IP = terraform output -json sparrow_instance_ip | ConvertFrom-Json

# Write IP address to Ansible inventory file
"[sparrow]" | sudo Out-File /etc/ansible hosts -Append
$SPARROW_IP | sudo Out-File /etc/ansible hosts -Append
