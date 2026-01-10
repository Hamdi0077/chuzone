# Configuration Terraform pour le cluster Kubernetes
# Modifiez ces valeurs selon vos besoins

aws_region          = "us-east-1"  # Changez si nécessaire (us-east-1, eu-west-1, etc.)
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.medium"   # Type d'instance EC2
key_pair_name      = "k8s-keypair" # Nom de votre clé SSH AWS

# Note : Créez la clé SSH avant de déployer :
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/k8s-keypair -N ""
# aws ec2 import-key-pair --key-name k8s-keypair --public-key-material fileb://~/.ssh/k8s-keypair.pub --region us-east-1
