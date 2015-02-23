require 'spec_helper'

describe 'rails::application' do
  let(:title) { 'testapp' }
  let(:params) do
    {
      :user              => 'heinz',
      :rails_env         => 'production',
      :database_adapter  => 'mysql',
      :database_host     => 'localhost',
      :database_port     => '3306',
      :database_user     => 'root',
      :database_password => '',
    }
  end

  it 'configures logrotate' do
     should contain_package('logrotate').with_ensure('latest')

     should contain_File('/etc/logrotate.d/testapp-production').
       with_ensure('present').
       with_group('root').
       with_owner('root').
       with_content(/daily/).
       with_content(/compress/).
       with_content(/olddir/).
       with_content(/rotate 99/).
       without_content(/rails::application/).
       with_content(%r!testapp!).
       with_content(%r!/home/heinz/projects/testapp/production/shared/log/\*\.log!)

     should contain_File('/home/heinz/projects/testapp/production/shared/log/rotated').
       with_ensure("directory").
       with_mode("0755")
  end
end
