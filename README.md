puppet-monitoring-server
========================

Puppet module for monitoring tools like Nagios, NTOP, Riemann.


prepare Puppet modules:
```
cd puppet/modules
git clone https://github.com/hoccer/puppet-monitoring-server.git monitoring-server
gem install librarian-puppet
cd monitoring-server
librarian-puppet install --path ../
```

create puppet/monitoringhost.pp manifest:
```
include monitoring-server
```
