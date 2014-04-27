require_relative '../../spec/spec_helper'

describe Tweet do

  it 'should pass along queries to elasticsearch' do
    query={
        query:{
            query_string:{
                query:{
                    text: '*the*'
                }
            }
        }
    }

    result = Tweet.query query
    expect(result).to be_a_kind_of Array
    puts result
    result.each do |r|
      expect(r.size).to eq 2
    end

    puts result
  end

end