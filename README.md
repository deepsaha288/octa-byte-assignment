# octa-byte-assignment
Project Summary:
This project provisions AWS infrastructure using Terraform, deploys a containerized React + Express.js + PostgreSQL app to Amazon EKS, sets up CI/CD using Jenkins, and configures monitoring (Prometheus + Grafana) and backup (Velero for EKS, snapshot for RDS).

Step-by-Step Process

Step 1️⃣: Infrastructure Provisioning (Terraform)
cd environments/dev
terraform init
terraform plan
terraform apply -auto-approve

Modules Provisioned:
VPC, Subnets, Internet/NAT Gateways
EKS Cluster
RDS PostgreSQL with backups
EC2 instance for Jenkins
IAM roles
Security Groups

Step 2️⃣: Setup Jenkins on EC2

ssh -i <pem-file> ec2-user@<jenkins-public-ip>
on jenkins server install--> java, jenkins,docker,aws-cli,kubectl

open up jenkins--> 
Install plugins: Docker, GitHub, Kubernetes CLI, etc.

Step 3️⃣: ECR Image Build & Push
Update Dockerfile and Jenkinsfile to use ECR:

Step 4️⃣: Deploy to EKS

aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/ingress.yaml

Step 5️⃣: Install Ingress Controller (ALB)

helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=dev-eks-cluster \
  --set serviceAccount.create=false \
  --set region=us-east-1 \
  --set vpcId=vpc-0edbd7ea30d4ffeb6 \
  --set serviceAccount.name=aws-load-balancer-controller

Step 6️⃣: Install Prometheus & Grafana (Helm)

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

Step 7️⃣: Expose Grafana via Ingress

Edit grafana-ingress.yaml:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
  - host: grafana.dev.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: monitoring-grafana
            port:
              number: 80

kubectl apply -f grafana-ingress.yaml

Step 8️⃣: RDS Backup via Terraform

Ensure this in rds/main.tf:

backup_retention_period = 7
backup_window           = "03:00-04:00"
skip_final_snapshot     = false

Step 9️⃣: EKS Backup with Velero

# Install Velero CLI
curl -L https://github.com/vmware-tanzu/velero/releases/latest/download/velero-linux-amd64.tar.gz | tar -xz
sudo mv velero-v*/velero /usr/local/bin/

# Create S3 bucket
aws s3api create-bucket --bucket my-eks-backups --region us-east-1

# Install Velero with Helm
helm install velero vmware-tanzu/velero \
  --namespace velero --create-namespace \
  --set configuration.provider=aws \
  --set configuration.backupStorageLocation.bucket=my-eks-backups \
  --set configuration.backupStorageLocation.config.region=us-east-1 \
  --set initContainers[0].name=velero-plugin-for-aws \
  --set initContainers[0].image=velero/velero-plugin-for-aws:v1.7.0

To Backup:
velero backup create dev-backup --include-namespaces=dev
To Restore:
velero restore create --from-backup dev-backup