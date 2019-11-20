require 'csv'

IMAGE_FIELDS = ['Image 1', 'Image 2', 'Image 3', 'Image 4', 'Image 5', 'Image 6', 'Image 7', 'Image 8', 'Image 9', 'Image 10', 'Image 11', 'Image 12']
CONDITIONS = { 'New': 5, 'Like new': 4, 'Good': 3, 'Fair': 2, 'Poor': 1 }

email = "" ## CHANGE VALUE HERE
password = "" ## CHANGE VALUE HERE

File.write('listing_cmds.txt', "set-staging\n", mode: 'a')
File.write('listing_cmds.txt', "login #{email} #{password}\n", mode: 'a')

errors = []

CSV.foreach('importer.csv', headers: true) do |row|
  title = row['Title']
  price = row['Price ($5 ~ $2000)']

  unless price.empty?
    price = row['Price ($5 ~ $2000)'].strip.gsub("$", "").to_i * 100
  end

  zip_code = row['Ships from Zipcode']
  category_id = row['C2 ID']
  size_id = row['Item size ID'] === "#N/A" ? '' : row['Item size ID']
  brand_id = row['Brand ID'] === "#N/A" ? '' : row['Brand ID']
  condition_id = CONDITIONS[row['Item Condition'].to_sym]
  photo_ids = []
  IMAGE_FIELDS.each do |field|
    photo_ids.push("#{row[field]}.jpg") if row[field]
  end
  photo_ids = photo_ids.join(',')

  next unless title

  if price.empty? || (price < 500 || price > 200000) || zip_code.empty? || category_id.empty? || condition_id.empty? || photo_ids.empty?
    puts "Cannot make listing for #{title}"
  end

  cmd = "sell"
  cmd << " '#{title}'"
  cmd << " #{price}"
  cmd << " zip_code=#{zip_code}"
  cmd << " shipping_ids=0"
  cmd << " category_id=#{category_id}"

  unless size_id.empty?
    cmd << " size_id=#{size_id}"
  end

  unless brand_id.empty?
    cmd << " brand_id=#{brand_id}"
  end

  cmd << " condition_id=#{condition_id}"
  cmd << " photo_ids=\"#{photo_ids}\""

  cmd <<"\n"
  File.write('listing_cmds.txt', cmd, mode: 'a')
end
