ActiveRecord::Base.logger = Logger.new STDOUT

User.create!(name: "admin", password: "admin", admin: true) unless User.exists?(name: "admin")

FsIsacIgnore.find_or_create_by regex_string: "IBM",       case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "BIG-IP",    case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "Juniper",   case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "Red Hat",   case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "Amazon",    case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "Junos",     case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "McAfee",    case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "SonicWALL", case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "Apache",    case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "Cisco",     case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "SUSE",      case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "HP",        case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "Palo Alto", case_sensitive: false
FsIsacIgnore.find_or_create_by regex_string: "F5",        case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "SAP",       case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "iOS",       case_sensitive: true
FsIsacIgnore.find_or_create_by regex_string: "Drupal",    case_sensitive: false
