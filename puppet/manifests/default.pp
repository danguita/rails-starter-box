# Make sure apt-get -y update runs before anything else.
stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}

class { 'apt_get_update':
  stage => preinstall
}

# System packages
package { [ 'build-essential',
            'zlib1g-dev',
            'libssl-dev',
            'libreadline-dev',
            'git-core' ]:
  ensure => installed,
}

# RMagick dependencies
package { ['libmagickwand4', 'libmagickwand-dev']:
  ensure => installed,
}

# Capybara-webkit dependencies
package { 'libqt4-dev':
  ensure => installed,
}

# Nokogiri dependencies
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime
package { 'nodejs':
  ensure => installed
}

# SQLite
package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# Utils
package { ['tmux', 'vim-nox']:
  ensure => installed;
}

# MySQL
class install_mysql {
  class { 'mysql': }

  class { 'mysql::server':
    config_hash => { 'root_password' => '' }
  }

  package { 'libmysqlclient15-dev':
    ensure => installed
  }
}
class { 'install_mysql': }

# PostgreSQL
class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_database { 'rails-starter':
    ensure   => present,
    encoding => 'UTF8',
    require  => Class['postgresql::server']
  }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }
}
class { 'install_postgres': }


# RVM
class install-rvm {
  include rvm

  rvm::system_user { vagrant: ; }

  rvm_system_ruby {
    'ruby-1.9.3-p429':
      ensure => 'present',
      default_use => false;
    'ruby-1.9.2-p320':
      ensure => 'present',
      default_use => false;
    'ruby-1.8.7-p371':
      ensure => 'present',
      default_use => false;
  }

  rvm_gem {
    'ruby-1.9.3-p429/bundler':
        ensure => latest,
        require => Rvm_system_ruby['ruby-1.9.3-p429'];
    'ruby-1.9.2-p320/bundler':
        ensure => latest,
        require => Rvm_system_ruby['ruby-1.9.2-p320'];
    'ruby-1.8.7-p371/bundler':
        ensure => latest,
        require => Rvm_system_ruby['ruby-1.8.7-p371'];
  }
}

class { 'install-rvm': }
