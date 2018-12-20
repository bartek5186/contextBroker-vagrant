require 'yaml'
require 'fileutils'

required_plugins = %w( vagrant-hostmanager vagrant-vbguest )
required_plugins.each do |plugin|
    system("vagrant plugin install #{plugin}", :chdir=>"/tmp") || exit! unless Vagrant.has_plugin?(plugin)
end

domains = {
  app: 'orion.devel'
}

vagrantfile_dir_path = File.dirname(__FILE__)

config = {
  local: vagrantfile_dir_path + '/config/vagrant-local.yml',
  example: vagrantfile_dir_path + '/config/vagrant-local.example.yml'
}

FileUtils.cp config[:example], config[:local] unless File.exist?(config[:local])
options = YAML.load_file config[:local]

# check github token
if options['github_token'].nil? || options['github_token'].to_s.length != 40
  puts "You must place REAL GitHub token into configuration:\n/config/vagrant-local.yml"
  exit
end

Vagrant.configure(2) do |config|
  config.vm.box = 'centos/7'
  config.vm.box_check_update = options['box_check_update']

  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = options['cpus']
    vb.memory = options['memory']
    vb.name = options['machine_name']
  end

  config.vm.define options['machine_name']
  config.vm.hostname = options['machine_name']
  config.vm.network 'private_network', ip: options['ip']
  config.vm.synced_folder '/var/www/', '/app', owner: 'vagrant', group: 'vagrant'
  config.vm.synced_folder '/var/www/', '/vagrant', disabled: true

  config.vm.provision :hostmanager
  config.hostmanager.enabled            = true
  config.hostmanager.manage_host        = true
  config.hostmanager.ignore_private_ip  = false
  config.hostmanager.include_offline    = true
  config.hostmanager.aliases            = domains.values

  config.vm.provision 'shell', path: './provision/once-as-root.sh', args: [options['timezone']]
  config.vm.provision 'shell', path: './provision/once-as-vagrant.sh', args: [options['github_token']], privileged: false
  config.vm.provision 'shell', path: './provision/always-as-root.sh', run: 'always'

end
