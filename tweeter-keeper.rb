require 'rubygems'
require 'tweetstream'
require 'mongo'
require 'twitter'
require 'yaml'
require 'date'
require 'time'

config = YAML.load_file('config.yaml')

#set up a connection to a local MongoDB or MongoLab from Heroku
  if ENV['MONGOLAB_URI']
    uri = URI.parse(ENV['MONGOLAB_URI'])
    conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
    db = conn.db(uri.path.gsub(/^\//, ''))
  else
    db = Mongo::Connection.new.db("tweeterkeeper")

  end

#all tweets will be stored in a collection
tweets = db.collection("tweets")

tracking_keywords = Array['bieber'];
follow_users = Twitter.friend_ids("jefflinwood").ids;

TweetStream.configure do |c|
  c.consumer_key       = 'change_me'
  c.consumer_secret    = 'change_me'
  c.oauth_token        = 'change_me'
  c.oauth_token_secret = 'change_me'
  c.auth_method = :basic
  c.parser = :yajl
end

client = TweetStream::Client.new()

client.on_delete do |status_id, user_id|
  puts "Removing #{status_id} from storage"
  tweets.remove({"status" => status_id})
end

client.on_error do |message|
  puts "Error received #{message}"
end

params = Hash.new;
params[:follow] = follow_users;
params[:track] = tracking_keywords;

client.filter(params) do |status|
  puts "#{status.text} - #{status.created_at}"
  tweets.insert(status)
end
