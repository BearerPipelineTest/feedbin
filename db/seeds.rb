Plan.create!(stripe_id: "basic-monthly", name: "Monthly", price: 2, price_tier: 1)
Plan.create!(stripe_id: "basic-yearly", name: "Yearly", price: 20, price_tier: 1)
Plan.create!(stripe_id: "basic-monthly-2", name: "Monthly", price: 3, price_tier: 2)
Plan.create!(stripe_id: "basic-yearly-2", name: "Yearly", price: 30, price_tier: 2)
Plan.create!(stripe_id: "basic-monthly-3", name: "Monthly", price: 5, price_tier: 3)
Plan.create!(stripe_id: "basic-yearly-3", name: "Yearly", price: 50, price_tier: 3)

Plan.create!(stripe_id: "free", name: "Free", price: 0, price_tier: 3)
Plan.create!(stripe_id: "timed", name: "Timed", price: 0, price_tier: 3)
Plan.create!(stripe_id: "timed", name: "Timed", price: 0, price_tier: 2)
Plan.create!(stripe_id: "app-subscription", name: "App Subscription", price: 0, price_tier: 3)
Plan.create!(stripe_id: "podcast-subscription", name: "Podcast Subscription", price: 0, price_tier: 3)
plan = Plan.create!(stripe_id: "trial", name: "Trial", price: 0, price_tier: 3)

SuggestedCategory.create!(name: "Popular")
SuggestedCategory.create!(name: "Tech")
SuggestedCategory.create!(name: "Design")
SuggestedCategory.create!(name: "Arts & Entertainment")
SuggestedCategory.create!(name: "Sports")
SuggestedCategory.create!(name: "Business")
SuggestedCategory.create!(name: "Food")
SuggestedCategory.create!(name: "News")
SuggestedCategory.create!(name: "Gaming")

if Rails.env.development?
  u = User.new(email: "ben@benubois.com", password: "passw0rd", password_confirmation: "passw0rd", admin: true)
  u.plan = plan
  u.update_auth_token = true
  u.save

  # migration = u.account_migrations.create!(api_token: "asdf")
  # migration.account_migration_items.create!(data: {
  #   title: "Daring Fireball",
  #   feed_id: 290,
  #   feed_url: "http://daringfireball.net/index.xml"
  # })
  # migration.account_migration_items.failed.create!(
  # message: "404 Not Found",
  # data: {
  #   title: "Daring Fireball",
  #   feed_id: 290,
  #   feed_url: "http://daringfireball.net/index.xml"
  # })
  # migration.account_migration_items.complete.create!(
  # message: "Feed imported. Matched 3 of 3 unread articles.",
  # data: {
  #   title: "Daring Fireball",
  #   feed_id: 290,
  #   feed_url: "http://daringfireball.net/index.xml"
  # })

end
