require "spec_helper"

describe "rails::application" do
  let(:title) { "testapp" }
  let(:common_params) do
    {
      :user              => "heinz",
      :rails_env         => "production",
      :database_adapter  => "mysql",
      :database_host     => "localhost",
      :database_port     => "3306",
      :database_user     => "root",
      :database_password => "",
    }
  end
  let(:params) { common_params }

  it "configures logrotate" do
     should contain_package("logrotate").with_ensure("latest")

     should contain_file("/etc/logrotate.d/testapp-production").
       with_ensure("present").
       with_group("root").
       with_owner("root").
       with_content(/daily/).
       with_content(/compress/).
       with_content(/olddir/).
       with_content(/rotate 99/).
       without_content(/rails::application/).
       with_content(%r!testapp!).
       with_content(%r!/home/heinz/projects/testapp/production/shared/log/\*\.log!)

     should contain_file("/home/heinz/projects/testapp/production/shared/log/rotated").
       with_ensure("directory").
       with_mode("0755")
  end

  it "ensures that crond is running" do
    should contain_package("cron").with_ensure("installed")
    should contain_service("crond").with_ensure("running")
  end

  it "provides directories for logs" do
    should contain_file("/home/heinz/projects/testapp/production/shared/log").
      with_ensure("directory").
      with_owner("heinz").
      with_group("heinz").
      with_mode("0755")

    should contain_file("/home/heinz/projects/testapp/production/shared/log/rotated").
      with_ensure("directory").
      with_owner("heinz").
      with_group("heinz").
      with_mode("0755")

    should contain_file("/home/heinz/projects/testapp/production/shared/log/production.log").
      with_mode("0666")
  end

  it "database.yml is initialized" do
    should contain_file("/home/heinz/projects/testapp/production/shared/config/database.yml").
      with_replace("false")
  end

  it "creates a normal capistrano-setup" do
    should contain_file("/home/heinz/projects/testapp/production/releases").
      with_ensure("directory").
      with_owner("heinz").
      with_group("heinz").
      with_mode("0755")

    should contain_file("/home/heinz/projects/testapp/production/shared").
      with_ensure("directory").
      with_owner("heinz").
      with_group("heinz").
      with_mode("0755")

    should contain_file("/home/heinz/projects/testapp/production/shared/config").
      with_ensure("directory").
      with_owner("heinz").
      with_group("heinz").
      with_mode("0755")
  end

  it "maintains a symlink to the releases-dir" do
    should contain_file("/home/heinz/projects/testapp/production/current")
      .with_ensure("link")
      .with_target(%r!/home/heinz/projects/testapp/production/releases/.*!)
  end

  context "capistrano-versions" do
    context "2.x" do
      let(:params) do
        common_params.merge({
          :capistrano_version => 2,
        })
      end

      it "creates a capistrano 2-system dir" do
        should contain_file("/home/heinz/projects/testapp/production/shared/system").
          with_ensure("directory").
          with_owner("heinz").
          with_group("heinz").
          with_mode("0755")
      end

      it "creates a directory for run-files" do
        should contain_file("run-dir for heinz of testapp").
          with_ensure("directory").
          with_path("/home/heinz/projects/testapp/production/shared/pids").
          with_owner("heinz").
          with_group("root").
          with_mode("0755")
      end
    end

    context "3.x" do
      let(:params) do
        common_params.merge({
          :capistrano_version => 3,
        })
      end

      it "creates a capistrano 3-system dir" do
        should contain_file("/home/heinz/projects/testapp/production/shared/public/system").
          with_ensure("directory").
          with_owner("heinz").
          with_group("heinz").
          with_mode("0755")
      end

      it "creates a directory for run-files" do
        should contain_file("run-dir for heinz of testapp").
          with_ensure("directory").
          with_path("/home/heinz/projects/testapp/production/shared/tmp/pids").
          with_owner("heinz").
          with_group("root").
          with_mode("0755")
      end

      it "creates a directory for the repo" do
        should contain_file("/home/heinz/projects/testapp/production/repo").
          with_ensure("directory").
          with_owner("heinz").
          with_group("heinz").
          with_mode("0755")
      end
    end
  end
end
