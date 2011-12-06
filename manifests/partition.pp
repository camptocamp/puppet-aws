class aws::partition {

  $fstype = $lsbdistcodename ? {
    'squeeze' => 'ext4',
    default   => 'ext3',
  }

  if ($ec2_block_device_mapping_ephemeral0) {
    file {'/mnt':
      ensure => directory,
      mode   => 755,
    }
    mount {'/mnt':
      ensure  => mounted,
      device  => "/dev/${ec2_block_device_mapping_ephemeral0}",
      fstype  => $fstype,
      options => 'defaults',
      require => File['/mnt'],
    }
  }

  if ($ec2_block_device_mapping_ephemeral1) {
    file {'/mnt2':
      ensure => directory,
      mode   => 755,
    }
    mount {'/mnt2':
      ensure  => mounted,
      device  => "/dev/${ec2_block_device_mapping_ephemeral1}",
      fstype  => $fstype,
      options => 'defaults',
      require => File['/mnt2'],
    }
  }

  if ($ec2_block_device_mapping_ephemeral2) {
    file {'/mnt3':
      ensure => directory,
      mode   => 755,
    }
    mount {'/mnt3':
      ensure  => mounted,
      device  => "/dev/${ec2_block_device_mapping_ephemeral2}",
      fstype  => $fstype,
      options => 'defaults',
      require => File['/mnt3'],
    }
  }

  if ($ec2_block_device_mapping_ephemeral3) {
    file {'/mnt4':
      ensure => directory,
      mode   => 755,
    }
    mount {'/mnt4':
      ensure  => mounted,
      device  => "/dev/${ec2_block_device_mapping_ephemeral3}",
      fstype  => $fstype,
      options => 'defaults',
      require => File['/mnt4'],
    }
  }

}
