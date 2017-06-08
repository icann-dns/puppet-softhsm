# Class: SoftHSM
#
class softhsm (
  String                       $package             = 'softhsm2',
  Stdlib::Absolutepath         $conf_file           = '/etc/softhsm/softhsm2.conf',
  Stdlib::Absolutepath         $tokendir            = '/var/lib/softhsm/tokens/',
  Enum['file','db']            $objectstore_backend = 'file',
  Tea::Syslog_level            $log_level           = 'info',
  Hash[String, Softhsm::Token] $tokens              = {},
) {
  ensure_packages([$package])

  $conf_file_content = @("EOF")
  directories.tokendir = ${tokendir}
  objectstore.backend = ${objectstore_backend}
  log.level = ${log_level.upcase}
  | EOF

  file {$tokendir:
    ensure => directory,
  }
  file {$conf_file:
    ensure  => file,
    content => $conf_file_content,
  }

  $tokens.each |String $token_name, Softhsm::Token $token| {
    exec {"softhsm2-util init ${token_name}":
      path    => ['/usr/bin', '/bin'],
      command => "softhsm2-util --init-token --free --pin ${token['pin']} --so-pin ${token['so_pin']} --label ${token_name}",
      unless  => "softhsm2-util --show-slots | egrep '^\s+Label:\s+${token_name}\s+$'",
    }
  }
}
