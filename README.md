# Event Analytics Hub Infrastructure

This repository, **Event Analytics Hub Infra**, contains the Infrastructure as Code (IaC) definitions corresponding CI/CD configurations for the [Event Analytics Hub](https://blog.nick.shimokochi.com/post/building-an-event-analytics-hub-a-journey-in-software-development). project. This project demonstrates a scalable, event-driven analytics platform, with a focus on AWS infrastructure and Kubernetes.

---

## **Overview**

The **Event Analytics Hub** project is an educational initiative to explore modern software development principles, including:

- Event-driven architecture
- Kubernetes for container orchestration
- CI/CD pipelines for automation
- Infrastructure provisioning with Terraform

This repository provides the infrastructure and automation required to deploy and manage the Event Analytics Hub.

---

## **Repository Structure**

### **1. `.github/workflows/`**

This directory contains GitHub Actions workflows to automate CI/CD processes.

#### Key Workflows:

- **`default-example.yml`**: Placeholder/example workflow.
- **`eks-tf.yml`**: Workflow to validate, plan, and apply Terraform configurations for the EKS cluster.

#### Utility:

- Automates infrastructure provisioning.
- Ensures consistent application of Terraform changes through validation and deployment pipelines.

---

### **2. `eks-cluster/`**

This directory contains Terraform configurations for provisioning the EKS cluster and related AWS resources.

#### Key Files:

- **`main.tf`**: Core Terraform file defining the EKS cluster, databases, IAM roles, and related resources.
- **`variables.tf`**: Defines input variables for the infrastructure.
- **`outputs.tf`**: Exposes key outputs, such as cluster endpoint and security group IDs.
- **`ingress.yml`**: Kubernetes manifest for configuring ingress resources on the EKS cluster.

#### Utility:

- Manages the lifecycle of the EKS cluster.
- Integrates Kubernetes ingress for routing traffic to deployed services.
- Provisions secure databases and IAM roles for access management.

---

## **How This Fits into the Event Analytics Hub**

This repository plays a critical role in the Event Analytics Hub by:

1. **Provisioning Infrastructure:**

   - Deploying a Kubernetes-based platform on AWS EKS.
   - Managing ancillary AWS resources such as VPCs, databases, and IAM roles.

2. **CI/CD Automation:**

   - Automating Terraform deployments and validations.
   - Supporting iterative development with GitHub Actions workflows.

3. **Educational Value:**
   - Showcasing best practices in IaC and CI/CD.
   - Providing a hands-on example for deploying cloud-native applications.

## **License**

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For more information about the Event Analytics Hub project, refer to the [blog post](https://blog.nick.shimokochi.com/post/building-an-event-analytics-hub-a-journey-in-software-development).
