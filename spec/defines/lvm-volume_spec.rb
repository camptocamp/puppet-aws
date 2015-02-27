require 'spec_helper'
describe 'aws::lvm-volume' do
  let (:title) { 'foo' }

  let (:facts) { {
    :ec2_instance_type                   => 'm1.large',
    :ec2_block_device_mapping_ephemeral0 => 'dsp',
    :ec2_block_device_mapping_ephemeral1 => 'dsq',
  } }

  context 'when no parameters are passed' do
    it 'should fail' do
      expect { should compile }.to raise_error(/Must pass/)
    end
  end

  context 'when setting all mandatory parameters' do
    let (:params) { {
      :size      => '10G',
      :mountpath => '/srv/bar',
    } }

    it { should compile.with_all_deps }
  end
end
