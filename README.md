# Openstack Benchmarks

## Prerequisites

- Install hashicorp [packer](https://packer.io/) and add it to your PATH
- Install hashicorp [terraform](https://www.terraform.io/) and add it to your PATH
- Install https://github.com/nbering/terraform-provider-ansible as per instructions

```
export PATH=~/will:$PATH
```

## Configuration

Configuration is done via extra variables passed to ansible, see `site.yml`. This contains an example set of values which will need to modified for your environment.


## Building the image

Build an image with linpack compiled using `march=native`

```
ansible-playbook -i terraform_benchmarks/terraform.py build.yml -e@site.yml
```

## Running Linpack

```
ANSIBLE_TF_DIR=terraform_benchmarks/ ansible-playbook -i terraform_benchmarks/terraform.py benchmark.yml -e@site.yml -e@scenarios/hpl.yml
```

The results will be output to the results directory:

```
(.venv) [stackhpc@localhost hpl]$ ls results/
HPL-20200319T175315.stdout  HPL-20200319T175452.stdout  HPL-20200319T194000.stdout  HPL-20200319T194303.stdout
```
### Tuning
-----

### HPL.dat:
Should sized appropriately for the machine, see:

https://www.advancedclustering.com/act_kb/tune-hpl-dat-file/

## Running iperf2

```
ANSIBLE_TF_DIR=terraform_benchmarks/ ansible-playbook -i terraform_benchmarks/terraform.py build.yml -e@site.yml -e@scenarios/iperf.yml
```

It is possible to increase the number of instances defined in `scenarios/iperf.yml`. The number of instances
defines how many clients simulateously connect to the iperf server. The first instance is always the server.

