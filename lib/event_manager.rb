require "csv"
require "sunlight/congress"
require "erb"

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
		if  clean_phone.length == 11 #having trouble getting it to act right if the first of 11 digits is 1
			#check if first is 1 and delete if it is, or return nil if it isn't
			
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

puts "EventManager Initialized."

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
	id = row[0]
	
	name = row[:first_name]

	zipcode = clean_zipcode(row[:zipcode])

	home_phone = clean_phone_number(row[:homephone])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)
	
	#save_thank_you_letters(id, form_letter)
	puts "#{name}, #{home_phone}"

end