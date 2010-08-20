class aws::partition {
  case $ec2_instance_type {
    "m1.small", "m2.2xlarge" : {
    
      file {"/mnt":
        ensure => directory,
      }

      mount {"/mnt":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral0}",
        fstype => "ext3",
        options => "defaults",
        require => File["/mnt"],
      }
    }

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

    "m1.xlarge", "c1.xlarge" : {
      
      file {["/mnt","/mnt2", "/mnt3", "/mnt4"]:
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
     
      mount {"/mnt3":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral2}",
        fstype => "ext3",
        options => "defaults",   
        require => File["/mnt3"],
      }

      mount {"/mnt4":
        ensure => mounted,
        device => "/dev/${ec2_block_device_mapping_ephemeral3}",
        fstype => "ext3",
        options => "defaults",   
        require => File["/mnt4"],
      }

    }
  }
}
