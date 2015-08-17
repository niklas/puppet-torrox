require "spec_helper"

describe "rails::passenger" do
  let(:facts) do
    {
      :rvm_installed => true
    }
  end
  let(:title) { "ruby-1.9.3-p194" }
  let(:params) do
    {
      :passenger_version => "4.0.8",
    }
  end

  it "installs passenger" do
    should contain_class("rvm::passenger::apache").
      with_ruby_version("ruby-1.9.3-p194").
      with_version("4.0.8")
  end

  it "integrates with apache" do
    should contain_package("apache2").with_ensure("present")
    should contain_service("apache2").with_ensure("running")
  end
end
