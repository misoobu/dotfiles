Pry.config.editor = "vim"

Pry.config.color = true

Pry.config.prompt = proc do |obj, nest_level, _pry_|
version = ''
version << "\001\e[0;31m\002"
version << "[ruby:#{RUBY_VERSION}]"
version << "\001\e[0m\002"

if defined? Rails
  version << "\001\e[0;32m\002"
  version << "[rails:#{Rails.version}]"
  version << "\001\e[0m\002"
end

"#{version} #{Pry.config.prompt_name}(#{Pry.view_clip(obj)})> "
end
