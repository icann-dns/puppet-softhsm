# Class: SoftHSM
#
class softhsm (
  Integer[1,2]                 $version     = $::softhsm::params::version,
  String                       $package     = $::softhsm::params::package,
  String                       $utils_cmd   = $::softhsm::params::utils_cmd,
  Stdlib::Absolutepath         $conf_file   = $::softhsm::params::conf_file,
  Stdlib::Absolutepath         $tokendir    = '/var/lib/softhsm/tokens/',
  Enum['file','db']            $objectstore = 'file',
  Tea::Syslog_level            $log_level   = 'info',
  Hash[String, Softhsm::Token] $tokens      = {},
) inherits softhsm::params {
  ensure_packages([$package])

  if $version == 1 {
    $conf_file_content = $tokens.reduce('') |$memo, $value| {
      if $memo == '' { $index = 0 }
      else { $index = $memo[0] + 1 }
      "${index}:${tokendir}${value[0]}.db\n${memo}"
    }
  } else {
    $conf_file_content = @("EOF")
    directories.tokendir = ${tokendir}
    objectstore.backend = ${objectstore}
    log.level = ${log_level.upcase}
    | EOF
  }

  file {$tokendir:
    ensure => directory,
  }
  file {$conf_file:
    ensure  => file,
    content => $conf_file_content,
  }
  $tokens_array = any2array($tokens)
  $tokens_array.slice(2).each |$idx, $token| {
    if $version == 1 {
      $pattern = "^\s+Token\slabel:\s${token[0]}\s+$"
      $command = "${utils_cmd} --init-token --slot ${idx} --pin ${token[1]['pin']} --so-pin ${token[1]['so_pin']} --label ${token[0]}"
    } else {
      $pattern = "^\s+Label:\s+${token[0]}\s+$"
      $command = "${utils_cmd} --init-token --free --pin ${token[1]['pin']} --so-pin ${token[1]['so_pin']} --label ${token[0]}"
    }
    exec {"${utils_cmd} init ${token[0]}":
      path    => ['/usr/bin', '/bin'],
      command => $command,
      unless  => "${utils_cmd} --show-slots | egrep '${pattern}'",
      require => File[$conf_file],
    }
  }
}
