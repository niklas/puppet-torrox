require "spec_helper"

describe "rails::webserver" do
  let(:facts) do
    {
      :rvm_installed => true
    }
  end
  let(:title) { "rails-store" }

  context "in standard usage" do
    let(:params) do
      {
        :app_name          => "rails-store",
        :deploy_to         => "/tmp/",
        :rails_env         => "production",
        :ruby_version      => "ruby-1.9.3-p194",
        :server_name       => "rails-store.de",
        :server_aliases    => "www.rails-store.de rails-store.de www.rails-store.de",
        :server_ssl_port   => "443",
        :server_web_port   => "80",
        :ssl_cert_key_path => "/tmp/shared/rails-store.de.key",
        :ssl_cert_path     => "/tmp/shared/star.rails-store.de.cert",
        :user              => "application",
        :vhost_template    => "rails/apache-vhost-example.conf.erb",
      }
    end

    it "creates a vhost-config" do
      should contain_file("/etc/apache2/sites-available/rails-store.conf").
        with_content(%r!rails-store.de!).
        with_content(%r!ServerAlias www.rails-store.de rails-store.de www.rails-store.de!).
        with_content(%r!VirtualHost \*:443!).
        with_content(%r!^  ErrorDocument 503 .system.maintenance.html!).
        with_content(%r!^  RewriteCond %.DOCUMENT_ROOT..system.maintenance.html -l!)
    end

    it "creates the vhost without prefix" do
      should contain_rails__webserver("rails-store").
        with_server_prefix(/^$/).
        with_app_name("rails-store")

      should contain_file("/etc/apache2/sites-available/rails-store.conf").
        with_ensure("file")
    end

    it "integrates with apache" do
      should contain_exec("a2dissite default")
      should contain_exec("a2enmod ssl")
    end

    it "activates the vhost" do
      should contain_exec("a2ensite rails-store")
    end
  end

  context "with a changed prefix" do
    let(:params) do
      {
        :app_name          => "rails-store",
        :deploy_to         => "/tmp/",
        :rails_env         => "production",
        :ruby_version      => "ruby-1.9.3-p194",
        :server_name       => "rails-store.de",
        :server_aliases    => "www.rails-store.de rails-store.de www.rails-store.de",
        :server_ssl_port   => "443",
        :server_web_port   => "80",
        :ssl_cert_key_path => "/tmp/shared/rails-store.de.key",
        :ssl_cert_path     => "/tmp/shared/star.rails-store.de.cert",
        :user              => "application",
        :vhost_template    => "rails/apache-vhost-example.conf.erb",

        :server_prefix     => "00-",
      }
    end

    it "creates a vhost-config" do
      should contain_file("/etc/apache2/sites-available/00-rails-store.conf").
        with_content(%r!rails-store.de!).
        with_content(%r!ServerAlias www.rails-store.de rails-store.de www.rails-store.de!).
        with_content(%r!VirtualHost \*:443!).
        with_content(%r!^  ErrorDocument 503 .system.maintenance.html!).
        with_content(%r!^  RewriteCond %.DOCUMENT_ROOT..system.maintenance.html -l!)
    end

    it "handles the prefixed file" do
      should contain_file("/etc/apache2/sites-available/00-rails-store.conf").
        with_ensure("file")
    end

    it "supports changing from the non-prefixed version" do
      should contain_file("/etc/apache2/sites-available/rails-store.conf").
        with_ensure("absent")

      should_not contain_exec("a2ensite rails-store")
    end

    it "activates the vhost" do
      should contain_exec("a2ensite 00-rails-store")
    end
  end
end
