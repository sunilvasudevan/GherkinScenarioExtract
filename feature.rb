# Class will parse all the Gherkin format files in to JSON and then HASH
#
# For example:
#
#   Given
#     I have all feature_files to be testes in an array
#   Then
#     This class parse feature files one by one and create Scenario class object for each scenario
#
# List of feature or one feature is mandatory for this class
# Feature absolute path is required for this class
#
#class will be calling from EXECUTOR class
#
# @author : Sunil
# @dateModified: 5/14/2015
#
#@TODO-  Need to add Command line input
#
require 'gherkin/parser/parser'
require 'gherkin/formatter/json_formatter'
require 'stringio'
require 'multi_json'
require 'json'

class Feature

  attr_accessor :feature_file_name, :scenario_name, :tier_config

  attr_accessor :feature_json, :feature_hash, :scenario_hash

  @tag_hash =[]

  @array_scenarios = []

  # constructor for setting up the feature.
  def initialize(feature_file)
    @array_scenarios = []
    self.feature_file_name = feature_file
    parse_gherkin_to_json
#    scenario = ScenarioDetails.new(feature_file_name)
#    @array_scenarios << scenario
  end

  def get_scenario_details_array
    @array_scenarios
  end

  # convert the Gherkin format to Json format
  def parse_gherkin_to_json
    feature_file_name.each do |file_name|
      string_file = file_name.to_s
      io = StringIO.new
      formatter = Gherkin::Formatter::JSONFormatter.new(io)
      parser = Gherkin::Parser::Parser.new(formatter)
      #path = File.expand_path(string_file)
      parser.parse(IO.read(string_file), string_file, 0)
      formatter.done
      self.feature_json = MultiJson.dump(MultiJson.load(io.string), :pretty => true)
      get_scenario_details
    end

  end

  # Method will return all the scenario names from the feature file provided
  # @return scenario_details_hash
  # @param feature_hash
  def get_scenario_hash(feature_hash)
    # scenario details are inside the elements tag
    feature_hash['elements']
  end

  # Method will return the absolute path of the feature file
  # @return absolure_path
  # @param feature_hash
  def get_feature_file_absolute_path(feature_hash)
    feature_hash['uri']
  end

  # get scenario details from json
  def get_scenario_details(json_gherkin = self.feature_json)
    json_hash = json_to_hash(json_gherkin)
    self.scenario_hash = get_scenario_hash(json_hash)
    feature_absolute_path = get_feature_file_absolute_path(json_hash)
    self.scenario_hash.each do |one_scenario|
      one_scenario_hash = Hash[one_scenario]
      self.scenario_name = one_scenario_hash['name']
      tags = one_scenario_hash['tags']
      @tag_hash = []
      unless tags.nil?
        tags.each do |each_tag|
          @tag_hash.push(each_tag['name'])
        end
      end
    # Each Scenario Object will be tagged to One Browser for Parallel Execetion 
    #@TODO need to add cod for Browser Config and Pass to Scenario Details Class. For now passing NIL
       scenario_details = ScenarioDetails.new(self.scenario_name, @tag_hash, feature_absolute_path, nil)
       @array_scenarios << scenario_details
    end
  end

  # convert Json object to Hash map
  def json_to_hash(json_obj)
    Hash[JSON.parse(json_obj)[0]]
  end



# class for storing the scenario details
# this will then stored inside feature class

class ScenarioDetails
  attr_accessor :scenario_name, :scenario_tag, :scenario_uri, :browser

  def initialize(scenario_name, scenario_tag, scenario_uri, browser)
    self.scenario_tag = []
    self.scenario_name = scenario_name
    self.scenario_tag = scenario_tag
    self.scenario_uri = scenario_uri
    self.browser = browser
  end

  # return the scenario name from the gherkin file
  def get_scenario_name
    self.scenario_name
  end

  # return all the scenario tags as an array
  def get_scenario_tags
    self.scenario_tag
  end

  # method will return the scenario URI for that specific obj
  #this will be absolute path
  #eg: {C:\users\xyx\project\features\xyz.feature}
  def get_scenario_uri
    self.scenario_uri
  end

  def get_browser
    self.browser
  end

end
