# Falco installation 
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg

sudo cat >>/etc/apt/sources.list.d/falcosecurity.list <<EOF
deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main
EOF

apt-get update
sudo apt install -y dkms make linux-headers-$(uname -r)
sudo apt install -y clang llvm
sudo apt install -y dialog
apt-get install -y falco


# Create rule files
vim /etc/falco/falco_rules.local.yaml

cat falco_rules.local.yaml
# Your custom rules!

- macro: custom_macro
  condition: evt.type = execve and container.id != host

- list: blacklist_binaries
  items: [cat,grep,date]

- rule: The program "cat" is run in a container
  desc: An event will trigger every time you run cat in a container
  condition: custom_macro and proc.name in (blacklist_binaries)
  output: demo %evt.time %user.name %container.name
  priority: ERROR
  tags: [demo]

- rule: spawned-processes
  desc: Spawned process
  condition: spawned_process and container.id != host
  output: spawned %evt.time %proc.name %user.uid
  priority: ERROR

# Start capturing
## Launch falco
timeout 30s falco | grep spawned
## Copy output
vim spawn.txt
## Filter
cat spawn.txt | awk '{print $4 " " $5 " " $6}' > /tmp/falco.txt
