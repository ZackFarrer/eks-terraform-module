# eks-terraform-module
EKS Module Enforcing Karpenter, EKS Access Entries and supportting AL2, AL2023 and Bottlerocket nodes

## Key Features

- **Supported Node Types**: The EKS cluster supports Amazon Linux 2 (AL2), Amazon Linux 2023 (AL2023), and Bottlerocket AMIs. The module is designed to automate AMI upgrades when the EKS control plane is updated, ensuring that the AMI used by both the EKS Node Group and Karpenter EC2NodeClass is consistent. The appropriate `userdata` is applied based on the node type.

- **Automated AMI Management**: When an AMI ID is not specified, the module pulls the latest AMI from AWS's public repository based on the selected node type. This AMI is then privately copied and used for both the EKS Node Group and Karpenter EC2NodeClass, ensuring consistency across the cluster.

- **Karpenter Deployment out of the box**: This module deploys Karpenter for efficient, resilient and cost-effective scaling. This means that cluster autoscaler is not used at all so the AWS resources used for cluster-autoscaler such as EKS Node Groups, Launch Templates and Autoscaling groups are not used and are handled by Karpenters EC2NodeClass and Nodepool Kubernetes resources. However, cluster-autoscaler is still required to run isolated nodes which run the karpenter pods as it would be detrimental to run Karpenter on the same nodes it provisions.

- **Static Scaling for EKS Node Group**: The EKS Node Group is configured with static scaling. Since it only runs Karpenter-related pods and EKS-managed add-ons, it does not need to scale dynamically.

- **Node Taints for Dedicated Pod Scheduling**: The EKS Node Group is tainted to restrict scheduling to Karpenter-specific pods and EKS-managed add-ons. All other workloads are scheduled on nodes provisioned by Karpenter, ensuring better control over resource allocation.

- **AWS-K8s Auth without Deprecated aws-auth ConfigMap**: This module does not use the deprecated `aws-auth` configmap for authentication. Instead, it configures access entries for `aws-k8s Auth`. The minimal `access_entry` configuration required to run the cluster has been predefined, with the flexibility to add additional entries as needed.

## Directory Structure

The module is structured into two primary directories to separate concerns between infrastructure and Kubernetes-level configurations:

- **infra/**: This directory contains Terraform configurations to provision all necessary AWS resources, including the EKS cluster, security groups, IAM roles, and networking components.
  
- **apps/**: This directory contains the Terraform configurations for managing Kubernetes resources such as deployments, services, and Helm charts. It's designed to be separate from the infrastructure to prevent issues during cluster upgrades (e.g., during EKS control plane upgrades, the Kubernetes provider might not be able to communicate with the cluster).

### Separate State Management

It is recommended to maintain separate Terraform state files for the `infra` and `apps` modules. This ensures that any changes to the cluster infrastructure (such as an EKS cluster upgrade) do not disrupt the Kubernetes resources, as the `helm` and `kubernetes` providers may be unable to reach the cluster if they are part of the same configuration.

## Security Groups

- **Cluster Security Group**: The default EKS cluster security group is used for control plane communication.
  
- **Worker Node Security Group**: A custom security group is created for the worker nodes. This security group contains the appropriate rules to allow communication between the worker nodes and the EKS control plane.

## Example Usage

This repository includes an example of how to call the `infra` and `apps` modules. The example demonstrates how both modules can be integrated into a GitHub workflow, providing flexibility in deploying infrastructure and Kubernetes resources either together or separately. The workflow can also specify different Terraform operations (e.g., `plan`, `apply`, `destroy`) for the `infra` and `apps` modules.

### Example `tfvars` Files

Sample `tfvars` files for each supported node type (AL2, AL2023, Bottlerocket) are provided in the repository. These examples can be used to quickly provision the EKS cluster with the desired node type.

---

By using this module, you can easily manage EKS clusters with a focus on consistency, automation, and security. The separation between infrastructure and Kubernetes resources ensures a smooth upgrade path and better management of Terraform state.

