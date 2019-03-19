[
  "flexibleplan.com",
].map {|i| Whitelist.find_or_create_by regex_string: i}
