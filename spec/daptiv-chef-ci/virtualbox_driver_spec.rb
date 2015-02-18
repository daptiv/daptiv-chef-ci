require 'daptiv-chef-ci/virtualbox_driver'
require 'daptiv-chef-ci/logger'

describe DaptivChefCI::VirtualBoxDriver, unit: true do
  describe 'cleanup_vms' do
    it 'should poweroff and unregister all machines with a matching name' do
      boxes = [
        '"aspnet_1372120179" {b1937a1c-c6c4-4777-88d0-dfa9066fb126}',
        '"aspnet_1379346156" {7bb1bbce-c6cc-47a2-9c51-57ede42e02b5}',
        '"python_1372120178" {c1937a1c-c6c4-4777-88d0-dfa9066fb156}'
      ]
      @shell = mock
      @vbox = DaptivChefCI::VirtualBoxDriver.new(@shell)

      @shell.should_receive(:exec_cmd)
        .with('vboxmanage list runningvms').and_return(boxes)

      @shell.should_receive(:exec_cmd)
        .with('vboxmanage controlvm "aspnet_1372120179" poweroff').once
      @shell.should_receive(:exec_cmd)
        .with('vboxmanage unregistervm "aspnet_1372120179"').once

      @shell.should_receive(:exec_cmd)
        .with('vboxmanage controlvm "aspnet_1379346156" poweroff').once
      @shell.should_receive(:exec_cmd)
        .with('vboxmanage unregistervm "aspnet_1379346156"').once

      @shell.should_receive(:exec_cmd)
        .with('vboxmanage controlvm "python_1372120178" poweroff').never
      @shell.should_receive(:exec_cmd)
        .with('vboxmanage unregistervm "python_1372120178"').never

      @vbox.cleanup_vms('aspnet')
    end
  end
end
