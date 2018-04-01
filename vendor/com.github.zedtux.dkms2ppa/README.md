# DKMS 2 PPA

__dkms2ppa__ aims to prepare a DKMS Debian package of a [kernel module](http://en.wikipedia.org/wiki/Kernel_module), for [Ubuntu](http://en.wikipedia.org/wiki/Ubuntu_%28operating_system%29), and upload it to a given [Launchpad.net](https://launchpad.net/) [Personal Package Archives for Ubuntu](https://help.launchpad.net/Packaging/PPA) (PPA) or any other repository with a configuration in dput.

To get more information about DKMS please visit http://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support.

The generated packge will ensure that the kernel module will be re-compiled automatically when a new kernel is installed.
To makes your kernel module available to multiple Ubuntu series (Quantal, Raring, Saucy, ...) you have to uplad a package per serie.
This script make this process very easy because you just have to call it once per Ubuntu serie where you want your package available.

# Pre-requisites

You must have:

1. a dkms.conf file in the project folder
2. a debian folder with all the required files

#### If you want to upload to a PPA

2. a valid Launchpad.net account ([Create a new account](https://login.launchpad.net/+new_account))
3. an actif PPA
4. a synchronized personal PGP key ([Youtube](http://www.youtube.com/watch?v=uEiyfbg9h-A))

### Folders structure

The struct of the folders has to be as following (for example the project is named douane-daemon):

```
douane-daemon/
  douane-daemon/
    dkms.conf
    douane.c
  douane-daemon-debian/
    debian/
      changelog
      control
      ...
```

# Usage

Find bellow an example:

    sudo dkms2ppa ppa:zedtux/sandbox raring

1. PPA URL (__ppa:zedtux/sandbox__ in the example).
2. Ubuntu serie name (__raring__ in the example).
