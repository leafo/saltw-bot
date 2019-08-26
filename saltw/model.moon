
import Model from require "lapis.db.model"

class SaltwModel extends Model
  @get_relation_model: (name) =>
    require("saltw.models")[name]

