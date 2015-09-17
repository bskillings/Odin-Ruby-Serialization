require "csv"
require "sunlight/congress"
require "erb"
require "date"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone)
	if phone
		clean_phone = []
		phone = phone.split("")
		phone.each do |number|
			if number.match(/\A[0-9]+\Z/)
				clean_phone.push (number)
			end
		end
		if  clean_phone.length == 11 
			
			if clean_phone[0] == "1"
				clean_phone.shift
				return clean_phone.join
			else 
				return nil
			end
		elsif clean_phone.length == 10
			return clean_phone.join
		else
			return nil
		end
	end	
end


def legislators_by_zipcode(zipcode)
	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename, "w") do |file|
		file.puts form_letter
	end
end

def calculate_peak_hour
	data = open_attendees
	hours = Array.new(24, 0)
	days_of_week = Hash.new
	data.each do |row| #not getting in here
		parsed_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
		hours[parsed_date.hour.to_i] += 1
		day =  parsed_date.strftime("%A")
		unless days_of_week.has_key?(day)
			days_of_week[day] = 0
		end
		days_of_week[day] += 1
	end
	hours.each_with_index do |count, index|
	puts "#{count.to_s} people registered at hour #{index.to_s}"
	end
	puts days_of_week
end

def open_attendees
	CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
end

puts "EventManager Initialized."

contents = open_attendees

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|

	id = row[0]
	
	name = row[:first_name]

	zipcode = clean_zipcode(row[:zipcode])

	home_phone = clean_phone_number(row[:homephone])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

		
	
	save_thank_you_letters(id, form_letter)
	#puts "#{name}, #{home_phone}" 

end

calculate_peak_hour
