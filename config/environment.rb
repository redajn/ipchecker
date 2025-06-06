require 'bundler/setup'
Bundler.require(:default)

require_relative 'database'

%w[models contracts services helpers routes workers].each do |folder|
  Dir["#{__dir__}/../app/#{folder}/**/*.rb"].each { |f| require f }
end
