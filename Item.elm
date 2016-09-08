module Item exposing(Model, ItemId)

type alias ItemId = Int

type alias Model = {id: ItemId, name: String, description: String}
