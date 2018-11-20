# # encoding: utf-8

# Inspec test for recipe crowchild::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# Icinga Repository
describe apt('http://packages.icinga.com/ubuntu') do
  it { should exist }
  it { should be_enabled }
end
