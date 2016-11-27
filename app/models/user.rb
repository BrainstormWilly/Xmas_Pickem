class User < ApplicationRecord

  default_scope { order(name: :asc) }
end
