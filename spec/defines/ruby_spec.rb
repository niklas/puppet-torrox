require 'spec_helper'

# In order to deploy a rails app using capistrano without any hassle
# As a developer
# I want to have a ruby with bundler preinstalled

describe 'rails::ruby' do
  let(:facts) do
    {
      :rvm_installed => true
    }
  end

  context 'intended standard usage' do
    let(:title) { 'ree-1.7.01' }
    let(:params) do
      {
        :user            => 'bert',
        :gemset          => 'nasa',
        :default_use     => false,
        :bundler_version => '1.2.3.4.5',
      }
    end

    it 'installs a ruby for a user' do
      should contain_rails__ruby('ree-1.7.01').
        with_user("bert").
        with_gemset("nasa")
    end

    it 'manages system-wide rvmrc' do
      should contain_file('/etc/rvmrc').
        with_content(%r!rvm_auto_reload_flag=2!)
    end

    it 'manages system-wide gemrc' do
      should contain_file('/etc/gemrc')
    end

    it 'uses rvms primitives to provide a ruby' do
      should contain_rvm__system_user('bert')

      should contain_rvm_system_ruby('ree-1.7.01').
        with_default_use("false")
    end

    it 'creates a gemset' do
      should contain_rvm_gemset('ree-1.7.01@nasa')
    end

    it 'installs bundler' do
      should contain_rvm_gem('ree-1.7.01@nasa/bundler').
        with_ensure("1.2.3.4.5")
    end
  end

  context 'usage without gemset' do
    let(:title) { 'ree-1.7.02' }
    let(:params) do
      {
        :user         => 'wally',
        :ruby_version => 'ree-1.7.01',
        :default_use  => false,
      }
    end

    it 'installs a ruby for a user' do
      should contain_rails__ruby('ree-1.7.02').
        with_user("wally").
        with_ruby_version('ree-1.7.01').
        with_gemset(false)
    end

    it 'manages system-wide rvmrc' do
      should contain_file('/etc/rvmrc').
        with_content(%r!rvm_auto_reload_flag=2!)
    end

    it 'manages system-wide gemrc' do
      should contain_file('/etc/gemrc')
    end

    it 'uses rvms primitives to provide a ruby' do
      should contain_rvm__system_user('wally')

      should contain_rvm_system_ruby('ree-1.7.01').
        with_default_use("false")
    end

    it 'does not create a gemset' do
      should_not contain_rvm_gemset('ree-1.7.01@false')
      should_not contain_rvm_gemset('ree-1.7.01')
    end

    it 'installs bundler' do
      should contain_rvm_gem('ree-1.7.01/bundler').
        with_ensure("1.1.5")
    end
  end
end
