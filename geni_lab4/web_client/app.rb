require 'sinatra'
require 'httparty'

get '/' do
  url = 'http://128.110.152.120:8090/list'
  @output = CloudLab.new url

  erb :index
end

class CloudLab
  BASIC_AUTH = { username: 'clouduser', password: 'EasyPassword15' }

  def initialize url
    @response = HTTParty.get(url, basic_auth: BASIC_AUTH)
  end

  def each
    output = @response['output'].split "\n"
    i = 3 # Start from row i + 1
    while i < output.length - 1
      instance = output[i].split "|"
      yield instance[1..-1]
      i = i + 1
    end
  end
end
