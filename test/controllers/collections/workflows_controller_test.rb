require "test_helper"

class Collections::WorkflowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "update" do
    collection = collections(:writebook)

    patch collection_workflow_path(collection), params: { collection: { workflow_id: workflows(:on_call).id } }

    assert_redirected_to edit_collection_path(collection)
    assert_equal workflows(:on_call), collection.reload.workflow
  end
end
