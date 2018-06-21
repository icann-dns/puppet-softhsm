#== Class: softhsm
#
class softhsm::params {
  case $::operatingsystem {
    'ubuntu': {
      case $::lsbdistcodename {
        'trusty': {
          $version   = 1
          $package   = 'softhsm'
          $utils_cmd = 'softhsm'
          $conf_file = '/etc/softhsm/softhsm.conf'
        }
        default: {
          $version   = 2
          $package   = 'softhsm2'
          $utils_cmd = 'softhsm2-util'
          $conf_file = '/etc/softhsm/softhsm2.conf'
        }
      }
    }
    'RedHat': {
      $version   = 2
      $package   = 'softhsm'
      $utils_cmd = 'softhsm2-util'
      $conf_file = '/etc/softhsm2.conf'
    }
    default: {
      $version   = 2
      $package   = 'softhsm2'
      $utils_cmd = 'softhsm2-util'
      $conf_file = '/etc/softhsm/softhsm2.conf'
    }
  }
}
