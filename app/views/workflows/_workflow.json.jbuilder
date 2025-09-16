json.cache! workflow do
  json.(workflow, :id, :name)

  json.created_at workflow.created_at.utc
  json.updated_at workflow.updated_at.utc
end
