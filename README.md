# ps-umn-ibmonitor
Puppet Module for the UMN IBMonitorService Utility

Once deployed, the module will do the following:

* Install Java 1.8 if it is not already installed
* Download the IBMonitorService utility from `'https://umn-peoplesoft.github.io/IBMonitorService/IBMonitorService.zip'` _or an alternate location that you specify_
* Extract the utility and deploy a default configuration file
* Pull data from your target server's hiera hierarchy and use it to populate the configuration file
* If it isn't already running, start the IBMonitorService utility

## Limitations

* At the time of release, this module is only supported on Linux PeopleSoft servers. Windows support will come in a future release.

### Prerequisites

* Puppet has been deployed on the target server.
* The hiera hierarchy has been built out (i.e. `psft_customizations.yaml` contains site-specific values).

### Installing and Deploying

Perform these steps to download the IBMonitorService to your PeopleSoft server:

1. Create a directory for the IBMonitorService utility to reside in. We'll call this `<BASE_DIR>`
   * make sure you have read/write access to this directory.
2. Download the files in this repository and place them in the appropriate puppet directories on your server. Assuming puppet is installed in `/etc/puppet`:

```
/etc/puppet/manifests/ps-umn-ibmonitor.pp
/etc/puppet/modules/ps-umn-ibmonitor/files/IBMon-configs.yaml
```
3. Update `ps-umn-ibmonitor.pp` to your liking. The only items that _need_ to be updated are in a block at the top of the file.
   * set `$downloadDirLin` to the `<BASE_DIR>` directory you created earlier
4. If desired, update `IBMon-configs.yaml` to set your preferences for the IBMonitor utility.
   * updating this file is not required; it works as-delivered with a default configuration
   * all values preceded with "dummy" will be updated automatically using values from your hiera hierarchy
   * see the link at the top of the config file for full documentation on configuring this utility
5. With root access, use puppet to download, configure, and start the utility:
```
sudo puppet apply /etc/puppet/manifests/ps-umn-ibmonitor.pp --debug --trace
```

## Acknowledgments

* Hats off to the crew at the University of Minnesota for creating the IBMonitorService utility!
  * https://github.com/UMN-PeopleSoft/IBMonitorService

