# This class installs and configures apache to serve mrepo repositories.
#
# == Examples
#
# This class does not need to be directly included
#
# == Author
#
# Adrien Thebo <adrien@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppet Labs, unless otherwise noted
#
class mrepo::webservice(
  $ensure = 'present'
){
  include mrepo::params

  $user       = $mrepo::params::user
  $group      = $mrepo::params::group
  $docroot    = $mrepo::params::www_root
  $servername = $mrepo::params::www_servername
  $priority   = $mrepo::params::priority
  $port       = $mrepo::params::port
  $ip_based   = $mrepo::params::www_ip_based
  $ip         = $mrepo::params::www_ip

  case $ensure {
    present: {
      include apache

      file { $docroot:
        ensure  => directory,
        owner   => $user,
        group   => $group,
        mode    => '0755',
      }

      apache::vhost { 'mrepo':
        priority          => $priority,
        port              => $port,
        servername        => $servername,
        docroot           => $docroot,
        custom_fragment   => template("${module_name}/apache.conf.erb"),
        ip_based          => $ip_based,
      }
      if $ip_based {
        Apache::Vhost['mrepo'] {
          ip => $ip,
        }
      }
    }

    'absent': {
      apache::vhost { 'mrepo':
        ensure  => $ensure,
        port    => $port,
        docroot => $docroot,
      }
    }
  }
}
