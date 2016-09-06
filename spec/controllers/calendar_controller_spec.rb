require 'rails_helper'

RSpec.describe CalendarController, type: :controller do
  describe "GET index" do
    it "assigns @date" do
      get :index
      expect(assigns(:date)).to be_a(Date)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end
end
