class AppQuery

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  attr_accessor :posts
  attr_accessor :users
  attr_accessor :user
  attr_accessor :locations
  attr_accessor :following_locations
  attr_accessor :location

  ###########################################
  #  TODO: Implement the following methods  #
  ###########################################

  # Purpose: Show all the locations being followed by the current user
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @following_locations - An array of hashes of location information.
  #                          Order does not matter.
  #                          Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_following_locations(user_id)
    @following_locations = []

    query = "SELECT L.id AS id, L.name AS name,
                    L.latitude AS latitude,
                    L.longitude AS longitude
             FROM locations L, follows F
             WHERE L.id = F.location_id AND F.user_id = #{user_id}"
    results = ActiveRecord::Base.connection.execute(query)

    results.each do |row|
      @following_locations.push({:id => row["id"],
                                 :name => row["name"],
                                 :latitude => row["latitude"],
                                 :longitude => row["longitude"]})
    end

  end

  # Purpose: Show the information and all posts for a given location
  # Input:
  #   location_id - The id of the location for which to show the information and posts
  # Assign: assign the following variables
  #   @location - A hash of the given location. The hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #   @posts - An array of hashes of post information, for the given location.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_posts_for_location(location_id)
    loc_query = "SELECT L.id AS id, L.name AS name,
                        L.latitude AS latitude,
                        L.longitude AS longitude
                 FROM locations L
                 WHERE L.id = #{location_id}"
    @location = ActiveRecord::Base.connection.execute(query)[0]
    post_query = "SELECT P.user_id as author_id, U.name as author,
                         P.text as text, P.created_at as create_at
                  FROM posts P, users U
                  WHERE P.user_id = U.id AND P.location_id = #{location_id}"
    results = ActiveRecord::Base.connection.execute(post_query)
    results.each {|post| post.merge(:location => @location)}

    @posts = results
  end

  # Purpose: Show the current user's stream of posts from all the locations the user follows
  # Input:
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information from all locations the current user follows.
  #            Reverse chronological order by creation time (newest post first).
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_stream_for_user(user_id)
    final_posts = []

    # @following_locations
    get_following_locations(user_id)

    @following_locations.each do |location|
      get_posts_for_location(location[:id])
      final_posts.merge(@posts)
    end

    @posts = final_posts
  end

  # Purpose: Retrieve the locations within a GPS bounding box
  # Input:
  #   nelat - latitude of the north-east corner of the bounding box
  #   nelng - longitude of the north-east corner of the bounding box
  #   swlat - latitude of the south-west corner of the bounding box
  #   swlng - longitude of the south-west corner of the bounding box
  #   user_id - the user id of the current user
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information, which lie within the bounding box specified by the input.
  #                In increasing latitude order.
  #                At most 50 locations.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     * :follows - true if the current user follows this location. false otherwise.
  # Output: None
  def get_nearby_locations(nelat, nelng, swlat, swlng, user_id)
    near_query = "SELECT L.id AS id, L.name as name,
                         L.latitude as latitude, L.longitude as longitude,
                         CASE WHEN F.user_id = #{user_id} THEN true ELSE false
                  FROM locations L, follows F
                  WHERE F.location_id = L.id,
                        L.latitude < nelast AND L.latitude > swlat AND
                        L.longitude < nelng AND L.longitude > swlng"

    @locations = ActiveRecord::Base.connection.execute(near_query)
  end

  # Purpose: Create a new location
  # Input:
  #   location_hash - A hash of the new location information.
  #                   The hash MAY include:
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_location(location_hash={})
    new_loc = Location.new(location_hash)
    save_successful = new_loc.save
    @location = new_loc
    return save_successful
  end

  # Purpose: The current user follows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should follow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def follow_location(user_id, location_id)
    new_follow = Follow.new(:user_id => user_id, :location_id => location_id)
    new_follow.save
  end

  # Purpose: The current user unfollows a location
  # Input:
  #   user_id - the user id of the current user
  #   location_id - The id of the location the current user should unfollow
  # Assign: None
  # Output: None
  # NOTE: Although the UI will never call this method multiple times,
  #       we may call it multiple times to test your schema/models.
  #       Your schema/models/code should prevent corruption of the database.
  def unfollow_location(user_id, location_id)
    unfollow_query = "DELETE FROM follows F
                      WHERE F.user_id = #{user_id} AND F.location_id = #{location_id}"
    ActionRecord::Base.connection.execute(unfollow_query)
  end

  # Purpose: The current user creates a post to a given location
  # Input:
  #   user_id - the user id of the current user
  #   post_hash - A hash of the new post information.
  #               The hash may include:
  #     * :location_id - the id of the location
  #     * :text - the text of the posts
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: None
  # Output: true if the creation is successful, false otherwise
  def create_post(user_id, post_hash={})
    print post_hash
    new_post = Post.new(:user_id=>user_id,
                        :location_id=>post_hash[:location_id],
                        :text=>post_hash[:text])
    save_successful = new_post.save
    @post = new_post
    return save_successful
  end

  # Purpose: Create a new user
  # Input:
  #   user_hash - A hash of the new post information.
  #               The hash may include:
  #     * :name - name of the new user
  #     * :email - email of the new user
  #     * :password - password of the new user
  #     NOTE: Although the UI will always populate all these fields in this hash,
  #           we may use hashes with missing fields to test your schema/models.
  #           Your schema/models/code should prevent corruption of the database.
  # Assign: assign the following variables
  #   @user - the new user object
  # Output: true if the creation is successful, false otherwise
  # NOTE: This method is already implemented, but you are allowed to modify it if needed.
  def create_user(user_hash={})
    @user = User.new(user_hash)
    save_successful = @user.save
    return save_successful
  end

  # Purpose: Get all the posts
  # Input: None
  # Assign: assign the following variables
  #   @posts - An array of hashes of post information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :author_id - the id of the user who created this post
  #     * :author - the name of the user who created this post
  #     * :text - the contents of the post
  #     * :created_at - the time the post was created
  #     * :location - a hash of this post's location information. The hash should include:
  #         * :id - the location id
  #         * :name - the name of the location
  #         * :latitude - the latitude
  #         * :longitude - the longitude
  # Output: None
  def get_all_posts
    all_posts_query = "SELECT P.user_id as author_id,
                              U.name as author,
                              P.text as text,
                              P.created_at as created_at,
                              (SELECT L.id as id,
                                      L.name as name,
                                      L.latitude as latitude,
                                      L.longitude as longitude) as location
                        FROM posts P, users U, locations L
                        WHERE P.user_id = U.id AND P.location_id = L.id"
    @posts = ActiveRecord::Base.connection.execute(all_posts_query)
  end

  # Purpose: Get all the users
  # Input: None
  # Assign: assign the following variables
  #   @users - An array of hashes of user information.
  #            Order does not matter.
  #            Each hash should include:
  #     * :id - id of the user
  #     * :name - name of the user
  #     * :email - email of th user
  # Output: None
  def get_all_users
    all_users_query = "SELECT U.id as id, U.name as name, U.email as email
                       FROM users U"
    @users = ActiveRecord::Base.connection.execute(all_users_query)
    return @users
  end

  # Purpose: Get all the locations
  # Input: None
  # Assign: assign the following variables
  #   @locations - An array of hashes of location information.
  #                Order does not matter.
  #                Each hash should include:
  #     * :id - the location id
  #     * :name - the name of the location
  #     * :latitude - the latitude
  #     * :longitude - the longitude
  # Output: None
  def get_all_locations
    all_locations_query = "SELECT L.id as id, L.name as name, L.latitude as latitude, L.longitude as longitude
                           FROM locations L"
    result = ActiveRecord::Base.connection.execute(all_locations_query)
    @locations = []

    result.each do |row|
      @locations.push({ :id => row["id"],
                        :name => row["name"],
                        :latitude => row["latitude"],
                        :longitude => row["longitude"]})
    end

  end

  # Retrieve the top 5 users who created the most posts.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_posts - number of posts the user has created
  def top_users_posts_sql
    "SELECT '' AS name, 0 AS num_posts FROM users WHERE 1=2"
  end

  # Retrieve the top 5 locations with the most unique posters. Only retrieve locations with at least 2 unique posters.
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the location
  #   * num_users - number of unique users who have posted to the location
  def top_locations_unique_users_sql
    "SELECT '' AS name, 0 AS num_users FROM users WHERE 1=2"
  end

  # Retrieve the top 5 users who follow the most locations, where each location has at least 2 posts
  # Retrieve at most 5 rows.
  # Returns a string of the SQL query.
  # The resulting columns names must include (but are not limited to):
  #   * name - name of the user
  #   * num_locations - number of locations (has at least 2 posts) the user follows
  def top_users_locations_sql
    "SELECT '' AS name, 0 AS num_locations FROM users WHERE 1=2"
  end

end
