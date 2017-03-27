namespace :ptourist do
  MEMBERS = %w(mike carol alice greg marsha peter jan bobby cindy)
  ADMINS = %w(mike carol)
  ORIGINATORS = %w(carol alice)

  def user_name(first_name)
    last_name = first_name == 'alice' ? 'nelson' : 'brady'
    "#{first_name} #{last_name}".titleize
  end

  def user_email(first_name)
    "#{first_name}@bbunch.org"
  end

  def user(first_name)
    User.find_by(email: user_email(first_name))
  end

  def users(first_names)
    first_names.map { |fn| user(fn) }
  end

  def admin_users
    @admin_users ||= users(ADMINS)
  end

  def originator_users
    @originator_users ||= users(ORIGINATORS)
  end

  def create_image(organizer, img)
    puts "building image for #{img[:caption]}, by #{organizer.name}"
    image = Image.create(creator_id: organizer.id, caption: img[:caption])
    organizer.add_role(Role::ORGANIZER, image).save
  end

  def create_thing(thing, organizer, images)
    thing = Thing.create!(thing)
    organizer.add_role(Role::ORGANIZER, thing).save

    images.each do |img|
      puts "building image for #{Thing.name}, #{img[:caption]}, by #{organizer.name}"
      image = Image.create(creator_id: organizer.id, caption: img[:caption])
      organizer.add_role(Role::ORGANIZER, image).save

      ThingImage.new(thing: thing, image: image, creator_id: organizer.id).tap do |ti|
        ti.priority = img[:priority] if img[:priority]
      end.save!
    end
  end

  desc 'reset all data'
  task reset_all: [:users, :subjects] do
  end

  desc 'deletes things, images and links'
  task delete_subjects: :environment do
    puts "removing #{Thing.count} things and #{ThingImage.count} thing_images"
    puts "removing #{Image.count} images"
    DatabaseCleaner[:active_record].clean_with(:truncation, except: %w(users))
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  desc 'delete all data'
  task delete_all: [:delete_subjects] do
    puts "removing #{User.count} users"
    DatabaseCleaner[:active_record].clean_with(:truncation, only: %w(users))
  end

  desc 'reset users'
  task users: [:delete_all] do
    puts "creating users: #{MEMBERS}"

    MEMBERS.each_with_index do |fn, idx|
      User.create(name: user_name(fn), email: user_email(fn), password: "password#{idx}")
    end

    admin_users.each do |user|
      user.roles.create(role_name: Role::ADMIN)
    end

    originator_users.each do |user|
      user.add_role(Role::ORIGINATOR, Thing).save
    end

    puts "users: #{User.pluck(:name)}"
  end

  desc 'reset things, images and links'
  task subjects: [:users] do
    puts 'creating things, images and links'

    thing = { name: 'Holiday Inn Timonium', description: "Group friendly located just a few miles north of Baltimore's Inner Harbor. Great neighborhood in Baltimore County",
              notes: 'Early to bed, early to rise' }

    organizer = user('alice')
    images = [
        {
            path: 'db/bta/hitim-001.jpg',
            caption: 'Hotel Front Entrance',
            lng: -76.64285450000001,
            lat: 39.454538,
            priority: 0
        }
    ]

    create_thing(thing, organizer, images)
  end
end
