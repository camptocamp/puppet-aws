define aws::lvm-volume(
  $ensure=present,
  $size,
  $vg='vg0',
  $fstype='ext4',
  $mountpath,
  $mountpath_owner=root,
  $mountpath_group=root,
  $mountpath_mode=755,
  $pass=2,
  $dump=1) {

  if !defined(Package['lvm2']) {
    package{'lvm2':
      ensure => present,
    }
  }

  if !defined(Mount['/mnt']) { 
    mount {'/mnt': 
      ensure => absent,
    }
  }

  case $ec2_instance_type {
    
    'm1.small','m2.2xlarge' : {
      
      $empheral0 = "/dev/${ec2_block_device_mapping_ephemeral0}"

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
          require => [Package['lvm2'], Mount['/mnt']],
        }
      }
      
      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure => present,
          physical_volumes => $empheral0,
          require => Physical_volume[$empheral0],
        }
      }

    }

    'm1.large' : {
     
      $empheral0 = "/dev/${ec2_block_device_mapping_ephemeral0}"
      $empheral1 = "/dev/${ec2_block_device_mapping_ephemeral1}"

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
          require => [Package['lvm2'], Mount['/mnt']],
        }
      }
 
      if !defined(Physical_volume[$empheral1]) {
        physical_volume { $empheral1:
          ensure => present
        }
      }
      
      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure => present,
          physical_volumes => [$empheral0,$empheral1],
          require => [Physical_volume[$empheral0],Physical_volume[$empheral1]]
        }
      }

    }

    'm1.xlarge', 'c1.xlarge' : {
      
      $empheral0 = "/dev/${ec2_block_device_mapping_ephemeral0}"
      $empheral1 = "/dev/${ec2_block_device_mapping_ephemeral1}"
      $empheral2 = "/dev/${ec2_block_device_mapping_ephemeral2}"

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
          require => [Package['lvm2'], Mount['/mnt']],
        }
      } 

      if !defined(Physical_volume[$empheral1]) {
        physical_volume { $empheral1:
          ensure  => present,
          require => [Package['lvm2'], Mount['/mnt']],
        }
      } 

      if !defined(Physical_volume[$empheral2]) {
        physical_volume { $empheral2:
          ensure  => present,
          require => [Package['lvm2'], Mount['/mnt']],
        }
      }
      
      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure => present,
          physical_volumes => [$empheral0,$empheral1,$empheral2],
          require => [
            Physical_volume[$empheral0],
            Physical_volume[$empheral1],
            Physical_volume[$empheral2],
          ],
        }
      }
    }

    default : { fail 'Unknown ec2 instance type' }

  }
   
  logical_volume { $name:
    ensure       => present,
    volume_group => $vg,
    size         => $size,
    require      => Volume_group[$vg],
  }

  filesystem { "/dev/${vg}/${name}":
    ensure  => $ensure,
    require => Logical_volume[$name],
  }

  if !defined(File[$mountpath]){
    file{ $mountpath:
      ensure => directory,
      owner  => $mountpath_owner,
      group  => $mountpath_group,
      mode   => $mountpath_mode,
    }
  } 

  mount { $mountpath:
    device  => "/dev/mapper/${vg}-${name}",
    ensure  => mounted,
    fstype  => $fstype,
    options => 'defaults',
    pass    => $pass,
    dump    => $dump,
    atboot  => true,
    require => [File[$mountpath],Filesystem["/dev/${vg}/${name}"]],
  }

}
