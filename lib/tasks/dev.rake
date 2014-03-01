namespace :import do

  task :city_tsv, [:filename] => [:environment] do |task, args|
    puts "PATH WAS: #{args[:filename]}"
    City.import args[:filename]
  end
end