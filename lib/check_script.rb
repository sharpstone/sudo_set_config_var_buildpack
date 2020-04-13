#! /usr/bin/env ruby
STDOUT.sync = true

puts "-----> Checking for absolute values in PATHs"

ENV.select {|k,v| k.end_with?("PATH") }.each do |env_key, env_value|
  if (relative_path = env_value.split(":").detect {|path| !path.start_with?("/")})
    msg = %Q{All paths must be absolute, ENV["#{env_key}"] contains #{env_value.inspect} with relative_path #{relative_path.inspect}}
    raise msg
  end
end

puts "       Everything looks good to me"
exit 0
