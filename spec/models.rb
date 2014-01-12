class Genre < ActiveRecord::Base
   translates :name, :description
end

class Movie < ActiveRecord::Base
   translates :title, :description
end
