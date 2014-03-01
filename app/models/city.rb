require 'csv'

class City < ActiveRecord::Base

  #attr_accessible :name, :latitude, :longitude

  def self.import(tsv_path)
    raise "Not a valid TSV file" unless File.basename(tsv_path).match(/\.tsv$/)
    parsed_file = CSV.read(tsv_path, { :col_sep => "\t" })
    lat_col = parsed_file[0].each_with_index.detect{ |value, index| value.match /^lat/i }[-1]
    long_col = parsed_file[0].each_with_index.detect{ |value, index| value.match /^long/i }[-1]
    name_col = parsed_file[0].each_with_index.detect{ |value, index| value.match /^(cit|name)/i }[-1]

    parsed_file[1..-1].each do |city_arr|
      city = self.new name: city_arr[name_col], longitude: city_arr[long_col], latitude: city_arr[lat_col]
      city.save!
    end
  end

end
