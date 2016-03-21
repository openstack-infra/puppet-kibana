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
class kibana::js (
  $elasticsearch_url           = 'http://localhost:9200',
  $elasticsearch_prefix        = '/',  # Must contain trailing /
  $git_revision                = 'v3.1.2',
  $vhost_aliases               = [],
  $vhost_name                  = $::fqdn,
  $vhost_proxy_connect_timeout = '15',
  $vhost_proxy_timeout         = '120',
  $vhost_template              = 'kibana/dual-elasticsearch.vhost.erb',
) {

  $base_path = "/opt/kibana/${git_revision}"

  vcsrepo { $base_path:
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/elasticsearch/kibana.git',
    revision => $git_revision,
    owner    => 'www-data',
  }

  file { "${base_path}/src/config.js":
    ensure    => present,
    content   => template('kibana/config.js.erb'),
    owner     => 'www-data',
    require   => Vcsrepo[$base_path],
    subscribe => Vcsrepo[$base_path],
  }

  file { "${base_path}/src/app/dashboards/logstash.json":
    ensure    => present,
    source    => 'puppet:///modules/kibana/logstash.json',
    owner     => 'www-data',
    require   => Vcsrepo[$base_path],
    subscribe => Vcsrepo[$base_path],
  }

  file { "${base_path}/src/app/controllers/dashLoader.js":
    ensure    => present,
    source    => 'puppet:///modules/kibana/dashLoader.js',
    owner     => 'www-data',
    require   => Vcsrepo[$base_path],
    subscribe => Vcsrepo[$base_path],
  }

  httpd::vhost { 'kibana':
    docroot       => "${base_path}/src",
    vhost_name    => $vhost_name,
    serveraliases => $vhost_aliases,
    port          => 80,
    template      => $vhost_template,
  }

}
