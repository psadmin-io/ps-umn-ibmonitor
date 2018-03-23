$downloadSrc = 'https://umn-peoplesoft.github.io/IBMonitorService/IBMonitorService.zip'
$downloadDir = '/psoft/IBMon'
$configFile  = "$downloadDir/IBMonitorService/IBMon-configs.yaml"

if $osFamily == 'windows' {
  #TODO: Add windows functionality.
  #      Some steps below may work for Lin/Win. If so, add osFamily check
  #       only for steps that need to, vs one big check at the beginning.
}
else {
  # Non-Windows

  # Create download directory
  file {"$downloadDir":
    ensure  =>  directory,
    #owner   =>  "${::id}",
    #group   =>  "${::gid}",
  }

  # Download IBMonitor
  exec {"download-IBMonitor":
    command =>  "wget --quiet --no-check-certificate $downloadSrc",
    cwd     =>  "$downloadDir",
    path    =>  ['/bin', '/sbin', '/usr/bin'],
    creates =>  "$downloadDir/IBMonitorService.zip",
  }

  # Extract IBMonitorService zip
  exec {"extract-IBMonitorService.zip":
    command =>  "unzip IBMonitorService.zip",
    cwd     =>  "$downloadDir",
    path    =>  ['/bin', '/sbin', '/usr/bin'],
    creates =>  "$downloadDir/IBMonitorService/bin",
  }

  #TODO: should we just deploy yaml? xml? jason? Or all?
  # Deploy IBMon-configs.yaml
  file {"IBMon-configs.yaml":
      ensure  => present,
      path    => "$configFile",
      source  => "puppet:///modules/ps-umn-ibmonitor/IBMon-configs.yaml",
  }

  # Start/Stop IBMonitor Service
  # TODO: Uncomment/update if we want this, otherwise remove
  #service {"IBMonitorService":
  #  ensure  =>  running,
  #  start   =>  "sudo nohup $downloadDir/IBMonitorService/bin/IBMonitorService $configFile 2>/dev/null &",
  #  stop    =>  "sudo pkill -f IBMon",
  #  status  =>  "sudo pgrep -f IBMon",
  #}
}
