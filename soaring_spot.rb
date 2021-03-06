require 'json'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'restclient/components'

class SoaringSpot
    MAIN_URL = 'http://soaringspot.com'
    API_URL = 'http://soaringspot.dev'

    def competitions
        doc = Nokogiri::HTML(open(MAIN_URL))

        competitions = {}
        # Competitions in progress
        progress = get_competitions doc.css('td.mainbody table')[1]
        competitions["progress"] = progress if progress.length > 0
        # Recent competitions 
        recent = get_competitions doc.css('td.mainbody table')[3]
        competitions["recent"] = recent if recent.length > 0
        # Upcomming competitions
        upcoming = get_competitions doc.css('td.mainbody table')[6]
        competitions["upcoming"] = upcoming if upcoming.length > 0

        { competitions: competitions }
    end

    #
    # Valid countries: ...
    # Valid years: 2000 - ...
    #
    def filtered_competitions(country, year)
        content = RestClient.post MAIN_URL + "/competitions/", :country => country, :year => year
        doc = Nokogiri::HTML content

        competitions = get_competitions(doc.css("td.mainbody table")[1])
        { competitions: competitions }
    end

    def competition(code)
        content = RestClient.get MAIN_URL + "/#{code}/results/"
        doc = Nokogiri::HTML content

        competition = { key: code, classes: {} }
        tables = doc.css('td.mainbody div.padding div')[0].children()
        tables[0].css("table").each do |klass|
            key = get_klass_key(code, klass)
            competition[:classes][key] = get_klass_value(code, key, klass) unless key.nil?
        end
        if tables[2]
            tables[2].css("table").each do |klass|
                key = get_klass_key(code, klass)
                unless key.nil?
                    previous_key_value = competition[:classes][key]
                    new_days = get_klass_value(code, key, klass)[:days]
                    refactored_days = {}
                    new_days.each do |key, value|
                        refactored_days[900 - key * -1] = value
                    end
                    competition[:classes][key][:days] = previous_key_value[:days].merge(refactored_days)
                end
            end
        end
        { competition: competition }
    end

    def pilots(code, klass)
        doc = Nokogiri::HTML(open(MAIN_URL + "/#{code}/results/#{klass}/day-by-day.html"))
        pilots = [] 
        table = doc.css('td.mainbody table.cuc')[0]
        table.css("tr.odd, tr.even").each_with_index do |pilot, index|
            pilots << get_pilot_value(pilot, table.css("tr.headerlight").first.css("th"))
        end
        { pilots: pilots }
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
        image = doc.css('td.mainbody div.padding div p img')
        { day: {
                :totals => totals,
                :daily => fix_max_number(daily),
                :task => get_task_value(table, image.nil? || image.size == 0 ? nil : "#{MAIN_URL}#{image.first.attributes["src"].content}")
            }
        }
    end

    private

    def fix_max_number(list)
        max = -1
        list.each do |item|
            max = item["#"] if item["#"] && item["#"] > max
        end
        list.each do |item|
            item["#"] = max + 1 if item["#"] && item["#"] == -1
        end
    end

    def get_daily_value(pilot, headers)
        pilot = pilot.css("td")
        values = {}
        headers.each_with_index do |header, index|
            values[header.content.downcase] = get_value(pilot[index])
            values[header.content.downcase] = parse_number header.content.downcase, get_value(pilot[index])
            if has_igc_link(pilot[index])
                values["igc"] = get_igc_link(pilot[index])
            end
        end

        values
    end

    def get_pilot_value(pilot, headers)
        pilot = pilot.css("td")
        info_values = {}
        result_values = {}
        headers.each_with_index do |header, index|
            if /^([0-9]*)$/.match header.content.downcase.strip
                result_values[header.content.downcase] = get_value(pilot[index])
            else
                info_values[header.content.downcase] = parse_number header.content.downcase, get_value(pilot[index])
            end
        end
        {
            :info    => info_values,
            :results => result_values
        }
    end

    def get_total_value(pilot, headers)
        pilot = pilot.css("td")
        values = {}
        headers.each_with_index do |header, index|
            values[header.content.downcase] = get_value(pilot[index])
            values[header.content.downcase] = parse_number header.content.downcase, get_value(pilot[index])
        end
        values
    end

    def get_task_value(table, image)
        {
            :distance => table.css("tr.even th:last-child").first.content,
            :type => table.css("tr:first-child td").first.children[2].content,
            :image => image,
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

    def has_igc_link(element)
        element.css("a").count > 0
    end

    def get_igc_link(element)
        element.css("a").first.attributes["href"].value.sub("/", "")
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
        if table.css("a:first-child").first
            table.css("a:first-child").first.attributes["href"].value.gsub("/#{code}/results/", "").gsub(/\/task.*/, "")
        else
            nil
        end
    end

    def get_klass_value(code, klass_code, table)
        name = table.css("tr.headerlight th").children.first.content
        {
            :name   => name,
            :days   => get_klass_days(code, klass_code, table)
        }
    end

    def get_klass_days(code, klass_code, table)
        days = {}
        table.css("tr:not(.even)").css("tr:not(.headerlight)").css("tr:not(.underline)").each_with_index do |day, index|
            columns = day.css("td")
            days[("%02d" % index).to_i]= {
                "name" => columns[0].content,
                "date" => columns[1].content,
                "key"  => columns[2].css("a:first-child").first.attributes["href"].value.gsub("/#{code}/results/#{klass_code}/task/", "").gsub(".html", "")
            }
        end
        days
    end

    def parse_number(key, value)
        if key == "#"
            value.to_i == 0 ? -1 : value.to_i
        else
            value
        end
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

