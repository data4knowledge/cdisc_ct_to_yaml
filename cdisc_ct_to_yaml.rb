require 'csv'
require 'json'
require 'yaml'
require 'roo'
require 'roo-xls'
require 'pry'

def set_cl(data)
  result = set_concept(data[0], data[3], data[4], data[5], data[6], data[7])
  result[:items] = []
  result
end

def set_cli(data)
  set_concept(data[0], data[7], data[4], data[5], data[6], data[7])
end

def set_concept(c_code, label, submission, synonyms, definition, preferred_term)
  synonyms = synonyms.nil? ? "" : synonyms
  definition = definition.nil? ? "" : definition
  preferred_term = preferred_term.nil? ? "" : preferred_term
  { identifier: c_code, label: label, submission: submission, synonyms: synonyms, definition: definition, preferred_term: preferred_term }
end

version = ARGV.shift
Dir.chdir(version)
version_date = Date.parse(version)
files = Dir.glob("*.xls")
files.each do |file|
  puts "Converting '#{file}' to YAML as version '#{version}'."
  workbook = Roo::Spreadsheet.open(file)
  workbook.default_sheet = workbook.sheets.last
  records = { version: "#{version_date.strftime("%F")}", owner: 'CDISC', last_identifier: 0, items: {} }
  ((workbook.first_row + 1) .. workbook.last_row).each do |row|
    data = workbook.row(row)
  puts "Data #{data}"  
  puts "Data[1] #{data[1]}"
    records[:items][data[0]] = set_cl(data) if data[1].nil? #!records.key?(data[1])
    records[:items][data[1]][:items] << set_cli(data) unless data[1].nil?
  end
  puts "F: #{file}, B: #{File.basename(file, ".*")}"
  File.open("#{File.basename(file, ".*") }.yml","w") do |file|
    file.write records.to_yaml
  end
end

