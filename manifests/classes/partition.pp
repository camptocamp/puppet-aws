class aws::partition {
  case $ec2_instance_type {
    "m1.large" : {

      file {["/mnt","/mnt2"]:
        ensure => directory,
      }

      mount {"/mnt":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral0}",
        fstype => "ext3",
        options => "defaults",
        require => File["/mnt"],
      }

      mount {"/mnt2":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral1}",
        fstype => "ext3",
        options => "defaults",
        require => File["/mnt2"],
      }

    }
  }
}
