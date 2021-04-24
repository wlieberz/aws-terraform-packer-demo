# About

Some time ago I was asked to put together a technical demo of Packer and Terraform bringing up an example project in AWS. This is the infrastructure as code for the demo.

## Pre-requisites:

* Install tools:

You need these installed on your management workstation to bring up the stack:

* AWS CLI
* Terraform
* Ansible
* Packer

* Ensure ssh-agent forwarding (for bastion-hosts):

You need ssh-agent forwarding enabled on your management workstation so as to be able to ssh through the bastion-hosts without placing your private key on the bastion-hosts themselves. One way to enable this config is to ensure the option: `ForwardAgent yes` is in the file: `/etc/ssh/ssh_config`.

* Customize bastion-hosts ssh key:

For the purposes of this exercise, please generate a new ssh key:

```
ssh-keygen -t rsa -b 4096 -C ThreeTierAppWilliam-Ohio-bastion-key -f ~/.ssh/id_rsa_ThreeTierAppWilliam-Ohio-bastion-key

```

Then get the public key, 
`cat ~/.ssh/id_rsa_ThreeTierAppWilliam-Ohio-bastion-key.pub`

and replace the `default`  string in the variable
 `"bastion_public_key"` 
 in the file:
 `terraform/terraform-variables.tf`. 

In a production environment we would use a secrets management system to distribute the private key securely to those who need it.

* Customize your public IP (for bastion-hosts ssh access):

In the file `terraform/terraform-variables.tf` :

replace the `default` value of the variable `headquarters_public_ip` with your public IP address, eg:

`default     = "YOUR.IP.GOES.HERE/32"`

Normally changing this would not be needed - in a corporate environment it is expected the business would have a static corporate IP and any administrators would first VPN into the corporate network before accessing AWS resources. We might also want to keep this variable encrypted so as not to expose in the code repo. We are assuming a private repo in this case.

## Deploying the stack:

From a shell in the project root directory:

```
./bring-up-project.sh

```

## Current State:

This is a limited, time-constrained proof of concept (PoC) implementation to get a sense of the application. Further work should be done before considering this production ready - see the "Future Work" section, below, for further details.

### Summary of what has been implemented:

* Packer builds a custom front-end server machine image (AMI), provisioned via an Ansible playbook.

* A new VPC is created with two AZs, each with a public and private subnet along with associated routes, route tables, internet gateway, and a NAT Gateway in each AZ. 

* A bastion host is deployed into the public subnet of each of the two AZs along with security groups to allow the bastion-hosts to connect to other servers and to allow ssh ingress to the bastion-hosts only from the corporate IP. An Elastic IP is attached to each bastion-host to make it easier to whitelist traffic through the corporate firewall, etc. Finally, an existing SSH keypair on the administrator's workstation is pushed into AWS and attached to the bastion hosts.

* The front-end is configured with security groups to allow http-from-anywhere (only used by public-facing load-balancer), and then http-allowed-from-vpc which allows the load-balancer to pass http to the front-end servers. One front-end server is instantiated in the private subnet of each AZ from the custom AMI provisioned earlier by Packer. A load balancer is instantiated and the custom front-end servers are put behind the load balancer. 

* Very basic method to confirm application deployed correctly:

At the end of running the `./bring-up-project.sh` script you should see:
`front-end-lb-dns-name = "dns-load-balancer-dns-name-here"` 
This can be verifed by visiting in a browser or via curl. 

Note: This may not work for the first minute due to the 60 second warm-up time for the load-balancer to start sending traffic to the front-end servers. Please wait 1 minute and try again, if you run into any issues after first deploying the stack.

# Future Work:

There are a number of ways to make this more production-ready. Here is a non-exhaustive list which is more traditional (avoiding containers and Kubernetes):

* Use the custom AMI images in a launch configuration and ASG (auto scaling group) with load-balancers between the layers. The revised architecture would look something like this, simplified:

```

+--------------------+
|                    |
|  internet traffic  |
|                    |
+--------+-----------+
         |
         |
         |
         v
+-------------------+
|  front-end LB     |
|                   |
+--------+----------+
         |
         |
         |
+--------v---------+         +----------------+         +---------------+
|                  |         |                |         |               |
| front-end ASG    |+------->|  back-end LB   |+------->| back-end ASG  |
|                  |         |                |         |               |
+------------------+         +----------------+         +---------------+

```


* For performance, a caching layer should be added (Elasticache).

* Add an S3 bucket for front-end LB access logs and associate it with the load balancer.

* Add Web Application Firewall (WAF) "in front" of front-end public load-balancer.

* Configure suport for multiple environments, e.g. Dev, Staging, Prod.

* Implement robust health checks for hosts behind load balancers.

* Possibly replace the bastion-hosts with  `EC2 Instance Connect` which might provide tighter security:

> ...it generates a one-time-use SSH public key, pushes the key to the instance where it remains for 60 seconds, and connects the user to the instance.

[Source: AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html)