/*

== Definition: aws::lvm-volume

A simple wrapper to easily create LVM volumes based on the aggregation of
the EC2 ephemeral storages.

Parameters:
- *name*: LogicalVolumeName (see option -n of lvcreate)
- *ensure*: present/absent, defaults to present.
- *size*: LogicalVolumeSize (see option -L of lvcreate)
- *fstype*: file system, defaults to ext4
- *mountpath*: a directory to mount the LogicalVolume
- *$mountpath_owner*: owner directory
- *mountpath_group*: group directory
- *mountpath_mode*: mode directory
- *pass*: The pass in which the mount is checked
- *dump*: Whether to dump the mount

Example usage:

  aws::lvm-volume {
    'backups': size => '10G', mountpath => '/var/backups';
    'vhosts':  size => '40G', mountpath => '/var/www/vhosts';
  }

Safety limitations:

Specifying "ensure => absent", only unmount and drop the logical volume.
Logical volume size can be extended, but not reduced (see README file of the
puppet-lvm module)

*/
define aws::lvm-volume(
  $size,
  $mountpath,
  $ensure=present,
  $vg='vg0',
  $fstype='ext4',
  $mountpath_owner=root,
  $mountpath_group=root,
  $mountpath_mode=755,
  $pass=2,
  $dump=1) {

  Physical_volume {
    require => [Package['lvm2'], Mount['/mnt']]
  }

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
    # Cf http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/instance-types.html?r=2844

    # One ephemeral device
    'm1.small', 'c1.medium', 'm2.xlarge', 'm2.2xlarge' : {

      $empheral0 = $::ec2_block_device_mapping_ephemeral0 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral0'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral0}"
      }

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
        }
      }

      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure           => present,
          physical_volumes => $empheral0,
          require          => Physical_volume[$empheral0],
        }
      }

    }

    # Two ephemeral devices
    'm1.large', 'm2.4xlarge', 'cc1.4xlarge', 'cg1.4xlarge' : {

      $empheral0 = $::ec2_block_device_mapping_ephemeral0 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral0'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral0}"
      }

      $empheral1 = $ec2_block_device_mapping_ephemeral1 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral1'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral1}"
      }

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
        }
      }

      if !defined(Physical_volume[$empheral1]) {
        physical_volume { $empheral1:
          ensure => present
        }
      }

      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure           => present,
          physical_volumes => [$empheral0,$empheral1],
        }
      }

    }

    # Four ephemeral devices
    'm1.xlarge', 'c1.xlarge', 'c2.8xlarge' : {

      $empheral0 = $::ec2_block_device_mapping_ephemeral0 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral0'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral0}"
      }

      $empheral1 = $::ec2_block_device_mapping_ephemeral1 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral1'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral1}"
      }

      $empheral2 = $::ec2_block_device_mapping_ephemeral2 ? {
        ''      => fail('unknown value for fact ec2_block_device_mapping_ephemeral2'),
        default => "/dev/${::ec2_block_device_mapping_ephemeral2}"
      }

      if !defined(Physical_volume[$empheral0]) {
        physical_volume { $empheral0:
          ensure  => present,
        }
      }

      if !defined(Physical_volume[$empheral1]) {
        physical_volume { $empheral1:
          ensure  => present,
        }
      }

      if !defined(Physical_volume[$empheral2]) {
        physical_volume { $empheral2:
          ensure  => present,
        }
      }

      if !defined(Volume_group[$vg]){
        volume_group { $vg:
          ensure           => present,
          physical_volumes => [$empheral0,$empheral1,$empheral2],
          require          => [
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
    ensure       => $ensure,
    volume_group => $vg,
    size         => $size,
    require      => $ensure ? {
      present => Volume_group[$vg],
      absent  => Mount[$mountpath],
    },
  }

  filesystem { "/dev/${vg}/${name}":
    ensure    => $ensure,
    fs_type   => $fstype,
    require   => $ensure ? {
      present => Logical_volume[$name],
      absent  => undef,
    }
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
    ensure  => $ensure ? {
      present => mounted,
      default => absent,
    },
    device  => "/dev/mapper/${vg}-${name}",
    fstype  => $fstype,
    options => 'defaults',
    pass    => $pass,
    dump    => $dump,
    atboot  => true,
    require => [File[$mountpath],Filesystem["/dev/${vg}/${name}"]],
  }

}
