## Udacity DevOps Enginner Nanodegree

## Prerequisites:
1. Jenkins Server
2. Ansible Server
3. Kubernetes Master (kubectl)

### Jenkins Server
- Launch AWS EC2 Instance on Amazon Linux
- Install Jenkins and required plugins (Blue Ocean, Publish Over SSH, AWS plugin)
- Set up Jenkins pipeline using Blue Ocean
- Register GitHub repo and check if there is any updates on the repo
- Jenkins Server is responsible to copy artifacts to Ansible Server over SSH and execute required tasks by using ansible-playbook

### Ansible Server: [ansible-server]
- Launch AWS EC2 Instance on Amazon Linux
- Install Ansible, Docker
- Run a ansible playbook(/ansible/create-simple-devops-image.yml) against [ansible-server]  to build docker image and push it to Docker Hub
- Run two ansible playbooks(ansible/kubernetes-udacity-deployment.yml, /ansible/kubernetes-udacity-service.yml) againt [kops-machine]

### Kubernetes Master: [kops-machine]
Launch AWS EC2 instance on Ubuntu-18.04
Install kubectl
```
 curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
 chmod +x kops-linux-amd64
 sudo mv kops-linux-amd64 /usr/local/bin/kops
```

## Kubernetes Cluster Deployment
Use cloudFormation to create a network
```
aws cloudformation create-stack --stack-name udacity-eks-network --template-body cloudformation/udacity-eks-network.yml --region=us-west-2
```

Create a cluster on Kubernetes Master
```
aws eks create-cluster --name udacity-eks-cluster \
--region us-west-2 --role-arn arn:aws:iam::864313990414:role/udacity-eks-cluster-role \ 
--resources-vpc-config subnetIds=subnet-0f31dccbb4a5645b0,subnet-0c748c5c3762c4dce,subnet-06410719393b29856,securityGroupIds=sg-084e9b7e122c352f6
```

Check if the cluster is created and active
```
aws eks describe-cluster --name udacity-eks-cluster --region us-west-2 --query cluster.status
```

Update config with the kubernetes cluster
```
aws eks update-kubeconfig --region us-west-2 --name udacity-eks-cluster
```

Use CloudFormation to Create a NodeGroup
```
aws cloudformation create-stack --stack-name udacity-eks-network --template-body cloudformation/udacity-eks-nodegroup --region=us-west-2
```

## Deploy to Kubernetes Cluster

Jenkins Server runs two ansible playbooks on ansible Server against [kops-machine]
```
ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/kubernetes-udacity-deployment.yml
ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/kubernetes-udacity-service.yml
```
Creating two Kubernetes objects (deployment & service) with two kubectl commands below
```
kubectl apply -f udacity-deployment.yml
kubectl apply -f udacity-service.yml
```
Rolling out deoployment stragety
```
kubectl rollout restart deployment udacity-deployment
```

After running rollout restart deployment command, two running pods are replaced with newly created pods with zero downtime.
```
root@ip-172-31-15-212:~# kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
ip-172-31-178-114.us-west-2.compute.internal   Ready    <none>   19m   v1.17.9-eks-4c6976
ip-172-31-226-110.us-west-2.compute.internal   Ready    <none>   19m   v1.17.9-eks-4c6976
ip-172-31-86-110.us-west-2.compute.internal    Ready    <none>   19m   v1.17.9-eks-4c6976
root@ip-172-31-15-212:~# kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
udacity-deployment-6cbf7cc458-cdptm   1/1     Running   0          6m23s
udacity-deployment-6cbf7cc458-jn2hn   1/1     Running   0          6m23s
root@ip-172-31-15-212:~# kubectl get service
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)          AGE
kubernetes        ClusterIP      10.100.0.1      <none>                                                                    443/TCP          33m
udacity-service   LoadBalancer   10.100.229.29   a551fe8d3f69d465d830a0a176942324-1061316627.us-west-2.elb.amazonaws.com   8080:31200/TCP   6m23s
root@ip-172-31-15-212:~# kubectl get pods
NAME                                  READY   STATUS        RESTARTS   AGE
udacity-deployment-6cbf7cc458-jn2hn   0/1     Terminating   0          8m50s
udacity-deployment-75cc46c8b9-h55t6   1/1     Running       0          5s
udacity-deployment-75cc46c8b9-pw8tx   1/1     Running       0          5s
root@ip-172-31-15-212:~#
root@ip-172-31-15-212:~# kubectl get pods
NAME                                  READY   STATUS        RESTARTS   AGE
udacity-deployment-6cbf7cc458-jn2hn   0/1     Terminating   0          8m54s
udacity-deployment-75cc46c8b9-h55t6   1/1     Running       0          9s
udacity-deployment-75cc46c8b9-pw8tx   1/1     Running       0          9s
root@ip-172-31-15-212:~# kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
udacity-deployment-75cc46c8b9-h55t6   1/1     Running   0          13s
udacity-deployment-75cc46c8b9-pw8tx   1/1     Running   0          13s
root@ip-172-31-15-212:~# date
Mon Sep  7 08:09:37 UTC 2020
root@ip-172-31-15-212:~#
```


