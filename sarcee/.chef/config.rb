local_mode true
chef_zero.enabled true
cookbook_path "berks-cookbooks"
data_bag_path "test/data_bags"
knife[:secret_file] = "test/encrypted_data_bag_secret"
