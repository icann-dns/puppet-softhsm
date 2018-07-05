# Class: SoftHSM
#
class softhsm (
  Integer[1,2]                 $version,
  String                       $package,
  String                       $utils_cmd,
  String                       $user,
  String                       $group,
  Stdlib::Absolutepath         $conf_file,
  Stdlib::Absolutepath         $tokendir,
  Enum['file','db']            $objectstore,
  Tea::Syslog_level            $log_level,
  Hash[String, Softhsm::Token] $tokens,
) {
  ensure_packages([$package])

  # lint:ignore:version_comparison
  if $version == 1 {
  # lint:endignore
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
    ensure  => directory,
    owner   => $user,
    group   => $group,
  }
  file {$conf_file:
    ensure  => file,
    content => $conf_file_content,
  }
  $tokens_array = any2array($tokens)
  $tokens_array.slice(2).each |$idx, $token| {
  # lint:ignore:version_comparison
    if $version == 1 {
  # lint:endignore
      $pattern = "^\s+Token\slabel:\s${token[0]}\s+$"
      $command = "${utils_cmd} --init-token --slot ${idx} --pin ${token[1]['pin']} --so-pin ${token[1]['so_pin']} --label ${token[0]}"
    } else {
      $pattern = "^\s+Label:\s+${token[0]}\s+$"
      $command = "${utils_cmd} --init-token --free --pin ${token[1]['pin']} --so-pin ${token[1]['so_pin']} --label ${token[0]}"
    }
    exec {"${utils_cmd} init ${token[0]}":
      path    => ['/usr/bin', '/bin'],
      command => $command,
      user    => $user,
      group   => $group,
      unless  => "${utils_cmd} --show-slots | egrep '${pattern}'",
      require => File[$conf_file,$tokendir],
    }
  }
}
