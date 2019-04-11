class petclinic {
  exec{'apt-update':
    command => '/usr/bin/apt-get update'
  }

  $packages = ['openjdk-8-jre', 'tomcat7']
  package { $packages:
    require => Exec['apt-update'],
    ensure => installed,
  }

  file {'/usr/share/tomcat7':
    owner => 'tomcat7',
    group => 'tomcat7',
    ensure => directory,
    require => Package['tomcat7'],
  }

  file {'/var/lib/tomcat7/webapps/petclinic.war':
    owner => 'tomcat7',
    group => 'tomcat7',
    mode => '0644',
    ensure => present,
    require => Exec['download-petclinic-war']
  }
  exec { 'download-petclinic-war':
    command => '/usr/bin/curl -o petclinic.war http://10.0.2.2:18081/artifactory/libs-snapshot-local/org/springframework/samples/spring-petclinic/1.0.1-SNAPSHOT/spring-petclinic-1.0.1-20190411.154125-1.war',
    creates => '/var/lib/tomcat7/webapps/petclinic.war',
    cwd => '/var/lib/tomcat7/webapps',
    require => Package['tomcat7']
  }
  service { tomcat7:
    ensure => running,
    enable => true
  }
  exec{'add-tomcat-java-home':
    cwd => ['/etc'],
    path => ['/etc','/usr/bin'],
    command => '/bin/echo "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/" >> /etc/default/tomcat7',
    notify => Service['tomcat7']
  }
}
