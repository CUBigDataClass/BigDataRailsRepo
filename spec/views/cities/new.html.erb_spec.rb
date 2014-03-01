require 'spec_helper'

describe "cities/new" do
  before(:each) do
    assign(:city, stub_model(City,
      :name => "MyString",
      :latitude => 1.5,
      :longitude => 1.5
    ).as_new_record)
  end

  it "renders new city form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", cities_path, "post" do
      assert_select "input#city_name[name=?]", "city[name]"
      assert_select "input#city_latitude[name=?]", "city[latitude]"
      assert_select "input#city_longitude[name=?]", "city[longitude]"
    end
  end
end
