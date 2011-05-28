require 'rubygems'
require 'tweetstream'
require 'mongo'

#set up a connection to a local MongoDB
@db = Mongo::Connection.new.db("tweeterkeeper")

#all tweets will be stored in a collection called tweets
@tweets = @db.collection("tweets")

@tracking_keywords = Array['drupal','mongodb','three20'];

@client = TweetStream::Client.new('USERNAME','PASSWORD')

@client.on_delete do |status_id, user_id|
  puts "Removing #{status_id} from storage"
  @tweets.remove({"status" => status_id})
end

@client.track(*@tracking_keywords) do |status|
  puts "#{status.text}"
 @tweets.insert(status)
end