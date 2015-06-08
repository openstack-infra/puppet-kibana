# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Class to install kibana frontend to logstash.
#
class kibana::ruby (
) {

  vcsrepo { '/opt/kibana/kibana':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/rashidkpc/Kibana2.git',
    revision => 'v0.2.0',
    require  => File['/opt/kibana'],
  }

  package { 'bundler':
    ensure   => latest,
    provider => 'gem',
  }

  exec { 'install_kibana':
    command     => 'bundle install',
    path        => ['/usr/bin', '/usr/local/bin'],
    cwd         => '/opt/kibana/kibana',
    logoutput   => true,
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/kibana/kibana'],
    require     => [
      User['kibana'],
      Package['bundler'],
    ],
  }

  file { '/opt/kibana/kibana/KibanaConfig.rb':
    ensure  => present,
    content => template('kibana/config.rb.erb'),
    replace => true,
    owner   => 'kibana',
    group   => 'kibana',
    require => Vcsrepo['/opt/kibana/kibana'],
  }

  file { '/etc/init/kibana.conf':
    ensure => present,
    source => 'puppet:///modules/kibana/kibana.init',
  }

  service { 'kibana':
    ensure  => running,
    require => [
      File['/etc/init/kibana.conf'],
      File['/opt/kibana/kibana/KibanaConfig.rb'],
      Exec['install_kibana'],
    ],
  }

}
