namespace :user_system_has_groups do

  desc "Run migrations for the UserSystemHasGroups Extension"
  task :migrate => [:environment] do
    require File.join(File.dirname(__FILE__), '..', 'ext_lib', 'plugin_migrator')
    ActiveRecord::PluginMigrator.migrate(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  desc 'Test the UserSystemHasGroups Extension.'
  Rake::TestTask.new(:test) do |t|
    t.ruby_opts << "-r#{RAILS_ROOT}/test/test_helper"
    t.libs << File.join(File.dirname(__FILE__), '..', 'lib')
    t.pattern = File.join(File.dirname(__FILE__), '..', 'test/**/*_test.rb')
    t.verbose = true
  end

end
