require 'csv'
require 'json'
require 'pry'

data_source1 = CSV.read('source1.csv', { encoding: "UTF-8", 
								 headers: true, 
								 header_converters: :symbol, 
								 converters: :all
								})

data_source2 = CSV.read('source2.csv', { encoding: "UTF-8", 
								 headers: true, 
								 header_converters: :symbol, 
								 converters: :all
								})

hashed_data1 = data_source1.map {|d| d.to_hash }
hashed_data2 = data_source2.map {|d| d.to_hash }
# 1. what was the total spent against people with purple hair?

def array_of_uniq_purple_campaigns(hashed_data1)
	arr = hashed_data1.select {|row| row[:audience].include?("purple")}.uniq{|row| row[:campaign_id]}
end

def money_spent_on_purple(hashed_data2, hashed_data1)
	money_spent = 0
	arr_purple_campaign_ids = array_of_uniq_purple_campaigns(hashed_data1).map {|row| row[:campaign_id]}
	hashed_data2.each do |row|
		if arr_purple_campaign_ids.include?(row[:campaign_id]) 
			money_spent += row[:spend]
		end
	end
	money_spent
end

# 2. how many campaigns spent on more than 4 days?
def campaign_count(hashed_data2)
	answer_hash = {}
	hashed_data2.each do |row|
		answer_hash[row[:campaign_id]] ? answer_hash[row[:campaign_id]] += 1 : answer_hash[row[:campaign_id]] = 1
	end
	answer_hash
end

def hash_of_campaigns_gt_4_days(hashed_data2)
	count = 0
	campaign_count(hashed_data2).each do |id, val|
		val > 4 ? count += 1 : nil
	end
	count
end

# 3. how many times did source H report on clicks?
def source_h_clicks(hashed_data2)
	clicks = 0
	hashed_data2.each do |row|
		action = JSON.parse(row[:actions])
		action_data = action
		action_data.each do |action|
			if action["h"] && action["action"] == "clicks"
				clicks += action["h"]
			elsif action["H"] && action["action"] == "clicks"
				clicks += action["H"]
			else
				nil
			end
		end
	end
	clicks
end

# 4. which sources reported more "junk" than "noise"?

def more_junk_than_noise_source(hashed_data2)
	answer_hash = {}
	hashed_data2.each do |row|
		action = JSON.parse(row[:actions])
		action_data = action
		action_data.each do |action_set|
			if validate_junk(action_set)
				source = action_set.keys.first
				conversions = action_set[source]
				if !answer_hash[source]
					answer_hash[source] = {}
					answer_hash[source]["junk"] = conversions
				elsif !answer_hash[source]["junk"] 
					answer_hash[source]["junk"] = conversions
				else
					answer_hash[source]["junk"] += conversions
				end
			elsif validate_noise(action_set)
				source = action_set.keys.first
				conversions = action_set[source]
				if !answer_hash[source]
					answer_hash[source] = {}
					answer_hash[source]["noise"] = conversions
				elsif !answer_hash[source]["noise"] 
					answer_hash[source]["noise"] = conversions
				else
					answer_hash[source]["noise"] += conversions
				end
			end
		end
	end
	answer_more_junk_than_noise(answer_hash)
end

def validate_junk(action)
	action["action"] == "junk" ? true : false
end

def validate_noise(action)
	action["action"] == "noise" ? true : false
end

def answer_more_junk_than_noise(answer_hash)
	keys = answer_hash.keys
	answer_arr = []
	keys.each do |source|
		answer_hash[source]["junk"] > answer_hash[source]["noise"] ? answer_arr.push(source => answer_hash[source]) : nil
	end
	answer_arr
end

# 5. what was the total cost per view for all video ads, truncated to two decimal places?
def cost_per_view_video_ads(hashed_data2)
	total_spend = 0	
	hashed_data2.each do |row|
		total_views = 0
		only_views  = 0
		if validate_ad_type(row) && validate_action_has_views(row)
			actions = JSON.parse(row[:actions])
			# binding.pry
			actions.each do |action|
				# binding.pry
				source = action.keys.first
				total_views += action[source].to_f
				only_views += action[source].to_f if action["action"] == "views"
			end
		else
			next
		end
		# binding.pry
		total_spend += (row[:spend] * (only_views.to_f / total_views.to_f)).round(2)
		total_views = 0
		only_views  = 0
	end
	total_spend.round(2)
end

def validate_ad_type(row)
	row[:ad_type] == "video"
end

def validate_action_has_views(row)
	actions = JSON.parse(row[:actions])
	values = actions.collect{ |action| action["action"]}
	values.include?("views") ? true : false
end

# 6. how many source B conversions were there for campaigns targeting NY?
def array_of_uniq_new_york_campaigns(hashed_data1)
	arr = hashed_data1.select {|row| row[:audience].include?("NY")}
	arr = arr.collect {|row| row[:campaign_id]}
end

def source_B_conversions_for_NY(hashed_data2, hashed_data1)
	conversions = 0
	uniq_NY_ids = array_of_uniq_new_york_campaigns(hashed_data1)
	hashed_data2.each do |row|
		if uniq_NY_ids.include?(row[:campaign_id])
			actions = JSON.parse(row[:actions])
			actions.each do |action|
				source = action.keys.first
				conversions += action[source] if source == "B" && action["action"] == "conversions"
			end
		end
	end
	conversions
end

# 1. what was the total spent against people with purple hair?
	puts "1. what was the total spent against people with purple hair? $#{money_spent_on_purple(hashed_data2, hashed_data1)} spent"
# 2. how many campaigns spent on more than 4 days?
	puts "2. how many campaigns spent on more than 4 days? #{hash_of_campaigns_gt_4_days(hashed_data2)} campaigns"
# 3. how many times did source H report on clicks?
	puts "3. how many times did source H report on clicks? #{source_h_clicks(hashed_data2)} clicks reported from H"
# 4. which sources reported more "junk" than "noise"?
	puts "4. which sources reported more 'junk' than 'noise'? #{more_junk_than_noise_source(hashed_data2)}"
# 5. what was the total cost per view for all video ads, truncated to two decimal places?
	puts "5. what was the total cost per view for all video ads, truncated to two decimal places? $#{cost_per_view_video_ads(hashed_data2)}"
# 6. how many source B conversions were there for campaigns targeting NY?
	puts "6. how many source B conversions were there for campaigns targeting NY? #{source_B_conversions_for_NY(hashed_data2, hashed_data1)} conversions"
# 7. what combination of state and hair color had the best CPM?



