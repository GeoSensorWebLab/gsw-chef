# # encoding: utf-8

# Inspec test for recipe crowchild::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# Icinga Repository
describe apt('http://packages.icinga.com/ubuntu') do
  it { should exist }
  it { should be_enabled }
end

# Icinga 2
describe package('icinga2') do
  it { should be_installed }
end

describe service('icinga2') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe directory('/etc/icinga2') do
  it { should exist }
end

# Icinga Web 2
describe package('postgresql-10') do
  it { should be_installed }
end

describe service('postgresql') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe port(5432) do
  it { should be_listening }
  its('processes') {should include 'postgres'}
end

describe package('icinga2-ido-pgsql') do
  it { should be_installed }
end

describe file('/opt/icinga_web_db_imported') do
  it { should exist }
end

describe package('apache2') do
  it { should be_installed }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
  its('processes') {should include 'apache2'}
end
