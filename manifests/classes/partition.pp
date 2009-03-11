class aws::partition {
  case $ec2_instance_type {
    "m1.large" : {
      mount {"/mnt":
        ensure => absent,
      }

      file {["/mnt/data1", "/mnt/data2"]:
        ensure => directory,
      }

      mount {"/mnt/data1":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral0}",
        fstype => "ext3",
        options => "defaults",
        require => [ Mount["/mnt"], File["/mnt/data1"] ],
      }

      mount {"/mnt/data2":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral1}",
        fstype => "ext3",
        options => "defaults",
        require => [ Mount["/mnt"], File["/mnt/data2"] ],
      }
    }
  }
}
