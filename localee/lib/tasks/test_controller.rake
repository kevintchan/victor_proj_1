require 'set'

task :test_controller => :environment do
  aq = AppQuery.new
  puts aq

  aq.get_all_users
  if (!aq.users.empty?)
    print "please empty users table first\n"
    exit 0
  end

  aq.get_all_locations
  if (!aq.locations.empty?)
    print "please empty locations table first\n"
    exit 0
  end

  num_users = 15
  num_locations = 15
  more_follows = 7
  more_posts = 30


  srand(123)
  rng = Random.new(123)

  # users we create, id => userhash
  users_in_mem = {}

  # create 'num_users' users
  (1..num_users).each do |i|
    uname = "user" + i.to_s
    email = uname + "@roxsox.com"
    user_hash = {:name => uname, :email => uname, :password => uname}

    if(!aq.create_user(user_hash))
      print "create_user failed for user hash:"
      print user_hash
      print "/n"
      exit 0
    end

    users_in_mem[aq.user[:id]]=(aq.user)
  end

  # locations we create, id => locationhash
  locations_in_mem = {}

  # create locations
  (1..num_locations).each do |i|
    lname = "location" + i.to_s
    lat = rng.rand * (37.90302207665658 - 37.84882225623786) + 37.84882225623786
    lng = rng.rand * (122.30416958764647 - 122.2011727614746) - 122.30416958764647
    location_hash = {:name => lname, :latitude => lat, :longitude => lng}
    if (!aq.create_location(location_hash))
      print "create_location failed for location hash:"
      print location_hash
      print "\n"
      exit 0
    end
    locations_in_mem[aq.new_location[:id]] = aq.new_location
  end

  ### test get_all_users ###
  # test by :id field
  aq.get_all_users
  if (aq.users.length != num_users)
    print "get_all_users found " + aq.users.length.to_s +
          "when we created " + num_users.to_s + " users\n"
    print "get_all_users found: " + aq.users.to_s
    exit 0
  end

  user_ids = []
  aq.users.each do |user_from_db|
    user_id = user_from_db[:id]
    if (!users_in_mem.has_key?(user_id))
      print "user in memory differed from user in db for user id: " + user_id.to_s + "\n"
      exit 0
    end
    
    user_ids.push(user_id)
  end

  print "get_all_users passed!\n"


  ### test get_all_locations ###
  # test by :id field
  aq.get_all_locations

  if (aq.locations.length != num_locations)
    print "get_all_locations found " + aq.locations.length.to_s +
          " locations when we created " + num_locations.to_s + "locations\n"
    print "get_all_locations found: " + aq.locations.to_s
    exit 0
  end

  location_ids = []
  aq.locations.each do |location_from_db|
    location_id = location_from_db[:id]
    if (!locations_in_mem.has_key?(location_id))
      print "location in memory differed from location in db for location id: " +
            location_id.to_s + "\n"
      exit 0
    end

    location_ids.push(location_id)
  end

  print "get_all_locations passed!\n"

  follows_in_mem = {}

  # add some follows
  user_ids.each do |u|
    num_follows = rng.rand(more_follows)
    location_ids.sample(num_follows).each do |l|
      aq.follow_location(u, l)
      if (!follows_in_mem.has_key?(u))
        follows_in_mem[u] = []
      end
      follows_in_mem[u].push(l)
    end
  end

  posts_in_mem = {}
  posts_by_location = {}
  
  # add some posts
  post_counter = 1
  user_ids.each do |u|
    num_posts = rng.rand(more_posts)
    (1..num_posts).each do |p|
      lid = location_ids.sample
      post_hash = {:location_id => lid, :text => "post" + post_counter.to_s}
      if (!aq.create_post(u, post_hash))
        print "create_post failed for arguments:\n"
        print "user_id: " + u.to_s + "\n"
        print "post hash: " + post_hash.to_s + "\n"
        exit 0
      end
        
      post_counter += 1
      posts_in_mem[aq.new_post[:text]] = aq.new_post

      if (!posts_by_location.has_key?(lid))
        posts_by_location[lid] = Set.new
      end
      posts_by_location[lid].add(aq.new_post)
    end
  end

  ### test get_all_posts
  ## by post text
  aq.get_all_posts

  if (aq.posts.length != posts_in_mem.length)
    print "get_all_posts found " + aq.posts.length.to_s +
          " posts when we created " + posts_in_mem.to_s + "posts\n"
    print "get_all_posts found: " + aq.posts.to_s
    exit 0
  end

  aq.posts.each do |post_from_db|
    post_text = post_from_db[:text]
    if (!posts_in_mem.has_key?(post_text))
      print "post in memory differed from post in db for post id: " +
            post_text.to_s + "\n"
      exit 0
    end
  end

  print "get_all_posts passed!\n"

  ### test get_following_locations ###
  # by arrays of ids

  user_ids.each do |user_id|
    location_ids_from_db = []
    aq.get_following_locations(user_id)
    locations_from_db = aq.following_locations
    locations_from_db.each do |loc|
      location_ids_from_db.push(loc[:id])
    end
    if (!follows_in_mem.has_key?(user_id))
      follows_in_mem[user_id] = []
    end
    if (!location_ids_from_db.eql?(follows_in_mem[user_id]))
      print "get_following_locations failed for user id: " + user_id.to_s + "\n"
      print "user followed: " + follows_in_mem[user_id].to_s + "\n"
      print "db said user follows: " + location_ids_from_db.to_s + "\n"
      exit 0
    end
  end

  print "get_following_locations passed!\n"

  ### test get_posts_for_location ###
  # compare arrays of :text
  
  location_ids.each do |loc_id|
    aq.get_posts_for_location(loc_id)
    post_texts_from_db = []
    aq.posts.each do |post|
      post_texts_from_db.push(post[:text])
    end

    post_texts_from_mem = []
    posts_by_location[loc_id].each do |post|
      post_texts_from_mem.push(post[:text])
    end

    if (!post_texts_from_db.eql?(post_texts_from_mem))
      print "get_posts_for_location failed for location id: " + loc_id.to_s + "\n"
      print "location had: " + post_texts_from_mem.to_s + "\n"
      print "db said location_had: " + post_texts_from_db.to_s + "\n"
      exit 0
    end
  end

  print "get_posts_for_location passed!\n"

end