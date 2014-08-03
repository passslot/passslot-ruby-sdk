#!/usr/bin/env ruby

require 'PassSlot'

app_key = ''
pass_template_id = ''

values = {
    Name: 'John',
    Level: 'Platinum',
    Balance: 20.50
}

images = {
    thumbnail: 'thumbnail.png'
}

begin

  engine = PassSlot.start(app_key)
  pass = engine.create_pass_from_template(pass_template_id, values, images)
  puts "Created Pass: #{pass.url}"

  # Download the pass
  filename = "#{pass.serialNumber}.pkpass"
  File.open(filename, 'w') { |file| file.write(pass.download!) }
  puts "Downloaded Pass to #{filename}"

  pass.email!('user@example.com')
  pass.update!(Name: 'John', Level: 'Gold', Balance: 10.5)
  updated_values = pass.update!(:Balance, 0.15)
  puts "Updated values: #{updated_values}"


rescue PassSlot::ApiError => error
  puts 'Something went wrong'
  puts error
end
