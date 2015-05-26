require 'json'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'restclient/components'

class SoaringSpot
  MAIN_URL = 'http://www.soaringspot.com'

  def competitions
    doc = Nokogiri::HTML(open(MAIN_URL))

    competitions = {}
    # Competitions in progress
    progress = get_competitions doc.css('div.contest-list ul')[0]
    competitions["progress"] = progress if progress.length > 0
    # Recent competitions
    recent = get_competitions doc.css('div.contest-list ul')[1]
    competitions["recent"] = recent if recent.length > 0
    # Upcomming competitions
    upcoming = get_competitions doc.css('div.contest-list ul')[2]
    competitions["upcoming"] = upcoming if upcoming.length > 0

    { competitions: competitions }
  end

  #
  # Valid countries: ...
  # Valid years: 2000 - ...
  #
  def filtered_competitions(country, year)
    content = RestClient.post MAIN_URL + "/en_gb/search/", country: country, year: year
    doc = Nokogiri::HTML content

    competitions = get_competitions(doc.css("div.contest-list ul")[0])
    { competitions: competitions }
  end

  def competition(code)
    content = RestClient.get MAIN_URL + "/en_gb/#{code}/results"
    doc = Nokogiri::HTML content

    competition = { key: code, classes: {} }
    tables = doc.css('table.result-overview')
    tables.each do |table|
      key = get_klass_key code, table.css("th")[0]
      competition[:classes][key] = get_klass_value(code, key, table) unless key.nil?
    end
    { competition: competition }
  end

  def pilots(code, klass)
    doc = Nokogiri::HTML(open(MAIN_URL + "/en_gb/#{code}/results/#{klass}"))
    pilots = []
    table = doc.css('table.result-class')[0]
    table.css('tbody tr').each do |pilot, index|
      pilots << get_pilot_value(pilot, table.css("th"))
    end
    { pilots: pilots }
  end

  def day(code, klass, day)
    doc = Nokogiri::HTML(open(MAIN_URL + "/en_gb/#{code}/results/#{klass}/#{day}/total"))
    totals =[]
    table = doc.css('table.result-total-daily')[0]
    table.css("tbody tr").each do |pilot|
      totals << get_total_value(pilot, table.css("thead tr th"))
    end

    doc = Nokogiri::HTML(open(MAIN_URL + "/en_gb/#{code}/results/#{klass}/#{day}/daily"))
    daily =[]
    table = doc.css('table.result-daily')[0]
    table.css("tbody tr").each do |pilot|
      daily << get_daily_value(pilot, table.css("thead tr th"))
    end

    doc = Nokogiri::HTML(open(MAIN_URL + "/en_gb/#{code}/tasks/#{klass}/#{day}"))
    table = doc.css('table.task')[0]
    image = doc.css('div.task-images img')
    {
      day: {
        totals: totals,
        daily:  daily,
        task:   get_task_value(table, image.nil? || image.size == 0 ? nil : "#{MAIN_URL}#{image.first.attributes["src"].content}")
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
      if /^total|([0-9]*\.)$/.match header.content.downcase.strip
        result_values[header.content.downcase] = get_value(pilot[index])
      else
        info_values[header.content.downcase] = parse_number header.content.downcase, get_value(pilot[index])
      end
    end
    {
      info:    info_values,
      results: result_values
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
      distance:   table.css("tfoot td").last.content.strip,
      image:      image,
      turnpoints: get_turnpoint_value(table)
    }
  end

  def get_turnpoint_value(table)
    points = []
    headers = table.css("thead th")
    table.css("tbody tr").each_with_index do |point, index|
      values = {}
      headers.each_with_index do |header, indexe|
        values[header.content.downcase] = get_value(point.css("td")[indexe])
      end
      values[:point] = index
      points << values
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
    (element.css("b").first.try(:content) || element.css("a").first.try(:content) || element.css("span").first.try(:content) || element.content).try :strip
  end

  def get_competitions(list)
    competitions = {}
    list.css("li a").each do |element|
      key = element.attributes["href"].value.split('/').last
      competitions[key] = { name: element.content }
    end
    competitions
  end

  def get_klass_key(code, table)
    if table.css("a:first-child").first
      table.css("a:first-child").first.attributes["href"].value.gsub("/en_gb/#{code}/results/", "")
    else
      nil
    end
  end

  def get_klass_value(code, klass_code, table)
    name = table.css("th")[0].content.strip
    {
      :name   => name,
      :days   => get_klass_days(code, klass_code, table)
    }
  end

  def get_klass_days(code, klass_code, table)
    days = {}
    table.css("tbody tr").each_with_index do |day, index|
      columns = day.css("td")
      if columns[1].css("a").first.nil?
        days[("%02d" % index).to_i]= {
          "date" => columns[0].content
        }
      else
        days[("%02d" % index).to_i]= {
          "name" => columns[1].content.strip,
          "date" => columns[0].content,
          "key"  => columns[1].css("a").first.attributes["href"].value.gsub("/en_gb/#{code}/tasks/#{klass_code}/", "").gsub(".html", "")
        }
      end
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
  def try(method)
    send method if respond_to? method
  end
end
