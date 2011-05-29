require 'rubygems'
require 'tweetstream'
require 'mongo'
require 'twitter'
require 'yaml'

@config = YAML.load_file('config.yaml')

#set up a connection to a local MongoDB
@db = Mongo::Connection.new.db("tweeterkeeper")

#all tweets will be stored in a collection called tweets
@tweets = @db.collection("tweets")

@tracking_keywords = Array['drupal','mongodb','three20'];
@follow_users = Twitter.friend_ids("jefflinwood").ids;

@client = TweetStream::Client.new(@config['username'],@config['password'])

@client.on_delete do |status_id, user_id|
  puts "Removing #{status_id} from storage"
  @tweets.remove({"status" => status_id})
end

@params = Hash.new;
@params[:follow] = @follow_users;
@params[:track] = @tracking_keywords;

@client.filter(@params) do |status|
  puts "#{status.text}"
 @tweets.insert(status)
end