class Genre < ActiveRecord::Base
   translates :name, :description
   attr_accessible :name, :description
end

class Movie < ActiveRecord::Base
   translates :title, :description
   attr_accessible :title, :description
end
