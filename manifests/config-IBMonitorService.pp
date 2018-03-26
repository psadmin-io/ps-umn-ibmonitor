$downloadSrc      = 'https://umn-peoplesoft.github.io/IBMonitorService/IBMonitorService.zip'
$downloadDir      = '/psoft/IBMon'
$configFile       = "$downloadDir/IBMonitorService/IBMon-configs.yaml"
$emailFrom        = 'email@address.com' 
$defaultNotifyTo  = 'notify@email.com' 
$escalateTo       = '' 
$onCallFile       = ''
$debugMode        = 'OFF'
$dbUser           = 'SYSADM'
$dbPswd           = 'P@ssw0rd!'

# Hiera lookups
$dbType           = hiera('db_platform')
$dbName           = hiera('db_name')
$dbHost           = hiera('db_host_name')
$dbPort           = hiera('db_port')
$pubNode          = hiera('gateway_node_name')
$appserver_domain_list = hiera('appserver_domain_list')

##############################################
# Deploy IB Monitor
##############################################

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


##############################################
# Configure IB Monitor
##############################################

# Configure lines in IBMon-configs.yaml

file_line {"IBMon-configs.yaml-emailReployTo":
    path    =>  "$configFile",
    match   =>  'dummy-emailReplyTo',
    line    =>  "  emailReployTo: ${emailFrom}",
}

file_line {"IBMon-configs.yaml-onCallFile":
    path    =>  "$configFile",
    match   =>  'dummy-onCallFile',
    line    =>  "  onCallFile: ${onCallFile}",
}

file_line {"IBMon-configs.yaml-dbType":
    path    =>  "$configFile",
    match   =>  'dummy-dbType',
    line    =>  "  dbType: ${dbType}",
}

file_line {"IBMon-configs.yaml-debugMode":
    path    =>  "$configFile",
    match   =>  'dummy-debugMode',
    line    =>  "  debugMode: ${debugMode}",
}

file_line {"IBMon-configs.yaml-dbName":
    path    =>  "$configFile",
    match   =>  'dummy-databaseName',
    line    =>  "    databaseName: ${dbName}",
}

file_line {"IBMon-configs.yaml-dbHost":
    path    =>  "$configFile",
    match   =>  'dummy-host',
    line    =>  "    host: ${dbHost}:${dbPort}/${dbName}",
}

file_line {"IBMon-configs.yaml-user":
    path    =>  "$configFile",
    match   =>  'dummy-user',
    line    =>  "    user: ${dbUser}",
}

file_line {"IBMon-configs.yaml-password":
    path    =>  "$configFile",
    match   =>  'dummy-password',
    line    =>  "    password: ${dbPswd}",
}

file_line {"IBMon-configs.yaml-defaultNotifyTo":
    path    =>  "$configFile",
    match   =>  'dummy-defaultNotifyTo',
    line    =>  "    defaultNotifyTo: ${defaultNotifyTo}",
}

file_line {"IBMon-configs.yaml-monitorEventNotifyTo":
    path      =>  "$configFile",
    match     =>  'dummy-notifyTo',
    line      =>  "      notifyTo: ${defaultNotifyTo}",
    multiple  =>  true,
}

file_line {"IBMon-configs.yaml-escalationNotifyTo":
    path      =>  "$configFile",
    match     =>  'dummy-escalation.*notifyTo',
    line      =>  "      - notifyTo: ${defaultNotifyTo}",
    multiple  =>  true,
}

file_line {"IBMon-configs.yaml-publishNode":
    path      =>  "$configFile",
    match     =>  'dummy-publishNode',
    line      =>  "      publishNode: ${pubNode}",
    multiple  =>  true,
}

file_line {"IBMon-configs.yaml-subscribeNode":
    path      =>  "$configFile",
    match     =>  'dummy-subscribeNode',
    line      =>  "      subscribeNode: ${pubNode}",
    multiple  =>  true,
}

# Fields specified in the App Server domain configuration
# note - if there are multiple domains, values from the LAST one listed will be used
$appserver_domain_list.each | $domain_name, $appserver_domain_info | {
  $config_settings = $appserver_domain_info['config_settings']
  $smtpServer = $config_settings['SMTP Settings/SMTPServer']
  $smtpPort = $config_settings['SMTP Settings/SMTPPort']
  $smtpUser = $config_settings['SMTP Settings/SMTPUsername']
  $smtpPswd = $config_settings['SMTP Settings/SMTPassword']

  file_line {"IBMon-configs.yaml-emailUser-${domain_name}":
      path    =>  "$configFile",
      match   =>  'dummy-emailUser',
      line    =>  "  emailUser: ${smtpUser}",
  }

  file_line {"IBMon-configs.yaml-emailPassword-${domain_name}":
      path    =>  "$configFile",
      match   =>  'dummy-emailPassword',
      line    =>  "  emailPassword: ${smtpPswd}",
  }

  file_line {"IBMon-configs.yaml-emailHost-${domain_name}":
      path    =>  "$configFile",
      match   =>  'dummy-emailHost',
      line    =>  "  emailHost: ${smtpServer}",
  }

  file_line {"IBMon-configs.yaml-emailPort-${domain_name}":
      path    =>  "$configFile",
      match   =>  'dummy-emailPort',
      line    =>  "  emailPort: ${smtpPort}",
  }
}
# Start/Stop IBMonitor Service
# TODO: Uncomment/update if we want this, otherwise remove
#service {"IBMonitorService":
#  ensure  =>  running,
#  start   =>  "sudo nohup $downloadDir/IBMonitorService/bin/IBMonitorService $configFile 2>/dev/null &",
#  stop    =>  "sudo pkill -f IBMon",
#  status  =>  "sudo pgrep -f IBMon",
#}
