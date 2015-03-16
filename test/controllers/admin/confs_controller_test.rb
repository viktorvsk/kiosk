require 'test_helper'

class Admin::ConfsControllerTest < ActionController::TestCase
  setup do
    @admin_conf = admin_confs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_confs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_conf" do
    assert_difference('Admin::Conf.count') do
      post :create, admin_conf: {  }
    end

    assert_redirected_to admin_conf_path(assigns(:admin_conf))
  end

  test "should show admin_conf" do
    get :show, id: @admin_conf
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_conf
    assert_response :success
  end

  test "should update admin_conf" do
    patch :update, id: @admin_conf, admin_conf: {  }
    assert_redirected_to admin_conf_path(assigns(:admin_conf))
  end

  test "should destroy admin_conf" do
    assert_difference('Admin::Conf.count', -1) do
      delete :destroy, id: @admin_conf
    end

    assert_redirected_to admin_confs_path
  end
end
