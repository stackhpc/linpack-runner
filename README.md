Prerequisites
-------------

Install hashicorp [packer](https://packer.io/) and add it to your PATH:

```
export PATH=~/will:$PATH
```

Building the image
------------------

Build an image with linpack compiled using `march=native`

```
ansible-playbook build.yml -e @variables.json
```

Running Linpack
---------------

```
ansible-playbook launch.yml -e @variables.json
```

The results will be output to the results directory:

```
(.venv) [stackhpc@localhost hpl]$ ls results/
HPL-20200319T175315.stdout  HPL-20200319T175452.stdout  HPL-20200319T194000.stdout  HPL-20200319T194303.stdout
```
Tuning
------

### HPL.dat:
Should sized appropriately for the machine, see:

https://www.advancedclustering.com/act_kb/tune-hpl-dat-file/
