require 'test_helper'

class Admin::MarkupsControllerTest < ActionController::TestCase
  setup do
    @admin_markup = admin_markups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_markups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_markup" do
    assert_difference('Admin::Markup.count') do
      post :create, admin_markup: {  }
    end

    assert_redirected_to admin_markup_path(assigns(:admin_markup))
  end

  test "should show admin_markup" do
    get :show, id: @admin_markup
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_markup
    assert_response :success
  end

  test "should update admin_markup" do
    patch :update, id: @admin_markup, admin_markup: {  }
    assert_redirected_to admin_markup_path(assigns(:admin_markup))
  end

  test "should destroy admin_markup" do
    assert_difference('Admin::Markup.count', -1) do
      delete :destroy, id: @admin_markup
    end

    assert_redirected_to admin_markups_path
  end
end
