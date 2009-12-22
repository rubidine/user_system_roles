namespace :user_system_roles do

  desc "Run migrations for the UserSystemRoles Extension"
  task :migrate => [:environment] do
    require File.join(File.dirname(__FILE__), '..', 'db', 'user_system_roles_migrator')
    UserSystemRolesMigrator.migrate(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  desc 'Test the UserSystemHasRoles Extension.'
  Rake::TestTask.new(:test) do |t|
    t.ruby_opts << "-r#{RAILS_ROOT}/test/test_helper"
    t.libs << File.join(File.dirname(__FILE__), '..', 'lib')
    t.pattern = File.join(File.dirname(__FILE__), '..', 'test/**/*_test.rb')
    t.verbose = true
  end

end
