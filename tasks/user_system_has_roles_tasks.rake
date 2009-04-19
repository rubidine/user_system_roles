namespace :user_system_has_roles do

  desc "Run migrations for the UserSystemHasRoles Extension"
  task :migrate => [:environment] do
    require File.join(File.dirname(__FILE__), '..', 'ext_lib', 'plugin_migrator')
    ActiveRecord::UserSystemHasRolesMigrator.migrate(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  desc 'Test the UserSystemHasRoles Extension.'
  Rake::TestTask.new(:test) do |t|
    t.ruby_opts << "-r#{RAILS_ROOT}/test/test_helper"
    t.libs << File.join(File.dirname(__FILE__), '..', 'lib')
    t.pattern = File.join(File.dirname(__FILE__), '..', 'test/**/*_test.rb')
    t.verbose = true
  end

end
