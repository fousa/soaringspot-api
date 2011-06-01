require 'json'
require 'yaml'
require 'nokogiri'
require 'open-uri'

class SoaringSpot
	MAIN_URL = 'http://soaringspot.com'
	API_URL = 'http://soaringspot.dev'

	def competitions
		doc = Nokogiri::HTML(open(MAIN_URL))

		competitions = {}
		# Competitions in progress
		competitions["in-progress"] = get_competitions doc.css('td.mainbody table')[1]
		# Recent competitions 
		competitions["recent"] = get_competitions doc.css('td.mainbody table')[3]
		# Upcomming competitions
		competitions["upcomming"] = get_competitions doc.css('td.mainbody table')[6]

		competitions
	end

	def competition(code)
		doc = Nokogiri::HTML(open(MAIN_URL + "/#{code}/results/"))
		
		klasses = {}
		doc.css('td.mainbody table')[1].css("table").each do |klass|
			key = get_klass_key(code, klass)
			klasses[key] = get_klass_value(code, key, klass)
		end
		klasses
	end

	def day(code, klass, day)
		doc = Nokogiri::HTML(open(MAIN_URL + "/#{code}/results/#{klass}/total/#{day}.html"))
		totals =[] 
		table = doc.css('td.mainbody table')[0]
		table.css("tr.odd, tr.even").each do |pilot|
			totals << get_total_value(pilot, table.css("tr.headerlight").first.css("th"))
		end

		doc = Nokogiri::HTML(open(MAIN_URL + "/#{code}/results/#{klass}/daily/#{day}.html"))
		daily =[] 
		table = doc.css('td.mainbody table')[0]
		table.css("tr.odd, tr.even").each do |pilot|
			daily << get_daily_value(pilot, table.css("tr.headerlight").first.css("th"))
		end

		doc = Nokogiri::HTML(open(MAIN_URL + "/#{code}/results/#{klass}/task/#{day}.html"))
		table = doc.css('td.mainbody table')[0]
		{
			:totals => totals,
			:daily => daily,
			:task => get_task_value(table)
		}
	end

	private

	def get_daily_value(pilot, headers)
		pilot = pilot.css("td")
		values = {}
		headers.each_with_index do |header, index|
			values[header.content.downcase] = get_value(pilot[index])
		end
		values
	end

	def get_total_value(pilot, headers)
		pilot = pilot.css("td")
		values = {}
		headers.each_with_index do |header, index|
			values[header.content.downcase] = get_value(pilot[index])
		end
		values
	end

	def get_task_value(table)
		{
			:distance => table.css("tr.even th:last-child").first.content,
			:type => table.css("tr:first-child td").first.children[2].content,
			:turnpoints => get_turnpoint_value(table, table.css("tr.headerlight th"))
		}
	end

	def get_turnpoint_value(table, headers)
		points = []
		table.css("tr").each_with_index do |point, index|
			if index > 2 && index < table.css("tr").count - 1
				values = {}
				headers.each_with_index do |header, indexe|
					values[header.content.downcase] = get_value(point.css("td")[indexe])
				end
				values[:point] = index - 2
				points << values
			end
		end
		points
	end

	def get_value(element)
		element.css("b").first.try(:content) || element.css("a").first.try(:content) || element.css("span").first.try(:content) || element.content
	end

	def get_competitions(table)
		competitions = {}
		table.css("tr.odd a:first-child, tr.even a:first-child").each do |element|
			key = element.attributes["href"].value.gsub("/", "")
			competitions[key] = {
				"name" => element.content
			}
		end
		competitions
	end

	def get_klass_key(code, table)
		table.css("a:first-child").first.attributes["href"].value.gsub("/#{code}/results/", "").gsub(/\/task.*/, "")
	end

	def get_klass_value(code, klass_code, table)
		name = table.css("tr.headerlight th").children.first.content
		{
			:name => name,
			:days => get_klass_days(code, klass_code, table)
		}
	end

	def get_klass_days(code, klass_code, table)
		days = {}
		table.css("tr:not(.even)").css("tr:not(.headerlight)").css("tr:not(.underline)").each do |day|
			columns = day.css("td")
			days[columns[2].css("a:first-child").first.attributes["href"].value.gsub("/#{code}/results/#{klass_code}/task/", "").gsub(".html", "")]= {
				"name" => columns[0].content,
				"date" => columns[1].content
			}
		end
		days
	end
end

class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end

