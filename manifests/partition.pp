class aws::partition {

  if defined('$ec2_instance_type') {
    $fstype = $::lsbdistcodename ? {
      'squeeze' => 'ext4',
      default   => 'ext3',
    }

    case $::ec2_instance_type {
      'm1.small', 'm2.2xlarge' : {

        file {'/mnt':
          ensure => directory,
          mode   => '0755',
        }

        mount {'/mnt':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral0}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt'],
        }
      }

      'm1.large' : {

        file {['/mnt','/mnt2']:
          ensure => directory,
          mode   => '0755',
        }

        mount {'/mnt':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral0}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt'],
        }

        mount {'/mnt2':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral1}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt2'],
        }
      }

      'm1.xlarge', 'c1.xlarge' : {

        file {['/mnt', '/mnt2', '/mnt3', '/mnt4']:
          ensure => directory,
          mode   => '0755',
        }

        mount {'/mnt':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral0}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt'],
        }

        mount {'/mnt2':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral1}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt2'],
        }

        mount {'/mnt3':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral2}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt3'],
        }

        mount {'/mnt4':
          ensure  => mounted,
          device  => "/dev/${::ec2_block_device_mapping_ephemeral3}",
          fstype  => $fstype,
          options => 'defaults',
          require => File['/mnt4'],
        }

      }

      default: {
        fail "Unknown EC2 instance type : ${::ec2_instance_type }"
      }
    }
  }
}
