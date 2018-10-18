# kubernetes-installer

This is a simple solution to deploy Kubernetes clusters using a combination of terraform and Rancher Kubernetes Engine (RKE).

## Introduction

We leave the infrastructure orchestration to Terraform to create initial nodes and prepare the environment. Then we let RKE deploy the Kubernetes components to
the provisioned nodes.

## Motivation

While `tectonic-installer` has more features and more cloud provider integrations, it also tends to be more complicated to setup and more coupled with the topology defined in its scripts.

This solution offers reusable terraform modules that can be assembled easily to create any kind of topologies. After the infrastructure is provisioned, then the current code sample shows how to feed the output to a script that will generate the templated node details used for the next stage of provisioning via RKE in order to create the Kubernetes cluster.

## Installation

### Prerequisites

- terraform 0.11+
- python3
- pip
- virtualenv
- rke (https://github.com/rancher/rke/releases)

## Features

Currently only provides examples for simple openstack-nova topologies.

## Usage

First, create the variable file `terraform.tfvars` from the example file and set the values according to your environment.

Then, source your openstack `OS_*` environment variables.

Finally,
```bash
make apply
```
