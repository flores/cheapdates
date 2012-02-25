#!/usr/bin/env ruby

require 'rubygems'
require 'mongo'
require 'haml'
require 'sinatra'
require 'crack'

set :environment, :production
set :port, '60000'

get '/fuckthatshit' do
  haml :fuckthatshit
end

get '/justgimmie' do
  geoip=`/usr/bin/geoiplookup -f /srv/cheapdates/geoip/GeoLiteCity.dat #{request.ip}`.split(',')
  @ip = request.ip
  @city = geoip[3].gsub(/[^[:alnum:]]/, '')
  if ( @city == 'NA' )
  haml :error
  else
  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
    @results=Hash.new
    data.find("date_city" => @city).each do |date|
          puts date.inspect
            if ( date.inspect =~ /_id\"=>.+?\'(.+?)\'/ )
                  oid = $1
          end
    if ( date.inspect =~ /date_name\"=>\"(.+?)\"/ )
                  date_name = $1
          else
                  date_name = "somedate"
          end
          puts date_name
          if ( date.inspect =~ /date_total_cost\"=>(.+?)\,/ )
                  date_cost = $1
          else
                  date_cost = 0
          end
          puts date_cost
          if ( date.inspect =~ /date_city\"=>\"(.+?)\"/ )
                  city = $1
          else
                  city = "unknown"
          end
          puts city
          @results["#{date_name}"]=Hash.new
          @results["#{date_name}"]["cost"] = "#{date_cost}"
          @results["#{date_name}"]["city"] = "#{city}"
          @results["#{date_name}"]["oid"] = "#{oid}"
  end
  haml :gimmie
  end
  
end


get '/' do
  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
  @results=Hash.new
  data.find().each do |date|
    date_name = date.get(date_name)
    oid = date.get(id)
    @results["#{date_name}"]=Hash.new
    @results["#{date_name}"]["cost"] = date.get(date_cost)
    @results["#{date_name}"]["city"] = date.get(city)
    @results["#{date_name}"]["oid"]  = date.get(id)
  end
  haml :list
end

get '/search' do
  haml :search
end

get '/add' do
  @myitemscount = [ "1", "2", "3", "4" ]
  @myloccount = [ "1", "2", "3" ]
  haml :add
end

get '/date/:id/show' do |oid|
  @myitemscount = [ "1", "2", "3", "4" ]
  @myloccount = [ "1", "2", "3" ]
  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
  @results=Hash.new
  data.find("date_name" => oid).each do |date|
    @loccount = []
    datename = date.get(date_name)
    @myloccount.each do |loc|
      newitemcount = 1
# sooo sorry
#{"_id"=>BSON::ObjectId('4e200af8eb5ea67ae6000001'), "date_total_cost"=>42.0, "activities"=>{"location1"=>{"name"=>"Gallery bar", "location1_item4_name"=>"", "location1_item4_cost"=>"", "location1_item3_name"=>"Tip", "location1_item1_name"=>"Jameson", "location1_item2_name"=>"Wine", "location1_item3_cost"=>"2", "location1_item2_cost"=>"5", "location1_item1_cost"=>"5"}, "location2"=>{"location2_item4_name"=>0, "name"=>"Various galleries", "location2_item4_cost"=>"", "location2_item3_name"=>0, "location2_item2_name"=>0, "location2_item3_cost"=>"", "location2_item1_name"=>0, "location2_item2_cost"=>"4", "location2_item1_cost"=>"20"}, "location3"=>{"location3_item3_name"=>0, "name"=>"Taco Trucks", "location3_item4_cost"=>"", "location3_item3_cost"=>"", "location3_item2_name"=>0, "location3_item1_name"=>0, "location3_item2_cost"=>"", "location3_item1_cost"=>"6", "location3_item4_name"=>0}}, "date_city"=>"DowntownLA", "date_name"=>"ArtWalk"}
      if ( date.inspect =~ /location#{loc}.+?[^_]name\"=>\"(.*?)\"/ )
        pie = $1 || nil
        if (pie)
        if ( pie != '' ) || ( pie =~ /[a-z]/) 
          @results["#{date_name}"]["location#{loc}"] = Hash.new
          @results["#{date_name}"]["location#{loc}"]["name"] = pie
          @results["#{date_name}"]["location#{loc}"]["stuff"]=Array.new
          @myitemscount.each do |item|


          if ( date.inspect =~ /location#{loc}_item#{item}_name\"=>\"?(.+?)"/ )
            itemname = $1
            puts "itemname is #{itemname}"
            if ( itemname != 0 ) && ( itemname =~ /\w/ ) && ( itemname !~ /\"/ )
              @results["#{date_name}"]["location#{loc}"]["stuff"] << newitemcount
              newitemcount+=1
              @results["#{date_name}"]["location#{loc}"]["item#{item}_name"] = itemname
              if ( date.inspect =~ /\"location#{loc}_item#{item}_cost\"=>\"*(.+?)(\}|\,|\")/ )
                @results["#{date_name}"]["location#{loc}"]["item#{item}_cost"] = $1
                puts "This is #{@results["#{date_name}"]["location#{loc}"]["item#{item}_cost"]}"
              end
            end
          end
        end
        @loccount << loc
      end
      end  
    end
  end
        @results["#{date_name}"]["cost"] = "#{date_cost}"
        @results["#{date_name}"]["city"] = "#{city}"
        @results["#{date_name}"]["oid"] = "#{oid}"
  @date_name=date_name
  end
  haml :listone
end

get '/city/:id/show' do |city|
  @city = city
  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
  @results=Hash.new
  data.find("date_city" => city).each do |date|
        puts date.inspect
	 oid = $1
        end
        if ( date.inspect =~ /date_name\"=>\"(.+?)\"/ )
                date_name = $1
        else
                date_name = "somedate"
        end
        puts date_name
        if ( date.inspect =~ /date_total_cost\"=>(.+?)\,/ )
                date_cost = $1
        else
                date_cost = 0
        end
        puts date_cost
        if ( date.inspect =~ /date_city\"=>\"(.+?)\"/ )
                city = $1
        else
                city = "unknown"
        end
        puts city
        @results["#{date_name}"]=Hash.new
        @results["#{date_name}"]["cost"] = "#{date_cost}"
        @results["#{date_name}"]["city"] = "#{city}"
        @results["#{date_name}"]["oid"] = "#{oid}"
  end
  haml :citylist

end

post '/add' do
    myitemscount = [ "1", "2", "3", "4" ]
    myloccount = [ "1", "2", "3" ]

        date_name = params["date_name"].gsub(/[^[:alnum:]]/, '')
  date_city = params["date_city"].gsub(/[^[:alnum:]]/, '')
  location1_name = params["location1_name"] || 0
  location1_item1_name = params["location1_item1_name"] || 0
  location1_item1_cost = params["location1_item1_cost"] || 0
  location1_item2_name = params["location1_item2_name"] || 0
  location1_item2_cost = params["location1_item2_cost"] || 0
  location1_item3_name = params["location1_item3_name"] || 0
  location1_item3_cost = params["location1_item3_cost"] || 0
  location1_item4_name = params["location1_item4_name"] || 0
  location1_item4_cost = params["location1_item4_cost"] || 0
  location2_name = params["location2_name"] || 0
  location2_item1_name = params["location2_item1_name"] || 0
  location2_item1_cost = params["location2_item1_cost"] || 0
  location2_item2_name = params["location2_item2_name"] || 0
  location2_item2_cost = params["location2_item2_cost"] || 0
  location2_item3_name = params["location2_item3_name"] || 0
  location2_item3_cost = params["location2_item3_cost"] || 0
  location2_item4_name = params["location2_item4_name"] || 0
  location2_item4_cost = params["location2_item4_cost"] || 0
  location3_name = params["location3_name"] || 0
  location3_item1_name = params["location3_item1_name"] || 0
  location3_item1_cost = params["location3_item1_cost"] || 0
  location3_item2_name = params["location3_item2_name"] || 0
  location3_item2_cost = params["location3_item2_cost"] || 0
  location3_item3_name = params["location3_item3_name"] || 0
  location3_item3_cost = params["location3_item3_cost"] || 0
  location3_item4_name = params["location3_item4_name"] || 0
  location3_item4_cost = params["location3_item4_cost"] || 0
  
  total_cost = location1_item1_cost.to_f + location1_item2_cost.to_f + location1_item3_cost.to_f + location1_item4_cost.to_f + location2_item1_cost.to_f + location2_item2_cost.to_f + location2_item3_cost.to_f + location2_item4_cost.to_f + location3_item1_cost.to_f + location3_item2_cost.to_f + location3_item3_cost.to_f + location3_item4_cost.to_f
  location1_cost = location1_item1_cost.to_f + location1_item2_cost.to_f + location1_item3_cost.to_f + location1_item4_cost.to_f
  location2_cost = location2_item1_cost.to_f + location2_item2_cost.to_f + location2_item3_cost.to_f + location2_item4_cost.to_f
  location3_cost = location3_item1_cost.to_f + location3_item2_cost.to_f + location3_item3_cost.to_f + location3_item4_cost.to_f
#        location_name = params["location_name"]|| 0
#        item_name = params["item_name"]
#        item_cost = params["item_cost"]
  

#  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
  id = data.insert(
  {
        "date_name" => date_name,
  "activities" => {
"location1" => {
  "name" => location1_name,

    "location1_item1_name" => location1_item1_name,
    "location1_item1_cost" => location1_item1_cost,
    "location1_item2_name" => location1_item2_name,
    "location1_item2_cost" => location1_item2_cost,
    "location1_item3_name" => location1_item3_name,
    "location1_item3_cost" => location1_item3_cost,
    "location1_item4_name" => location1_item4_name,
    "location1_item4_cost" => location1_item4_cost
    },
"location2" => {
  "name" => location2_name,

    "location2_item1_name" => location2_item1_name,
    "location2_item1_cost" => location2_item1_cost,
    "location2_item2_name" => location2_item2_name,
    "location2_item2_cost" => location2_item2_cost,
    "location2_item3_name" => location2_item3_name,
    "location2_item3_cost" => location2_item3_cost,
    "location2_item4_name" => location2_item4_name,
    "location2_item4_cost" => location2_item4_cost
    },
"location3" => {
  "name" => location3_name,

    "location3_item1_name" => location3_item1_name,
    "location3_item1_cost" => location3_item1_cost,
    "location3_item2_name" => location3_item2_name,
    "location3_item2_cost" => location3_item2_cost,
    "location3_item3_name" => location3_item3_name,
    "location3_item3_cost" => location3_item3_cost,
    "location3_item4_name" => location3_item4_name,
    "location3_item4_cost" => location3_item4_cost

    }
  },
  "date_total_cost" =>  total_cost,
  "date_city" => date_city
  })
  redirect "/date/#{date_name}/show"
end

post '/search' do
  howcheap = params["howcheap"].to_i
  puts howcheap
    db = Mongo::Connection.new("localhost", 27017).db("cheapdates")
  data = db.collection('dates')
#  result = data.find().inspect
#  puts result.inspect
  @results=Hash.new
  data.find("date_total_cost" => {"$lte" => howcheap}).each do |date|
        puts date.inspect
#       @results << date.inspect
#       puts @results[0][:date_name]
        oid = date.get(id)
        @results["#{date_name}"]=Hash.new
        @results["#{date_name}"]["cost"] = date.get(cost)
        @results["#{date_name}"]["city"] = date.get(city)
        @results["#{date_name}"]["oid"] = oid
  end
  haml :searchlist
end
