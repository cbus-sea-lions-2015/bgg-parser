class BggParser
  def self.parse(raw_json, library_id)
    raw_json["item"].each do |game_json|
      game = Game.new
      game.bgg_id        = game_json["id"]
      game.name          = game_json["name"][0]["value"]
      game.description   = game_json["description"]
      game.minplayers    = game_json["minplayers"][0]["value"].to_i
      game.maxplayers    = game_json["maxplayers"][0]["value"].to_i
      game.minplaytime   = game_json["minplaytime"][0]["value"].to_i
      game.maxplaytime   = game_json["maxplaytime"][0]["value"].to_i
      game.poll          = game_json["poll"][0] if game_json["poll"][0]["name"] == "suggested_numplayers"
      game.image_url     = game_json["image"][0]
      game.thumbnail_url = game_json["thumbnail"][0]

      game.save

      GamesLibrary.create game: game, library_id: library_id

      game_json["link"].each do |row|
        if row["type"] == "boardgamecategory"
          category = Category.find_or_create_by bgg_id: row["id"], name: row["value"]
          gamescategory = GamesCategory.create(game: game, category: category) if category.valid?
        elsif row["type"] == "boardgamemechanic"
          mechanic = Mechanic.find_or_create_by bgg_id: row["id"], name: row["value"]
          gamesmechanic = GamesMechanic.create(game: game, mechanic: mechanic) if mechanic.valid?
        end
      end
    end
  end
end
