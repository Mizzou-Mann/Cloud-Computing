require 'sinatra'
require 'httparty'

configure :production do
  set :port, 80
end

get '/' do
  @cloudlab = CloudLab.new
  @aws = Aws.new 

  erb :index
end

class CloudLab
  BASE_URL = 'http://128.110.152.120:8090'
  BASIC_AUTH = { username: 'clouduser', password: 'EasyPassword15' }

  def list
    web_request 'list' do |row|
      yield row
    end
  end

  def list_user
    web_request 'list_user' do |row|
      yield row
    end
  end

  private
  def web_request service
    response = HTTParty.get("#{BASE_URL}/#{service}", basic_auth: BASIC_AUTH)
    output = response['output'].split "\n"

    i = 3 # Start from row i + 1
    while i < output.length - 1
      row = output[i].split "|"
      yield row[1..-1]
      i = i + 1
    end
  end
end

class Aws
  attr_reader :hostname, :instance_id, :zone, :secgroup

  def initialize 
    @hostname = HTTParty.get('http://169.254.169.254/latest/meta-data/public-hostname').to_s
    @instance_id = HTTParty.get('http://169.254.169.254/latest/meta-data/instance-id').to_s
    @zone = HTTParty.get('http://169.254.169.254/latest/meta-data/placement/availability-zone').to_s
    @secgroup = HTTParty.get('http://169.254.169.254/latest/meta-data/security-groups').to_s
  end
end
