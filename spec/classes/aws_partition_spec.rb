require 'spec_helper'
describe 'aws::partition' do
  context 'when $ec2_instance_type is defined' do
    let (:facts) { {
      :ec2_instance_type                   => 'm1.small',
      :ec2_block_device_mapping_ephemeral0 => 'dsp',
      :lsbdistcodename                     => 'wheezy',
    } }

    it { should compile.with_all_deps }
  end
end
