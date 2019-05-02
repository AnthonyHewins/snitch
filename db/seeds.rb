ActiveRecord::Base.logger = Logger.new STDOUT

User.create!(name: "admin", password: "admin", admin: true) unless User.exists?(name: "admin")
