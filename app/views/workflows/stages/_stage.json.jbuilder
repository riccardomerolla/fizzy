json.cache! stage do
  json.(stage, :id, :name, :color)

  json.created_at stage.created_at.utc

  json.workflow do
    json.partial! "workflows/workflow", workflow: stage.workflow
  end
end
